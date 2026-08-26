#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/acceptance/30-build-iso.sh

Build an acceptance ISO. By default, evidence is retained in
validation/<UTC-run-id>/iso and the candidate ISO in
packages/iso/<UTC-run-id>/.

Overrides: MEOARCH_RUN_ID, MEOARCH_RUN_DIR, MEOARCH_OUTPUT_ROOT, and
MEOARCH_ISO_OUTPUT_DIR. Explicit paths take precedence.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  "")
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

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
evidence_dir="${run_dir}/iso"
output_dir="${MEOARCH_ISO_OUTPUT_DIR:-${outputs_root}/packages/iso/${run_id}}"
mkdir -p "${evidence_dir}" "${output_dir}"

"${repo_root}/scripts/build-iso.sh" --output "${output_dir}" |
  tee "${evidence_dir}/build.log"
iso_path="$(find "${output_dir}" -maxdepth 1 -type f -name '*.iso' -print -quit)"
[ -n "${iso_path}" ] && [ -s "${iso_path}" ]
sha256sum "${iso_path}" | tee "${evidence_dir}/sha256.txt"
stat -c '%s' "${iso_path}" | tee "${evidence_dir}/size-bytes.txt"
printf '%s\n' "${iso_path}" >"${evidence_dir}/iso-path.txt"
echo "PASS: ISO build" | tee "${evidence_dir}/status.txt"
