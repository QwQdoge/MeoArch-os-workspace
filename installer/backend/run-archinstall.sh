#!/usr/bin/env bash
set -euo pipefail

state_dir="${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}"
generated_dir="${state_dir}/generated"
log_dir="${state_dir}/logs"
log_file="${log_dir}/install.log"
events_file="${log_dir}/install-events.jsonl"
confirm_file="${state_dir}/summary_confirmed"
consumed_confirm_file="${state_dir}/.summary_confirmed_consumed"
install_lock="${state_dir}/.installation_started"
lock_acquired=false
destructive_started=false
confirmation_consumed=false
state_safe=false

require_private_directory() {
  python3 - "$1" <<'PY'
import os
import stat
import sys
from pathlib import Path

path = Path(sys.argv[1])
if path.is_symlink() or not path.is_dir():
    raise SystemExit("installer state directory is missing or symlinked")
info = path.stat()
if info.st_uid != os.geteuid() or info.st_mode & 0o077:
    raise SystemExit("installer state directory is not private")
PY
}

make_private_child_directory() {
  python3 - "$1" <<'PY'
import os
import stat
import sys
from pathlib import Path

path = Path(sys.argv[1])
if path.is_symlink():
    raise SystemExit("installer state child must not be a symlink")
path.mkdir(parents=True, exist_ok=True, mode=0o700)
info = path.stat()
if not stat.S_ISDIR(info.st_mode) or info.st_uid != os.geteuid():
    raise SystemExit("installer state child has unsafe ownership")
os.chmod(path, 0o700)
PY
}

cleanup_network_handoff() {
  rm -f -- "${generated_dir}/network-handoff.nmconnection"
}

cleanup_secrets() {
  # Do not truncate first: truncating a malicious symlink would write outside
  # the state tree, whereas rm removes the link itself.
  rm -f -- "${generated_dir}/user_credentials.json"
  if [ -f /var/log/archinstall/user_credentials.json ] \
      && [ ! -L /var/log/archinstall/user_credentials.json ]; then
    rm -f -- /var/log/archinstall/user_credentials.json
  fi
}

cleanup() {
  local status=$?
  trap - EXIT INT TERM
  if [ "${state_safe}" = true ]; then
    cleanup_secrets
    cleanup_network_handoff
  fi
  # Before archinstall begins it is safe to let the user regenerate and
  # reconfirm after fixing a transient preflight issue.  Once disk work starts,
  # keep the lock as an explicit no-automatic-retry barrier.
  if [ "${destructive_started}" = false ]; then
    [ "${confirmation_consumed}" = false ] || rm -f -- "${consumed_confirm_file}"
    [ "${lock_acquired}" = false ] || rmdir "${install_lock}" 2>/dev/null || true
  fi
  exit "${status}"
}

trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

require_private_directory "${state_dir}"
require_private_directory "${generated_dir}"
make_private_child_directory "${log_dir}"
state_safe=true

if [ -L "${log_file}" ] || [ -L "${events_file}" ]; then
  echo "Installer log path is unsafe." >&2
  exit 2
fi
umask 077
: >"${events_file}"
: >"${log_file}"

log() {
  printf '%s\n' "$1" | tee -a "${log_file}"
}

progress() {
  local id="$1"
  local percent="$2"
  local message="$3"
  printf '{"event":"stage","id":"%s","progress":%s,"message":"%s"}\n' \
    "${id}" "${percent}" "${message//\"/\\\"}" >>"${events_file}"
  printf '[%s%%] %s\n' "${percent}" "${message}" | tee -a "${log_file}"
}

