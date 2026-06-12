import QtQuick 2.15
import QtQuick.Controls 2.15
import Qt5Compat.GraphicalEffects 1.15
import MeoUI 1.0
pragma ComponentBehavior: Bound
Button {
    id: control

    // 🌟 核心开关
    property string type: "filled" // "filled" (默认) | "tonal" | "outlined" | "elevated" | "text"
    property bool isEmphasized: false // MD3 Expressive: Use bold typography

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false

    readonly property var fontLabelLarge: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        return isEmphasized ? (MeoTheme.labelLargeEmphasized || MeoTheme.labelLarge) : MeoTheme.labelLarge;
    }

    readonly property color bgColor: {
        if (!control.enabled) {
            if (type === "outlined" || type === "text")
                return Qt.rgba(textColor.r, textColor.g, textColor.b, 0);
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        }
        if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
        if (type === "tonal") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8";
        if (type === "elevated") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA";
        return Qt.rgba(textColor.r, textColor.g, textColor.b, 0);
    }

    readonly property real elevation: {
        if (!control.enabled || type === "text" || type === "outlined") return 0;
        if (type === "elevated") return control.pressed ? 2 : (control.hovered ? 2 : 1);
        if (type === "filled" || type === "tonal") return control.pressed ? 0 : (control.hovered ? 1 : 0);
        return 0;
    }

    readonly property color textColor: {
        if (!control.enabled) {
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        }
        if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF";
        if (type === "tonal") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B";
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
    }

    leftPadding: {
        if (control.icon.name !== "" || control.icon.source.toString() !== "") return 16 * MeoTheme.globalScale;
        return (control.type === "text" ? 12 : 24) * MeoTheme.globalScale;
    }
    rightPadding: (control.type === "text" ? 12 : 24) * MeoTheme.globalScale
    topPadding: 0
    bottomPadding: 0
    implicitHeight: 40 * MeoTheme.globalScale

    contentItem: Row {
        spacing: 8 * MeoTheme.globalScale
        anchors.centerIn: parent

        MeoIcon {
            icon: control.icon.name || control.icon.source.toString()
            visible: control.icon.name !== "" || control.icon.source.toString() !== ""
            size: 18
            color: control.textColor
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Text {
            text: control.text
            font.pixelSize: fontLabelLarge.size * MeoTheme.globalScale
            font.weight: fontLabelLarge.weight
            font.letterSpacing: (fontLabelLarge.letterSpacing || 0) * MeoTheme.globalScale
            lineHeight: (fontLabelLarge.lineHeight ? (fontLabelLarge.lineHeight / fontLabelLarge.size) : 1.2)
            color: control.textColor
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    background: Rectangle {
        implicitWidth: Math.max((control.type === "text" ? 48 : 64) * MeoTheme.globalScale, contentItem.implicitWidth + leftPadding + rightPadding)
        implicitHeight: 40 * MeoTheme.globalScale
        radius: 20 * MeoTheme.globalScale
        
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
        border.width: (control.type === "outlined" && control.activeFocus) ? 2 : (control.type === "outlined" ? 1 : 0)

        // Simplified Elevation Shadow
        layer.enabled: control.elevation > 0
        layer.effect: DropShadow {

            radius: 0.2
            verticalOffset: control.elevation * MeoTheme.globalScale
            color: Qt.rgba(0,0,0,0.2)
        }

        Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1] } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
        Behavior on border.width { NumberAnimation { duration: 150 } }
    }
}
