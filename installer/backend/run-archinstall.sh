#!/usr/bin/env bash
set -euo pipefail

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

progress "preparing_disk" 10 "Preparing the selected disk"
progress "installing_base" 35 "Installing the base system and packages"
archinstall --silent --config "${config_file}" --creds "${creds_file}" 2>&1 | tee -a "${log_file}"

installer_root="${MEOARCH_INSTALLER_ROOT:-/opt/meoarch-installer}"
target_root="${MEOARCH_TARGET_ROOT:-/mnt}"
if [ ! -s "${target_root}/etc/fstab" ] \
  || { [ ! -s "${target_root}/boot/grub/grub.cfg" ] \
       && [ ! -d "${target_root}/boot/loader/entries" ]; }; then
  echo "Archinstall did not produce a complete bootable target." | tee -a "${log_file}" >&2
  exit 7
fi
progress "applying_meo" 82 "Installing Meo Desktop and target settings"
"${installer_root}/backend/apply-target-customizations.sh" \
  "${target_root}" "/opt/meo-desktop" "${generated_dir}" 2>&1 | tee -a "${log_file}"
progress "final_validation" 94 "Validating the installed target"
for path in \
  "${target_root}/etc/os-release" \
  "${target_root}/etc/fstab" \
  "${target_root}/usr/lib/qt6/qml/MeoUI/qmldir"; do
  [ -e "${path}" ] || { echo "Final validation is missing ${path}." | tee -a "${log_file}" >&2; exit 8; }
done
progress "complete" 100 "Installation complete"
