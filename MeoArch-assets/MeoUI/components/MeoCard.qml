import QtQuick
import QtQuick.Controls

Frame {
    id: control

    // 🌟 核心属性
    // type: "elevated" | "filled" | "outlined"
    property string type: "elevated"
    property real radius: 12 * themeGlobalScale

    // MD3 Elevation (Simplified)
    readonly property var elevationShadow: {
        if (type !== "elevated") return { "color": "#00000000", "blur": 0, "y": 0 }
        return { "color": Qt.rgba(0,0,0,0.15), "blur": 3, "y": 1 }
    }

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceVariant !== 'undefined') ? MeoTheme.surfaceVariant : "#E7E0EC"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    padding: 16 * themeGlobalScale

    background: Rectangle {
        radius: control.radius
        color: {
            if (type === "filled") return control.themeSurfaceVariant
            if (type === "elevated") return control.themeSurfaceContainerLow
            return control.themeSurface // outlined
        }

        border.color: control.type === "outlined" ? control.themeOutlineVariant : "transparent"
        border.width: control.type === "outlined" ? 1 : 0

        // MD3 Elevation for 'elevated' type
        layer.enabled: control.type === "elevated"

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
