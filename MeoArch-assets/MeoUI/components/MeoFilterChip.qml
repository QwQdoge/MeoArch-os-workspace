import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string label: ""
    property string leadingIcon: ""
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

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    implicitHeight: 32 * themeGlobalScale
    implicitWidth: contentRow.implicitWidth + leftPadding + rightPadding

    leftPadding: (selected || leadingIcon !== "" ? 8 : 12) * themeGlobalScale
    rightPadding: 12 * themeGlobalScale

    background: Rectangle {
        radius: 8 * themeGlobalScale
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

        Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
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
        spacing: 8 * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter

        // 🌟 Checkmark Animation
        Item {
            id: checkmarkContainer
            width: (control.selected || control.leadingIcon !== "") ? 18 * control.themeGlobalScale : 0
            height: 18 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            clip: true
            visible: width > 0

            Behavior on width {
                NumberAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] }
            }

            MeoIcon {
                anchors.centerIn: parent
                icon: control.selected ? "check" : control.leadingIcon
                size: 18
                color: control.selected ? control.themePrimary : control.themeOnSurfaceVariant

                scale: control.selected || control.leadingIcon !== "" ? 1.0 : 0.5
                opacity: control.selected || control.leadingIcon !== "" ? 1.0 : 0.0

                Behavior on scale { NumberAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }
        }

        Text {
            text: control.label
            font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
            font.weight: fontLabelLarge.weight
            color: control.selected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
}
