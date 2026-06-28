import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string label: ""
    property string leadingIcon: ""
    property string avatarSource: "" // 🖼️ New: Profile avatar support
    property string size: "m" // 🌟 MD3 Expressive: "xs" | "s" | "m" | "l" | "xl"
    property bool isEmphasized: false
    property bool selected: false
    property bool elevated: false

    signal clicked()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B"
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
    leftPadding: (selected || leadingIcon !== "" || avatarSource !== "" ? (size === "xl" ? 12 : 8) : (size === "xl" ? 24 : 12)) * themeGlobalScale
    rightPadding: (size === "xl" ? 24 : 12) * themeGlobalScale

    background: Rectangle {
        radius: (size === "xl" ? 16 : 8) * themeGlobalScale
        color: {
            if (!control.enabled) return "transparent"
            if (control.selected) return control.themeSecondaryContainer
            return control.elevated ? control.themeSurfaceContainerLow : "transparent"
        }
        border.color: {
            if (control.selected || control.elevated) return "transparent"
            return control.enabled ? control.themeOutline : Qt.rgba(control.themeOutline.r, control.themeOutline.g, control.themeOutline.b, 0.12)
        }
        border.width: (control.selected || control.elevated) ? 0 : 1 * themeGlobalScale

        // MD3 Elevation for 'elevated' type
        layer.enabled: control.elevated && !control.selected

        MeoStateLayer {
            radius: parent.radius
            pressed: mouseArea.pressed
            hovered: mouseArea.containsMouse
            color: control.selected ? control.themeOnSecondaryContainer : control.themeOnSurface
        }

        Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            control.selected = !control.selected
            control.clicked()
        }
    }

    contentItem: Row {
        id: contentRow
        spacing: (size === "xs" ? 4 : 8) * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter

        // 🖼️ Avatar Support
        Rectangle {
            width: (control.avatarSource !== "" && !control.selected) ? (size === "xl" ? 40 : 24) * control.themeGlobalScale : 0
            height: (size === "xl" ? 40 : 24) * control.themeGlobalScale
            radius: width / 2
            clip: true
            visible: width > 0
            anchors.verticalCenter: parent.verticalCenter
            Image {
                anchors.fill: parent
                source: control.avatarSource
                fillMode: Image.PreserveAspectCrop
            }
            Behavior on width { NumberAnimation { duration: 150 } }
        }

        // 🌟 Checkmark Animation
        Item {
            id: checkmarkContainer
            width: (control.selected || (control.leadingIcon !== "" && control.avatarSource === "")) ? (size === "xl" ? 32 : 18) * control.themeGlobalScale : 0
            height: (size === "xl" ? 32 : 18) * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            clip: true
            visible: width > 0

            Behavior on width {
                NumberAnimation {
                    duration: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionDurationShort3 : 150)
                    easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1])
                }
            }

            MeoIcon {
                anchors.centerIn: parent
                icon: control.selected ? "check" : control.leadingIcon
                size: {
                    if (size === "xs" || size === "s") return 18;
                    if (size === "xl") return 32;
                    return 24;
                }
                color: control.selected ? control.themePrimary : control.themeOnSurfaceVariant

                scale: control.selected || (control.leadingIcon !== "" && control.avatarSource === "") ? 1.0 : 0.5
                opacity: control.selected || (control.leadingIcon !== "" && control.avatarSource === "") ? 1.0 : 0.0

                Behavior on scale {
                    NumberAnimation {
                        duration: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionDurationShort3 : 150)
                        easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1])
                    }
                }
                Behavior on opacity {
                    NumberAnimation {
                        duration: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionDurationShort3 : 150)
                    }
                }
            }
        }

        Text {
            text: control.label
            font.pixelSize: fontToken.size * control.themeGlobalScale
            font.weight: fontToken.weight
            font.letterSpacing: (fontToken.letterSpacing || 0) * control.themeGlobalScale
            color: control.selected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
}
