import QtQuick
import QtQuick.Controls

ToolTip {
    id: control

    // 🌟 作用域与主题安全防御
    readonly property color themeInverseSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined' && MeoTheme.isDarkMode) ? "#E6E1E5" : "#313033"
    readonly property color themeInverseOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined' && MeoTheme.isDarkMode) ? "#313033" : "#F4F0F4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    padding: 8 * themeGlobalScale

    contentItem: Text {
        text: control.text
        font.pixelSize: 12 * control.themeGlobalScale
        color: control.themeInverseOnSurface
    }

    background: Rectangle {
        color: control.themeInverseSurface
        radius: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeExtraSmall !== 'undefined') ? MeoTheme.shapeExtraSmall : 4 * control.themeGlobalScale
        // MD3 Elevation (Simplified)
        border.color: Qt.rgba(0,0,0,0.1)
        border.width: 0.5 * themeGlobalScale
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
    }
}
