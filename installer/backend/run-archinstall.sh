#!/usr/bin/env bash
set -euo pipefail

state_dir="${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}"
generated_dir="${state_dir}/generated"
log_dir="${state_dir}/logs"
log_file="${log_dir}/install.log"
confirm_file="${state_dir}/summary_confirmed"

mkdir -p "${log_dir}"

if [ ! -f "${confirm_file}" ]; then
  echo "Summary has not been confirmed; refusing to call archinstall." | tee -a "${log_file}" >&2
  exit 3
fi

config_file="${generated_dir}/user_configuration.json"
creds_file="${generated_dir}/user_credentials.json"

if [ ! -f "${config_file}" ] || [ ! -f "${creds_file}" ]; then
  echo "Generated archinstall config files are missing." | tee -a "${log_file}" >&2
  exit 4
fi

manifest_file="${state_dir}/config_manifest.json"
if [ ! -f "${manifest_file}" ] || ! python3 -c 'import json,sys; sys.exit(0 if json.load(open(sys.argv[1], encoding="utf-8")).get("realInstallReady") else 1)' "${manifest_file}"; then
  echo "Generated configuration is preview-only; refusing real installation." | tee -a "${log_file}" >&2
  exit 5
fi

if ! command -v archinstall >/dev/null 2>&1; then
  echo "archinstall is not available." | tee -a "${log_file}" >&2
  exit 127
fi

echo "Starting archinstall with generated MeoArch JSON." | tee -a "${log_file}"
archinstall --config "${config_file}" --creds "${creds_file}" 2>&1 | tee -a "${log_file}"
