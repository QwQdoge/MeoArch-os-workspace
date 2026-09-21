#!/usr/bin/env bash
set -u -o pipefail

echo "[storage] block devices"
lsblk --bytes --output NAME,TYPE,SIZE,FSTYPE,FSVER,LABEL,UUID,MOUNTPOINTS 2>&1 || true

echo "[storage] filesystems"
findmnt --real --output TARGET,SOURCE,FSTYPE,OPTIONS 2>&1 || true
df -hT 2>&1 || true

scope="${MEOARCH_REPAIR_SCOPE:-system}"
storage_root="/"
check_root_filesystem=1
root_finding_code="storage.root_nearly_full"
root_description="The root filesystem is at least 90 percent full."
if [ "${scope}" = "live" ]; then
  if [ -d /mnt/etc ] && findmnt -rn /mnt >/dev/null 2>&1; then
    storage_root="/mnt"
    root_finding_code="storage.target_root_nearly_full"
    root_description="The mounted installed system root filesystem is at least 90 percent full."
    echo "[storage] mounted installed target capacity"
    df -hT /mnt 2>&1 || true
  else
    check_root_filesystem=0
    echo "MEO_FINDING|warning|storage.target_not_mounted|No installed system root is mounted at /mnt."
  fi
fi

if [ "${check_root_filesystem}" -eq 1 ]; then
  root_percent="$(df --output=pcent "${storage_root}" 2>/dev/null | tail -n 1 | tr -dc '0-9')"
  if [ -n "${root_percent}" ] && [ "${root_percent}" -ge 90 ]; then
    printf 'MEO_FINDING|warning|%s|%s\n' "${root_finding_code}" "${root_description}"
  fi
fi

if [ "${check_root_filesystem}" -eq 1 ] \
   && findmnt -n -o FSTYPE "${storage_root}" 2>/dev/null | grep -qx btrfs \
   && command -v btrfs >/dev/null 2>&1; then
  echo "[storage] btrfs device stats for ${storage_root}"
  btrfs_stats="$(btrfs device stats "${storage_root}" 2>&1 || true)"
  printf '%s\n' "${btrfs_stats}"
  if grep -Eq '[[:space:]][1-9][0-9]*$' <<<"${btrfs_stats}"; then
    echo "MEO_FINDING|warning|storage.btrfs_device_errors|Btrfs reported non-zero device error counters."
  fi
fi

echo "[storage] SMART health"
if command -v smartctl >/dev/null 2>&1; then
  while IFS= read -r disk; do
    [ -b "/dev/${disk}" ] || continue
    smart_output="$(timeout 20 smartctl -H "/dev/${disk}" 2>&1 || true)"
    printf '%s\n' "--- /dev/${disk} ---"
    printf '%s\n' "${smart_output}"
    if grep -Eqi '(overall-health[^:]*:[[:space:]]*FAILED|SMART Health Status:[[:space:]]*FAIL|SMART overall-health.*FAILED)' <<<"${smart_output}"; then
      echo "MEO_FINDING|warning|storage.smart_failed|SMART reported a failed health result for /dev/${disk}."
    elif grep -Eqi 'Permission denied|Operation not permitted|Unknown USB bridge|not available' <<<"${smart_output}"; then
      echo "MEO_FINDING|info|storage.smart_unavailable|SMART health is not available for /dev/${disk} through its current controller."
    fi
  done < <(lsblk -dn -o NAME,TYPE 2>/dev/null | awk '$2 == "disk" { print $1 }')
else
  echo "MEO_FINDING|info|storage.smartctl_missing|SMART diagnostics are unavailable because smartctl is not installed."
fi

echo "[storage] NVMe health"
if command -v nvme >/dev/null 2>&1; then
  for device in /dev/nvme*n1; do
    [ -b "${device}" ] || continue
    nvme_output="$(timeout 20 nvme smart-log "${device}" 2>&1 || true)"
    printf '%s\n' "--- ${device} ---"
    printf '%s\n' "${nvme_output}"
    critical_warning="$(sed -n 's/^[[:space:]]*critical_warning[[:space:]]*:[[:space:]]*//p' <<<"${nvme_output}" | head -n 1)"
    case "${critical_warning}" in
      ""|0|0x00) ;;
      *) echo "MEO_FINDING|warning|storage.nvme_critical_warning|NVMe reported a non-zero critical warning for ${device}." ;;
    esac
  done
fi

