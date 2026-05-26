import QtQuick
import QtQuick.Controls

Button {
    id: control

    // 🌟 核心属性
    // type: "small" | "regular" (默认) | "large" | "extended"
    property string type: "regular"
    property string icon: "+"

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimaryContainer !== 'undefined') ? MeoTheme.onPrimaryContainer : "#21005D"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // 📐 尺寸映射
    readonly property real size: {
        if (type === "small") return 40 * themeGlobalScale
        if (type === "large") return 96 * themeGlobalScale
        return 56 * themeGlobalScale // regular and extended
    }

    readonly property real radiusSize: {
        if (type === "small") return 12 * themeGlobalScale
        if (type === "large") return 28 * themeGlobalScale
        return 16 * themeGlobalScale
    }

    implicitWidth: type === "extended" ? Math.max(size, contentRow.implicitWidth + 32 * themeGlobalScale) : size
    implicitHeight: size

    background: Rectangle {
        radius: control.radiusSize
        color: control.themePrimaryContainer

        // MD3 Elevation (Shadow) - Simplified for QML without heavy effects
        border.color: Qt.rgba(0,0,0,0.05)
        border.width: 1

        // 🌟 状态层
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: {
                if (control.pressed) return Qt.rgba(control.themeOnPrimaryContainer.r, control.themeOnPrimaryContainer.g, control.themeOnPrimaryContainer.b, 0.12)
                if (control.hovered) return Qt.rgba(control.themeOnPrimaryContainer.r, control.themeOnPrimaryContainer.g, control.themeOnPrimaryContainer.b, 0.08)
                return "transparent"
            }
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    contentItem: Row {
        id: contentRow
        spacing: 8 * control.themeGlobalScale
        alignment: Qt.AlignCenter

        Text {
            text: control.icon
            font.pixelSize: (control.type === "large" ? 36 : 24) * control.themeGlobalScale
            color: control.themeOnPrimaryContainer
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: control.text
            visible: control.type === "extended" && control.text !== ""
            font.pixelSize: 14 * control.themeGlobalScale
            font.weight: Font.Medium
            color: control.themeOnPrimaryContainer
            verticalAlignment: Text.AlignVCenter
        }
    }
}
