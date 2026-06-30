import QtQuick
import QtQuick.Effects

Item {
    id: control

    // 🌟 核心属性
    property bool pressed: false
    property bool hovered: false
    property bool focused: false
    property bool dragged: false
    property color color: "#000000" // 默认覆盖颜色（通常为 On-Surface 或 Primary）
    property real radius: 0
    property real pressX: pointerTracker.containsMouse ? pointerTracker.mouseX : width / 2
    property real pressY: pointerTracker.containsMouse ? pointerTracker.mouseY : height / 2

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // 🌟 状态层透明度定义 (MD3 规范)
    readonly property real hoverOpacity: 0.08
    readonly property real focusOpacity: 0.10
    readonly property real pressedOpacity: 0.12
    readonly property real draggedOpacity: 0.16

    anchors.fill: parent
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    clip: true

    MouseArea {
        id: pointerTracker
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.NoButton
    }

    function trigger(x, y) {
        rippleLayer.originX = Math.max(0, Math.min(control.width, x))
        rippleLayer.originY = Math.max(0, Math.min(control.height, y))
        rippleLayer.radiusValue = 0
        rippleLayer.opacity = pressedOpacity
        rippleAnimation.restart()
    }

    onPressedChanged: {
        if (pressed)
            trigger(pressX, pressY)
        else
            rippleFade.restart()
    }

    Item {
        id: maskedLayer
        anchors.fill: parent
        layer.enabled: control.radius > 0
        layer.effect: MultiEffect {
            maskEnabled: true
            maskThresholdMin: 0.5
            maskSource: Rectangle {
                width: control.width
                height: control.height
                radius: control.radius
            }
        }

        Rectangle {
            id: baseLayer
            anchors.fill: parent
            color: control.color
            opacity: {
                if (control.dragged) return control.draggedOpacity
                if (control.hovered) return control.hoverOpacity
                if (control.focused) return control.focusOpacity
                return 0
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: 150
                    easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                }
            }
        }

        Rectangle {
            id: rippleLayer
            property real originX: control.width / 2
            property real originY: control.height / 2
            property real radiusValue: 0
            readonly property real targetRadius: Math.sqrt(Math.pow(Math.max(originX, control.width - originX), 2)
                                                        + Math.pow(Math.max(originY, control.height - originY), 2))
            x: originX - radiusValue
            y: originY - radiusValue
            width: radiusValue * 2
            height: radiusValue * 2
            radius: radiusValue
            color: control.color
            opacity: 0
        }
    }

    ParallelAnimation {
        id: rippleAnimation
        NumberAnimation {
            target: rippleLayer
            property: "radiusValue"
            from: 0
            to: rippleLayer.targetRadius
            duration: 420
            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingEmphasizedDecelerate !== 'undefined') ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
        }
        SequentialAnimation {
            PauseAnimation { duration: 120 }
            NumberAnimation {
                target: rippleLayer
                property: "opacity"
                to: 0
                duration: 300
                easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
            }
        }
    }

    NumberAnimation {
        id: rippleFade
        target: rippleLayer
        property: "opacity"
        to: 0
        duration: 160
        easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
    }

    readonly property real stateOpacity: {
        if (dragged) return draggedOpacity
        if (pressed) return pressedOpacity
        if (hovered) return hoverOpacity
        if (focused) return focusOpacity
        return 0
    }
}
