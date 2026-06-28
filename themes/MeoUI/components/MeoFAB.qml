import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Button {
    id: control

    // 🌟 核心属性
    // type: "small" | "regular" (默认) | "large" | "extended"
    property string type: "regular"
    property bool collapsed: false // MD3 Expressive: Collapse extended FAB to circle
    icon.name: "add"

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimaryContainer !== 'undefined') ? MeoTheme.onPrimaryContainer : "#21005D"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

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

    implicitWidth: (type === "extended" && !collapsed) ? Math.max(80 * themeGlobalScale, contentRow.implicitWidth + 32 * themeGlobalScale) : size
    implicitHeight: size

    Behavior on implicitWidth { NumberAnimation { duration: 300; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }

    background: Rectangle {
        radius: control.radiusSize
        color: control.themePrimaryContainer

        // MD3 Elevation (Shadow)
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.2
            shadowVerticalOffset: (control.pressed ? 3 : (control.hovered ? 4 : 3)) * control.themeGlobalScale
            shadowColor: Qt.rgba(0,0,0,0.2)
        }

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
        anchors.centerIn: parent

        MeoIcon {
            icon: control.icon.name || control.icon.source.toString()
            size: (control.type === "large" ? 36 : 24)
            color: control.themeOnPrimaryContainer
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            id: labelText
            text: control.text
            visible: control.type === "extended" && control.text !== ""
            font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
            font.weight: fontLabelLarge.weight
            color: control.themeOnPrimaryContainer
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter

            opacity: (control.type === "extended" && !control.collapsed) ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 200 } }

            // Clip text when collapsing to avoid layout artifacts
            clip: true
            width: (control.type === "extended" && control.collapsed) ? 0 : implicitWidth
            Behavior on width { NumberAnimation { duration: 300; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
        }
    }
}
