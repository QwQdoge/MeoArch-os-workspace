import QtQuick
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string text: ""
    property bool emphasized: false

    // 🌟 作用域与主题安全防御
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelMedium !== 'undefined') ? MeoTheme.labelMedium : { "size": 12, "weight": Font.Medium }

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 48 * themeGlobalScale

    Text {
        anchors.fill: parent
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.rightMargin: 16 * control.themeGlobalScale
        text: control.text
        font.pixelSize: fontLabelMedium.size * control.themeGlobalScale
        font.weight: emphasized ? Font.Bold : fontLabelMedium.weight
        color: emphasized ? control.themePrimary : control.themeOnSurfaceVariant
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight
    }
}
