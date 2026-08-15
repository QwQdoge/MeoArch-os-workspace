#!/usr/bin/env bash
set -uo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_id="${MEOARCH_RUN_ID:-$(date -u +%Y%m%dT%H%M%SZ)}"
export MEOARCH_RUN_DIR="${repo_root}/artifacts/validation/test-runs/${run_id}"
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
