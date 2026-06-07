import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string text: ""
    property string type: "standard" // "standard" | "emphasized"

    // 🌟 作用域与主题安全防御
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    implicitWidth: parent ? parent.width : 360 * themeGlobalScale
    implicitHeight: 40 * themeGlobalScale

    Text {
        anchors.fill: parent
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.rightMargin: 16 * control.themeGlobalScale
        text: control.text
        font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
        font.weight: fontLabelLarge.weight
        color: control.type === "emphasized" ? control.themePrimary : control.themeOnSurfaceVariant
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
