#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/acceptance/65-capture-step.sh STEP_LABEL [QMP_SOCKET]

Capture an installer checkpoint. The retained PNG is stored beneath
validation/<UTC-run-id>/screenshots/; the intermediate PPM is disposable and
stored beneath tmp/<UTC-run-id>/.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac
[ "$#" -le 2 ] || { usage >&2; exit 2; }

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
tmp_dir="${MEOARCH_TMP_DIR:-${outputs_root}/tmp/${run_id}}"
evidence_dir="${run_dir}/vm"
label="${1:-}"
qmp_socket="${2:-}"

if [ -z "${qmp_socket}" ] && [ -f "${evidence_dir}/qmp-path.txt" ]; then
  qmp_socket="$(<"${evidence_dir}/qmp-path.txt")"
fi
qmp_socket="${qmp_socket:-${tmp_dir}/q/live/q}"

[ -n "${label}" ] || { echo "Usage: $0 STEP_LABEL [QMP_SOCKET]" >&2; exit 2; }
[ -S "${qmp_socket}" ] || { echo "QMP socket not found: ${qmp_socket}" >&2; exit 2; }

safe_label="$(printf '%s' "${label}" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-')"
safe_label="${safe_label#-}"
safe_label="${safe_label%-}"
[ -n "${safe_label}" ] || { echo "Step label contains no safe filename characters." >&2; exit 2; }

screenshot_dir="${run_dir}/screenshots/installer"
capture_dir="${tmp_dir}/capture"
mkdir -p "${screenshot_dir}" "${capture_dir}"
sequence="$(find "${screenshot_dir}" -maxdepth 1 -type f -name '*.png' | wc -l)"
sequence="$(printf '%02d' "$((sequence + 1))")"
ppm_path="${capture_dir}/${sequence}-${safe_label}.ppm"
png_path="${screenshot_dir}/${sequence}-${safe_label}.png"

python3 - "${qmp_socket}" "${ppm_path}" <<'PY'
import json
import socket
import sys

socket_path, screenshot_path = sys.argv[1:]
with socket.socket(socket.AF_UNIX, socket.SOCK_STREAM) as client:
    client.settimeout(5)
    client.connect(socket_path)
    stream = client.makefile("rwb", buffering=0)
    stream.readline()
    stream.write(json.dumps({"execute": "qmp_capabilities"}).encode() + b"\n")
    while True:
        response = json.loads(stream.readline())
        if "return" in response:
            break
        if "error" in response:
            raise SystemExit(response["error"])
    stream.write(json.dumps({
        "execute": "screendump",
        "arguments": {"filename": screenshot_path},
    }).encode() + b"\n")
    while True:
        response = json.loads(stream.readline())
        if "return" in response:
            break
        if "error" in response:
            raise SystemExit(response["error"])
PY

magick "${ppm_path}" "${png_path}"
rm "${ppm_path}"
printf '%s\n' "${png_path}"
