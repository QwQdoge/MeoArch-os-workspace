import QtQuick
import QtQuick.Controls

Control {
    id: control

    // 🌟 核心属性
    property real from: 0.0
    property real to: 100.0
    property real value: 0.0
    property bool discrete: false
    property real stepSize: 1.0

    signal moved(real value)

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 200 * themeGlobalScale
    implicitHeight: 44 * themeGlobalScale

    // 内部逻辑：计算百分比
    readonly property real visualPosition: (value - from) / (to - from)

    Slider {
        id: internalSlider
        anchors.fill: parent
        from: control.from
        to: control.to
        value: control.value
        stepSize: control.discrete ? control.stepSize : 0.0
        live: true

        onMoved: {
            control.value = value
            control.moved(value)
        }

        background: Item {
            x: internalSlider.leftPadding
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: internalSlider.availableWidth
            height: 16 * control.themeGlobalScale

            // 轨道背景
            Rectangle {
                anchors.centerIn: parent
                width: parent.width
                height: 4 * control.themeGlobalScale
                radius: 2 * control.themeGlobalScale
                color: Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.24)

                // Tick marks for discrete slider
                Repeater {
                    model: control.discrete ? Math.floor((control.to - control.from) / control.stepSize) + 1 : 0
                    delegate: Rectangle {
                        x: index * (parent.width / (model - 1)) - width / 2
                        y: (parent.height - height) / 2
                        width: 2 * control.themeGlobalScale
                        height: 2 * control.themeGlobalScale
                        radius: 1 * control.themeGlobalScale
                        color: control.themeOnSurfaceVariant
                        opacity: 0.38
                    }
                }
            }

            // 已填充部分
            Rectangle {
                y: (parent.height - height) / 2
                width: internalSlider.visualPosition * parent.width
                height: 4 * control.themeGlobalScale
                radius: 2 * control.themeGlobalScale
                color: control.themePrimary
            }
        }

        handle: Item {
            x: internalSlider.leftPadding + internalSlider.visualPosition * (internalSlider.availableWidth - width)
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: 20 * control.themeGlobalScale
            height: 20 * control.themeGlobalScale

            // 🌟 滑块主体 (Thumb)
            Rectangle {
                anchors.centerIn: parent
                width: internalSlider.pressed ? 2 * control.themeGlobalScale : 20 * control.themeGlobalScale
                height: 20 * control.themeGlobalScale
                radius: width / 2
                color: control.themePrimary

                // MD3 规范中，按下时 Thumb 会变细长或者有状态层
                Behavior on width { NumberAnimation { duration: 100 } }
                Behavior on height { NumberAnimation { duration: 100 } }
            }

            // 🌟 Value Label (MD3 Tooltip style)
            Rectangle {
                id: valueLabel
                anchors.bottom: parent.top
                anchors.bottomMargin: 12 * control.themeGlobalScale
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(32 * control.themeGlobalScale, labelText.implicitWidth + 12 * control.themeGlobalScale)
                height: 28 * control.themeGlobalScale
                radius: 4 * control.themeGlobalScale
                color: control.themePrimary
                visible: internalSlider.pressed

                Text {
                    id: labelText
                    anchors.centerIn: parent
                    text: control.discrete ? control.value.toFixed(0) : control.value.toFixed(1)
                    color: control.themeOnPrimary
                    font.pixelSize: 12 * control.themeGlobalScale
                    font.weight: Font.Medium
                }

                // Small arrow down
                Rectangle {
                    anchors.top: parent.bottom
                    anchors.topMargin: -4 * control.themeGlobalScale
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 8 * control.themeGlobalScale
                    height: 8 * control.themeGlobalScale
                    rotation: 45
                    color: control.themePrimary
                }

                scale: internalSlider.pressed ? 1.0 : 0.0
                opacity: internalSlider.pressed ? 1.0 : 0.0
                Behavior on scale { NumberAnimation { duration: 150; easing.bezierCurve: [0.2, 0, 0, 1] } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
            }

            // 🌟 状态层反馈
            Rectangle {
                anchors.centerIn: parent
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                radius: 20 * control.themeGlobalScale
                z: -1
                color: {
                    if (internalSlider.pressed) return Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.12)
                    if (internalSlider.hovered) return Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.08)
                    return "transparent"
                }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
