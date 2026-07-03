import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property real value: 0.0 // 0.0 ~ 1.0 for determinate mode
    property bool indeterminate: true
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property bool vibrant: false
    property color color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: {
        if (size === "xs") return 24 * themeGlobalScale
        if (size === "s") return 32 * themeGlobalScale
        if (size === "l") return 48 * themeGlobalScale
        if (size === "xl") return 64 * themeGlobalScale
        return 40 * themeGlobalScale // medium
    }
    implicitHeight: implicitWidth

    contentItem: Item {
        id: container

        Canvas {
            id: canvas
            anchors.fill: parent

            property real morphProgress: 0.0
            property real rotationAngle: 0.0

            onMorphProgressChanged: requestPaint()
            onRotationAngleChanged: requestPaint()

            // Indeterminate Animation: Continuous Morphing and Rotation
            SequentialAnimation {
                running: control.indeterminate && control.visible
                loops: Animation.Infinite

                ParallelAnimation {
                    NumberAnimation { target: canvas; property: "morphProgress"; from: 0; to: 1; duration: 2000; easing.type: Easing.InOutSine }
                    NumberAnimation { target: canvas; property: "rotationAngle"; from: 0; to: 360; duration: 2000; easing.type: Easing.Linear }
                }
                ParallelAnimation {
                    NumberAnimation { target: canvas; property: "morphProgress"; from: 1; to: 0; duration: 2000; easing.type: Easing.InOutSine }
                    NumberAnimation { target: canvas; property: "rotationAngle"; from: 360; to: 720; duration: 2000; easing.type: Easing.Linear }
                }
            }

            // Determinate Animation: Value-based morphing
            Binding {
                target: canvas
                property: "morphProgress"
                value: control.value
                when: !control.indeterminate
            }

            onPaint: {
                var ctx = getContext("2d");
                ctx.reset();

                var cx = width / 2;
                var cy = height / 2;
                var r = (width / 2) * 0.9;

                ctx.translate(cx, cy);
                ctx.rotate(rotationAngle * Math.PI / 180);

                ctx.beginPath();

                // We will morph between 3 shapes:
                // 0.0 -> Circle
                // 0.5 -> Squircle
                // 1.0 -> Rounded Pentagon/Burst

                var points = 60;
                for (var i = 0; i <= points; i++) {
                    var angle = (i / points) * 2 * Math.PI;

                    // Shape 1: Circle
                    var x1 = r * Math.cos(angle);
                    var y1 = r * Math.sin(angle);

                    // Shape 2: Squircle (n=4)
                    var n = 4;
                    var cosA = Math.cos(angle);
                    var sinA = Math.sin(angle);
                    var x2 = Math.pow(Math.abs(cosA), 2/n) * r * Math.sign(cosA);
                    var y2 = Math.pow(Math.abs(sinA), 2/n) * r * Math.sign(sinA);

                    // Shape 3: Rounded Star/Burst (5 points)
                    var burstPoints = 5;
                    var innerR = r * 0.7;
                    var burstR = (Math.abs(Math.sin(angle * burstPoints / 2)) * (r - innerR)) + innerR;
                    var x3 = burstR * Math.cos(angle);
                    var y3 = burstR * Math.sin(angle);

                    var fx, fy;
                    if (morphProgress <= 0.5) {
                        var t = morphProgress / 0.5;
                        fx = x1 + (x2 - x1) * t;
                        fy = y1 + (y2 - y1) * t;
                    } else {
                        var t = (morphProgress - 0.5) / 0.5;
                        fx = x2 + (x3 - x2) * t;
                        fy = y2 + (y3 - y2) * t;
                    }

                    if (i === 0) ctx.moveTo(fx, fy);
                    else ctx.lineTo(fx, fy);
                }

                ctx.closePath();

                if (control.vibrant) {
                    var grad = ctx.createLinearGradient(-r, -r, r, r);
                    grad.addColorStop(0, control.color);
                    grad.addColorStop(1, (typeof MeoTheme !== 'undefined' ? MeoTheme.tertiary : "#7D5260"));
                    ctx.fillStyle = grad;
                } else {
                    ctx.fillStyle = control.color;
                }

                ctx.fill();
            }
        }
    }
}
