#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${MEOARCH_RUN_DIR:-${repo_root}/artifacts/test-runs/$(date -u +%Y%m%dT%H%M%SZ)}"
evidence_dir="${run_dir}/runtime"
mkdir -p "${evidence_dir}"
exec > >(tee "${evidence_dir}/component-build.log") 2>&1

"${repo_root}/scripts/build-installer-app.sh"
runtime="${repo_root}/build/installer-runtime-root/usr"
library="${runtime}/lib/libmeoui.so.0.3.1"
plugin="${runtime}/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so"

[ -f "${library}" ]
[ -L "${runtime}/lib/libmeoui.so.0" ]
[ -f "${plugin}" ]
[ -f "${runtime}/lib/qt6/qml/MeoUI/qmldir" ]
[ -f "${runtime}/lib/qt6/qml/MeoUI/meoui_module.qmltypes" ]
readelf -d "${library}" | tee "${evidence_dir}/libmeoui-readelf.txt"
readelf -d "${plugin}" | tee "${evidence_dir}/plugin-readelf.txt"
readelf -d "${library}" | grep -q 'Library soname: \[libmeoui.so.0\]'
readelf -d "${plugin}" | grep -q 'Shared library: \[libmeoui.so.0\]'

echo "PASS: component build and shared runtime" | tee "${evidence_dir}/status.txt"
