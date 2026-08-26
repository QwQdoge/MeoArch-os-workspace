#!/usr/bin/env bash
set -Eeuo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
projects_root="$(cd "${repo_root}/.." && pwd)"
# Persistent releases and validation evidence are centralized by project.
# Reproducible ArchISO working state still stays under this checkout's build/.
default_outputs_root="${MEO_OUTPUT_ROOT:-${projects_root}/outputs}/meo-arch-os-workspace"
outputs_root="${MEOARCH_OUTPUT_ROOT:-${default_outputs_root}}"
source_profile="${repo_root}/meoarch-os"
build_root="${repo_root}/build/archiso"
work_dir="${build_root}/work"
staged_profile="${build_root}/profile"
baseline_profile="${build_root}/baseline-profile"
out_dir="${outputs_root}/packages/iso"
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

command -v flock >/dev/null 2>&1 || {
  echo "Missing required tool: flock" >&2
  exit 127
}
mkdir -p "${repo_root}/build"
iso_lock_path="${repo_root}/build/.meoarch-iso-build.lock"
exec {iso_lock_fd}>"${iso_lock_path}"
if ! flock -n "${iso_lock_fd}"; then
  echo "Another MeoArch ISO build owns ${iso_lock_path}; refusing concurrent staging/work mutation." >&2
  exit 75
fi
printf 'pid=%s\nstarted_utc=%s\n' "$$" "$(date -u +%FT%TZ)" 1>&"${iso_lock_fd}"

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
  "${projects_root}/meo-ui/CMakeLists.txt"; do
  [ -f "${required}" ] || {
    echo "Required project file is missing: ${required}" >&2
    exit 3
  }
done

# The profile itself must be a version-controlled baseline.  Runtime payloads
# are injected later by sync-installer-to-airootfs.sh and recorded by the
# provenance gate; ignored leftovers in airootfs must never become ISO input.
if git status --porcelain --untracked-files=all -- "${source_profile}" | grep -q .; then
  echo "The ArchISO profile has uncommitted files. Refuse an ambiguous candidate; stage or resolve them first." >&2
  exit 7
fi

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

run_id="$(date -u +%Y-%m-%dT%H%M%SZ)-iso-build"
log_dir="${outputs_root}/validation/${run_id}/logs"
mkdir -p "${log_dir}" "${build_root}" "${out_dir}"
log_file="${log_dir}/build-iso.log"
exec > >(tee -a "${log_file}") 2>&1

echo "MeoArch ISO build"
echo "Git commit: $(git -C "${repo_root}" rev-parse HEAD)"
echo "Profile: ${source_profile}"
echo "Output directory: ${out_dir}"
echo "Log: ${log_file}"

for profile_dir in "${baseline_profile}" "${staged_profile}"; do
  if [ -e "${profile_dir}" ]; then
    find "${profile_dir}" -mindepth 1 -delete
  else
    mkdir -p "${profile_dir}"
  fi
done
git archive --format=tar HEAD meoarch-os | tar -x -C "${baseline_profile}" --strip-components=1
cp -a "${baseline_profile}/." "${staged_profile}/"
sed -i -e "s/iso_version=\".*\"/iso_version=\"$(date -u +%Y.%m.%d-%H%M%S)\"/g" "${staged_profile}/profiledef.sh"

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

MEOARCH_AIROOTFS="${staged_profile}/airootfs" \
  "${repo_root}/scripts/sync-installer-to-airootfs.sh"
"${repo_root}/scripts/verify-staging-provenance.sh" \
  "${baseline_profile}" "${staged_profile}" "${log_dir}/staging-provenance.tsv"

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
  iso_path="$(find "${out_dir}" -maxdepth 1 -type f -name '*.iso' -printf '%T@ %p\n' | sort -n | tail -n 1 | cut -d' ' -f2-)"
fi

if [ -z "${iso_path}" ]; then
  echo "mkarchiso returned successfully but no ISO was found in ${out_dir}." >&2
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
