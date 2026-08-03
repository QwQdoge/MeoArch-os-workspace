#!/usr/bin/env bash
set -euo pipefail

state_dir="${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}"
generated_dir="${state_dir}/generated"
log_dir="${state_dir}/logs"
log_file="${log_dir}/install.log"
confirm_file="${state_dir}/summary_confirmed"

mkdir -p "${log_dir}"

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

if ! command -v archinstall >/dev/null 2>&1; then
  echo "archinstall is not available." | tee -a "${log_file}" >&2
  exit 127
fi

prepare_package_mirrors() {
  local mirrorlist="/etc/pacman.d/mirrorlist"
  local refreshed="${state_dir}/mirrorlist.refreshed"

  # Package downloads happen after the destructive disk step. Refresh and rank
  # several HTTPS mirrors first so one slow CDN endpoint cannot strand a target
  # after partitioning. Retain the rest of the ISO's generated mirror list as
  # fallbacks, except for the Fastly endpoint that repeatedly times out on small
  # signature files in the acceptance environment.
  {
    printf '%s\n' \
      'Server = https://singapore.mirror.pkgbuild.com/$repo/os/$arch' \
      'Server = https://geo.mirror.pkgbuild.com/$repo/os/$arch' \
      'Server = https://mirror.rackspace.com/archlinux/$repo/os/$arch'
    grep '^Server = ' "${mirrorlist}" \
      | grep -Ev 'fastly\.mirror\.pkgbuild\.com|singapore\.mirror\.pkgbuild\.com|geo\.mirror\.pkgbuild\.com|mirror\.rackspace\.com'
  } >"${refreshed}"
  install -m 0644 "${refreshed}" "${mirrorlist}"
  echo "Prepared a stable multi-mirror package fallback." | tee -a "${log_file}"

  # Pacman's default low-speed timeout is too aggressive for large firmware
  # packages on otherwise healthy links. Integrity remains enforced by package
  # signatures and hashes.
  sed -i '/^[[:space:]]*DisableDownloadTimeout[[:space:]]*$/d' /etc/pacman.conf
  sed -i '/^[[:space:]]*ParallelDownloads[[:space:]]*=/a DisableDownloadTimeout' /etc/pacman.conf
}

prepare_package_mirrors

echo "Starting archinstall with generated MeoArch JSON." | tee -a "${log_file}"
archinstall --silent --config "${config_file}" --creds "${creds_file}" 2>&1 | tee -a "${log_file}"

installer_root="${MEOARCH_INSTALLER_ROOT:-/opt/meoarch-installer}"
target_root="${MEOARCH_TARGET_ROOT:-/mnt}"
if [ ! -s "${target_root}/etc/fstab" ] \
  || { [ ! -s "${target_root}/boot/grub/grub.cfg" ] \
       && [ ! -d "${target_root}/boot/loader/entries" ]; }; then
  echo "Archinstall did not produce a complete bootable target." | tee -a "${log_file}" >&2
  exit 6
fi
"${installer_root}/backend/apply-target-customizations.sh" \
  "${target_root}" "/opt/meo-desktop" "${generated_dir}" 2>&1 | tee -a "${log_file}"
