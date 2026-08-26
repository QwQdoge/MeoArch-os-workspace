#!/usr/bin/env bash
set -uo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/acceptance/run-all.sh

Run the non-interactive MeoArch acceptance stages. By default, evidence is
written to outputs/meo-arch-os-workspace/validation/<UTC-run-id>/ and ISO
candidates to packages/iso/<UTC-run-id>/.

Overrides: MEOARCH_RUN_ID, MEOARCH_RUN_DIR, MEOARCH_OUTPUT_ROOT,
MEOARCH_TMP_DIR, and MEOARCH_ISO_OUTPUT_DIR. Explicit paths take precedence.
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
export MEOARCH_OUTPUT_ROOT="${outputs_root}"
export MEOARCH_RUN_ID="${run_id}"
export MEOARCH_RUN_DIR="${run_dir}"
export MEOARCH_TMP_DIR="${MEOARCH_TMP_DIR:-${outputs_root}/tmp/${run_id}}"
export MEOARCH_ISO_OUTPUT_DIR="${MEOARCH_ISO_OUTPUT_DIR:-${outputs_root}/packages/iso/${run_id}}"
mkdir -p "${MEOARCH_RUN_DIR}"
summary="${MEOARCH_RUN_DIR}/summary.md"
overall=0

run_stage() {
  local name="$1"
  shift
  echo "Running ${name}..."
  if "$@"; then
    printf '%s|PASS\n' "${name}" >>"${MEOARCH_RUN_DIR}/stages.txt"
  else
    status=$?
    printf '%s|FAIL (%s)\n' "${name}" "${status}" >>"${MEOARCH_RUN_DIR}/stages.txt"
    overall=1
  fi
}

run_stage environment "${repo_root}/scripts/acceptance/00-environment.sh"
run_stage source-validation "${repo_root}/scripts/acceptance/10-source-validation.sh"
run_stage component-build "${repo_root}/scripts/acceptance/20-build-components.sh"
run_stage iso-build "${repo_root}/scripts/acceptance/30-build-iso.sh"
if [ -f "${MEOARCH_RUN_DIR}/iso/iso-path.txt" ]; then
  run_stage iso-inspection "${repo_root}/scripts/acceptance/40-inspect-iso.sh"
  run_stage vm-disk "${repo_root}/scripts/acceptance/50-create-vm.sh"
else
  printf 'iso-inspection|SKIPPED\nvm-disk|SKIPPED\n' >>"${MEOARCH_RUN_DIR}/stages.txt"
fi

{
  echo "# MeoArch Acceptance Test"
  echo
  echo "## Build Identification"
  echo
  echo "- Git commit: $(git -C "${repo_root}" rev-parse HEAD)"
  echo "- Branch: $(git -C "${repo_root}" branch --show-current)"
  echo "- Timestamp: $(date -u +%FT%TZ)"
  echo
  echo "## Automated Stages"
  echo
  while IFS='|' read -r stage status; do
    echo "- ${stage}: ${status}"
  done <"${MEOARCH_RUN_DIR}/stages.txt"
  echo
  echo "## Environment-dependent Stages"
  echo
  echo "- UEFI boot: BLOCKED pending controlled VM observation"
  echo "- Live Desktop: BLOCKED pending controlled VM observation"
  echo "- Installer and full installation: BLOCKED pending controlled VM operation"
  echo "- Installed-system boot: BLOCKED pending ISO removal and independent boot"
  echo "- Performance and UX smoke test: BLOCKED pending installed-system boot"
  echo
  echo "## Overall Result"
  echo
  if [ "${overall}" -eq 0 ]; then echo "PARTIAL PASS"; else echo "FAIL"; fi
} >"${summary}"

echo "Report: ${summary}"
exit "${overall}"
