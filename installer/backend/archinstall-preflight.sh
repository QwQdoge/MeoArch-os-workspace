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

# Connectivity here is diagnostic only. A single fixed endpoint is not a
# reliable reason to reject an otherwise valid installation plan: the real
# installation uses the configured mirror path and the signed Meo repository
# preflight immediately before any disk write.
mirror_probe="https://geo.mirror.pkgbuild.com/core/os/x86_64/core.db"
if ! getent ahosts geo.mirror.pkgbuild.com >/dev/null 2>&1; then
  echo "warning: Arch mirror DNS probe failed; continuing configuration dry-run" >>"${log_file}"
elif ! command -v curl >/dev/null 2>&1; then
  echo "warning: curl is unavailable; skipping advisory Arch mirror probe" >>"${log_file}"
elif ! curl --fail --silent --show-error --location --max-time 20 --range 0-0 --output /dev/null "${mirror_probe}" >>"${log_file}" 2>&1; then
  echo "warning: fixed Arch mirror probe failed; continuing configuration dry-run" >>"${log_file}"
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
