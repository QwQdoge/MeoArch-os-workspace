import QtQuick
import QtQuick.Controls
import MeoUI

Button {
    id: control

    // 🌟 核心开关
    property string type: "filled" // "filled" (默认) | "tonal" | "outlined" | "elevated" | "text"
    property string icon: ""

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    readonly property color bgColor: {
        if (!control.enabled) {
            if (type === "outlined" || type === "text")
                return Qt.rgba(textColor.r, textColor.g, textColor.b, 0);
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        }
        if (type === "filled") return MeoTheme.primary;
        if (type === "tonal") return MeoTheme.secondaryContainer;
        if (type === "elevated") return MeoTheme.surfaceContainerLow;
        return Qt.rgba(textColor.r, textColor.g, textColor.b, 0);
    }

    readonly property color textColor: {
        if (!control.enabled) {
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        }
        if (type === "filled") return MeoTheme.onPrimary;
        if (type === "tonal") return MeoTheme.onSecondaryContainer;
        return MeoTheme.primary;
    }

    leftPadding: {
        if (control.icon !== "") return 16 * MeoTheme.globalScale;
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
            icon: control.icon
            visible: control.icon !== ""
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
        
        color: {
            let base = control.bgColor;
            let overlay = control.textColor;
            if (control.pressed) return Qt.tint(base, Qt.rgba(overlay.r, overlay.g, overlay.b, 0.12));
            if (control.hovered) return Qt.tint(base, Qt.rgba(overlay.r, overlay.g, overlay.b, 0.08));
            if (control.visualFocus) return Qt.tint(base, Qt.rgba(overlay.r, overlay.g, overlay.b, 0.10));
            return base;
        }

        border.color: {
            if (control.type !== "outlined") return "transparent";
            if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
            return MeoTheme.outline;
        }
        border.width: control.type === "outlined" ? 1 : 0
        layer.enabled: control.type === "elevated"

        Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1] } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }
}
