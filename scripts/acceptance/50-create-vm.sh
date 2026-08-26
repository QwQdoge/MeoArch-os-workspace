#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/acceptance/50-create-vm.sh [DISK_PATH]

Create a disposable qcow2 disk. The default disk is in
tmp/<UTC-run-id>/vm/. Set MEOARCH_VM_HANDOFF=1 (or MEOARCH_INSTALL_DIR) to
place a bootable handoff VM under install/<UTC-run-id>/ instead.
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
disk_path="${1:-${vm_dir}/meoarch-test.qcow2}"
disk_size="${MEOARCH_VM_DISK_SIZE:-64G}"
mkdir -p "${vm_dir}" "${evidence_dir}"

case "${disk_path}" in
  /dev/*) echo "Refusing host block-device target: ${disk_path}" >&2; exit 2 ;;
esac
resolved_disk_path="$(realpath -m "${disk_path}")"
resolved_vm_dir="$(realpath -m "${vm_dir}")"
legacy_vm_dir="$(realpath -m "${run_dir}/vm")"
case "${resolved_disk_path}" in
  "${resolved_vm_dir}/"*|"${legacy_vm_dir}/"*) ;;
  *)
    echo "VM disk must remain below ${vm_dir} (or the explicit legacy run VM directory): ${disk_path}" >&2
    exit 2
    ;;
esac
if [ -e "${disk_path}" ]; then
  [ -f "${disk_path}" ] || { echo "Target is not a regular file." >&2; exit 2; }
  echo "Refusing to overwrite existing VM disk: ${disk_path}" >&2
  exit 3
fi

qemu-img create -f qcow2 "${disk_path}" "${disk_size}"
qemu-img info "${disk_path}" | tee "${evidence_dir}/disk-info.txt"
printf '%s\n' "${disk_path}" >"${evidence_dir}/disk-path.txt"
echo "PASS: disposable VM disk created" | tee "${evidence_dir}/status.txt"
