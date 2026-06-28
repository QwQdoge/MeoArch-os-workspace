import QtQuick
import QtQuick.Effects
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string source: "" // Image source
    property string initials: "" // Fallback initials (e.g. "JD")
    property real size: 40 // MD3 Standard: 40dp
    property string variant: "circle" // "circle" | "square" | "squircle" | "hexagon" | ...
    property color color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    property color textColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimaryContainer !== 'undefined') ? MeoTheme.onPrimaryContainer : "#21005D"

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: size * themeGlobalScale
    implicitHeight: size * themeGlobalScale

    Item {
        anchors.fill: parent
        clip: true

        MeoShape {
            id: shapeBg
            anchors.fill: parent
            type: (control.variant === "circle" || control.variant === "square") ? "rect" : control.variant
            radius: control.variant === "circle" ? width / 2 : 8 * themeGlobalScale
            color: control.color
        }

        // Initial fallback
        Text {
            anchors.centerIn: parent
            text: control.initials.toUpperCase()
            visible: control.source === "" && control.initials !== ""
            font.pixelSize: (control.size * 0.4) * themeGlobalScale
            font.weight: Font.Medium
            color: control.textColor
        }

        // Image (with clipping to shape via OpacityMask)
        Image {
            id: img
            anchors.fill: parent
            source: control.source
            visible: control.source !== ""
            fillMode: Image.PreserveAspectCrop

            layer.enabled: true
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: shapeBg
            }
        }

        // Icon fallback if no source and no initials
        MeoIcon {
            anchors.centerIn: parent
            icon: "person"
            visible: control.source === "" && control.initials === ""
            size: control.size * 0.6
            color: control.textColor
        }
    }
}
