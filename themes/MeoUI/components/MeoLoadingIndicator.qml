import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property real value: 0.0 // 0.0 ~ 1.0 for determinate mode
    property bool indeterminate: true
    property bool running: true
    property bool withContainer: false
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property bool vibrant: false
    property color color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    property color containerColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int loadingCycleDuration: MeoTheme.reduceMotion ? 0 : 2400
    readonly property int loadingRotationDuration: MeoTheme.reduceMotion ? 0 : 1800
    // Canvas is among the most expensive primitives in a dense installer.
    // Do not keep its two infinite animations alive while it has no pixels.
    readonly property bool animationActive: running && indeterminate && visible
                                                && width > 0 && height > 0
                                                && !MeoTheme.reduceMotion
    // Start and end on the same contour. The previous 2 → 10 reset was the
    // visible hard snap at the end of each loop.
    readonly property var lobeSequence: [10, 9, 5, 2, 8, 4, 2, 10]

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

        Rectangle {
            anchors.fill: parent
            radius: width / 2
            visible: control.withContainer
            color: control.containerColor
        }

        Canvas {
            id: canvas
            anchors.centerIn: parent
            width: control.withContainer ? parent.width * 0.56 : parent.width
            height: control.withContainer ? parent.height * 0.56 : parent.height

            property real morphProgress: 0.0
            property real rotationAngle: 0.0
            readonly property int sequenceMax: Math.max(1, control.lobeSequence.length - 1)

            onMorphProgressChanged: requestPaint()
            onRotationAngleChanged: requestPaint()

            ParallelAnimation {
                running: control.animationActive
                loops: Animation.Infinite

                NumberAnimation {
                    target: canvas
                    property: "rotationAngle"
                    from: 0
                    to: 360
                    duration: control.loadingRotationDuration
                    easing.type: Easing.Linear
                }

                SequentialAnimation {
                    NumberAnimation {
                        target: canvas
                        property: "morphProgress"
                        from: 0
                        to: canvas.sequenceMax
                        duration: control.loadingCycleDuration
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]
                    }
                    ScriptAction { script: canvas.morphProgress = 0 }
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
                // MD3E-style lobed silhouettes, driven by a MeoUI-owned sequence.

                var lowerIndex = Math.floor(Math.max(0, Math.min(canvas.sequenceMax, morphProgress)));
                var upperIndex = Math.min(canvas.sequenceMax, lowerIndex + 1);
                var segmentT = Math.max(0, Math.min(1, morphProgress - lowerIndex));
                var lowerLobes = control.lobeSequence[lowerIndex];
                var upperLobes = control.lobeSequence[upperIndex];
                var lobeCount = lowerLobes + (upperLobes - lowerLobes) * segmentT;
                var lobeDepth = 0.11 + 0.16 * (1 - Math.min(1, lobeCount / 10));

                var points = 60;
                for (var i = 0; i <= points; i++) {
                    var angle = (i / points) * 2 * Math.PI;

                    var wave = Math.cos(angle * lobeCount);
                    var softWave = (wave + 1) / 2;
                    var edgeR = r * (1 - lobeDepth * softWave);
                    var fx = edgeR * Math.cos(angle);
                    var fy = edgeR * Math.sin(angle);

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
