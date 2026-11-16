#!/usr/bin/env bash
# macOS local preview of the Quick Repair / AI help UI (stub controller, no VM).
# Optional env: SHOT=/path/out.png (screenshot and exit), STAGE=repair-approval, CATEGORY=audio|display|network|..., SIMPLE=1 (wizard/simple mode instead of advanced overview)
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
STUB="$REPO/scripts/mac-preview"
B="${MEO_PREVIEW_BUILD:-$HOME/.cache/meoarch-preview}"
MEOUI="${MEOUI_SOURCE_DIR:-$REPO/../MeoUI}"
QT_PREFIX="$(dirname "$(dirname "$(command -v qmake6)")")"
if [ ! -f "$B/meoui/MeoUI/qmldir" ]; then
  cmake -S "$MEOUI" -B "$B/meoui" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$QT_PREFIX"
  cmake --build "$B/meoui"
fi
mkdir -p "$B/repair"
sed -e "s#@REPAIR_QML@#$REPO/repair/qml#" -e "s#@SHOT@#${SHOT:-}#" -e "s#@ADV@#$([ -n "${SIMPLE:-}" ] && echo false || echo true)#" -e "s#@STAGE@#${STAGE:-}#" -e "s#@CATEGORY@#${CATEGORY:-all}#" "$STUB/PreviewRepair.qml" > "$B/repair/PreviewRepair.qml"
cp "$STUB/RepairControllerStub.qml" "$B/repair/"
QT_QUICK_CONTROLS_STYLE=Basic exec qml -I "$REPO/repair/qml" -I "$STUB" -I "$B/meoui" "$B/repair/PreviewRepair.qml"
