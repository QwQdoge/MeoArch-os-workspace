import QtQuick
import MeoUI 1.0 as Meo

Meo.MeoButton {
    id: control
    property string kind: "filled"
    property real minWidth: 96
    property bool busy: false
    type: kind
    size: "m"
    isEmphasized: kind === "filled"
    loading: busy
    implicitWidth: Math.max(minWidth, contentItem.implicitWidth + leftPadding + rightPadding)
}
