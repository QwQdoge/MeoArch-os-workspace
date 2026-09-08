#!/usr/bin/env bash
set -euo pipefail

# The generated handoff may contain one NetworkManager profile and is never a
# diagnostic artifact. Remove it on all install exits, including preflight or
# target-customization failures.
cleanup_network_handoff() {
  rm -f -- "${generated_dir:-/tmp/meoarch-installer/generated}/network-handoff.nmconnection"
}
trap cleanup_network_handoff EXIT

state_dir="${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}"
generated_dir="${state_dir}/generated"
log_dir="${state_dir}/logs"
log_file="${log_dir}/install.log"
events_file="${log_dir}/install-events.jsonl"
confirm_file="${state_dir}/summary_confirmed"

mkdir -p "${log_dir}"

progress() {
  local id="$1"
  local percent="$2"
  local message="$3"
  printf '{"event":"stage","id":"%s","progress":%s,"message":"%s"}\n' \
    "${id}" "${percent}" "${message//\"/\\\"}" >>"${events_file}"
  printf '[%s%%] %s\n' "${percent}" "${message}" | tee -a "${log_file}"
}

cleanup_secrets() {
  if [ -f "${generated_dir}/user_credentials.json" ]; then
    : >"${generated_dir}/user_credentials.json"
    rm -f "${generated_dir}/user_credentials.json"
  fi
}
trap cleanup_secrets EXIT INT TERM

if [ ! -f "${confirm_file}" ]; then
  echo "Summary has not been confirmed; refusing to call archinstall." | tee -a "${log_file}" >&2
  exit 3
fi

config_file="${generated_dir}/user_configuration.json"
creds_file="${generated_dir}/user_credentials.json"

if [ ! -f "${config_file}" ] || [ ! -f "${creds_file}" ]; then
  echo "Generated archinstall config files are missing." | tee -a "${log_file}" >&2
  exit 4
fi

manifest_file="${state_dir}/config_manifest.json"
if [ ! -f "${manifest_file}" ] || ! python3 -c 'import json,sys; sys.exit(0 if json.load(open(sys.argv[1], encoding="utf-8")).get("realInstallReady") else 1)' "${manifest_file}"; then
  echo "Generated configuration is preview-only; refusing real installation." | tee -a "${log_file}" >&2
  exit 5
fi

preflight_file="${state_dir}/preflight_status.json"
if ! python3 -c 'import json,sys; sys.exit(0 if json.load(open(sys.argv[1], encoding="utf-8")).get("state") == "complete" else 1)' "${preflight_file}" 2>/dev/null; then
  echo "Archinstall preflight has not completed successfully; refusing real installation." | tee -a "${log_file}" >&2
  exit 6
fi

if ! command -v archinstall >/dev/null 2>&1; then
  echo "archinstall is not available." | tee -a "${log_file}" >&2
  exit 127
fi

installer_root="${MEOARCH_INSTALLER_ROOT:-/opt/meoarch-installer}"
install_plan="${generated_dir}/install-plan.json"
[ -f "${install_plan}" ] || { echo "Generated Meo install plan is missing." | tee -a "${log_file}" >&2; exit 8; }
progress "preflighting_meo_repository" 5 "Verifying signed Meo repository metadata and selected packages"
"${installer_root}/backend/preflight-meo-repository.sh" \
  "${install_plan}" "${installer_root}/bootstrap" 2>&1 | tee -a "${log_file}"

progress "preparing_disk" 10 "Preparing the selected disk"
progress "installing_base" 35 "Installing the base system and packages"
archinstall --silent --config "${config_file}" --creds "${creds_file}" 2>&1 | tee -a "${log_file}"

target_root="${MEOARCH_TARGET_ROOT:-/mnt}"
if [ ! -s "${target_root}/etc/fstab" ] \
  || { [ ! -s "${target_root}/boot/grub/grub.cfg" ] \
       && [ ! -d "${target_root}/boot/loader/entries" ]; }; then
  echo "Archinstall did not produce a complete bootable target." | tee -a "${log_file}" >&2
  exit 7
fi
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
arch-chroot "${target_root}" pacman -S --needed --noconfirm "${meo_packages[@]}" 2>&1 | tee -a "${log_file}"
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
python3 "${installer_root}/backend/verify-target.py" "${target_root}" 2>&1 | tee -a "${log_file}"
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