prepare_selected_mounts() {
  local mount_plan
  if ! mount_plan="$(python3 - "${manifest_file}" <<'PY'
import json
import re
import subprocess
import sys

manifest = json.load(open(sys.argv[1], encoding="utf-8"))
identity = manifest.get("handoff", {}).get("disk", {})
device = identity.get("devicePath")
mode = identity.get("mode")
if not isinstance(device, str) or not re.fullmatch(
    r"/dev/(?:vd[a-z]+|sd[a-z]+|xvd[a-z]+|nvme\d+n\d+|mmcblk\d+|pmem\d+)", device
):
    raise SystemExit("selected disk identity is invalid")

selected = set()
if mode == "partition":
    partitions = identity.get("partitions")
    if not isinstance(partitions, list) or len(partitions) != 2:
        raise SystemExit("selected partition identity is invalid")
    selected = {entry.get("path") for entry in partitions if isinstance(entry, dict)}
    if None in selected or len(selected) != 2:
        raise SystemExit("selected partition identity is invalid")

result = subprocess.run(
    ["findmnt", "-J", "-o", "TARGET,SOURCE"],
    check=False, capture_output=True, text=True,
)
if result.returncode != 0:
    raise SystemExit("could not inspect mounted filesystems")
payload = json.loads(result.stdout or "{}")
filesystems = payload.get("filesystems", [])
device_re = re.compile(re.escape(device) + r"(?:p?[0-9]+)?(?:\[.*\])?$")
protected = ("/", "/boot", "/usr", "/etc", "/var", "/home", "/opt", "/run", "/proc", "/sys", "/dev", "/tmp")

targets = []
for entry in filesystems if isinstance(filesystems, list) else []:
    if not isinstance(entry, dict):
        continue
    target = entry.get("target")
    source = entry.get("source")
    if not isinstance(target, str) or not isinstance(source, str):
        continue
    base_source = source.split("[", 1)[0]
    matches = base_source in selected if mode == "partition" else bool(device_re.fullmatch(source))
    if not matches:
        continue
    if target in protected or target.startswith("/run/archiso"):
        raise SystemExit(f"selected target backs protected Live mount {target}")
    targets.append(target)

for target in sorted(set(targets), key=lambda value: (value.count("/"), len(value)), reverse=True):
    print(target)
PY
)"; then
    echo "Selected target has mounted filesystems that cannot be prepared safely." | tee -a "${log_file}" >&2
    return 1
  fi

  [ -z "${mount_plan}" ] && return 0
  while IFS= read -r target; do
    [ -n "${target}" ] || continue
    log "Unmounting selected target filesystem: ${target}"
    if ! umount -- "${target}" >>"${log_file}" 2>&1; then
      echo "Could not unmount selected target filesystem: ${target}" | tee -a "${log_file}" >&2
      return 1
    fi
  done <<<"${mount_plan}"
}

if [ ! -f "${confirm_file}" ] || [ -L "${confirm_file}" ]; then
  echo "Summary has not been confirmed; refusing to call archinstall." | tee -a "${log_file}" >&2
  exit 3
fi

config_file="${generated_dir}/user_configuration.json"
creds_file="${generated_dir}/user_credentials.json"

if [ ! -f "${config_file}" ] || [ -L "${config_file}" ] \
    || [ ! -f "${creds_file}" ] || [ -L "${creds_file}" ]; then
  echo "Generated archinstall config files are missing." | tee -a "${log_file}" >&2
  exit 4
fi

manifest_file="${state_dir}/config_manifest.json"
if [ ! -f "${manifest_file}" ] || [ -L "${manifest_file}" ] \
    || ! python3 -c 'import json,sys; sys.exit(0 if json.load(open(sys.argv[1], encoding="utf-8")).get("realInstallReady") else 1)' "${manifest_file}"; then
  echo "Generated configuration is preview-only; refusing real installation." | tee -a "${log_file}" >&2
  exit 5
fi

preflight_file="${state_dir}/preflight_status.json"
if [ ! -f "${preflight_file}" ] || [ -L "${preflight_file}" ] || ! python3 - "${preflight_file}" "${manifest_file}" <<'PY'
import hashlib
import json
import sys
from pathlib import Path

status_path, manifest_path = map(Path, sys.argv[1:])
if status_path.is_symlink() or manifest_path.is_symlink():
    raise SystemExit(1)
status = json.loads(status_path.read_text(encoding="utf-8"))
digest = hashlib.sha256(manifest_path.read_bytes()).hexdigest()
if status.get("state") != "complete" or status.get("manifestSha256") != digest:
    raise SystemExit(1)
PY
then
  echo "Archinstall preflight is stale or has not completed successfully; refusing real installation." | tee -a "${log_file}" >&2
  exit 6
fi

installer_root="${MEOARCH_INSTALLER_ROOT:-/opt/meoarch-installer}"
install_plan="${generated_dir}/install-plan.json"
[ -f "${install_plan}" ] || { echo "Generated Meo install plan is missing." | tee -a "${log_file}" >&2; exit 8; }
if ! python3 "${installer_root}/backend/generate-config.py" --state-dir "${state_dir}" --verify-handoff; then
  echo "Generated installation handoff changed or the selected disk is no longer safe." | tee -a "${log_file}" >&2
  exit 6
