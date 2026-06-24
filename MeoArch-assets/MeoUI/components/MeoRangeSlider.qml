import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property real from: 0.0
    property real to: 100.0
    property real firstValue: 20.0
    property real secondValue: 80.0
    property bool discrete: false
    property real stepSize: 1.0
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"

    signal moved()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // 📐 尺寸映射 (MD3 Expressive Slider)
    readonly property real trackHeight: {
        if (size === "s") return (MeoTheme.sliderTrackHeightS || 16 * themeGlobalScale)
        if (size === "m") return (MeoTheme.sliderTrackHeightM || 28 * themeGlobalScale)
        if (size === "l") return (MeoTheme.sliderTrackHeightL || 36 * themeGlobalScale)
        if (size === "xl") return (MeoTheme.sliderTrackHeightXL || 44 * themeGlobalScale)
        return (MeoTheme.sliderTrackHeightXS || 4 * themeGlobalScale) // default "xs"
    }

    implicitWidth: 200 * themeGlobalScale
    implicitHeight: Math.max(44, trackHeight + 20) * themeGlobalScale

    RangeSlider {
        id: internalSlider
        anchors.fill: parent
        from: control.from
        to: control.to
        first.value: control.firstValue
        second.value: control.secondValue
        stepSize: control.discrete ? control.stepSize : 0.0
        live: true

        first.onMoved: {
            control.firstValue = first.value
            control.moved()
        }
        second.onMoved: {
            control.secondValue = second.value
            control.moved()
        }

        background: Item {
            x: internalSlider.leftPadding
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: internalSlider.availableWidth
            height: Math.max(control.implicitHeight, trackRect.height + 8 * control.themeGlobalScale)

            // 轨道背景
            Rectangle {
                id: trackRect
                anchors.centerIn: parent
                width: parent.width
                height: control.trackHeight
                radius: height / 2
                color: Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.12)

                Behavior on height { NumberAnimation { duration: 200 } }

                // Tick marks for discrete slider
                Repeater {
                    model: control.discrete ? Math.floor((control.to - control.from) / control.stepSize) + 1 : 0
                    delegate: Rectangle {
                        x: index * (parent.width / (model - 1)) - width / 2
                        y: (parent.height - height) / 2
                        width: (control.size !== "xs" ? 4 : 2) * control.themeGlobalScale
                        height: (control.size !== "xs" ? 4 : 2) * control.themeGlobalScale
                        radius: width / 2
                        color: control.themeOnSurfaceVariant
                        opacity: 0.38
                    }
                }
            }

            // 已填充部分 (Active Range)
            Rectangle {
                y: (parent.height - height) / 2
                x: internalSlider.first.visualPosition * parent.width
                width: (internalSlider.second.visualPosition - internalSlider.first.visualPosition) * parent.width
                height: trackRect.height
                radius: height / 2
                color: control.themePrimary

                Behavior on height { NumberAnimation { duration: 200 } }
            }
        }

        first.handle: Item {
            x: internalSlider.leftPadding + internalSlider.first.visualPosition * (internalSlider.availableWidth - width)
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: (control.size !== "xs" ? 4 : 20) * control.themeGlobalScale
            height: (control.size === "xs" ? 20 : trackRect.height + 4) * control.themeGlobalScale

            Rectangle {
                anchors.centerIn: parent
                width: {
                    if (control.size !== "xs") return (internalSlider.first.pressed ? 2 : 4) * control.themeGlobalScale
                    return (internalSlider.first.pressed ? 2 : 20) * control.themeGlobalScale
                }
                height: parent.height
                radius: width / 2
                color: control.size !== "xs" ? control.themeOnPrimary : control.themePrimary
                border.color: control.size !== "xs" ? control.themePrimary : "transparent"
                border.width: control.size !== "xs" ? 1 * control.themeGlobalScale : 0
                Behavior on width { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]) } }
            }

            // 🌟 Value Label (MD3 Tooltip style)
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 12 * control.themeGlobalScale
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(32 * control.themeGlobalScale, firstLabelText.implicitWidth + 12 * control.themeGlobalScale)
                height: 28 * control.themeGlobalScale
                radius: 4 * control.themeGlobalScale
                color: control.themePrimary
                visible: internalSlider.first.pressed

                Text {
                    id: firstLabelText
                    anchors.centerIn: parent
                    text: control.discrete ? control.firstValue.toFixed(0) : control.firstValue.toFixed(1)
                    color: control.themeOnPrimary
                    font.pixelSize: 12 * control.themeGlobalScale
                    font.weight: Font.Medium
                }

                Rectangle {
                    anchors.top: parent.bottom
                    anchors.topMargin: -4 * control.themeGlobalScale
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 8 * control.themeGlobalScale
                    height: 8 * control.themeGlobalScale
                    rotation: 45
                    color: control.themePrimary
                }

                scale: internalSlider.first.pressed ? 1.0 : 0.0
                opacity: internalSlider.first.pressed ? 1.0 : 0.0
                Behavior on scale { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // State layer
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

        second.handle: Item {
            x: internalSlider.leftPadding + internalSlider.second.visualPosition * (internalSlider.availableWidth - width)
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: (control.size !== "xs" ? 4 : 20) * control.themeGlobalScale
            height: (control.size === "xs" ? 20 : trackRect.height + 4) * control.themeGlobalScale

            Rectangle {
                anchors.centerIn: parent
                width: {
                    if (control.size !== "xs") return (internalSlider.second.pressed ? 2 : 4) * control.themeGlobalScale
                    return (internalSlider.second.pressed ? 2 : 20) * control.themeGlobalScale
                }
                height: parent.height
                radius: width / 2
                color: control.size !== "xs" ? control.themeOnPrimary : control.themePrimary
                border.color: control.size !== "xs" ? control.themePrimary : "transparent"
                border.width: control.size !== "xs" ? 1 * control.themeGlobalScale : 0
                Behavior on width { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]) } }
            }

            // 🌟 Value Label (MD3 Tooltip style)
            Rectangle {
                anchors.bottom: parent.top
                anchors.bottomMargin: 12 * control.themeGlobalScale
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(32 * control.themeGlobalScale, secondLabelText.implicitWidth + 12 * control.themeGlobalScale)
                height: 28 * control.themeGlobalScale
                radius: 4 * control.themeGlobalScale
                color: control.themePrimary
                visible: internalSlider.second.pressed

                Text {
                    id: secondLabelText
                    anchors.centerIn: parent
                    text: control.discrete ? control.secondValue.toFixed(0) : control.secondValue.toFixed(1)
                    color: control.themeOnPrimary
                    font.pixelSize: 12 * control.themeGlobalScale
                    font.weight: Font.Medium
                }

                Rectangle {
                    anchors.top: parent.bottom
                    anchors.topMargin: -4 * control.themeGlobalScale
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 8 * control.themeGlobalScale
                    height: 8 * control.themeGlobalScale
                    rotation: 45
                    color: control.themePrimary
                }

                scale: internalSlider.second.pressed ? 1.0 : 0.0
                opacity: internalSlider.second.pressed ? 1.0 : 0.0
                Behavior on scale { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // State layer
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
