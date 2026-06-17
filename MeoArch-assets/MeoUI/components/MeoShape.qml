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
                // Approximate squircle using bezier curves
                var kappa = 0.552284749831; // For a circle, but we'll adjust for squircle look
                // For a more "squircle" look, we use a different approach or larger kappa
                var s = r * 1.2;
                ctx.moveTo(r, 0);
                ctx.lineTo(w - r, 0);
                ctx.bezierCurveTo(w - r + s, 0, w, r - s, w, r);
                ctx.lineTo(w, h - r);
                ctx.bezierCurveTo(w, h - r + s, w - r + s, h, w - r, h);
                ctx.lineTo(r, h);
                ctx.bezierCurveTo(r - s, h, 0, h - r + s, 0, h - r);
                ctx.lineTo(0, r);
                ctx.bezierCurveTo(0, r - s, r - s, 0, r, 0);
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
