import QtQuick
import QtQuick.Controls
import MeoUI

MeoCard {
    id: control
    type: "elevated"
    padding: 24 * themeGlobalScale

    // 🌟 核心属性
    property int hours: 10
    property int minutes: 30
    property bool isPM: false

    // 🌟 作用域与主题安全防御
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimaryContainer !== 'undefined') ? MeoTheme.onPrimaryContainer : "#21005D"
    readonly property color themeSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceVariant !== 'undefined') ? MeoTheme.surfaceVariant : "#E7E0EC"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 320 * themeGlobalScale
    implicitHeight: 450 * themeGlobalScale

    Column {
        anchors.fill: parent
        spacing: 24 * control.themeGlobalScale

        // Time Display
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 8 * control.themeGlobalScale

            // Hours
            Rectangle {
                width: 96 * control.themeGlobalScale
                height: 80 * control.themeGlobalScale
                radius: 8 * control.themeGlobalScale
                color: control.themePrimaryContainer
                Text {
                    anchors.centerIn: parent
                    text: control.hours.toString().padStart(2, '0')
                    font.pixelSize: 45 * control.themeGlobalScale
                    color: control.themeOnPrimaryContainer
                }
            }

            Text {
                text: ":"
                font.pixelSize: 45 * control.themeGlobalScale
                color: control.themeOnPrimaryContainer
                anchors.verticalCenter: parent.verticalCenter
            }

            // Minutes
            Rectangle {
                width: 96 * control.themeGlobalScale
                height: 80 * control.themeGlobalScale
                radius: 8 * control.themeGlobalScale
                color: control.themeSurfaceVariant
                Text {
                    anchors.centerIn: parent
                    text: control.minutes.toString().padStart(2, '0')
                    font.pixelSize: 45 * control.themeGlobalScale
                    color: control.themeOnPrimaryContainer
                }
            }

            // AM/PM Toggle
            Column {
                spacing: 0
                anchors.verticalCenter: parent.verticalCenter
                width: 52 * control.themeGlobalScale

                Rectangle {
                    width: parent.width
                    height: 40 * control.themeGlobalScale
                    radius: 8 * control.themeGlobalScale
                    border.color: control.themeSurfaceVariant
                    color: !control.isPM ? control.themePrimaryContainer : "transparent"
                    Text { anchors.centerIn: parent; text: "AM"; font.pixelSize: 14 * control.themeGlobalScale }
                    MouseArea { anchors.fill: parent; onClicked: control.isPM = false }
                }
                Rectangle {
                    width: parent.width
                    height: 40 * control.themeGlobalScale
                    radius: 8 * control.themeGlobalScale
                    border.color: control.themeSurfaceVariant
                    color: control.isPM ? control.themePrimaryContainer : "transparent"
                    Text { anchors.centerIn: parent; text: "PM"; font.pixelSize: 14 * control.themeGlobalScale }
                    MouseArea { anchors.fill: parent; onClicked: control.isPM = true }
                }
            }
        }

        // Clock Face (Simplified representation)
        Rectangle {
            width: 200 * control.themeGlobalScale
            height: 200 * control.themeGlobalScale
            radius: 100 * control.themeGlobalScale
            color: control.themeSurfaceVariant
            anchors.horizontalCenter: parent.horizontalCenter

            // Hand
            Rectangle {
                id: hand
                width: 2 * control.themeGlobalScale
                height: 80 * control.themeGlobalScale
                color: control.themePrimary
                anchors.bottom: parent.verticalCenter
                anchors.horizontalCenter: parent.horizontalCenter
                antialiasing: true
                transformOrigin: Item.Bottom
                rotation: (control.hours % 12) * 30
            }

            // Center dot
            Rectangle {
                width: 8 * control.themeGlobalScale
                height: 8 * control.themeGlobalScale
                radius: 4 * control.themeGlobalScale
                color: control.themePrimary
                anchors.centerIn: parent
            }

            // Interactive area for clock
            MouseArea {
                anchors.fill: parent
                onPositionChanged: {
                    if (pressed) {
                        let angle = Math.atan2(mouseY - height/2, mouseX - width/2) * 180 / Math.PI + 90
                        if (angle < 0) angle += 360
                        control.hours = Math.round(angle / 30)
                        if (control.hours === 0) control.hours = 12
                    }
                }
            }
        }
    }
}
