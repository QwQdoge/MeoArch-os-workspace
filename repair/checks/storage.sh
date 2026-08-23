#!/usr/bin/env bash
set -u -o pipefail

echo "[storage] block devices"
lsblk --bytes --output NAME,TYPE,SIZE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS 2>&1 || true

echo "[storage] filesystems"
findmnt --real --output TARGET,SOURCE,FSTYPE,OPTIONS 2>&1 || true
df -hT 2>&1 || true

root_percent="$(df --output=pcent / 2>/dev/null | tail -n 1 | tr -dc '0-9')"
if [ -n "${root_percent}" ] && [ "${root_percent}" -ge 90 ]; then
  echo "MEO_FINDING|warning|storage.root_nearly_full|The root filesystem is at least 90 percent full."
fi

if findmnt -n -o FSTYPE / 2>/dev/null | grep -qx btrfs && command -v btrfs >/dev/null 2>&1; then
  echo "[storage] btrfs device stats"
  btrfs device stats / 2>&1 || true
fi

if [ "${MEOARCH_REPAIR_SCOPE:-system}" = "live" ] && [ ! -d /mnt/etc ]; then
  echo "MEO_FINDING|info|storage.target_not_mounted|Mount an installed system at /mnt to inspect or repair its boot files."
fi
