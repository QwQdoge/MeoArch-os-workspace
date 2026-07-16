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

        function tracePath(ctx, inset) {
            var w = Math.max(0, width - inset * 2)
            var h = Math.max(0, height - inset * 2)
            var r = Math.max(0, Math.min(control.radius - inset, Math.min(w, h) / 2))
            var ox = inset
            var oy = inset

            ctx.beginPath()
            if (control.type === "squircle" || control.type === "MeoTheme.shapeSquircle") {
                var n = 4
                var step = Math.PI / 100
                for (var angle = 0; angle < 2 * Math.PI; angle += step) {
                    var x = Math.pow(Math.abs(Math.cos(angle)), 2 / n) * (w / 2) * Math.sign(Math.cos(angle)) + w / 2 + ox
                    var y = Math.pow(Math.abs(Math.sin(angle)), 2 / n) * (h / 2) * Math.sign(Math.sin(angle)) + h / 2 + oy
                    if (angle === 0) ctx.moveTo(x, y)
                    else ctx.lineTo(x, y)
                }
            } else if (control.type === "hexagon") {
                ctx.moveTo(ox + w * 0.5, oy)
                ctx.lineTo(ox + w, oy + h * 0.25)
                ctx.lineTo(ox + w, oy + h * 0.75)
                ctx.lineTo(ox + w * 0.5, oy + h)
                ctx.lineTo(ox, oy + h * 0.75)
                ctx.lineTo(ox, oy + h * 0.25)
            } else if (control.type === "octagon") {
                var s = 0.3
                ctx.moveTo(ox + w * s, oy)
                ctx.lineTo(ox + w * (1 - s), oy)
                ctx.lineTo(ox + w, oy + h * s)
                ctx.lineTo(ox + w, oy + h * (1 - s))
                ctx.lineTo(ox + w * (1 - s), oy + h)
                ctx.lineTo(ox + w * s, oy + h)
                ctx.lineTo(ox, oy + h * (1 - s))
                ctx.lineTo(ox, oy + h * s)
            } else if (control.type === "diamond") {
                ctx.moveTo(ox + w * 0.5, oy)
                ctx.lineTo(ox + w, oy + h * 0.5)
                ctx.lineTo(ox + w * 0.5, oy + h)
                ctx.lineTo(ox, oy + h * 0.5)
            } else if (control.type === "pentagon") {
                ctx.moveTo(ox + w * 0.5, oy)
                ctx.lineTo(ox + w, oy + h * 0.38)
                ctx.lineTo(ox + w * 0.81, oy + h)
                ctx.lineTo(ox + w * 0.19, oy + h)
                ctx.lineTo(ox, oy + h * 0.38)
            } else if (control.type === "pill") {
                ctx.roundedRect(ox, oy, w, h, h / 2, h / 2)
            } else if (control.type === "circle") {
                ctx.arc(ox + w / 2, oy + h / 2, Math.min(w, h) / 2, 0, 2 * Math.PI)
            } else if (control.type === "clover") {
                var centerX = ox + w / 2
                var centerY = oy + h / 2
                var leafRadius = Math.min(w, h) / 4
                ctx.arc(centerX, centerY - leafRadius, leafRadius, 0, 2 * Math.PI)
                ctx.moveTo(centerX + leafRadius * 2, centerY)
                ctx.arc(centerX + leafRadius, centerY, leafRadius, 0, 2 * Math.PI)
                ctx.moveTo(centerX, centerY + leafRadius * 2)
                ctx.arc(centerX, centerY + leafRadius, leafRadius, 0, 2 * Math.PI)
                ctx.moveTo(centerX - leafRadius * 2, centerY)
                ctx.arc(centerX - leafRadius, centerY, leafRadius, 0, 2 * Math.PI)
            } else if (control.type === "star") {
                var starCenterX = ox + w / 2
                var starCenterY = oy + h / 2
                var outerRadius = Math.min(w, h) / 2
                var innerRadius = outerRadius * 0.4
                var points = 5
                var starStep = Math.PI / points
                for (var i = 0; i < 2 * points; i++) {
                    var starRadius = (i % 2 === 0) ? outerRadius : innerRadius
                    var starAngle = i * starStep - Math.PI / 2
                    var starX = starCenterX + starRadius * Math.cos(starAngle)
                    var starY = starCenterY + starRadius * Math.sin(starAngle)
                    if (i === 0) ctx.moveTo(starX, starY)
                    else ctx.lineTo(starX, starY)
                }
            } else {
                ctx.roundedRect(ox, oy, w, h, r, r)
            }
            ctx.closePath()
        }

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();
            ctx.fillStyle = control.color;
            tracePath(ctx, 0)
            ctx.fill();

            if (control.strokeWidth > 0 && control.strokeColor !== "transparent") {
                ctx.strokeStyle = control.strokeColor;
                ctx.lineWidth = control.strokeWidth;
                // Canvas strokes are centered on their path.  Inset the second
                // path so an outlined bottom edge is never clipped by the item.
                tracePath(ctx, control.strokeWidth / 2)
                ctx.stroke();
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
    }
}
