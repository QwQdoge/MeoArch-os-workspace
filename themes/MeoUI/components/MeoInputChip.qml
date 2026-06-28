import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string label: ""
    property string avatarSource: ""
    property string leadingIcon: ""
    property string size: "m" // 🌟 MD3 Expressive: "xs" | "s" | "m" | "l" | "xl"
    property bool isEmphasized: false
    property bool selected: false

    signal clicked()
    signal deleted()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B"
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

    leftPadding: (avatarSource !== "" || leadingIcon !== "" ? 4 : (size === "xl" ? 24 : 12)) * themeGlobalScale
    rightPadding: (size === "xl" ? 16 : 8) * themeGlobalScale

    background: Rectangle {
        radius: (size === "xl" ? 16 : 8) * themeGlobalScale
        color: control.selected ? control.themeSecondaryContainer : "transparent"
        border.color: control.selected ? "transparent" : (control.enabled ? control.themeOutline : Qt.rgba(control.themeOutline.r, control.themeOutline.g, control.themeOutline.b, 0.12))
        border.width: control.selected ? 0 : 1 * themeGlobalScale

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
        onClicked: control.clicked()
    }

    contentItem: Row {
        id: contentRow
        spacing: (size === "xs" ? 4 : 8) * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter

        // Avatar or Leading Icon
        Item {
            width: (avatarSource !== "" || leadingIcon !== "") ? (size === "xl" ? 40 : 24) * control.themeGlobalScale : 0
            height: (size === "xl" ? 40 : 24) * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            visible: width > 0

            // Using a simple Rectangle for circle crop in QML
            Rectangle {
                anchors.fill: parent
                radius: width / 2
                color: "transparent"
                clip: true
                visible: control.avatarSource !== ""

                Image {
                    source: control.avatarSource
                    anchors.fill: parent
                }
            }

            MeoIcon {
                visible: control.avatarSource === "" && control.leadingIcon !== ""
                icon: control.leadingIcon
                size: {
                    if (size === "xs" || size === "s") return 18;
                    if (size === "xl") return 32;
                    return 24;
                }
                color: control.selected ? control.themePrimary : control.themeOnSurfaceVariant
                anchors.centerIn: parent
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
        }

        // Delete Icon
        MeoIconButton {
            icon.name: "close"
            width: (size === "xl" ? 32 : 18) * control.themeGlobalScale
            height: (size === "xl" ? 32 : 18) * control.themeGlobalScale
            padding: 2 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            onClicked: control.deleted()

            // Customizing internal MeoIcon for the delete button
            contentItem: MeoIcon {
                icon: "close"
                size: {
                    if (size === "xs" || size === "s") return 18;
                    if (size === "xl") return 32;
                    return 24;
                }
                color: control.selected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
            }
            background: null
        }
    }
}
