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
