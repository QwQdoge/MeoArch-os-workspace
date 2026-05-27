import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property real from: 0.0
    property real to: 100.0
    property real firstValue: 20.0
    property real secondValue: 80.0

    signal moved()

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 200 * themeGlobalScale
    implicitHeight: 44 * themeGlobalScale

    RangeSlider {
        id: internalSlider
        anchors.fill: parent
        from: control.from
        to: control.to
        first.value: control.firstValue
        second.value: control.secondValue

        onMoved: {
            control.firstValue = first.value
            control.secondValue = second.value
            control.moved()
        }

        background: Item {
            x: internalSlider.leftPadding
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: internalSlider.availableWidth
            height: 16 * control.themeGlobalScale

            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 4 * control.themeGlobalScale
                radius: 2 * control.themeGlobalScale
                color: Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.24)
            }

            Rectangle {
                y: (parent.height - height) / 2
                x: internalSlider.first.visualPosition * parent.width
                width: (internalSlider.second.visualPosition - internalSlider.first.visualPosition) * parent.width
                height: 4 * control.themeGlobalScale
                radius: 2 * control.themeGlobalScale
                color: control.themePrimary
            }
        }

        first.handle: Rectangle {
            x: internalSlider.leftPadding + internalSlider.first.visualPosition * (internalSlider.availableWidth - width)
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: 20 * control.themeGlobalScale
            height: 20 * control.themeGlobalScale
            radius: 10 * control.themeGlobalScale
            color: control.themePrimary

            Rectangle {
                anchors.centerIn: parent
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                radius: 20 * control.themeGlobalScale
                z: -1
                color: internalSlider.first.pressed ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.12) :
                       (internalSlider.first.hovered ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.08) : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        second.handle: Rectangle {
            x: internalSlider.leftPadding + internalSlider.second.visualPosition * (internalSlider.availableWidth - width)
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: 20 * control.themeGlobalScale
            height: 20 * control.themeGlobalScale
            radius: 10 * control.themeGlobalScale
            color: control.themePrimary

            Rectangle {
                anchors.centerIn: parent
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                radius: 20 * control.themeGlobalScale
                z: -1
                color: internalSlider.second.pressed ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.12) :
                       (internalSlider.second.hovered ? Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.08) : "transparent")
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
