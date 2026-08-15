#!/usr/bin/env bash
set -euo pipefail

state_dir="${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}"
log_dir="${state_dir}/logs"
reference_dir="${state_dir}/archinstall-reference"
status_file="${state_dir}/preflight_status.json"
log_file="${log_dir}/archinstall-dry-run.log"

mkdir -p "${log_dir}" "${reference_dir}"

json_escape() {
  printf '%s' "$1" | sed 's/\\/\\\\/g; s/"/\\"/g'
}

write_status() {
  local state="$1"
  local message="$2"
  local code="${3:-0}"
  cat >"${status_file}" <<EOF
{
  "state": "$(json_escape "${state}")",
  "message": "$(json_escape "${message}")",
  "exitCode": ${code},
  "log": "$(json_escape "${log_file}")",
  "referenceDir": "$(json_escape "${reference_dir}")"
}
EOF
}

copy_reference_configs() {
  local source_dir="/var/log/archinstall"
  for name in user_configuration.json user_credentials.json user_disk_layouts.json user_disk_layout.json; do
    if [ -f "${source_dir}/${name}" ]; then
      cp -f "${source_dir}/${name}" "${reference_dir}/${name}"
    fi
  done
}

write_status "starting" "Preparing archinstall dry-run preflight." 0

if ! command -v archinstall >/dev/null 2>&1; then
  write_status "missing" "archinstall is not available in this environment." 127
  exit 0
fi

archinstall --version >"${log_file}" 2>&1 || true
config_file="${state_dir}/generated/user_configuration.json"
creds_file="${state_dir}/generated/user_credentials.json"
if [ ! -f "${config_file}" ] || [ ! -f "${creds_file}" ]; then
  write_status "waiting" "Generate the MeoArch installation plan before running preflight." 0
  exit 0
fi

# A carrier/link-local interface is not proof that Arch packages are reachable.
# The test is intentionally independent of the UI and runs in this background
# preflight process, never in the QML GUI thread.
mirror_probe="https://geo.mirror.pkgbuild.com/core/os/x86_64/core.db"
if ! getent ahosts geo.mirror.pkgbuild.com >/dev/null 2>&1; then
  write_status "failed" "DNS cannot resolve an Arch mirror. Connect to the Internet and retry." 20
  exit 0
fi
if ! command -v curl >/dev/null 2>&1; then
  write_status "missing" "curl is unavailable; Internet reachability cannot be verified safely." 127
  exit 0
fi
if ! curl --fail --silent --show-error --location --max-time 20 --head "${mirror_probe}" >>"${log_file}" 2>&1; then
  write_status "failed" "An Arch mirror is not reachable. Check the Internet connection and retry." 21
  exit 0
fi

write_status "running" "Running a silent archinstall dry-run in the background." 0

set +e
if command -v timeout >/dev/null 2>&1; then
  timeout 120s archinstall --silent --dry-run --config "${config_file}" --creds "${creds_file}" >>"${log_file}" 2>&1 </dev/null
  rc=$?
else
  archinstall --silent --dry-run --config "${config_file}" --creds "${creds_file}" >>"${log_file}" 2>&1 </dev/null
  rc=$?
fi
set -e

copy_reference_configs

case "${rc}" in
  0)
    write_status "complete" "archinstall dry-run completed. Reference JSON files were copied when available." 0
    ;;
  124)
    write_status "timeout" "archinstall dry-run timed out; use the saved log and run it manually for a full reference." 124
    ;;
  *)
    write_status "failed" "archinstall dry-run exited early; this is acceptable before the real UI choices exist." "${rc}"
    ;;
esac

exit 0
