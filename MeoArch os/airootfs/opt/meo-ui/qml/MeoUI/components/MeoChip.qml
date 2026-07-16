import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    // type: "assist" | "filter" | "input" | "suggestion"
    property string type: "assist"
    property string label: ""
    property string icon: ""
    property string size: "m" // 🌟 MD3 Expressive: "xs" | "s" | "m" | "l" | "xl"
    property bool selected: false
    property bool closable: false
    property bool isEmphasized: false // MD3 Expressive: Use bold typography
    property real contentSpacing: (size === "xs" ? 4 : 8) * themeGlobalScale
    property color selectedContainerColor: themeSecondaryContainer
    property color selectedContentColor: themeOnSecondaryContainer
    property color contentColor: selected ? selectedContentColor : themeOnSurfaceVariant
    property color outlineColor: themeOutline

    signal clicked()
    signal closed()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationFast !== "undefined") ? MeoTheme.motionDurationFast : 150
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
        if (size === "xs") return 32 * themeGlobalScale;
        if (size === "s") return 32 * themeGlobalScale;
        if (size === "m") return 32 * themeGlobalScale;
        if (size === "l") return 40 * themeGlobalScale;
        if (size === "xl") return 48 * themeGlobalScale;
        return 32 * themeGlobalScale;
    }
    implicitWidth: contentRow.implicitWidth + leftPadding + rightPadding
    activeFocusOnTab: enabled
    Accessible.role: Accessible.Button
    Accessible.name: label
    Accessible.checkable: type === "filter"
    Accessible.checked: selected
    Accessible.onPressAction: control.clicked()
    Keys.onReturnPressed: control.clicked()
    Keys.onEnterPressed: control.clicked()
    Keys.onSpacePressed: control.clicked()

    padding: 0
    leftPadding: (icon !== "" ? 8 : (size === "xl" ? 24 : 16)) * themeGlobalScale
    rightPadding: (closable ? 8 : (size === "xl" ? 24 : 16)) * themeGlobalScale
    opacity: enabled ? 1.0 : 0.62
    scale: (enabled && mouseArea.pressed && MeoTheme.isExpressive) ? 0.98 : 1.0
    Behavior on scale { NumberAnimation { duration: control.motionFast; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
    Behavior on opacity { NumberAnimation { duration: control.motionFast } }

    background: Rectangle {
        radius: (size === "xl" ? 16 : 8) * themeGlobalScale
        color: control.selected ? control.selectedContainerColor : "transparent"
        border.color: {
            if (control.selected) return "transparent"
            if (!control.enabled) return Qt.rgba(control.outlineColor.r, control.outlineColor.g, control.outlineColor.b, 0.12)
            if (control.activeFocus) return control.themePrimary
            return control.outlineColor
        }
        border.width: (control.activeFocus && !control.selected) ? 2 * themeGlobalScale : 1 * themeGlobalScale

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            enabled: control.enabled
            onClicked: {
                control.forceActiveFocus(Qt.MouseFocusReason)
                control.clicked()
            }
        }

        MeoStateLayer {
            anchors.fill: parent
            radius: parent.radius
            shape: "rect"
            pressed: mouseArea.pressed
            hovered: mouseArea.containsMouse
            focused: control.visualFocus
            pressX: mouseArea.mouseX
            pressY: mouseArea.mouseY
            color: control.selected ? control.selectedContentColor : control.themeOnSurface
        }

        Behavior on color { ColorAnimation { duration: control.motionFast } }
    }

    contentItem: Row {
        id: contentRow
        spacing: control.contentSpacing
        anchors.verticalCenter: parent.verticalCenter

        MeoIcon {
            icon: control.icon
            fill: control.selected
            visible: icon !== ""
            size: {
                if (size === "xs" || size === "s") return 18;
                if (size === "xl") return 32;
                return 24;
            }
            color: control.contentColor
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: control.label
            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
            font.pixelSize: fontToken.size * control.themeGlobalScale
            font.weight: fontToken.weight
            font.letterSpacing: (fontToken.letterSpacing || 0) * control.themeGlobalScale
            lineHeightMode: Text.FixedHeight
            lineHeight: fontToken.lineHeight ? fontToken.lineHeight * control.themeGlobalScale : font.pixelSize * 1.2
            color: control.contentColor
            verticalAlignment: Text.AlignVCenter
        }

        Item {
            visible: control.closable
            width: (size === "xl" ? 32 : 18) * control.themeGlobalScale
            height: width
            anchors.verticalCenter: parent.verticalCenter

            MeoIcon {
                anchors.centerIn: parent
                icon: "close"
                size: control.size === "xl" ? 24 : 18
                color: control.contentColor
            }
            MouseArea {
                anchors.fill: parent
                enabled: control.enabled
                onClicked: control.closed()
            }
        }
    }
}
