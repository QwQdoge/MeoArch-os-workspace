import QtQuick
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string type: (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeSquircle : "squircle")
    property color color: "transparent"
    property real radius: 12 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    Canvas {
        id: canvas
        anchors.fill: parent
        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.fillStyle = control.color;
            ctx.beginPath();

            var w = width;
            var h = height;
            var r = control.radius;

            if (control.type === "squircle" || control.type === "MeoTheme.shapeSquircle") {
                // High-fidelity superellipse (n=4) approximation for MD3 compliance
                var cp = r * 0.05; // Control point adjustment for flatter sides
                ctx.moveTo(r, 0);
                ctx.lineTo(w - r, 0);
                ctx.bezierCurveTo(w - cp, 0, w, cp, w, r);
                ctx.lineTo(w, h - r);
                ctx.bezierCurveTo(w, h - cp, w - cp, h, w - r, h);
                ctx.lineTo(r, h);
                ctx.bezierCurveTo(cp, h, 0, h - cp, 0, h - r);
                ctx.lineTo(0, r);
                ctx.bezierCurveTo(0, cp, cp, 0, r, 0);
            } else if (control.type === "hexagon") {
                ctx.moveTo(w * 0.5, 0);
                ctx.lineTo(w, h * 0.25);
                ctx.lineTo(w, h * 0.75);
                ctx.lineTo(w * 0.5, h);
                ctx.lineTo(0, h * 0.75);
                ctx.lineTo(0, h * 0.25);
            } else if (control.type === "diamond") {
                ctx.moveTo(w * 0.5, 0);
                ctx.lineTo(w, h * 0.5);
                ctx.lineTo(w * 0.5, h);
                ctx.lineTo(0, h * 0.5);
            } else if (control.type === "pentagon") {
                ctx.moveTo(w * 0.5, 0);
                ctx.lineTo(w, h * 0.38);
                ctx.lineTo(w * 0.81, h);
                ctx.lineTo(w * 0.19, h);
                ctx.lineTo(0, h * 0.38);
            } else {
                // Fallback to rounded rect
                ctx.roundedRect(0, 0, w, h, r, r);
            }

            ctx.closePath();
            ctx.fill();
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onColorChanged: requestPaint()
    }
}
