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
cmake --fresh -S "${repo_root}/installer/live-system" \
  -B "${repo_root}/build/meo-system-live" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DMEO_KDE_SOURCE_DIR="${repo_root}/../meo-kde"
cmake --build "${repo_root}/build/meo-system-live" --parallel
runtime="${repo_root}/build/installer-runtime-root/usr"
library="${runtime}/lib/libmeoui.so.0"
plugin="${runtime}/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so"
live_system_plugin="${repo_root}/build/meo-system-live/qml/Meo/System/libmeosystemplugin.so"

[ -f "${library}" ]
[ -L "${runtime}/lib/libmeoui.so.0" ]
[ -f "${plugin}" ]
[ -f "${runtime}/lib/qt6/qml/MeoUI/qmldir" ]
[ -f "${runtime}/lib/qt6/qml/MeoUI/meoui_module.qmltypes" ]
# MeoCheckbox is implemented in QML, and Qt's generated module typeinfo is not
# a stable serialization of every property declared by QML-file types across
# Qt releases. Check the source contract here; the qmllint pass below then
# verifies that installer QML can actually consume controlled: true through
# the built MeoUI module.
grep -Fq 'property bool controlled: false' \
  "${repo_root}/../meo-ui/components/MeoCheckbox.qml" || {
    echo "MeoUI MeoCheckbox is missing the controlled property required by the installer." >&2
    exit 1
  }
[ -f "${repo_root}/build/meo-system/qml/Meo/System/qmldir" ]
[ -f "${repo_root}/build/meo-system/qml/Meo/System/plugins.qmltypes" ]
[ -f "${live_system_plugin}" ]
[ -f "${repo_root}/build/meo-system-live/qml/Meo/System/qmldir" ]
[ -x "${runtime}/bin/meoarch-repair" ]
[ -x "${runtime}/lib/meoarch-repair/meoarch-repair-privileged-service" ]
[ -x "${repo_root}/build/installer-host/meoarch-repair-ai-flow-smoke" ]
[ -x "${repo_root}/build/installer-host/meoarch-repair-core-contract-test" ]
[ -f "${runtime}/lib/meoarch-repair/qml/Main.qml" ]
[ -x "${runtime}/lib/meoarch-repair/checks/all.sh" ]
[ -x "${runtime}/lib/meoarch-repair/checks/audio.sh" ]
[ -x "${runtime}/lib/meoarch-repair/checks/display.sh" ]
[ -f "${runtime}/share/meoarch-repair/knowledge/manifest.json" ]
[ -f "${runtime}/share/polkit-1/actions/org.meo.repair.policy" ]
[ -f "${runtime}/share/dbus-1/system.d/org.meo.Repair1.conf" ]
[ -f "${runtime}/share/dbus-1/system-services/org.meo.Repair1.service" ]
[ -f "${runtime}/lib/systemd/system/meoarch-repair-privileged.service" ]
LD_LIBRARY_PATH="${runtime}/lib" "${runtime}/bin/meoarch-repair" --help \
  | grep -q '^MeoArch Quick Repair$'
audio_category="$(LD_LIBRARY_PATH="${runtime}/lib" "${runtime}/bin/meoarch-repair" \
  --classify='为什么没有声音？' | python -c 'import json,sys; print(json.load(sys.stdin)["category"])')"
display_category="$(LD_LIBRARY_PATH="${runtime}/lib" "${runtime}/bin/meoarch-repair" \
  --classify='第二个显示器连接了但不显示' | python -c 'import json,sys; print(json.load(sys.stdin)["category"])')"
[ "${audio_category}" = audio ]
[ "${display_category}" = display ]
LD_LIBRARY_PATH="${runtime}/lib" "${runtime}/bin/meoarch-repair" --questions=audio \
  | python -c 'import json,sys; d=json.load(sys.stdin); assert d["schema"] == "org.meo.repair-guided-questions/v1"; assert d["questions"]; assert all(q["label"] and len(q["options"]) == 2 for q in d["questions"])'
LD_LIBRARY_PATH="${runtime}/lib" "${runtime}/bin/meoarch-repair" --questions=display \
  | python -c 'import json,sys; d=json.load(sys.stdin); assert len(d["questions"]) == 3; assert all(len(q["options"]) == 2 for q in d["questions"])'
