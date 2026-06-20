import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import MeoUI 1.0

pragma ComponentBehavior: Bound

Button {
    id: control

    // 🌟 核心开关
    property string type: "filled" // "filled" (默认) | "tonal" | "outlined" | "elevated" | "text"
    property string size: "s" // "xs" | "s" | "m" | "l" | "xl"
    property string shape: "round" // "round" | "square"
    property bool isEmphasized: false // MD3 Expressive: Use bold typography
    property bool loading: false // 🌟 MD3: Loading state with progress indicator
    property bool selected: false // 🌟 MD3: Toggle state support

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false

    // 📐 尺寸映射 (MD3 Expressive)
    readonly property real containerHeight: {
        if (size === "xs") return 32
        if (size === "m") return 48
        if (size === "l") return 56
        if (size === "xl") return 72
        return 40 // default "s"
    }

    readonly property real iconSize: {
        if (size === "xs" || size === "s") return 18
        if (size === "m" || size === "l") return 24
        if (size === "xl") return 32
        return 18
    }

    readonly property var fontRole: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        let role;
        if (size === "xs") role = isEmphasized ? MeoTheme.labelSmallEmphasized : MeoTheme.labelSmall;
        else if (size === "m") role = isEmphasized ? MeoTheme.titleSmallEmphasized : MeoTheme.titleSmall;
        else if (size === "l" || size === "xl") role = isEmphasized ? MeoTheme.titleMediumEmphasized : MeoTheme.titleMedium;
        else role = isEmphasized ? MeoTheme.labelLargeEmphasized : MeoTheme.labelLarge; // default "s"
        return role || { "size": 14, "weight": Font.Medium };
    }

    readonly property real cornerRadius: {
        if (shape === "round") return (containerHeight * MeoTheme.globalScale) / 2;
        // Square shape uses theme tokens
        if (size === "xs" || size === "s") return (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeMedium : 12 * MeoTheme.globalScale);
        return (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeLarge : 16 * MeoTheme.globalScale);
    }

    readonly property color bgColor: {
        if (!control.enabled) {
            if (type === "outlined" || type === "text")
                return Qt.rgba(textColor.r, textColor.g, textColor.b, 0);
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        }

        if (selected) {
            // Toggle Selected State (Usually Primary/Secondary Container)
            if (type === "outlined" || type === "text") return (typeof MeoTheme !== 'undefined' ? MeoTheme.secondaryContainer : "#E8DEF8");
            return (typeof MeoTheme !== 'undefined' ? MeoTheme.primary : "#6750A4");
        }

        if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
        if (type === "tonal") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8";
        if (type === "elevated") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA";
        return Qt.rgba(textColor.r, textColor.g, textColor.b, 0);
    }

    readonly property real elevation: {
        if (!control.enabled || type === "text" || type === "outlined") return 0;
        if (type === "elevated") return (control.pressed || control.hovered) ? 2 : 1;
        if (type === "filled" || type === "tonal") return control.pressed ? 0 : (control.hovered ? 1 : 0);
        return 0;
    }

    readonly property color textColor: {
        if (!control.enabled) {
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        }

        if (selected) {
             if (type === "outlined" || type === "text") return (typeof MeoTheme !== 'undefined' ? MeoTheme.onSecondaryContainer : "#1D192B");
             return (typeof MeoTheme !== 'undefined' ? MeoTheme.onPrimary : "#FFFFFF");
        }

        if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF";
        if (type === "tonal") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B";
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
    }

    leftPadding: {
        let base = (control.icon.name !== "" || control.icon.source.toString() !== "") ? 16 : (control.type === "text" ? 12 : 24);
        if (size === "xs") base *= 0.75;
        if (size === "xl") base *= 1.5;
        return base * MeoTheme.globalScale;
    }
    rightPadding: {
        let base = (control.type === "text" ? 12 : 24);
        if (size === "xs") base *= 0.75;
        if (size === "xl") base *= 1.5;
        return base * MeoTheme.globalScale;
    }
    topPadding: 0
    bottomPadding: 0
    implicitHeight: containerHeight * MeoTheme.globalScale

    contentItem: Item {
        implicitWidth: loading ? (iconSize + 6) * MeoTheme.globalScale : contentRow.implicitWidth
        implicitHeight: loading ? (iconSize + 6) * MeoTheme.globalScale : contentRow.implicitHeight

        Row {
            id: contentRow
            spacing: 8 * MeoTheme.globalScale
            anchors.centerIn: parent
            opacity: control.loading ? 0.0 : 1.0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: 150 } }

            MeoIcon {
                icon: control.icon.name || control.icon.source.toString()
                visible: control.icon.name !== "" || control.icon.source.toString() !== ""
                size: control.iconSize
                color: control.textColor
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                text: control.text
                font.pixelSize: fontRole.size * MeoTheme.globalScale
                font.weight: fontRole.weight
                font.letterSpacing: (fontRole.letterSpacing || 0) * MeoTheme.globalScale
                lineHeight: (fontRole.lineHeight ? (fontRole.lineHeight / fontRole.size) : 1.2)
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
        implicitHeight: control.containerHeight * MeoTheme.globalScale
        radius: control.cornerRadius
        
        color: control.bgColor

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

        Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1] } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on border.width { NumberAnimation { duration: 150 } }
        Behavior on radius { NumberAnimation { duration: 200; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
    }
}
