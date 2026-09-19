#!/usr/bin/env bash
set -u -o pipefail

echo "[boot] firmware and loader"
if command -v bootctl >/dev/null 2>&1; then
  bootctl status --no-pager 2>&1 || true
else
  echo "MEO_FINDING|info|boot.bootctl_missing|bootctl is not installed; GRUB systems may not need it."
fi

echo "[boot] mounted boot paths"
findmnt --noheadings --output TARGET,SOURCE,FSTYPE,OPTIONS / /boot /boot/efi 2>&1 || true

if [ "${MEOARCH_REPAIR_SCOPE:-system}" = "live" ]; then
  if [ -d /mnt/etc ] && [ -d /mnt/usr ]; then
    target_boot_expected=0
    if awk '!/^[[:space:]]*#/ && $2 == "/boot" { found=1 } END { exit found ? 0 : 1 }' \
      /mnt/etc/fstab 2>/dev/null; then
      target_boot_expected=1
    fi
    if [ "${target_boot_expected}" -eq 1 ] && ! findmnt -rn /mnt/boot >/dev/null 2>&1; then
      echo "MEO_FINDING|warning|boot.target_boot_not_mounted|The target expects a separate /boot filesystem, but it is not mounted at /mnt/boot."
    elif [ -d /mnt/boot ] && ! find /mnt/boot -maxdepth 1 -type f -name 'initramfs-*.img' -size +0c -print -quit 2>/dev/null \
      | grep -q .; then
      echo "MEO_FINDING|warning|boot.initramfs_missing|The mounted target has no non-empty initramfs image."
    fi
  fi
else
  boot_expected=0
  if awk '!/^[[:space:]]*#/ && $2 == "/boot" { found=1 } END { exit found ? 0 : 1 }' \
    /etc/fstab 2>/dev/null; then
    boot_expected=1
  fi
  if [ "${boot_expected}" -eq 1 ] && ! findmnt -rn /boot >/dev/null 2>&1; then
    echo "MEO_FINDING|warning|boot.boot_not_mounted|The system expects a separate /boot filesystem, but it is not mounted."
  elif ! find /boot -maxdepth 1 -type f -name 'initramfs-*.img' -size +0c -print -quit 2>/dev/null \
    | grep -q .; then
    echo "MEO_FINDING|warning|boot.initramfs_missing|The system has no non-empty initramfs image."
  fi
  if timeout 10 systemctl show --type=service --all --property=NeedDaemonReload \
    --value 2>/dev/null | grep -qx yes; then
    echo "MEO_FINDING|info|boot.manager_reload_needed|The system service manager reports that its unit files changed on disk and need a daemon reload."
  fi
fi

echo "[boot] failed units"
failed_units="$(systemctl --failed --no-legend --no-pager 2>/dev/null || true)"
printf '%s\n' "${failed_units}"
if [ -n "${failed_units//[[:space:]]/}" ]; then
  echo "MEO_FINDING|warning|boot.failed_units|One or more systemd units are failed in the current environment."
fi

if [ "${MEOARCH_REPAIR_SCOPE:-system}" = "live" ]; then
  if [ -d /mnt/etc ] && [ -d /mnt/usr ]; then
    echo "[boot] mounted target"
    findmnt /mnt 2>&1 || true
    sed -n '1,120p' /mnt/etc/fstab 2>&1 || true
    if [ ! -d /mnt/boot ]; then
      echo "MEO_FINDING|warning|boot.target_boot_missing|The mounted target has no /boot directory."
    fi
  else
    echo "MEO_FINDING|info|boot.target_not_mounted|No installed target is mounted at /mnt."
  fi
fi
