#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${MEOARCH_RUN_DIR:-${repo_root}/artifacts/validation/test-runs/$(date -u +%Y%m%dT%H%M%SZ)}"
label="${1:-}"
qmp_socket="${2:-}"

if [ -z "${qmp_socket}" ] && [ -f "${run_dir}/vm/qmp-path.txt" ]; then
  qmp_socket="$(<"${run_dir}/vm/qmp-path.txt")"
fi
qmp_socket="${qmp_socket:-${run_dir}/vm/qmp.sock}"

[ -n "${label}" ] || { echo "Usage: $0 STEP_LABEL [QMP_SOCKET]" >&2; exit 2; }
[ -S "${qmp_socket}" ] || { echo "QMP socket not found: ${qmp_socket}" >&2; exit 2; }

safe_label="$(printf '%s' "${label}" | tr '[:upper:]' '[:lower:]' | tr -cs 'a-z0-9._-' '-')"
safe_label="${safe_label#-}"
safe_label="${safe_label%-}"
[ -n "${safe_label}" ] || { echo "Step label contains no safe filename characters." >&2; exit 2; }

screenshot_dir="${run_dir}/screenshots/installer"
mkdir -p "${screenshot_dir}"
sequence="$(find "${screenshot_dir}" -maxdepth 1 -type f -name '*.png' | wc -l)"
sequence="$(printf '%02d' "$((sequence + 1))")"
ppm_path="${screenshot_dir}/${sequence}-${safe_label}.ppm"
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
