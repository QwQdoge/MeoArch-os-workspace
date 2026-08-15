#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${MEOARCH_RUN_DIR:-${repo_root}/artifacts/validation/test-runs/$(date -u +%Y%m%dT%H%M%SZ)}"
vm_dir="${run_dir}/vm"
iso_path="${1:-}"
disk_path="${2:-${vm_dir}/meoarch-test.qcow2}"
display_mode="${MEOARCH_QEMU_DISPLAY:-gtk}"
mkdir -p "${vm_dir}"

# AF_UNIX paths are limited to roughly 108 bytes. Artifact directories are
# intentionally descriptive and can exceed that limit, so keep only the
# transient control sockets in a short runtime directory and record their
# locations beside the persistent VM artifacts.
run_tag="$(basename "${run_dir}")"
run_tag="${run_tag: -8}"
socket_dir="${MEOARCH_QEMU_SOCKET_DIR:-/tmp/meo-${run_tag}-live}"
mkdir -p "${socket_dir}"
qmp_socket="${socket_dir}/qmp.sock"
monitor_socket="${socket_dir}/monitor.sock"
printf '%s\n' "${qmp_socket}" >"${vm_dir}/qmp-path.txt"
printf '%s\n' "${monitor_socket}" >"${vm_dir}/monitor-path.txt"

[ -f "${iso_path}" ] || { echo "ISO not found: ${iso_path}" >&2; exit 2; }
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

cat >"${vm_dir}/vm-config.txt" <<EOF
firmware=UEFI OVMF
cpus=4
memory=8192 MiB
disk=${disk_path}
iso=${iso_path}
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
  -drive "file=${disk_path},if=none,id=install_disk,format=qcow2,cache=writeback" \
  -device "nvme,drive=install_disk,serial=MEOARCH-ACC-0001" \
  -drive "file=${iso_path},media=cdrom,readonly=on" \
  "${display_args[@]}" \
  -device virtio-net-pci,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp:127.0.0.1:2222-:22 \
  -device qemu-xhci \
  -device usb-tablet \
  -qmp "unix:${qmp_socket},server=on,wait=off" \
  -monitor "unix:${monitor_socket},server=on,wait=off" \
  -serial "file:${vm_dir}/serial.log" \
  -boot menu=on,order=d \
  -name "MeoArch Acceptance"
