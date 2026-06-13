import QtQuick
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string source: "" // Image source
    property string initials: "" // Fallback initials (e.g. "JD")
    property real size: 40 // MD3 Standard: 40dp
    property string variant: "circle" // "circle" | "square"
    property color color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    property color textColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimaryContainer !== 'undefined') ? MeoTheme.onPrimaryContainer : "#21005D"

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: size * themeGlobalScale
    implicitHeight: size * themeGlobalScale

    Rectangle {
        anchors.fill: parent
        radius: variant === "circle" ? width / 2 : 8 * themeGlobalScale
        color: control.color
        clip: true

        // Initial fallback
        Text {
            anchors.centerIn: parent
            text: control.initials.toUpperCase()
            visible: control.source === "" && control.initials !== ""
            font.pixelSize: (control.size * 0.4) * themeGlobalScale
            font.weight: Font.Medium
            color: control.textColor
        }

        // Image
        Image {
            anchors.fill: parent
            source: control.source
            visible: control.source !== ""
            fillMode: Image.PreserveAspectCrop
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
