#!/usr/bin/env bash
set -euo pipefail

state_dir="${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}"
log_dir="${state_dir}/logs"
reference_dir="${state_dir}/archinstall-reference"
status_file="${state_dir}/preflight_status.json"
log_file="${log_dir}/archinstall-dry-run.log"
manifest_file="${state_dir}/config_manifest.json"

ensure_private_directory() {
  python3 - "$1" <<'PY'
import os
import stat
import sys
from pathlib import Path

path = Path(sys.argv[1])
if path.is_symlink():
    raise SystemExit("installer state directory must not be a symlink")
path.mkdir(parents=True, exist_ok=True, mode=0o700)
info = path.stat()
if not stat.S_ISDIR(info.st_mode) or info.st_uid != os.geteuid():
    raise SystemExit("installer state directory has unsafe ownership")
os.chmod(path, 0o700)
PY
}

ensure_private_directory "${state_dir}"
ensure_private_directory "${log_dir}"
ensure_private_directory "${reference_dir}"

safe_regular_or_missing() {
  # A dangling link makes -e false, so test -L separately.  State files can
  # contain password hashes and must never be redirected outside this tree.
  [ ! -L "$1" ] && { [ ! -e "$1" ] || [ -f "$1" ]; }
}

write_status() {
  local state="$1"
  local message="$2"
  local code="${3:-0}"
  local manifest_digest="${4:-}"
  # Do not use shell redirection here: a stale status-file symlink would
  # otherwise write outside the private installer state directory.
  python3 - "${status_file}" "${state}" "${message}" "${code}" \
    "${log_file}" "${reference_dir}" "${manifest_digest}" <<'PY'
import json
import os
import tempfile
from pathlib import Path
import sys

target = Path(sys.argv[1])
if target.is_symlink():
    raise SystemExit("preflight status path is symlinked")
payload = {
    "state": sys.argv[2],
    "message": sys.argv[3],
    "exitCode": int(sys.argv[4]),
    "log": sys.argv[5],
    "referenceDir": sys.argv[6],
    "manifestSha256": sys.argv[7],
}
descriptor, temporary_name = tempfile.mkstemp(prefix=".preflight_status.", dir=target.parent)
temporary = Path(temporary_name)
try:
    with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
        json.dump(payload, handle, indent=2)
        handle.write("\n")
        handle.flush()
        os.fsync(handle.fileno())
    os.chmod(temporary, 0o600)
    os.replace(temporary, target)
finally:
    if temporary.exists():
        temporary.unlink()
PY
}

cleanup_archinstall_credentials() {
  local credential_file="/var/log/archinstall/user_credentials.json"
  if [ -f "${credential_file}" ] && [ ! -L "${credential_file}" ]; then
    rm -f -- "${credential_file}"
  fi
}

trap cleanup_archinstall_credentials EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

if ! safe_regular_or_missing "${status_file}" \
    || ! safe_regular_or_missing "${log_file}"; then
  echo "Installer preflight state contains an unsafe file path." >&2
  exit 2
fi
umask 077
: >"${log_file}"
chmod 600 "${log_file}"

copy_reference_configs() {
  local source_dir="/var/log/archinstall"
  # Credentials are not reference material.  Archinstall may emit them during
  # a dry run, but retaining password hashes outside the short-lived input is
  # neither needed for diagnosis nor acceptable for the installer state tree.
  rm -f -- "${reference_dir}/user_credentials.json"
  for name in user_configuration.json user_disk_layouts.json user_disk_layout.json; do
    if [ -f "${source_dir}/${name}" ]; then
      cp -f "${source_dir}/${name}" "${reference_dir}/${name}"
    fi
  done
  cleanup_archinstall_credentials
}

write_status "starting" "Preparing archinstall dry-run preflight." 0

if ! command -v archinstall >/dev/null 2>&1; then
  write_status "missing" "archinstall is not available in this environment." 127
  exit 0
fi

archinstall --version >"${log_file}" 2>&1 || true
config_file="${state_dir}/generated/user_configuration.json"
creds_file="${state_dir}/generated/user_credentials.json"
if [ -L "${config_file}" ] || [ -L "${creds_file}" ] || [ -L "${manifest_file}" ]; then
  write_status "failed" "Generated installation input contains an unsafe symlink." 22
  exit 0
fi
if [ ! -f "${config_file}" ] || [ ! -f "${creds_file}" ] || [ ! -f "${manifest_file}" ]; then
  write_status "waiting" "Generate the MeoArch installation plan before running preflight." 0
  exit 0
fi
manifest_digest="$(python3 - "${manifest_file}" <<'PY'
import hashlib
import sys
from pathlib import Path

path = Path(sys.argv[1])
if path.is_symlink() or not path.is_file():
    raise SystemExit("generated manifest is missing or symlinked")
print(hashlib.sha256(path.read_bytes()).hexdigest())
PY
)"

# Validate the actual Arch mirror path without trusting one fixed endpoint.
# curl is convenient but not a correctness dependency: Python is already
# required by the installer backend, so use urllib as a fallback.
probe_url() {
  local url="$1"
  if command -v curl >/dev/null 2>&1; then
    curl --fail --silent --show-error --location --connect-timeout 5 --max-time 20 \
      --range 0-0 --output /dev/null "${url}"
    return
  fi
  python3 - "${url}" <<'PY'
import sys
import urllib.request

request = urllib.request.Request(
    sys.argv[1],
    headers={
        "Range": "bytes=0-0",
        "User-Agent": "MeoArch-Installer-Preflight/1",
    },
)
with urllib.request.urlopen(request, timeout=20) as response:
    if not 200 <= response.status < 400:
        raise SystemExit(1)
    response.read(1)
PY
}