fi
if ! command -v archinstall >/dev/null 2>&1; then
  echo "archinstall is not available." | tee -a "${log_file}" >&2
  exit 127
fi

resolve_target_root() {
  python3 - "$1" <<'PY'
from pathlib import Path
import sys

path = Path(sys.argv[1])
if path == Path("/") or path.is_symlink():
    raise SystemExit("target root is unsafe")
try:
    resolved = path.resolve(strict=True)
except OSError as error:
    raise SystemExit(error)
if resolved == Path("/"):
    raise SystemExit("target root is unsafe")
print(resolved)
PY
}

target_root="$(resolve_target_root "${MEOARCH_TARGET_ROOT:-/mnt}")" || {
  echo "Refusing unsafe target root." | tee -a "${log_file}" >&2
  exit 7
}

# Validate the target-root boundary before touching selected mounts. This keeps
# an unsafe /mnt override or symlink from reaching any disk-preparation path.
if ! prepare_selected_mounts; then
  exit 6
fi

progress "preflighting_meo_repository" 5 "Verifying signed Meo repository metadata and selected packages"
"${installer_root}/backend/preflight-meo-repository.sh" \
  "${install_plan}" "${installer_root}/bootstrap" 2>&1 | tee -a "${log_file}"

# The repository request can take long enough for removable media or partition
# state to change. Recheck mounts and the hash-bound handoff immediately before
# the only command that is allowed to write a disk.
if ! prepare_selected_mounts; then
  exit 6
fi
if ! python3 "${installer_root}/backend/generate-config.py" --state-dir "${state_dir}" --verify-handoff; then
  echo "Selected disk or installation handoff changed before disk preparation." | tee -a "${log_file}" >&2
  exit 6
fi
# Retain the identity verified above instead of rereading a mutable state file
# after archinstall has started.  It is used only to bind /mnt back to the
# disk that was confirmed before the destructive command.
confirmed_device="$(python3 - "${manifest_file}" <<'PY'
import json
import re
import sys

manifest = json.load(open(sys.argv[1], encoding="utf-8"))
device = manifest.get("handoff", {}).get("disk", {}).get("devicePath")
if not isinstance(device, str) or not re.fullmatch(r"/dev/(?:vd[a-z]+|sd[a-z]+|xvd[a-z]+|nvme\d+n\d+|mmcblk\d+|pmem\d+)", device):
    raise SystemExit("confirmed disk identity is missing")
print(device)
PY
)" || { echo "Confirmed disk identity is missing." | tee -a "${log_file}" >&2; exit 7; }
if ! mkdir -m700 "${install_lock}" 2>/dev/null; then
  echo "An installation has already started for this live session; refusing automatic retry." | tee -a "${log_file}" >&2
  exit 13
fi
lock_acquired=true
if ! mv -f "${confirm_file}" "${consumed_confirm_file}"; then
  echo "Summary confirmation could not be consumed safely." | tee -a "${log_file}" >&2
  exit 3
fi
confirmation_consumed=true
progress "preparing_disk" 10 "Preparing the selected disk"
progress "installing_base" 35 "Installing the base system and packages"
destructive_started=true
archinstall --silent --config "${config_file}" --creds "${creds_file}" 2>&1 | tee -a "${log_file}"

if [ -L "${target_root}" ] || [ "$(resolve_target_root "${target_root}")" != "${target_root}" ] \
  || [ -L "${target_root}/etc" ] || [ -L "${target_root}/usr" ] || [ -L "${target_root}/boot" ] \
  || [ ! -d "${target_root}/etc" ] || [ ! -d "${target_root}/usr" ] || [ ! -d "${target_root}/boot" ] \
  || [ ! -s "${target_root}/etc/fstab" ] \
  || { [ ! -s "${target_root}/boot/grub/grub.cfg" ] \
       && [ ! -d "${target_root}/boot/loader/entries" ]; }; then
  echo "Archinstall did not produce a complete bootable target." | tee -a "${log_file}" >&2
  exit 7
fi
target_source="$(findmnt -rn -o SOURCE -T "${target_root}" 2>/dev/null || true)"
case "${target_source}" in
  "${confirmed_device}"|"${confirmed_device}"[0-9]*|"${confirmed_device}"p[0-9]*|"${confirmed_device}"\[* ) ;;
  *)
    echo "Installed target is not mounted from the confirmed disk." | tee -a "${log_file}" >&2
    exit 7
    ;;
