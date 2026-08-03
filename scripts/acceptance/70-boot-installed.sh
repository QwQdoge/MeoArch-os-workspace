#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${MEOARCH_RUN_DIR:-${repo_root}/artifacts/test-runs/$(date -u +%Y%m%dT%H%M%SZ)}"
vm_dir="${run_dir}/vm"
disk_path="${1:-${vm_dir}/meoarch-test.qcow2}"
display_mode="${MEOARCH_QEMU_DISPLAY:-gtk}"
mkdir -p "${vm_dir}"

[ -f "${disk_path}" ] || { echo "VM disk not found: ${disk_path}" >&2; exit 2; }
case "${disk_path}" in /dev/*) echo "Refusing host device." >&2; exit 2 ;; esac

ovmf_code="${MEOARCH_OVMF_CODE:-/usr/share/edk2/x64/OVMF_CODE.4m.fd}"
ovmf_vars_template="${MEOARCH_OVMF_VARS:-/usr/share/edk2/x64/OVMF_VARS.4m.fd}"
[ -f "${ovmf_code}" ] && [ -f "${ovmf_vars_template}" ] || {
  echo "OVMF firmware files are missing." >&2
  exit 2
}
ovmf_vars="${vm_dir}/OVMF_VARS.4m.fd"
if [ ! -e "${ovmf_vars}" ]; then
  cp "${ovmf_vars_template}" "${ovmf_vars}"
fi

accel_args=(-accel tcg,thread=multi)
if [ -r /dev/kvm ] && [ -w /dev/kvm ]; then
  accel_args=(-enable-kvm -cpu host)
fi

display_args=(-device virtio-vga-gl -display "${display_mode},gl=on")
if [ "${display_mode}" = "none" ]; then
  display_args=(-device virtio-vga -display none)
fi

cat >"${vm_dir}/installed-vm-config.txt" <<EOF
firmware=UEFI OVMF
cpus=4
memory=8192 MiB
disk=${disk_path}
iso=none
network=user/NAT hostfwd tcp 127.0.0.1:2222 to guest 22
display=${display_mode}
EOF

exec qemu-system-x86_64 \
  "${accel_args[@]}" \
  -machine q35 \
  -smp 4 \
  -m 8192 \
  -drive "if=pflash,format=raw,readonly=on,file=${ovmf_code}" \
  -drive "if=pflash,format=raw,file=${ovmf_vars}" \
  -drive "file=${disk_path},if=virtio,format=qcow2,cache=writeback" \
  "${display_args[@]}" \
  -device virtio-net-pci,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp:127.0.0.1:2222-:22 \
  -device qemu-xhci \
  -device usb-tablet \
  -qmp "unix:${vm_dir}/iqmp.sock,server=on,wait=off" \
  -monitor "unix:${vm_dir}/imon.sock,server=on,wait=off" \
  -serial "file:${vm_dir}/installed-serial.log" \
  -boot menu=on,order=c \
  -name "MeoArch Installed Acceptance"
