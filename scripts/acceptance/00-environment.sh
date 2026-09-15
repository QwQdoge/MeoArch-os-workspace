#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/acceptance/00-environment.sh

Record host prerequisites in validation/<UTC-run-id>/environment. By default
the run is stored beneath the global MeoArch output directory.
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
else
  run_id="${MEOARCH_RUN_ID:-$(date -u +%Y-%m-%dT%H%M%SZ)-acceptance}"
  run_dir="${outputs_root}/validation/${run_id}"
fi
evidence_dir="${run_dir}/environment"
mkdir -p "${evidence_dir}"
report="${evidence_dir}/environment.txt"

{
  echo "timestamp_utc=$(date -u +%FT%TZ)"
  echo "git_commit=$(git -C "${repo_root}" rev-parse HEAD)"
  echo "kernel=$(uname -srmo)"
  if [ -r /etc/os-release ]; then
    # os-release is the Linux build-host identity when it is available.
    # shellcheck disable=SC1091
    . /etc/os-release
    echo "distribution=${PRETTY_NAME:-unknown}"
  elif command -v sw_vers >/dev/null 2>&1; then
    echo "distribution=$(sw_vers -productName) $(sw_vers -productVersion)"
  else
    echo "distribution=unknown (no /etc/os-release)"
  fi
  echo "architecture=$(uname -m)"
  for tool in mkarchiso qemu-system-x86_64 qemu-img cmake ninja pkg-config \
    xorriso unsquashfs readelf objdump sha256sum; do
    if command -v "${tool}" >/dev/null 2>&1; then
      echo "${tool}=$(command -v "${tool}")"
    else
      echo "${tool}=MISSING"
    fi
  done
  if [ -e /dev/kvm ]; then
    echo "kvm=$(stat -c '%A %U:%G %n' /dev/kvm)"
  else
    echo "kvm=MISSING"
  fi
  if unshare -Ur true >/dev/null 2>&1; then
    echo "unprivileged_user_namespaces=available"
  else
    echo "unprivileged_user_namespaces=unavailable"
  fi
  if sudo -n true >/dev/null 2>&1; then
    echo "passwordless_sudo=available"
  else
    echo "passwordless_sudo=unavailable"
  fi
  find /usr/share/edk2 -type f -name 'OVMF_CODE*.fd' -print 2>/dev/null |
    sed 's/^/ovmf_code=/'
} | tee "${report}"

for required in mkarchiso qemu-system-x86_64 qemu-img xorriso unsquashfs readelf; do
  command -v "${required}" >/dev/null 2>&1 || {
    echo "FAIL: missing ${required}" >&2
    exit 1
  }
done
find /usr/share/edk2 -type f -name 'OVMF_CODE*.fd' -print -quit 2>/dev/null |
  grep -q . || { echo "FAIL: OVMF firmware is missing" >&2; exit 1; }

echo "PASS: environment" | tee "${evidence_dir}/status.txt"
