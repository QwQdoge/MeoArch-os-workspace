#!/usr/bin/env bash
set -u -o pipefail

scope="${MEOARCH_REPAIR_SCOPE:-system}"
target_root="${MEOARCH_TARGET_ROOT:-/mnt}"
[ "${target_root}" = "/mnt" ] || target_root="/mnt"

detect_loader() {
  local root="$1"
  local prefix="$2"
  if [ -s "${root}/boot/grub/grub.cfg" ]; then
    echo "MEO_FINDING|info|boot.loader_grub|${prefix} uses GRUB."
    return
  fi
  if [ -s "${root}/boot/limine.conf" ] || [ -s "${root}/boot/limine/limine.conf" ]; then
    echo "MEO_FINDING|info|boot.loader_limine|${prefix} uses Limine."
    return
  fi
  if [ -d "${root}/boot/loader/entries" ] || [ -s "${root}/boot/loader/loader.conf" ]; then
    echo "MEO_FINDING|info|boot.loader_systemd_boot|${prefix} uses systemd-boot."
    return
  fi
  echo "MEO_FINDING|warning|boot.loader_unknown|No supported GRUB, Limine, or systemd-boot configuration was found for ${prefix}."
}

check_boot_tree() {
  local root="$1"
  local target_code_prefix="$2"
  local description="$3"
  local boot_expected=0

  [ -d "${root}/etc" ] || {
    echo "MEO_FINDING|warning|boot.target_not_mounted|No installed target is mounted at ${root}."
    return
  }

  echo "[boot] ${description}"
  detect_loader "${root}" "${description}"

  if [ -r "${root}/etc/fstab" ] && awk '!/^[[:space:]]*#/ && $2 == "/boot" { found=1 } END { exit found ? 0 : 1 }' \
      "${root}/etc/fstab" 2>/dev/null; then
    boot_expected=1
  fi

  if [ "${root}" = "/" ]; then
    if [ "${boot_expected}" -eq 1 ] && ! findmnt -rn /boot >/dev/null 2>&1; then
      echo "MEO_FINDING|warning|boot.boot_not_mounted|The system expects a separate /boot filesystem, but it is not mounted."
    elif ! find /boot -maxdepth 1 -type f -name 'initramfs-*.img' -size +0c -print -quit 2>/dev/null | grep -q .; then
      echo "MEO_FINDING|warning|boot.initramfs_missing|The system has no non-empty initramfs image."
    fi
  else
    if [ "${boot_expected}" -eq 1 ] && ! findmnt -rn "${root}/boot" >/dev/null 2>&1; then
      echo "MEO_FINDING|warning|boot.target_boot_not_mounted|The target expects a separate /boot filesystem, but it is not mounted at /mnt/boot."
    elif [ ! -d "${root}/boot" ]; then
      echo "MEO_FINDING|warning|boot.target_boot_missing|The mounted target has no /boot directory."
    elif ! find "${root}/boot" -maxdepth 1 -type f -name 'initramfs-*.img' -size +0c -print -quit 2>/dev/null | grep -q .; then
      echo "MEO_FINDING|warning|boot.initramfs_missing|The mounted target has no non-empty initramfs image."
    fi
  fi
}

if [ "${scope}" = "live" ]; then
  check_boot_tree "${target_root}" "target" "mounted installed target"
  if [ -d "${target_root}/etc" ]; then
    echo "[boot] mounted target filesystems"
    findmnt "${target_root}" "${target_root}/boot" "${target_root}/boot/efi" 2>&1 || true
    sed -n '1,120p' "${target_root}/etc/fstab" 2>&1 || true
  fi
  echo "MEO_FINDING|info|boot.offline_service_state|Failed-unit state belongs to the running Live environment and is not used as evidence about the offline installed target."
  exit 0
fi

echo "[boot] firmware and loader"
check_boot_tree "/" "system" "installed system"
if command -v bootctl >/dev/null 2>&1; then
  bootctl status --no-pager 2>&1 || true
fi

if timeout 10 systemctl show --type=service --all --property=NeedDaemonReload \
  --value 2>/dev/null | grep -qx yes; then
  echo "MEO_FINDING|info|boot.manager_reload_needed|The system service manager reports that its unit files changed on disk and need a daemon reload."
fi

echo "[boot] failed units"
failed_units="$(systemctl --failed --no-legend --no-pager 2>/dev/null || true)"
printf '%s\n' "${failed_units}"
if [ -n "${failed_units//[[:space:]]/}" ]; then
  echo "MEO_FINDING|warning|boot.failed_units|One or more systemd units are failed in the installed system."
fi
