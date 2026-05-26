import QtQuick
import QtQuick.Controls

Control {
    id: control

    // 🌟 核心属性
    property bool checked: false
    property string label: ""
    signal toggled(bool checked)

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: Math.max(switchTrack.width + (label !== "" ? spacing + labelText.implicitWidth : 0), 52 * themeGlobalScale)
    implicitHeight: Math.max(switchTrack.height, 40 * themeGlobalScale)

    padding: 8 * themeGlobalScale
    spacing: 12 * themeGlobalScale

    // 点击交互
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

        // 🎨 开关轨道
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

            // 🌟 开关滑块 (Thumb)
            Rectangle {
                id: thumb
                width: control.checked ? 24 * control.themeGlobalScale : 16 * control.themeGlobalScale
                height: width
                radius: width / 2
                anchors.verticalCenter: parent.verticalCenter
                x: control.checked
                   ? (parent.width - width - 4 * control.themeGlobalScale)
                   : (4 * control.themeGlobalScale + (8 * control.themeGlobalScale - width/2)) // 修正未选中时的居中

                // 实际上 MD3 的未选中 thumb 是 16px，选中是 24px
                // 这里为了简化逻辑，直接计算 x 偏移
                property real targetX: control.checked ? (parent.width - width - 4 * control.themeGlobalScale) : 8 * control.themeGlobalScale
                x: targetX

                color: {
                    if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38)
                    if (control.checked) return control.themeOnPrimary
                    return control.themeOutline
                }

                // 🌟 状态层反馈 (Thumb 上的圆环)
                Rectangle {
                    anchors.centerIn: parent
                    width: 40 * control.themeGlobalScale
                    height: 40 * control.themeGlobalScale
                    radius: 20 * control.themeGlobalScale
                    z: -1
                    color: {
                        let overlay = control.checked ? control.themePrimary : control.themeOnSurface
                        if (mouseArea.pressed) return Qt.rgba(overlay.r, overlay.g, overlay.b, 0.12)
                        if (mouseArea.containsMouse) return Qt.rgba(overlay.r, overlay.g, overlay.b, 0.08)
                        return "transparent"
                    }
                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                Behavior on x { NumberAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
                Behavior on width { NumberAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }
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
