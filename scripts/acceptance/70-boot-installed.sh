#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/acceptance/70-boot-installed.sh [DISK_PATH]

Boot the installed acceptance VM without the ISO. Temporary qcow2, OVMF, and
QMP state defaults to tmp/<UTC-run-id>/vm; validation records remain under
validation/<UTC-run-id>/vm. Set MEOARCH_VM_HANDOFF=1 (or
MEOARCH_INSTALL_DIR) only when a bootable VM handoff must be retained.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac
[ "$#" -le 1 ] || { usage >&2; exit 2; }

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
projects_root="$(cd "${repo_root}/.." && pwd)"
default_outputs_root="${MEO_OUTPUT_ROOT:-${projects_root}/outputs}/meo-arch-os-workspace"
outputs_root="${MEOARCH_OUTPUT_ROOT:-${default_outputs_root}}"
if [ -n "${MEOARCH_RUN_DIR:-}" ]; then
  run_dir="${MEOARCH_RUN_DIR}"
  run_id="${MEOARCH_RUN_ID:-$(basename "${run_dir}")}"
else
  run_id="${MEOARCH_RUN_ID:-$(date -u +%Y-%m-%dT%H%M%SZ)-acceptance}"
  run_dir="${outputs_root}/validation/${run_id}"
fi
tmp_dir="${MEOARCH_TMP_DIR:-${outputs_root}/tmp/${run_id}}"
if [ -n "${MEOARCH_VM_DIR:-}" ]; then
  vm_dir="${MEOARCH_VM_DIR}"
elif [ -n "${MEOARCH_INSTALL_DIR:-}" ] || [ "${MEOARCH_VM_HANDOFF:-0}" = "1" ]; then
  vm_dir="${MEOARCH_INSTALL_DIR:-${outputs_root}/install/${run_id}}"
else
  vm_dir="${tmp_dir}/vm"
fi
evidence_dir="${run_dir}/vm"
if [ -n "${1:-}" ]; then
  disk_path="$1"
elif [ -f "${evidence_dir}/disk-path.txt" ]; then
  disk_path="$(<"${evidence_dir}/disk-path.txt")"
else
  disk_path="${vm_dir}/meoarch-test.qcow2"
fi
display_mode="${MEOARCH_QEMU_DISPLAY:-gtk}"
qemu_gl="${MEOARCH_QEMU_GL:-on}"
vm_width="${MEOARCH_VM_WIDTH:-1920}"
vm_height="${MEOARCH_VM_HEIGHT:-1080}"
vm_name="${MEOARCH_VM_NAME:-MeoArch Installed Acceptance}"
mkdir -p "${vm_dir}" "${evidence_dir}"
case "${qemu_gl}" in
  on|off) ;;
  *) echo "MEOARCH_QEMU_GL must be on or off." >&2; exit 2 ;;
esac
case "${vm_width}x${vm_height}" in
  *[!0-9x]*|x*|*x) echo "MEOARCH_VM_WIDTH and MEOARCH_VM_HEIGHT must be positive integers." >&2; exit 2 ;;
esac
[ "${vm_width}" -ge 960 ] && [ "${vm_height}" -ge 600 ] || {
  echo "The acceptance VM must be at least 960x600 so the installed desktop is not tested in a clipped layout." >&2
  exit 2
}

socket_dir="${MEOARCH_QEMU_SOCKET_DIR:-${tmp_dir}/q/installed}"
mkdir -p "${socket_dir}"
qmp_socket="${socket_dir}/q"
monitor_socket="${socket_dir}/m"
[ "${#qmp_socket}" -lt 104 ] && [ "${#monitor_socket}" -lt 104 ] || {
  echo "QMP socket path is too long; set MEOARCH_QEMU_SOCKET_DIR to a shorter temporary directory." >&2
  exit 2
}
printf '%s\n' "${qmp_socket}" >"${evidence_dir}/installed-qmp-path.txt"
printf '%s\n' "${monitor_socket}" >"${evidence_dir}/installed-monitor-path.txt"

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

display_args=(-device "virtio-vga-gl,xres=${vm_width},yres=${vm_height}" -display "${display_mode},gl=on")
if [ "${qemu_gl}" = "off" ]; then
  display_args=(-device "virtio-vga,xres=${vm_width},yres=${vm_height}" -display "${display_mode}")
fi
if [ "${display_mode}" = "none" ]; then
  display_args=(-device "virtio-vga,xres=${vm_width},yres=${vm_height}" -display none)
fi

cat >"${evidence_dir}/installed-vm-config.txt" <<EOF
firmware=UEFI OVMF
cpus=4
memory=8192 MiB
disk=${disk_path}
iso=none
network=user/NAT hostfwd tcp 127.0.0.1:2222 to guest 22
display=${display_mode}
gl=${qemu_gl}
resolution=${vm_width}x${vm_height}
EOF

# Stable USB input IDs make QMP-driven login acceptance deterministic.
exec qemu-system-x86_64 \
  "${accel_args[@]}" \
  -machine q35 \
  -smp 4 \
  -m 8192 \
  -drive "if=pflash,format=raw,readonly=on,file=${ovmf_code}" \
  -drive "if=pflash,format=raw,file=${ovmf_vars}" \
  -drive "file=${disk_path},if=none,id=install_disk,format=qcow2,cache=writeback" \
  -device "nvme,drive=install_disk,serial=MEOARCH-ACC-0001" \
  "${display_args[@]}" \
  -device virtio-net-pci,netdev=net0 \
  -netdev user,id=net0,hostfwd=tcp:127.0.0.1:2222-:22 \
  -device qemu-xhci \
  -device usb-tablet,id=meo_tablet \
  -device usb-kbd,id=meo_keyboard \
  -qmp "unix:${qmp_socket},server=on,wait=off" \
  -monitor "unix:${monitor_socket},server=on,wait=off" \
  -serial "file:${evidence_dir}/installed-serial.log" \
  -boot menu=on,order=c \
  -name "${vm_name}"
