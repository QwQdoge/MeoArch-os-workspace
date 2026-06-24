import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import MeoUI 1.0

pragma ComponentBehavior: Bound

Button {
    id: control

    // 🌟 核心开关
    property string type: "filled" // "filled" (默认) | "tonal" | "outlined" | "elevated" | "text"
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string shape: "round" // "round" | "square"
    property bool isEmphasized: false // MD3 Expressive: Use bold typography
    property bool loading: false // 🌟 MD3: Loading state with progress indicator
    property bool selected: false // 🌟 MD3: Toggle state support

    // Toggle Support
    checkable: false
    checked: false

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false

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

    readonly property color bgColor: {
        if (!control.enabled) {
            if (type === "outlined" || type === "text")
                return Qt.rgba(textColor.r, textColor.g, textColor.b, 0);
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        }

        let base;
        if (type === "filled") base = (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
        else if (type === "tonal") base = (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8";
        else if (type === "elevated") base = (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA";
        else base = Qt.rgba(0, 0, 0, 0);

        if (control.checked) {
            if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : base;
            if (type === "outlined") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : base;
        }
        return base;
    }

    readonly property real elevation: {
        if (!control.enabled || type === "text" || type === "outlined") return 0;
        if (type === "elevated") return control.pressed ? 2 : (control.hovered ? 2 : 1);
        if (type === "filled" || type === "tonal") return (control.pressed || control.checked) ? 0 : (control.hovered ? 1 : 0);
        return 0;
    }

    readonly property int iconSize: {
        if (size === "xs" || size === "s") return 18;
        if (size === "xl") return 32;
        return 24;
    }

    readonly property color textColor: {
        if (!control.enabled) {
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        }
        if (control.checked) {
             if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimaryContainer !== 'undefined') ? MeoTheme.onPrimaryContainer : "#21005D";
             if (type === "outlined") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B";
        }
        if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF";
        if (type === "tonal") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B";
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
    }

    leftPadding: {
        let base;
        if (size === "xs") base = 12;
        else if (size === "s") base = 16;
        else if (size === "l") base = 32;
        else if (size === "xl") base = 48;
        else base = 24;

        if (control.icon.name !== "" || control.icon.source.toString() !== "" || control.checked) return (base * 0.66) * MeoTheme.globalScale;
        return (control.type === "text" ? base * 0.5 : base) * MeoTheme.globalScale;
    }
    rightPadding: {
        let base;
        if (size === "xs") base = 12;
        else if (size === "s") base = 16;
        else if (size === "l") base = 32;
        else if (size === "xl") base = 48;
        else base = 24;
        return (control.type === "text" ? base * 0.5 : base) * MeoTheme.globalScale;
    }
    topPadding: 0
    bottomPadding: 0
    implicitHeight: {
        if (size === "xs") return MeoTheme.buttonHeightXS || 32 * MeoTheme.globalScale;
        if (size === "s") return MeoTheme.buttonHeightS || 40 * MeoTheme.globalScale;
        if (size === "l") return MeoTheme.buttonHeightL || 56 * MeoTheme.globalScale;
        if (size === "xl") return MeoTheme.buttonHeightXL || 72 * MeoTheme.globalScale;
        return MeoTheme.buttonHeightM || 48 * MeoTheme.globalScale;
    }

    contentItem: Item {
        implicitWidth: loading ? (iconSize + 6) * MeoTheme.globalScale : contentRow.implicitWidth
        implicitHeight: loading ? (iconSize + 6) * MeoTheme.globalScale : contentRow.implicitHeight

        Row {
            id: contentRow
            spacing: (size === "xs" ? 4 : 8) * MeoTheme.globalScale
            anchors.centerIn: parent
            opacity: control.loading ? 0.0 : 1.0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            MeoIcon {
                icon: control.checked ? "check" : (control.icon.name || control.icon.source.toString())
                visible: control.checked || control.icon.name !== "" || control.icon.source.toString() !== ""
                size: {
                    if (size === "xs" || size === "s") return 18;
                    if (size === "xl") return 32;
                    return 24;
                }
                color: control.textColor
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 150 } }

                Behavior on icon {
                    enabled: control.checkable
                    SequentialAnimation {
                        NumberAnimation { target: parent; property: "scale"; to: 0; duration: 100 }
                        PropertyAction { target: parent; property: "icon" }
                        NumberAnimation { target: parent; property: "scale"; to: 1; duration: 100 }
                    }
                }
            }

            Text {
                text: control.text
                font.pixelSize: fontToken.size * MeoTheme.globalScale
                font.weight: fontToken.weight
                font.letterSpacing: (fontToken.letterSpacing || 0) * MeoTheme.globalScale
                lineHeight: (fontToken.lineHeight ? (fontToken.lineHeight / fontToken.size) : 1.2)
                color: control.textColor
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        MeoProgressBar {
            type: "circular"
            indeterminate: true
            anchors.centerIn: parent
            width: (control.iconSize + 6) * MeoTheme.globalScale
            height: (control.iconSize + 6) * MeoTheme.globalScale
            visible: control.loading
            opacity: control.loading ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }
    }

    background: Rectangle {
        implicitWidth: Math.max((control.type === "text" ? 48 : 64) * MeoTheme.globalScale, contentItem.implicitWidth + leftPadding + rightPadding)
        implicitHeight: control.implicitHeight
        radius: {
            if (shape === "square") {
                if (size === "xs" || size === "s") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeMedium !== 'undefined') ? MeoTheme.shapeMedium : 12 * MeoTheme.globalScale;
                return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeLarge !== 'undefined') ? MeoTheme.shapeLarge : 16 * MeoTheme.globalScale;
            }
            return height / 2;
        }
        
        color: control.bgColor

        Behavior on radius {
            NumberAnimation { duration: 200; easing.bezierCurve: MeoTheme.motionEasingSoul }
        }

        // Surface Tint for Elevation
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: (control.type === "elevated" && typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceTint !== 'undefined') ? MeoTheme.surfaceTint(control.elevation) : "transparent"
            visible: control.type === "elevated"
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        MeoStateLayer {
            radius: parent.radius
            pressed: control.pressed
            hovered: control.hovered
            focused: control.visualFocus
            color: control.textColor
        }

        border.color: {
            if (control.type !== "outlined") return "transparent";
            if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
            if (control.activeFocus) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
            return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E";
        }
        border.width: (control.type === "outlined" && (control.activeFocus || control.selected)) ? 2 : (control.type === "outlined" ? 1 : 0)

        // Simplified Elevation Shadow
        layer.enabled: control.elevation > 0
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.2
            shadowVerticalOffset: control.elevation * MeoTheme.globalScale
            shadowColor: Qt.rgba(0,0,0,0.2)
        }

        Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on border.width { NumberAnimation { duration: 150 } }
        Behavior on radius { NumberAnimation { duration: 200; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
    }
}