for category in all network boot packages storage graphics security; do
  LD_LIBRARY_PATH="${runtime}/lib" "${runtime}/bin/meoarch-repair" --questions="${category}" \
    | python -c 'import json,sys; d=json.load(sys.stdin); assert d["schema"] == "org.meo.repair-guided-questions/v1"; assert len(d["questions"]) >= 2; assert all(len(q["options"]) == 2 for q in d["questions"])'
done
LD_LIBRARY_PATH="${runtime}/lib" "${runtime}/bin/meoarch-repair" \
  --evaluate-guidance=display --answer=detected:no \
  | python -c 'import json,sys; d=json.load(sys.stdin); assert d["schema"] == "org.meo.repair-guidance-evaluation/v1"; assert d["automaticDisplayRepairAllowed"] is False; assert d["handoffMessage"]'
LD_LIBRARY_PATH="${runtime}/lib" "${runtime}/bin/meoarch-repair" \
  --evaluate-guidance=audio --answer=scope:one_app \
  | python -c 'import json,sys; d=json.load(sys.stdin); assert d["answers"]["scope"] == "one_app"; assert d["automaticAudioRepairAllowed"] is False; assert d["handoffMessage"]'
if unshare -Ur true >/dev/null 2>&1; then
  "${repo_root}/repair/tests/run-ai-write-flow-smoke.sh" \
    "${repo_root}/build/installer-host/meoarch-repair-ai-flow-smoke" \
    | tee "${evidence_dir}/repair-ai-flow-smoke.log"
else
  echo "SKIP: repair AI write-flow bubblewrap smoke requires user namespaces on the build host." \
    | tee "${evidence_dir}/repair-ai-flow-smoke.log"
fi
"${repo_root}/build/installer-host/meoarch-repair-core-contract-test" \
  | tee "${evidence_dir}/repair-core-contract.log"
# The following ABI assertions intentionally match stable readelf labels.
# Pin its locale so the validation result does not depend on the build host's
# language (for example, a zh_CN session localizes "Shared library").
LC_ALL=C readelf -d "${library}" | tee "${evidence_dir}/libmeoui-readelf.txt"
LC_ALL=C readelf -d "${plugin}" | tee "${evidence_dir}/plugin-readelf.txt"
LC_ALL=C readelf -d "${live_system_plugin}" | tee "${evidence_dir}/live-system-plugin-readelf.txt"
LC_ALL=C readelf -d "${library}" | grep -q 'Library soname: \[libmeoui.so.0\]'
LC_ALL=C readelf -d "${plugin}" | grep -q 'Shared library: \[libmeoui.so.0\]'
if grep -Eq 'Shared library: \[(libPlasma\.so\.7|libkrdb\.so)\]' \
  "${evidence_dir}/live-system-plugin-readelf.txt"; then
  echo "Live Meo.System must not depend on Plasma Workspace libraries." >&2
  exit 1
fi
qmllint_bin="$(command -v qmllint6 || true)"
if [ -z "${qmllint_bin}" ] && [ -x /usr/lib/qt6/bin/qmllint ]; then
  qmllint_bin=/usr/lib/qt6/bin/qmllint
fi
[ -n "${qmllint_bin}" ] || {
  echo "Qt 6 qmllint was not found; refusing to validate Qt 6 QML with a Qt 5 parser." >&2
  exit 2
}
mapfile -t installer_qml_files < <(find "${repo_root}/installer/qml" -type f -name '*.qml' -print | sort)
[ "${#installer_qml_files[@]}" -gt 0 ] || {
  echo "No installer QML files were found for validation." >&2
  exit 2
}
"${qmllint_bin}" -i "${repo_root}/build/meo-system/qml/Meo/System/qmldir" \
  -I "${runtime}/lib/qt6/qml" -I "${repo_root}/build/meo-system/qml" \
  -I "${repo_root}/installer/qml" \
  "${installer_qml_files[@]}" "${repo_root}/repair/qml/Main.qml"

echo "PASS: component build and shared runtime" | tee "${evidence_dir}/status.txt"
