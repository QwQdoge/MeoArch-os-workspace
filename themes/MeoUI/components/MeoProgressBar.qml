import QtQuick
import QtQuick.Controls

Control {
    id: control

    // 🌟 核心属性
    property real value: 0.0 // 0.0 ~ 1.0
    property bool indeterminate: false
    property string type: "linear" // "linear" | "circular"
    property bool isThick: false // 🌟 MD3 Expressive: Thicker track variant

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: type === "linear" ? 240 * themeGlobalScale : 48 * themeGlobalScale
    implicitHeight: {
        if (type === "linear") return (isThick ? 8 : 4) * themeGlobalScale;
        return 48 * themeGlobalScale;
    }

    // Linear Progress
    Rectangle {
        visible: control.type === "linear"
        anchors.fill: parent
        color: control.themeSurfaceContainerHighest
        radius: height / 2
        clip: true

        Rectangle {
            id: indicator
            height: parent.height
            width: control.indeterminate ? parent.width * 0.3 : parent.width * control.value
            radius: height / 2
            color: control.themePrimary

            // Indeterminate animation
            SequentialAnimation on x {
                running: control.indeterminate && control.visible && control.type === "linear"
                loops: Animation.Infinite
                NumberAnimation { from: -indicator.width; to: control.width; duration: 1000; easing.type: Easing.InOutSine }
            }

            Behavior on width {
                enabled: !control.indeterminate
                NumberAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] }
            }
        }
    }

    // Circular Progress (Advanced MD3 Indeterminate Animation)
    Canvas {
        id: canvas
        visible: control.type === "circular"
        anchors.fill: parent

        property real startAngle: 0
        property real endAngle: control.indeterminate ? 0.2 : control.value

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var centerX = width / 2;
            var centerY = height / 2;
            var strokeWidth = (control.isThick ? 8 : 4) * control.themeGlobalScale;
            var radius = (width - strokeWidth) / 2;

            if (control.indeterminate) {
                ctx.beginPath();
                ctx.strokeStyle = control.themePrimary;
                ctx.lineWidth = strokeWidth;
                ctx.lineCap = "round";
                // MD3 circular indeterminate is a rotating arc that grows and shrinks
                ctx.arc(centerX, centerY, radius, startAngle * 2 * Math.PI, endAngle * 2 * Math.PI);
                ctx.stroke();
            } else {
                // Background track
                ctx.beginPath();
                ctx.strokeStyle = control.themeSurfaceContainerHighest;
                ctx.lineWidth = strokeWidth;
                ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                ctx.stroke();

                // Progress indicator
                ctx.beginPath();
                ctx.strokeStyle = control.themePrimary;
                ctx.lineWidth = strokeWidth;
                ctx.lineCap = "round";
                var eA = Math.max(0.01, control.value) * 2 * Math.PI;
                ctx.arc(centerX, centerY, radius, -0.5 * Math.PI, eA - 0.5 * Math.PI);
                ctx.stroke();
            }
        }

        onStartAngleChanged: requestPaint()
        onEndAngleChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        // 🌟 MD3 "Advance and Retreat" Animation logic
        SequentialAnimation {
            running: control.indeterminate && control.visible && control.type === "circular"
            loops: Animation.Infinite

            ParallelAnimation {
                NumberAnimation { target: canvas; property: "startAngle"; from: 0; to: 0.75; duration: 666; easing.type: Easing.InOutSine }
                NumberAnimation { target: canvas; property: "endAngle"; from: 0.2; to: 0.95; duration: 666; easing.type: Easing.InOutSine }
                NumberAnimation { target: canvas; property: "rotation"; from: 0; to: 180; duration: 666; easing.type: Easing.Linear }
            }
            ParallelAnimation {
                NumberAnimation { target: canvas; property: "startAngle"; from: 0.75; to: 1.5; duration: 666; easing.type: Easing.InOutSine }
                NumberAnimation { target: canvas; property: "endAngle"; from: 0.95; to: 1.7; duration: 666; easing.type: Easing.InOutSine }
                NumberAnimation { target: canvas; property: "rotation"; from: 180; to: 360; duration: 666; easing.type: Easing.Linear }
            }

            // Reset angles to prevent overflow while maintaining rotation continuity
            ScriptAction { script: { canvas.startAngle %= 1.0; canvas.endAngle %= 1.0; } }
        }
    }
}
