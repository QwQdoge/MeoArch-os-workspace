import QtQuick
import QtQuick.Controls
import MeoUI

Button {
    id: control

    // 🌟 核心属性
    // type: "standard" | "filled" | "tonal" | "outlined"
    property string type: "standard"
    property bool selected: false
    property string selectedIcon: ""

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B"
    readonly property color themeSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceVariant !== 'undefined') ? MeoTheme.surfaceVariant : "#E7E0EC"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 40 * themeGlobalScale
    implicitHeight: 40 * themeGlobalScale
    padding: 8 * themeGlobalScale

    background: Rectangle {
        radius: 20 * control.themeGlobalScale
        color: {
            if (!control.enabled) return (type === "filled" || type === "tonal") ? (isDarkMode ? Qt.rgba(1,1,1,0.12) : Qt.rgba(0,0,0,0.12)) : "transparent"
            if (type === "filled") return control.selected ? control.themePrimary : control.themeSurfaceVariant
            if (type === "tonal") return control.selected ? control.themeSecondaryContainer : control.themeSurfaceVariant
            return "transparent"
        }
        border.color: (type === "outlined") ? control.themeOutline : "transparent"
        border.width: (type === "outlined") ? 1 : 0

        MeoStateLayer {
            radius: parent.radius
            pressed: control.pressed
            hovered: control.hovered
            color: {
                if (type === "filled" && control.selected) return control.themeOnPrimary
                if (type === "tonal" && control.selected) return control.themeOnSecondaryContainer
                return control.themePrimary
            }
        }

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    contentItem: MeoIcon {
        icon: (control.selected && control.selectedIcon !== "") ? control.selectedIcon : (control.icon.name || control.icon.source.toString())
        size: 24
        color: {
            if (!control.enabled) return isDarkMode ? Qt.rgba(1,1,1,0.38) : Qt.rgba(0,0,0,0.38)
            if (type === "filled") return control.selected ? control.themeOnPrimary : control.themePrimary
            if (type === "tonal") return control.selected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
            return control.selected ? control.themePrimary : control.themeOnSurfaceVariant
        }
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        Behavior on color { ColorAnimation { duration: 150 } }
    }
}
