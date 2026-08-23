#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${MEOARCH_RUN_DIR:-${repo_root}/artifacts/validation/test-runs/$(date -u +%Y%m%dT%H%M%SZ)}"
evidence_dir="${run_dir}/runtime"
mkdir -p "${evidence_dir}"
exec > >(tee "${evidence_dir}/component-build.log") 2>&1

"${repo_root}/scripts/build-installer-app.sh"
cmake --fresh -S "${repo_root}/../meo-kde/native/system" -B "${repo_root}/build/meo-system" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build "${repo_root}/build/meo-system" --parallel
runtime="${repo_root}/build/installer-runtime-root/usr"
library="${runtime}/lib/libmeoui.so.0.3.1"
plugin="${runtime}/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so"

[ -f "${library}" ]
[ -L "${runtime}/lib/libmeoui.so.0" ]
[ -f "${plugin}" ]
[ -f "${runtime}/lib/qt6/qml/MeoUI/qmldir" ]
[ -f "${runtime}/lib/qt6/qml/MeoUI/meoui_module.qmltypes" ]
[ -x "${runtime}/bin/meoarch-repair" ]
[ -f "${runtime}/lib/meoarch-repair/qml/Main.qml" ]
[ -x "${runtime}/lib/meoarch-repair/checks/all.sh" ]
readelf -d "${library}" | tee "${evidence_dir}/libmeoui-readelf.txt"
readelf -d "${plugin}" | tee "${evidence_dir}/plugin-readelf.txt"
readelf -d "${library}" | grep -q 'Library soname: \[libmeoui.so.0\]'
readelf -d "${plugin}" | grep -q 'Shared library: \[libmeoui.so.0\]'
qmllint_bin="$(command -v qmllint6 || true)"
if [ -z "${qmllint_bin}" ] && [ -x /usr/lib/qt6/bin/qmllint ]; then
  qmllint_bin=/usr/lib/qt6/bin/qmllint
fi
[ -n "${qmllint_bin}" ] || {
  echo "Qt 6 qmllint was not found; refusing to validate Qt 6 QML with a Qt 5 parser." >&2
  exit 2
}
"${qmllint_bin}" -I "${runtime}/lib/qt6/qml" -I "${repo_root}/build/meo-system/qml" \
  -I "${repo_root}/installer/qml" "${repo_root}/installer/qml/Main.qml" \
  "${repo_root}/repair/qml/Main.qml" \
  "${repo_root}/installer/qml/pages/NetworkPage.qml" "${repo_root}/installer/qml/pages/DiskSelectionPage.qml"

echo "PASS: component build and shared runtime" | tee "${evidence_dir}/status.txt"