probe_arch_package_source() {
  local mirrorlist="/etc/pacman.d/mirrorlist"
  local server url attempts=0
  if [ -r "${mirrorlist}" ]; then
    while IFS= read -r server; do
      [ -n "${server}" ] || continue
      server="${server//\$repo/core}"
      server="${server//\$arch/x86_64}"
      url="${server%/}/core.db"
      attempts=$((attempts + 1))
      if probe_url "${url}" >>"${log_file}" 2>&1; then
        printf 'Arch package source reachable: %s\n' "${url}" >>"${log_file}"
        return 0
      fi
      [ "${attempts}" -lt 8 ] || break
    done < <(sed -n 's/^[[:space:]]*Server[[:space:]]*=[[:space:]]*//p' "${mirrorlist}")
  fi

  url="https://geo.mirror.pkgbuild.com/core/os/x86_64/core.db"
  probe_url "${url}" >>"${log_file}" 2>&1
}

if ! probe_arch_package_source; then
  write_status "failed" "No configured Arch package mirror is reachable. Check the Internet connection and retry." 21
  exit 0
fi

# Archinstall --dry-run validates configuration but returns before package
# installation. Resolve the complete bounded Arch-side package set against
# freshly downloaded sync databases so a renamed/missing driver or desktop
# package cannot fail only after disk preparation has begun.
if ! command -v pacman >/dev/null 2>&1; then
  write_status "missing" "pacman is not available; required Arch packages cannot be resolved." 127
  exit 0
fi
pacman_db="${state_dir}/pacman-preflight-db"
pacman_cache="${state_dir}/pacman-preflight-cache"
ensure_private_directory "${pacman_db}"
ensure_private_directory "${pacman_cache}"
mkdir -p "${pacman_db}/local" "${pacman_db}/sync"

mapfile -t arch_packages < <(python3 - "${config_file}" <<'PY'
import json
import re
import sys

config = json.load(open(sys.argv[1], encoding="utf-8"))
packages = ["base", "linux-firmware", "grub", "efibootmgr", "networkmanager", "sudo", "dosfstools"]

for kernel in config.get("kernels", []):
    if isinstance(kernel, str):
        packages.append(kernel)

for package in config.get("packages", []):
    if isinstance(package, str):
        packages.append(package)

profile = config.get("profile_config", {}).get("profile", {})
details = profile.get("details", []) if isinstance(profile, dict) else []
if isinstance(details, list) and "KDE Plasma" in details:
    packages.append("plasma-meta")

disk_config = config.get("disk_config", {})
for modification in disk_config.get("device_modifications", []) if isinstance(disk_config, dict) else []:
    for partition in modification.get("partitions", []) if isinstance(modification, dict) else []:
        fs_type = partition.get("fs_type") if isinstance(partition, dict) else None
        if fs_type == "btrfs":
            packages.append("btrfs-progs")
        elif fs_type == "ext4":
            packages.append("e2fsprogs")

seen = set()
for package in packages:
    if not isinstance(package, str) or not re.fullmatch(r"[A-Za-z0-9@._+:-]+", package):
        raise SystemExit("generated Arch package name is invalid")
    if package not in seen:
        seen.add(package)
        print(package)
PY
)
if [ "${#arch_packages[@]}" -eq 0 ]; then
  write_status "failed" "Generated Arch package set is empty." 23
  exit 0
fi

if ! pacman --sync --refresh --noconfirm \
    --dbpath "${pacman_db}" --cachedir "${pacman_cache}" \
    --logfile "${log_dir}/pacman-preflight.log" >>"${log_file}" 2>&1; then
  write_status "failed" "Arch package databases could not be refreshed. Check the network or mirror configuration and retry." 24
  exit 0
fi
if ! pacman --sync --print --print-format '%n %v' --noconfirm \
    --dbpath "${pacman_db}" --cachedir "${pacman_cache}" \
    --logfile "${log_dir}/pacman-preflight.log" \
    "${arch_packages[@]}" >>"${log_file}" 2>&1; then
  write_status "failed" "One or more required Arch packages are unavailable from the current repositories." 25
  exit 0
fi

write_status "running" "Running a silent archinstall dry-run in the background." 0

set +e
if command -v timeout >/dev/null 2>&1; then
  timeout 120s archinstall --silent --dry-run --config "${config_file}" --creds "${creds_file}" >>"${log_file}" 2>&1 </dev/null
  rc=$?
else
  archinstall --silent --dry-run --config "${config_file}" --creds "${creds_file}" >>"${log_file}" 2>&1 </dev/null
  rc=$?
fi
set -e

copy_reference_configs

case "${rc}" in
  0)
    write_status "complete" "archinstall dry-run completed. Reference JSON files were copied when available." 0 "${manifest_digest}"
    ;;
  124)
    write_status "timeout" "archinstall dry-run timed out; use the saved log and run it manually for a full reference." 124
    ;;
  *)
    write_status "failed" "archinstall dry-run rejected the generated configuration. Review the saved log before retrying." "${rc}"
    ;;
esac

exit 0
