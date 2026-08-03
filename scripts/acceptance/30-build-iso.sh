#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${MEOARCH_RUN_DIR:-${repo_root}/artifacts/test-runs/$(date -u +%Y%m%dT%H%M%SZ)}"
evidence_dir="${run_dir}/iso"
output_dir="${MEOARCH_ISO_OUTPUT_DIR:-${run_dir}/iso-image}"
mkdir -p "${evidence_dir}" "${output_dir}"

"${repo_root}/scripts/build-iso.sh" --clean --output "${output_dir}" |
  tee "${evidence_dir}/build.log"
iso_path="$(find "${output_dir}" -maxdepth 1 -type f -name '*.iso' -print -quit)"
[ -n "${iso_path}" ] && [ -s "${iso_path}" ]
sha256sum "${iso_path}" | tee "${evidence_dir}/sha256.txt"
stat -c '%s' "${iso_path}" | tee "${evidence_dir}/size-bytes.txt"
printf '%s\n' "${iso_path}" >"${evidence_dir}/iso-path.txt"
echo "PASS: ISO build" | tee "${evidence_dir}/status.txt"
