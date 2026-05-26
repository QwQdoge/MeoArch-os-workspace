import QtQuick
import QtQuick.Controls

Button {
    id: control

    // 🌟 核心属性
    // type: "standard" | "filled" | "tonal" | "outlined"
    property string type: "standard"
    property string icon: ""
    property bool selected: false
    property string selectedIcon: ""

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themeSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceVariant !== 'undefined') ? MeoTheme.surfaceVariant : "#E7E0EC"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 40 * themeGlobalScale
    implicitHeight: 40 * themeGlobalScale
    padding: 8 * themeGlobalScale

    background: Rectangle {
        radius: 20 * control.themeGlobalScale
        color: {
            if (!control.enabled) return isDarkMode ? Qt.rgba(1,1,1,0.12) : Qt.rgba(0,0,0,0.12)
            if (type === "filled") return control.selected ? control.themePrimary : control.themeSurfaceVariant
            if (type === "tonal") return control.selected ? control.themePrimary : control.themeSurfaceVariant
            return "transparent"
        }
        border.color: (type === "outlined") ? control.themeOutline : "transparent"
        border.width: (type === "outlined") ? 1 : 0

        // 🌟 状态层
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: {
                let overlay = (type === "filled" && control.selected) ? control.themeOnPrimary : control.themePrimary
                if (control.pressed) return Qt.rgba(overlay.r, overlay.g, overlay.b, 0.12)
                if (control.hovered) return Qt.rgba(overlay.r, overlay.g, overlay.b, 0.08)
                return "transparent"
            }
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    contentItem: Text {
        text: (control.selected && control.selectedIcon !== "") ? control.selectedIcon : control.icon
        font.pixelSize: 24 * control.themeGlobalScale
        color: {
            if (!control.enabled) return isDarkMode ? Qt.rgba(1,1,1,0.38) : Qt.rgba(0,0,0,0.38)
            if (type === "filled") return control.selected ? control.themeOnPrimary : control.themePrimary
            return control.selected ? control.themePrimary : control.themeOnSurfaceVariant
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
