#!/usr/bin/env bash
set -u -o pipefail

echo "[hardware] platform"
printf 'Architecture: %s\n' "$(uname -m 2>/dev/null || echo unknown)"
printf 'Kernel: %s\n' "$(uname -r 2>/dev/null || echo unknown)"
if [ -d /sys/firmware/efi ]; then
  echo "Firmware boot mode: UEFI"
  secure_boot_file="$(find /sys/firmware/efi/efivars -maxdepth 1 -type f -name 'SecureBoot-*' -print -quit 2>/dev/null || true)"
  if [ -n "${secure_boot_file}" ] && command -v od >/dev/null 2>&1; then
    secure_boot_value="$(od -An -j4 -N1 -tu1 "${secure_boot_file}" 2>/dev/null | tr -d '[:space:]' || true)"
    case "${secure_boot_value}" in
      1) echo "Secure Boot: enabled" ;;
      0) echo "Secure Boot: disabled" ;;
      *) echo "Secure Boot: unknown" ;;
    esac
  else
    echo "Secure Boot: unavailable"
  fi
else
  echo "Firmware boot mode: legacy/BIOS or unavailable"
  echo "Secure Boot: unavailable outside UEFI"
fi
if [ -e /sys/class/tpm/tpm0 ]; then
  echo "TPM: detected"
else
  echo "TPM: not detected"
fi
if command -v systemd-detect-virt >/dev/null 2>&1; then
  virtualization="$(systemd-detect-virt 2>/dev/null || true)"
  printf 'Virtualization: %s\n' "${virtualization:-none detected}"
fi

echo "[hardware] system identity"
read_trimmed() {
  local path="$1"
  if [ -r "${path}" ]; then
    tr -d '\000' <"${path}" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//' | head -c 180
  fi
}
vendor="$(read_trimmed /sys/class/dmi/id/sys_vendor || true)"
product="$(read_trimmed /sys/class/dmi/id/product_name || true)"
version="$(read_trimmed /sys/class/dmi/id/product_version || true)"
printf 'System: %s%s%s\n' \
  "${vendor:-unknown vendor}" \
  "${product:+ · ${product}}" \
  "${version:+ · ${version}}"

echo "[hardware] CPU"
cpu_model="$(awk -F: '/model name|Hardware|Processor/ {gsub(/^[[:space:]]+|[[:space:]]+$/, "", $2); if ($2 != "") {print $2; exit}}' /proc/cpuinfo 2>/dev/null || true)"
printf 'CPU: %s\n' "${cpu_model:-unknown}"
printf 'Logical CPUs: %s\n' "$(nproc 2>/dev/null || echo unknown)"

echo "[hardware] memory"
mem_total_kib="$(awk '/^MemTotal:/ {print $2; exit}' /proc/meminfo 2>/dev/null || true)"
mem_available_kib="$(awk '/^MemAvailable:/ {print $2; exit}' /proc/meminfo 2>/dev/null || true)"
if [[ "${mem_total_kib}" =~ ^[0-9]+$ ]]; then
  awk -v total="${mem_total_kib}" -v available="${mem_available_kib:-0}" 'BEGIN {
    printf "Memory: %.1f GiB total · %.1f GiB available\n", total/1048576, available/1048576
  }'
else
  echo "Memory information is unavailable."
fi

echo "[hardware] block devices"
if command -v lsblk >/dev/null 2>&1; then
  lsblk -d -e 7 -o NAME,SIZE,TYPE,TRAN,MODEL --noheadings 2>&1 | sed -n '1,80p' || true
else
  echo "lsblk is unavailable."
fi

echo "[hardware] network interfaces"
if command -v ip >/dev/null 2>&1; then
  ip -brief link 2>&1 | sed -n '1,80p' || true
else
  echo "ip is unavailable."
fi

echo "[hardware] batteries"
battery_count=0
for supply in /sys/class/power_supply/*; do
  [ -d "${supply}" ] || continue
  [ -r "${supply}/type" ] || continue
  if [ "$(cat "${supply}/type" 2>/dev/null || true)" != "Battery" ]; then
    continue
  fi
  battery_count=$((battery_count + 1))
  capacity="$(cat "${supply}/capacity" 2>/dev/null || true)"
  status="$(cat "${supply}/status" 2>/dev/null || true)"
  printf '%s: %s%%%s\n' "$(basename "${supply}")" "${capacity:-?}" "${status:+ · ${status}}"
done
if [ "${battery_count}" -eq 0 ]; then
  echo "No battery power-supply device was detected."
fi

if [ "${MEOARCH_REPAIR_SCOPE:-system}" = "live" ]; then
  echo "[hardware] Live environment"
  echo "This inventory describes the currently booted Live kernel and hardware."
  if [ -d /mnt/etc ] && [ -d /mnt/usr ]; then
    echo "Installed target at /mnt: mounted"
  else
    echo "Installed target at /mnt: not mounted"
  fi
else
  echo "[hardware] installed system"
  echo "This inventory describes the currently running installed system and its hardware."
fi
