#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/acceptance/20-build-components.sh

Build ISO components and retain logs/status under
validation/<UTC-run-id>/runtime. The default run directory is global output.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  "")
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
projects_root="$(cd "${repo_root}/.." && pwd)"
default_outputs_root="${MEO_OUTPUT_ROOT:-${projects_root}/outputs}/meo-arch-os-workspace"
outputs_root="${MEOARCH_OUTPUT_ROOT:-${default_outputs_root}}"
if [ -n "${MEOARCH_RUN_DIR:-}" ]; then
  run_dir="${MEOARCH_RUN_DIR}"
else
  run_id="${MEOARCH_RUN_ID:-$(date -u +%Y-%m-%dT%H%M%SZ)-acceptance}"
  run_dir="${outputs_root}/validation/${run_id}"
fi
evidence_dir="${run_dir}/runtime"
mkdir -p "${evidence_dir}"
exec > >(tee "${evidence_dir}/component-build.log") 2>&1

"${repo_root}/scripts/build-installer-app.sh"
cmake --fresh -S "${repo_root}/../meo-kde/native/system" -B "${repo_root}/build/meo-system" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build "${repo_root}/build/meo-system" --parallel
runtime="${repo_root}/build/installer-runtime-root/usr"
library="${runtime}/lib/libmeoui.so.0"
plugin="${runtime}/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so"

[ -f "${library}" ]
[ -L "${runtime}/lib/libmeoui.so.0" ]
[ -f "${plugin}" ]
[ -f "${runtime}/lib/qt6/qml/MeoUI/qmldir" ]
[ -f "${runtime}/lib/qt6/qml/MeoUI/meoui_module.qmltypes" ]
[ -f "${repo_root}/build/meo-system/qml/Meo/System/qmldir" ]
[ -f "${repo_root}/build/meo-system/qml/Meo/System/plugins.qmltypes" ]
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
"${qmllint_bin}" -i "${repo_root}/build/meo-system/qml/Meo/System/qmldir" \
  -I "${runtime}/lib/qt6/qml" -I "${repo_root}/build/meo-system/qml" \
  -I "${repo_root}/installer/qml" "${repo_root}/installer/qml/Main.qml" \
  "${repo_root}/repair/qml/Main.qml" \
  "${repo_root}/installer/qml/pages/NetworkPage.qml" "${repo_root}/installer/qml/pages/DiskSelectionPage.qml"

echo "PASS: component build and shared runtime" | tee "${evidence_dir}/status.txt"
