import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property bool checked: false
    property string label: ""
    property string icon: ""
    property string uncheckedIcon: ""
    signal toggled(bool checked)

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    implicitWidth: Math.max(switchTrack.width + (label !== "" ? spacing + labelText.implicitWidth : 0), 52 * themeGlobalScale)
    implicitHeight: Math.max(switchTrack.height, 40 * themeGlobalScale)

    padding: 8 * themeGlobalScale
    spacing: 12 * themeGlobalScale

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            control.checked = !control.checked
            control.toggled(control.checked)
        }
    }

    contentItem: Row {
        spacing: control.spacing

        Rectangle {
            id: switchTrack
            width: 52 * control.themeGlobalScale
            height: 32 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            radius: height / 2

            color: {
                if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
                if (control.checked) return control.themePrimary
                return control.themeSurfaceContainerHighest
            }

            border.color: {
                if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
                if (control.checked) return control.themePrimary
                return control.themeOutline
            }
            border.width: 2 * control.themeGlobalScale

            Rectangle {
                id: thumb
                width: {
                    if (mouseArea.pressed) return 28 * control.themeGlobalScale
                    return (control.checked || control.icon !== "") ? 24 * control.themeGlobalScale : 16 * control.themeGlobalScale
                }
                height: {
                    if (mouseArea.pressed) return 28 * control.themeGlobalScale
                    return (control.checked || control.icon !== "") ? 24 * control.themeGlobalScale : 16 * control.themeGlobalScale
                }
                radius: 14 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                x: control.checked ? (parent.width - width - 4 * control.themeGlobalScale) : (control.icon !== "" ? 4 * control.themeGlobalScale : (8 * control.themeGlobalScale + (16 * control.themeGlobalScale - width)/2))

                MeoIcon {
                    id: thumbIcon
                    anchors.centerIn: parent
                    icon: control.checked ? control.icon : control.uncheckedIcon
                    size: 16
                    color: control.checked ? control.themePrimary : control.themeOnSurfaceVariant
                    visible: icon !== ""
                    scale: (control.checked ? control.icon : control.uncheckedIcon) !== "" ? 1.0 : 0.0
                    Behavior on scale { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                }

                color: {
                    if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38)
                    if (control.checked) return control.themeOnPrimary
                    return control.themeOutline
                }

                Item {
                    anchors.centerIn: parent
                    width: 40 * control.themeGlobalScale
                    height: 40 * control.themeGlobalScale
                    z: -1

                    MeoStateLayer {
                        radius: width / 2
                        pressed: mouseArea.pressed
                        hovered: mouseArea.containsMouse
                        color: control.checked ? control.themePrimary : control.themeOnSurface
                    }
                }

                Behavior on x { NumberAnimation { duration: 200; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on width { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on height { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Behavior on color { ColorAnimation { duration: 200; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
            Behavior on border.color { ColorAnimation { duration: 200; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
        }

        Text {
            id: labelText
            text: control.label
            font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
            font.weight: fontLabelLarge.weight
            color: control.enabled ? control.themeOnSurface : (isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38))
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
        }
    }
}
