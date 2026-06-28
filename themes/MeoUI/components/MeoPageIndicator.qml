import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property int count: 0
    property int currentIndex: 0
    spacing: 8 * themeGlobalScale
    property real dotSize: 8 * themeGlobalScale
    property real activeDotWidth: 24 * themeGlobalScale

    // 🌟 作用域与主题安全防御
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitHeight: dotSize
    implicitWidth: count * dotSize + (count - 1) * spacing + (activeDotWidth - dotSize)

    contentItem: Row {
        spacing: control.spacing
        anchors.centerIn: parent

        Repeater {
            model: control.count
            delegate: Rectangle {
                width: index === control.currentIndex ? control.activeDotWidth : control.dotSize
                height: control.dotSize
                radius: height / 2
                color: index === control.currentIndex ? control.themePrimary : control.themeOutlineVariant

                Behavior on width {
                    NumberAnimation { duration: 200; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] }
                }
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
            }
        }
    }
}
