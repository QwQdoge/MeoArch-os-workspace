import QtQuick
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string type: (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeSquircle : "squircle")
    property color color: "transparent"
    property real radius: 12 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    onRadiusChanged: canvas.requestPaint()
    onTypeChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()

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
                // 🌟 MD3 Expressive Squircle (Superellipse approximation)
                // Using a more accurate squircle approximation for brand-expressive shapes
                var n = 4; // Power for superellipse (n=4 is a common squircle)
                var step = Math.PI / 100;
                for (var angle = 0; angle < 2 * Math.PI; angle += step) {
                    var x = Math.pow(Math.abs(Math.cos(angle)), 2/n) * (w/2) * Math.sign(Math.cos(angle)) + w/2;
                    var y = Math.pow(Math.abs(Math.sin(angle)), 2/n) * (h/2) * Math.sign(Math.sin(angle)) + h/2;
                    if (angle === 0) ctx.moveTo(x, y);
                    else ctx.lineTo(x, y);
                }
            } else if (control.type === "hexagon") {
                ctx.moveTo(w * 0.5, 0);
                ctx.lineTo(w, h * 0.25);
                ctx.lineTo(w, h * 0.75);
                ctx.lineTo(w * 0.5, h);
                ctx.lineTo(0, h * 0.75);
                ctx.lineTo(0, h * 0.25);
            } else if (control.type === "octagon") {
                // 🌟 MD3 Expressive Octagon
                var s = 0.3; // Proportion of the side
                ctx.moveTo(w * s, 0);
                ctx.lineTo(w * (1-s), 0);
                ctx.lineTo(w, h * s);
                ctx.lineTo(w, h * (1-s));
                ctx.lineTo(w * (1-s), h);
                ctx.lineTo(w * s, h);
                ctx.lineTo(0, h * (1-s));
                ctx.lineTo(0, h * s);
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
    }
}
