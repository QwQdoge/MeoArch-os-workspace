import QtQuick

Canvas {
    id: control

    // 🌟 核心属性
    property string type: "squircle" // "squircle" | "hexagon" | "diamond" | "pentagon" | "octagon"
    property color color: "#6750A4"
    property real radius: 16 // Only used for some shapes if needed, or as a general scale

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 100 * themeGlobalScale
    implicitHeight: 100 * themeGlobalScale

    onPaint: {
        var ctx = getContext("2d");
        ctx.reset();
        ctx.fillStyle = control.color;
        ctx.beginPath();

        var w = width;
        var h = height;
        var cx = w / 2;
        var cy = h / 2;

        if (type === "squircle") {
            // Squircle (Superellipse with n=4 approx)
            var r = Math.min(w, h) / 2;
            for (var angle = 0; angle < 2 * Math.PI; angle += 0.01) {
                var cosA = Math.cos(angle);
                var sinA = Math.sin(angle);
                var x = cx + r * Math.sign(cosA) * Math.pow(Math.abs(cosA), 0.5);
                var y = cy + r * Math.sign(sinA) * Math.pow(Math.abs(sinA), 0.5);
                if (angle === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
        } else if (type === "hexagon") {
            for (var i = 0; i < 6; i++) {
                var angle = (i * 60 - 90) * Math.PI / 180;
                var x = cx + (w / 2) * Math.cos(angle);
                var y = cy + (h / 2) * Math.sin(angle);
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
        } else if (type === "diamond") {
            ctx.moveTo(cx, 0);
            ctx.lineTo(w, cy);
            ctx.lineTo(cx, h);
            ctx.lineTo(0, cy);
        } else if (type === "pentagon") {
            for (var i = 0; i < 5; i++) {
                var angle = (i * 72 - 90) * Math.PI / 180;
                var x = cx + (w / 2) * Math.cos(angle);
                var y = cy + (h / 2) * Math.sin(angle);
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
        } else if (type === "octagon") {
            for (var i = 0; i < 8; i++) {
                var angle = (i * 45 - 22.5) * Math.PI / 180;
                var x = cx + (w / 2) * Math.cos(angle);
                var y = cy + (h / 2) * Math.sin(angle);
                if (i === 0) ctx.moveTo(x, y);
                else ctx.lineTo(x, y);
            }
        }

        ctx.closePath();
        ctx.fill();
    }

    onTypeChanged: requestPaint()
    onColorChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
}