esac
progress "configuring_meo_repository" 70 "Configuring the selected signed Meo repository"
"${installer_root}/backend/configure-meo-repository.sh" \
  "${target_root}" "${generated_dir}" "${installer_root}/bootstrap" 2>&1 | tee -a "${log_file}"
mapfile -t meo_packages < <(python3 - "${install_plan}" <<'PY'
import json,sys
payload=json.load(open(sys.argv[1], encoding='utf-8'))
for package in payload['package']['packages']:
    print(package)
PY
)
[ "${#meo_packages[@]}" -gt 0 ] || { echo "Resolved Meo package set is empty." | tee -a "${log_file}" >&2; exit 9; }
progress "installing_meo_packages" 82 "Installing selected MeoArch packages"
arch-chroot "${target_root}" pacman -Syu --needed --noconfirm "${meo_packages[@]}" 2>&1 | tee -a "${log_file}"
for package in "${meo_packages[@]}"; do
  arch-chroot "${target_root}" pacman -Q "${package}" >/dev/null || {
    echo "Selected Meo package was not installed: ${package}" | tee -a "${log_file}" >&2
    exit 10
  }
done
mapfile -t application_packages < <(python3 - "${install_plan}" <<'PY'
import json,sys
payload=json.load(open(sys.argv[1], encoding='utf-8'))
for package in payload.get('applications', {}).get('nativePackages', []):
    print(package)
PY
)
for package in "${application_packages[@]}"; do
  arch-chroot "${target_root}" pacman -Q "${package}" >/dev/null || {
    echo "Selected application package was not installed: ${package}" | tee -a "${log_file}" >&2
    exit 11
  }
done
progress "applying_meo" 89 "Applying target settings"
"${installer_root}/backend/apply-target-customizations.sh" \
  "${target_root}" "/opt/meo-desktop" "${generated_dir}" 2>&1 | tee -a "${log_file}"
progress "final_validation" 94 "Validating the installed target"
arch-chroot "${target_root}" systemd-tmpfiles --create --remove 2>&1 | tee -a "${log_file}"
python3 "${installer_root}/backend/verify-target.py" "${target_root}" 2>&1 | tee -a "${log_file}"
if printf '%s\n' "${meo_packages[@]}" | grep -qx 'meo-settings'; then
  studio_path=/usr/bin/meo-app-icon-studio
  [ -x "${target_root}${studio_path}" ] || {
    echo "Meo Settings requires the package-owned Icon Studio executable." | tee -a "${log_file}" >&2
    exit 12
  }
  studio_owner="$(arch-chroot "${target_root}" env LC_ALL=C pacman -Qo "${studio_path}" 2>&1)" || {
    echo "Icon Studio executable has no package owner." | tee -a "${log_file}" >&2
    exit 12
  }
  case "${studio_owner}" in
    "${studio_path} is owned by meo-icon-studio "*) ;;
    *)
      echo "Icon Studio executable is not owned by meo-icon-studio." | tee -a "${log_file}" >&2
      exit 12
      ;;
  esac
  studio_check="$(arch-chroot "${target_root}" env LC_ALL=C pacman -Qkk meo-icon-studio)" || {
    echo "Icon Studio package integrity check failed." | tee -a "${log_file}" >&2
    exit 12
  }
  grep -F '0 altered files' <<<"${studio_check}" >/dev/null || {
    echo "Icon Studio package integrity check found altered files." | tee -a "${log_file}" >&2
    exit 12
  }
fi
if printf '%s\n' "${meo_packages[@]}" | grep -qx 'omnistore-bin'; then
  for command_path in usr/bin/omnistore usr/bin/omnistore-cli usr/bin/omnistore-apps-export usr/bin/meo-update; do
    [ -x "${target_root}/${command_path}" ] || {
      echo "OmniStore integration is missing ${command_path}." | tee -a "${log_file}" >&2
      exit 12
    }
  done
  for integration_path in \
    usr/lib/omnistore/meo-repository-helper.py \
    usr/lib/systemd/user/omnistore-update.service \
    usr/lib/systemd/user/omnistore-update.timer; do
    [ -e "${target_root}/${integration_path}" ] || {
      echo "Unified update integration is missing ${integration_path}." | tee -a "${log_file}" >&2
      exit 12
    }
  done
fi
progress "complete" 100 "Installation complete"
