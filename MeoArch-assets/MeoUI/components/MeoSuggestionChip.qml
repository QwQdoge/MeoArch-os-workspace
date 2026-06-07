import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string label: ""
    property bool elevated: false

    signal clicked()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    implicitHeight: 32 * themeGlobalScale
    implicitWidth: contentRow.implicitWidth + leftPadding + rightPadding

    leftPadding: 16 * themeGlobalScale
    rightPadding: 16 * themeGlobalScale

    background: Rectangle {
        radius: 8 * themeGlobalScale
        color: control.elevated ? control.themeSurfaceContainerLow : "transparent"
        border.color: control.elevated ? "transparent" : (control.enabled ? control.themeOutline : Qt.rgba(control.themeOutline.r, control.themeOutline.g, control.themeOutline.b, 0.12))
        border.width: control.elevated ? 0 : 1 * themeGlobalScale

        // MD3 Elevation for 'elevated' variant
        layer.enabled: control.elevated && control.enabled
        layer.effect: DropShadow {

            radius: 0.1
            verticalOffset: (control.pressed ? 1 : (control.hovered ? 2 : 1)) * themeGlobalScale
            color: Qt.rgba(0,0,0,0.2)
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
        anchors.verticalCenter: parent.verticalCenter

        Text {
            text: control.label
            font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
            font.weight: fontLabelLarge.weight
            color: control.themeOnSurfaceVariant
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
