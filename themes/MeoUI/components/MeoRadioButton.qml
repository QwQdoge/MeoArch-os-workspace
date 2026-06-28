import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property bool checked: false
    property string label: ""
    signal toggled(bool checked)

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: Math.max(radioOuter.width + (label !== "" ? spacing + labelText.implicitWidth : 0), 40 * themeGlobalScale)
    implicitHeight: Math.max(radioOuter.height, 40 * themeGlobalScale)

    padding: 8 * themeGlobalScale
    spacing: 12 * themeGlobalScale

    // 点击交互
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            if (!control.checked) {
                control.checked = true
                control.toggled(true)
            }
        }
    }

    contentItem: Row {
        spacing: control.spacing

        // 🎨 单选框外圈
        Rectangle {
            id: radioOuter
            width: 20 * control.themeGlobalScale
            height: 20 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            radius: width / 2
            color: "transparent"
            border.color: control.checked ? control.themePrimary : control.themeOutline
            border.width: 2 * control.themeGlobalScale

            // 🌟 核心选中原点
            Rectangle {
                anchors.centerIn: parent
                width: control.checked ? 10 * control.themeGlobalScale : 0
                height: width
                radius: width / 2
                color: control.themePrimary

                Behavior on width {
                    NumberAnimation {
                        duration: 150;
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
                    }
                }
            }

            // 🌟 状态层反馈
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

            Behavior on border.color { ColorAnimation { duration: 200; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
        }

        // 🔤 标签文本
        Text {
            id: labelText
            text: control.label
            font.pixelSize: 14 * control.themeGlobalScale
            color: control.enabled ? control.themeOnSurface : (isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38))
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
        }
    }
}
