#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
projects_root="$(cd "${repo_root}/.." && pwd)"
outputs_root="${MEOARCH_OUTPUT_ROOT:-${projects_root}/outputs}"
source_profile="${repo_root}/meoarch-os"
build_root="${repo_root}/build/archiso"
work_dir="${build_root}/work"
staged_profile="${build_root}/profile"
out_dir="${outputs_root}/iso"
clean=0

usage() {
  cat <<'EOF'
Usage: scripts/build-iso.sh [--clean] [--output DIRECTORY]

Build the MeoArch ISO using a staged ArchISO profile. --clean removes only
reproducible work files under build/archiso; it never deletes existing ISOs.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --clean)
      clean=1
      shift
      ;;
    --output)
      [ "$#" -ge 2 ] || { echo "--output requires a directory" >&2; exit 2; }
      out_dir="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

case "${out_dir}" in
  /*) ;;
  *) out_dir="${repo_root}/${out_dir}" ;;
esac

for tool in cmake ninja pkg-config mkarchiso sha256sum stat tee; do
  command -v "${tool}" >/dev/null 2>&1 || {
    echo "Missing required tool: ${tool}" >&2
    exit 127
  }
done

for required in \
  "${source_profile}/profiledef.sh" \
  "${source_profile}/packages.x86_64" \
  "${repo_root}/installer/CMakeLists.txt" \
  "${repo_root}/themes/MeoUI/CMakeLists.txt"; do
  [ -f "${required}" ] || {
    echo "Required project file is missing: ${required}" >&2
    exit 3
  }
done

case "${build_root}" in
  "${repo_root}/build/"*) ;;
  *) echo "Refusing unsafe build root: ${build_root}" >&2; exit 4 ;;
esac

if [ "${clean}" -eq 1 ] && [ -d "${build_root}" ]; then
  echo "Cleaning reproducible work directory: ${build_root}"
  if ! find "${build_root}" -mindepth 1 -delete 2>/dev/null; then
    task_uid="$(id -u)"
    task_gid="$(id -g)"
    task_user="$(id -un)"
    task_subuid="$(awk -F: -v user="${task_user}" '$1 == user { print $2; exit }' /etc/subuid)"
    task_subgid="$(awk -F: -v user="${task_user}" '$1 == user { print $2; exit }' /etc/subgid)"
    if [ -z "${task_subuid}" ] || [ -z "${task_subgid}" ] || ! command -v unshare >/dev/null 2>&1; then
      echo "Could not clean rootless ArchISO ownership; subuid/subgid mappings are unavailable." >&2
      exit 4
    fi
    unshare --user \
      --map-users "0:${task_uid}:1" --map-users "1:${task_subuid}:65536" \
      --map-groups "0:${task_gid}:1" --map-groups "1:${task_subgid}:65536" \
      find "${build_root}" -mindepth 1 -delete
  fi
fi

run_id="$(date -u +%Y%m%dT%H%M%SZ)"
log_dir="${outputs_root}/logs/iso/${run_id}"
mkdir -p "${log_dir}" "${build_root}" "${out_dir}"
log_file="${log_dir}/build-iso.log"
exec > >(tee -a "${log_file}") 2>&1

echo "MeoArch ISO build"
echo "Git commit: $(git -C "${repo_root}" rev-parse HEAD)"
echo "Profile: ${source_profile}"
echo "Output directory: ${out_dir}"
echo "Log: ${log_file}"

if [ -e "${staged_profile}" ]; then
  find "${staged_profile}" -mindepth 1 -delete
else
  mkdir -p "${staged_profile}"
fi
cp -a "${source_profile}/." "${staged_profile}/"

if [ -n "${MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY:-}" ]; then
  [ -f "${MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY}" ] || {
    echo "Acceptance SSH public key not found: ${MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY}" >&2
    exit 6
  }
  install -d -m 700 "${staged_profile}/airootfs/root/.ssh"
  install -m 600 "${MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY}" \
    "${staged_profile}/airootfs/root/.ssh/authorized_keys"
  echo "Injected an ephemeral acceptance-only SSH public key into the staged profile."
fi

"${repo_root}/scripts/build-installer-app.sh"
MEOARCH_AIROOTFS="${staged_profile}/airootfs" \
  "${repo_root}/scripts/sync-installer-to-airootfs.sh"

mapfile -t before_isos < <(find "${out_dir}" -maxdepth 1 -type f -name '*.iso' -print)
mkarchiso -v -w "${work_dir}" -o "${out_dir}" "${staged_profile}"
mapfile -t after_isos < <(find "${out_dir}" -maxdepth 1 -type f -name '*.iso' -print)

iso_path=""
for candidate in "${after_isos[@]}"; do
  found=0
  for old in "${before_isos[@]}"; do
    if [ "${candidate}" = "${old}" ]; then
      found=1
      break
    fi
  done
  if [ "${found}" -eq 0 ]; then
    iso_path="${candidate}"
    break
  fi
done

if [ -z "${iso_path}" ]; then
  echo "mkarchiso returned successfully but no new ISO was found in ${out_dir}." >&2
  exit 5
fi

iso_size="$(stat -c '%s' "${iso_path}")"
iso_sha256="$(sha256sum "${iso_path}" | awk '{print $1}')"
printf '%s  %s\n' "${iso_sha256}" "$(basename "${iso_path}")" >"${log_dir}/sha256.txt"

echo "SUCCESS"
echo "ISO: ${iso_path}"
echo "Size: ${iso_size} bytes"
echo "SHA-256: ${iso_sha256}"
echo "Checksum file: ${log_dir}/sha256.txt"
