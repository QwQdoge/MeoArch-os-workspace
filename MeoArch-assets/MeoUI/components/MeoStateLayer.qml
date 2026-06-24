import QtQuick

Rectangle {
    id: control

    // 🌟 核心属性
    property bool pressed: false
    property bool hovered: false
    property bool focused: false
    property bool dragged: false
    property color color: "#000000" // 默认覆盖颜色（通常为 On-Surface 或 Primary）

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // 🌟 状态层透明度定义 (MD3 规范)
    readonly property real hoverOpacity: 0.08
    readonly property real focusOpacity: 0.10
    readonly property real pressedOpacity: 0.12
    readonly property real draggedOpacity: 0.16

    anchors.fill: parent
    visible: opacity > 0

    opacity: {
        if (dragged) return draggedOpacity
        if (pressed) return pressedOpacity
        if (hovered) return hoverOpacity
        if (focused) return focusOpacity
        return 0
    }

    // 🌟 严格锁死 Fast Effects 贝塞尔曲线动效 (150ms)
    Behavior on opacity {
        NumberAnimation {
            duration: 150
            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
        }
    }
}
