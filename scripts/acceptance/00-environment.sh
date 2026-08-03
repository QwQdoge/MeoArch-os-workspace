#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${MEOARCH_RUN_DIR:-${repo_root}/artifacts/test-runs/$(date -u +%Y%m%dT%H%M%SZ)}"
evidence_dir="${run_dir}/environment"
mkdir -p "${evidence_dir}"
report="${evidence_dir}/environment.txt"

{
  echo "timestamp_utc=$(date -u +%FT%TZ)"
  echo "git_commit=$(git -C "${repo_root}" rev-parse HEAD)"
  echo "kernel=$(uname -srmo)"
  . /etc/os-release
  echo "distribution=${PRETTY_NAME}"
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
