#!/usr/bin/env bash
# macOS local preview of the installer UI (mock controller, no VM). Extra args: --preview-installing / --preview-failed / --preview-complete
set -euo pipefail
REPO="$(cd "$(dirname "$0")/.." && pwd)"
MEOUI="${MEOUI_SOURCE_DIR:-$REPO/../MeoUI}"
B="${MEO_PREVIEW_BUILD:-$HOME/.cache/meoarch-preview}"
QT_PREFIX="$(dirname "$(dirname "$(command -v qmake6)")")"
if [ ! -f "$B/meoui/MeoUI/qmldir" ]; then
  cmake -S "$MEOUI" -B "$B/meoui" -G Ninja -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="$QT_PREFIX"
  cmake --build "$B/meoui"
fi
cat > "$B/PreviewMain.qml" <<QML
import QtQuick
import "file://$REPO/installer/qml" as I
I.Main { installerController: null; visualPreview: true }
QML
QT_QUICK_CONTROLS_STYLE=Basic exec qml -I "$REPO/installer/qml" -I "$B/meoui" "$B/PreviewMain.qml" -- "$@"
