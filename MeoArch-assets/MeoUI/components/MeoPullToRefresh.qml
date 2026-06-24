import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property bool refreshing: false
    property real pullDistance: 0.0 // 0.0 ~ 1.0 (pull progress)

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerHigh: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHigh !== 'undefined') ? MeoTheme.surfaceContainerHigh : "#ECE6F0"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 40 * themeGlobalScale
    implicitHeight: 40 * themeGlobalScale

    // MD3 Pull-to-refresh container: circular elevated surface
    background: Rectangle {
        radius: width / 2
        color: control.themeSurfaceContainerHigh

        // Elevation Shadow (Standard MD3 Level 2 for pull-to-refresh)
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.2
            shadowVerticalOffset: 2 * control.themeGlobalScale
            shadowColor: Qt.rgba(0,0,0,0.2)
        }

        // Indeterminate Progress (using the logic from MeoProgressBar circular type)
        Canvas {
            id: indicatorCanvas
            anchors.fill: parent
            anchors.margins: 8 * control.themeGlobalScale

            property real startAngle: 0
            property real endAngle: control.refreshing ? 0.2 : (control.pullDistance * 0.8)
            property real rotationAngle: 0

            // Internal state to avoid binding destruction
            property real animStartAngle: 0
            property real animEndAngle: 0
            property real animRotationAngle: 0

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                var centerX = width / 2;
                var centerY = height / 2;
                var strokeWidth = 3 * control.themeGlobalScale;
                var radius = (width - strokeWidth) / 2;

                ctx.beginPath();
                ctx.strokeStyle = control.themePrimary;
                ctx.lineWidth = strokeWidth;
                ctx.lineCap = "round";

                var sA, eA, rA;
                if (control.refreshing) {
                    sA = animStartAngle;
                    eA = animEndAngle;
                    rA = animRotationAngle;
                } else {
                    sA = startAngle;
                    eA = endAngle;
                    rA = rotationAngle;
                }

                // Draw arc based on pull progress or rotation
                var start = (sA + rA) * 2 * Math.PI - 0.5 * Math.PI;
                var end = (eA + rA) * 2 * Math.PI - 0.5 * Math.PI;

                ctx.arc(centerX, centerY, radius, start, end);
                ctx.stroke();

                // Draw arrowhead when pulling
                if (!control.refreshing && control.pullDistance > 0.1) {
                    var arrowAngle = end;
                    var arrowSize = 4 * control.themeGlobalScale;
                    ctx.save();
                    ctx.translate(centerX + radius * Math.cos(arrowAngle), centerY + radius * Math.sin(arrowAngle));
                    ctx.rotate(arrowAngle);
                    ctx.beginPath();
                    ctx.moveTo(-arrowSize, -arrowSize);
                    ctx.lineTo(0, 0);
                    ctx.lineTo(-arrowSize, arrowSize);
                    ctx.stroke();
                    ctx.restore();
                }
            }

            onStartAngleChanged: requestPaint()
            onEndAngleChanged: requestPaint()
            onRotationAngleChanged: requestPaint()
            onAnimStartAngleChanged: requestPaint()
            onAnimEndAngleChanged: requestPaint()
            onAnimRotationAngleChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()

            // Indeterminate animation
            SequentialAnimation {
                running: control.refreshing && control.visible
                loops: Animation.Infinite

                ParallelAnimation {
                    NumberAnimation { target: indicatorCanvas; property: "animStartAngle"; from: 0; to: 0.75; duration: 666; easing.type: Easing.InOutSine }
                    NumberAnimation { target: indicatorCanvas; property: "animEndAngle"; from: 0.2; to: 0.95; duration: 666; easing.type: Easing.InOutSine }
                    NumberAnimation { target: indicatorCanvas; property: "animRotationAngle"; from: 0; to: 0.5; duration: 666; easing.type: Easing.Linear }
                }
                ParallelAnimation {
                    NumberAnimation { target: indicatorCanvas; property: "animStartAngle"; from: 0.75; to: 1.5; duration: 666; easing.type: Easing.InOutSine }
                    NumberAnimation { target: indicatorCanvas; property: "animEndAngle"; from: 0.95; to: 1.7; duration: 666; easing.type: Easing.InOutSine }
                    NumberAnimation { target: indicatorCanvas; property: "animRotationAngle"; from: 0.5; to: 1.0; duration: 666; easing.type: Easing.Linear }
                }
                ScriptAction { script: { indicatorCanvas.animStartAngle %= 1.0; indicatorCanvas.animEndAngle %= 1.0; indicatorCanvas.animRotationAngle %= 1.0; } }
            }
        }
    }

    // Scale and opacity transitions
    scale: visible ? 1.0 : 0.0
    opacity: visible ? 1.0 : 0.0
    Behavior on scale { NumberAnimation { duration: 200; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
    Behavior on opacity { NumberAnimation { duration: 150 } }
}
