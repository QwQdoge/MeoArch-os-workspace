import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string text: ""
    property string type: "standard" // "standard" | "emphasized"
    property real topPadding: 0
    property real bottomPadding: 0
    property real leftPadding: 16 * themeGlobalScale
    property real rightPadding: 16 * themeGlobalScale

    // 🌟 作用域与主题安全防御
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    implicitWidth: parent ? parent.width : 360 * themeGlobalScale
    implicitHeight: 40 * themeGlobalScale + topPadding + bottomPadding

    Text {
        anchors.fill: parent
        anchors.leftMargin: control.leftPadding
        anchors.rightMargin: control.rightPadding
        anchors.topMargin: control.topPadding
        anchors.bottomMargin: control.bottomPadding
        text: control.text
        font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
        font.weight: fontLabelLarge.weight
        color: control.type === "emphasized" ? control.themePrimary : control.themeOnSurfaceVariant
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
