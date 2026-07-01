import QtQuick
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string type: (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeSquircle : "squircle")
    property color color: "transparent"
    property real radius: 12 * themeGlobalScale
    property color strokeColor: "transparent"
    property real strokeWidth: 0

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    onRadiusChanged: canvas.requestPaint()
    onTypeChanged: canvas.requestPaint()
    onColorChanged: canvas.requestPaint()
    onStrokeColorChanged: canvas.requestPaint()
    onStrokeWidthChanged: canvas.requestPaint()

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
            } else if (control.type === "pill") {
                ctx.roundedRect(0, 0, w, h, h / 2, h / 2);
            } else if (control.type === "circle") {
                ctx.arc(w / 2, h / 2, Math.min(w, h) / 2, 0, 2 * Math.PI);
            } else if (control.type === "clover") {
                // 🌟 MD3 Expressive Clover (4-leaf)
                var centerX = w / 2;
                var centerY = h / 2;
                var leafRadius = Math.min(w, h) / 4;
                ctx.arc(centerX, centerY - leafRadius, leafRadius, 0, 2 * Math.PI);
                ctx.moveTo(centerX + leafRadius * 2, centerY);
                ctx.arc(centerX + leafRadius, centerY, leafRadius, 0, 2 * Math.PI);
                ctx.moveTo(centerX, centerY + leafRadius * 2);
                ctx.arc(centerX, centerY + leafRadius, leafRadius, 0, 2 * Math.PI);
                ctx.moveTo(centerX - leafRadius * 2, centerY);
                ctx.arc(centerX - leafRadius, centerY, leafRadius, 0, 2 * Math.PI);
            } else if (control.type === "star") {
                // 🌟 MD3 Expressive 5-point Star
                var centerX = w / 2;
                var centerY = h / 2;
                var outerRadius = Math.min(w, h) / 2;
                var innerRadius = outerRadius * 0.4;
                var points = 5;
                var step = Math.PI / points;
                for (var i = 0; i < 2 * points; i++) {
                    var r = (i % 2 === 0) ? outerRadius : innerRadius;
                    var angle = i * step - Math.PI / 2;
                    var x = centerX + r * Math.cos(angle);
                    var y = centerY + r * Math.sin(angle);
                    if (i === 0) ctx.moveTo(x, y);
                    else ctx.lineTo(x, y);
                }
            } else {
                ctx.roundedRect(0, 0, w, h, r, r);
            }

            ctx.closePath();
            ctx.fill();

            if (control.strokeWidth > 0 && control.strokeColor !== "transparent") {
                ctx.strokeStyle = control.strokeColor;
                ctx.lineWidth = control.strokeWidth;
                ctx.stroke();
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }
}
