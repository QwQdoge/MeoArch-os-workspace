#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${MEOARCH_RUN_DIR:-${repo_root}/artifacts/validation/test-runs/$(date -u +%Y%m%dT%H%M%SZ)}"
vm_dir="${run_dir}/vm"
disk_path="${1:-${vm_dir}/meoarch-test.qcow2}"
disk_size="${MEOARCH_VM_DISK_SIZE:-64G}"
mkdir -p "${vm_dir}"

case "${disk_path}" in
  /dev/*) echo "Refusing host block-device target: ${disk_path}" >&2; exit 2 ;;
esac
case "$(realpath -m "${disk_path}")" in
  "${repo_root}/artifacts/"*) ;;
  *) echo "VM disk must remain below ${repo_root}/artifacts: ${disk_path}" >&2; exit 2 ;;
esac
if [ -e "${disk_path}" ]; then
  [ -f "${disk_path}" ] || { echo "Target is not a regular file." >&2; exit 2; }
  echo "Refusing to overwrite existing VM disk: ${disk_path}" >&2
  exit 3
fi

qemu-img create -f qcow2 "${disk_path}" "${disk_size}"
qemu-img info "${disk_path}" | tee "${vm_dir}/disk-info.txt"
printf '%s\n' "${disk_path}" >"${vm_dir}/disk-path.txt"
echo "PASS: disposable VM disk created" | tee "${vm_dir}/status.txt"
