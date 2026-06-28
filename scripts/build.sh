#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
profile_dir="${repo_root}/MeoArch os"
work_dir="${repo_root}/work"
out_dir="${repo_root}/out"

if ! command -v mkarchiso >/dev/null 2>&1; then
  echo "mkarchiso is required. Install the archiso package on Arch Linux." >&2
  exit 1
fi

"${repo_root}/scripts/sync-installer-to-airootfs.sh"

mkdir -p "${work_dir}" "${out_dir}"
mkarchiso -v -w "${work_dir}" -o "${out_dir}" "${profile_dir}"
