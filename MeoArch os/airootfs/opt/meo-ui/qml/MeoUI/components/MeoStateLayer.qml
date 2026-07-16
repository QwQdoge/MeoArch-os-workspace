import QtQuick
import QtQuick.Effects

Item {
    id: control

    // 🌟 核心属性
    property bool pressed: false
    property bool hovered: false
    property bool focused: false
    property bool dragged: false
    property bool rippleEnabled: true
    property color color: "#000000" // 默认覆盖颜色（通常为 On-Surface 或 Primary）
    property real radius: 0
    // Keep the state layer clipped to the same silhouette as its owner.  A
    // radius-only mask turns circular and expressive controls into rectangles.
    property string shape: "rect"
    property real pressX: pointerTracker.containsMouse ? pointerTracker.mouseX : width / 2
    property real pressY: pointerTracker.containsMouse ? pointerTracker.mouseY : height / 2

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // 🌟 状态层透明度定义 (MD3 规范)
    readonly property real hoverOpacity: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.stateOpacityHover !== 'undefined') ? MeoTheme.stateOpacityHover : 0.08
    readonly property real focusOpacity: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.stateOpacityFocus !== 'undefined') ? MeoTheme.stateOpacityFocus : 0.10
    readonly property real pressedOpacity: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.stateOpacityPressed !== 'undefined') ? MeoTheme.stateOpacityPressed : 0.10
    readonly property real draggedOpacity: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.stateOpacityDragged !== 'undefined') ? MeoTheme.stateOpacityDragged : 0.16
    readonly property int hoverDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationFast !== 'undefined') ? MeoTheme.motionDurationFast : 150
    readonly property int rippleExpandDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationRippleExpand !== 'undefined') ? MeoTheme.motionDurationRippleExpand : 400
    readonly property int rippleFadeDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationRippleFade !== 'undefined') ? MeoTheme.motionDurationRippleFade : 300

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
        if (!control.enabled || !control.rippleEnabled || (typeof MeoTheme !== "undefined" && MeoTheme.reduceMotion))
            return
        rippleExpand.stop()
        rippleFade.stop()
        rippleFadeIn.stop()
        rippleLayer.originX = Math.max(0, Math.min(control.width, x))
        rippleLayer.originY = Math.max(0, Math.min(control.height, y))
        rippleLayer.radiusValue = 0
        rippleLayer.opacity = 0
        rippleFadeIn.start()
        rippleExpand.start()
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
        visible: baseLayer.opacity > 0 || rippleLayer.opacity > 0
        layer.enabled: visible && control.radius > 0
        layer.effect: MultiEffect {
            maskEnabled: true
            maskThresholdMin: 0.5
            // Rectangle + radius is intentionally self-contained here.  The
            // state layer is used by every primitive, so importing the module
            // it belongs to would create a runtime self-import cycle.
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
                if (control.pressed) return control.pressedOpacity
                if (control.hovered) return control.hoverOpacity
                if (control.focused) return control.focusOpacity
                return 0
            }

            Behavior on opacity {
                NumberAnimation {
                    duration: control.hoverDuration
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

        Rectangle {
            anchors.fill: parent
            color: "transparent"
            radius: control.radius
            border.width: control.focused ? Math.max(2, 2 * control.themeGlobalScale) : 0
            border.color: control.color
            opacity: control.focused ? 0.78 : 0

            Behavior on opacity {
                NumberAnimation { duration: control.hoverDuration }
            }
        }
    }

    NumberAnimation {
        id: rippleExpand
        target: rippleLayer
        property: "radiusValue"
        from: 0
        to: rippleLayer.targetRadius
        duration: control.rippleExpandDuration
        easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingEmphasizedDecelerate !== 'undefined') ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
    }

    NumberAnimation {
        id: rippleFadeIn
        target: rippleLayer
        property: "opacity"
        to: control.pressedOpacity
        duration: control.hoverDuration
        easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingStandard !== 'undefined') ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
    }

    NumberAnimation {
        id: rippleFade
        target: rippleLayer
        property: "opacity"
        to: 0
        duration: control.hoverDuration
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
