import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string label: ""
    property string icon: ""
    property string size: "m" // 🌟 MD3 Expressive: "xs" | "s" | "m" | "l" | "xl"
    property bool isEmphasized: false
    property string avatarSource: "" // 🖼️ New: Profile avatar support
    property bool elevated: false

    signal clicked()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontToken: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        let token;
        if (size === "xs") token = MeoTheme.labelSmall;
        else if (size === "s") token = MeoTheme.labelMedium;
        else if (size === "l") token = MeoTheme.titleSmall;
        else if (size === "xl") token = MeoTheme.titleMedium;
        else token = MeoTheme.labelLarge;

        if (isEmphasized) {
            if (size === "xs") return MeoTheme.labelSmallEmphasized || token;
            if (size === "s") return MeoTheme.labelMediumEmphasized || token;
            if (size === "l") return MeoTheme.titleSmallEmphasized || token;
            if (size === "xl") return MeoTheme.titleMediumEmphasized || token;
            return MeoTheme.labelLargeEmphasized || token;
        }
        return token;
    }

    implicitHeight: {
        if (size === "xs") return 24 * themeGlobalScale;
        if (size === "s") return 28 * themeGlobalScale;
        if (size === "m") return 32 * themeGlobalScale;
        if (size === "l") return 40 * themeGlobalScale;
        if (size === "xl") return 48 * themeGlobalScale;
        return 32 * themeGlobalScale;
    }
    implicitWidth: contentRow.implicitWidth + leftPadding + rightPadding

    padding: 0
    leftPadding: (icon !== "" || avatarSource !== "" ? (size === "xl" ? 16 : 8) : (size === "xl" ? 24 : 16)) * themeGlobalScale
    rightPadding: (size === "xl" ? 24 : 16) * themeGlobalScale

    background: Rectangle {
        radius: (size === "xl" ? 16 : 8) * themeGlobalScale
        color: control.elevated ? control.themeSurfaceContainerLow : "transparent"
        border.color: control.elevated ? "transparent" : (control.enabled ? control.themeOutline : Qt.rgba(control.themeOutline.r, control.themeOutline.g, control.themeOutline.b, 0.12))
        border.width: control.elevated ? 0 : 1 * themeGlobalScale

        // MD3 Elevation for 'elevated' variant
        layer.enabled: control.elevated && control.enabled
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.1
            shadowVerticalOffset: (control.pressed ? 1 : (control.hovered ? 2 : 1)) * themeGlobalScale
            shadowColor: Qt.rgba(0,0,0,0.2)
        }

        MeoStateLayer {
            radius: parent.radius
            pressed: mouseArea.pressed
            hovered: mouseArea.containsMouse
            color: control.themeOnSurface
        }

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.clicked()
    }

    contentItem: Row {
        id: contentRow
        spacing: (size === "xs" ? 4 : 8) * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter

        // 🖼️ Avatar Support
        Rectangle {
            width: (size === "xl" ? 40 : 24) * control.themeGlobalScale
            height: (size === "xl" ? 40 : 24) * control.themeGlobalScale
            radius: width / 2
            clip: true
            visible: control.avatarSource !== ""
            anchors.verticalCenter: parent.verticalCenter
            Image {
                anchors.fill: parent
                source: control.avatarSource
                fillMode: Image.PreserveAspectCrop
            }
        }

        MeoIcon {
            icon: control.icon
            visible: icon !== "" && control.avatarSource === ""
            size: {
                if (size === "xs" || size === "s") return 18;
                if (size === "xl") return 32;
                return 24;
            }
            color: control.themePrimary
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: control.label
            font.pixelSize: fontToken.size * control.themeGlobalScale
            font.weight: fontToken.weight
            font.letterSpacing: (fontToken.letterSpacing || 0) * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
