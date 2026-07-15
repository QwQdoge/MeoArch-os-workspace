import QtQuick
import QtQuick.Controls

Control {
    id: control

    // 🌟 核心属性
    property real value: 0.0 // 0.0 ~ 1.0
    property bool indeterminate: false
    property string type: "linear" // "linear" | "circular"
    property bool isThick: false // 🌟 MD3 Expressive: Thicker track variant
    property bool vibrant: false // 🌟 MD3 Expressive: Gradient/Vibrant track
    property bool wavy: false // MD3 Expressive waveform linear indicator
    property bool showTrack: true
    property color activeColor: themePrimary
    property color trackColor: themeSurfaceContainerHighest

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int motionProgressDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationMedium1 !== 'undefined') ? MeoTheme.motionDurationMedium1 : 250
    readonly property int motionWaveDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationExtraLong3 !== 'undefined') ? MeoTheme.motionDurationExtraLong3 : 900
    readonly property int motionIndeterminateDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationExtraLong4 !== 'undefined') ? MeoTheme.motionDurationExtraLong4 + MeoTheme.motionDurationShort2 : 1100
    readonly property int motionIndeterminateCycle: motionIndeterminateDuration * 2
    readonly property int motionIndeterminateDelay: motionIndeterminateDuration
    readonly property int motionCircularSweepDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationLong4 !== 'undefined') ? MeoTheme.motionDurationLong4 + MeoTheme.motionDurationShort1 : 650
    readonly property int motionCircularRotationDuration: motionCircularSweepDuration

    implicitWidth: type === "linear" ? 240 * themeGlobalScale : 48 * themeGlobalScale
    implicitHeight: {
        if (type === "linear") return wavy ? 24 * themeGlobalScale : (isThick ? 8 : 4) * themeGlobalScale;
        return 48 * themeGlobalScale;
    }

    // Linear Progress
    Rectangle {
        visible: control.type === "linear" && !control.wavy
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: control.isThick ? 8 * control.themeGlobalScale : 4 * control.themeGlobalScale
        color: control.showTrack ? control.trackColor : "transparent"
        radius: height / 2
        clip: true

        Rectangle {
            id: indicator
            visible: !control.indeterminate
            height: parent.height
            x: 0
            width: parent.width * Math.max(0, Math.min(1, control.value))
            radius: height / 2
            color: control.activeColor

            Rectangle {
                anchors.fill: parent
                radius: parent.radius
                visible: control.vibrant
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: control.activeColor }
                    GradientStop { position: 1.0; color: (typeof MeoTheme !== 'undefined' ? MeoTheme.tertiary : "#7D5260") }
                }
            }

            Behavior on width {
                enabled: !control.indeterminate
                NumberAnimation { duration: control.motionProgressDuration; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] }
            }
        }

        Repeater {
            model: 2
            delegate: Rectangle {
                id: indeterminateBar
                visible: control.indeterminate
                height: parent.height
                radius: height / 2
                color: control.activeColor
                x: -width
                width: 0

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    visible: control.vibrant
                    gradient: Gradient {
                        orientation: Gradient.Horizontal
                        GradientStop { position: 0.0; color: control.activeColor }
                        GradientStop { position: 1.0; color: (typeof MeoTheme !== 'undefined' ? MeoTheme.tertiary : "#7D5260") }
                    }
                }

                SequentialAnimation {
                    running: control.indeterminate && control.visible && control.type === "linear" && !control.wavy
                    loops: Animation.Infinite
                    PauseAnimation { duration: index === 0 ? 0 : control.motionIndeterminateDelay }
                    ParallelAnimation {
                        NumberAnimation {
                            target: indeterminateBar
                            property: "x"
                            from: -parent.width * 0.45
                            to: parent.width
                            duration: control.motionIndeterminateCycle
                            easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]
                        }
                        SequentialAnimation {
                            NumberAnimation {
                                target: indeterminateBar
                                property: "width"
                                from: 0
                                to: parent.width * 0.52
                                duration: control.motionIndeterminateDuration
                                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                            }
                            NumberAnimation {
                                target: indeterminateBar
                                property: "width"
                                from: parent.width * 0.52
                                to: 0
                                duration: control.motionIndeterminateDuration
                                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandardAccelerate !== "undefined") ? MeoTheme.motionEasingStandardAccelerate : [0.3, 0, 1, 1]
                            }
                        }
                    }
                    PauseAnimation { duration: index === 0 ? control.motionIndeterminateDelay : 0 }
                }
            }
        }
    }

    Canvas {
        id: wavyCanvas
        visible: control.type === "linear" && control.wavy
        anchors.fill: parent

        property real phase: 0

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var strokeWidth = (control.isThick ? 10 : 8) * control.themeGlobalScale;
            var mid = height / 2;
            var progressWidth = Math.max(0, Math.min(width, width * control.value));
            var amp = 4 * control.themeGlobalScale;
            var wavelength = 26 * control.themeGlobalScale;

            ctx.lineCap = "round";
            ctx.lineJoin = "round";
            ctx.lineWidth = strokeWidth;

            if (control.showTrack) {
                ctx.strokeStyle = control.trackColor;
                ctx.beginPath();
                ctx.moveTo(0, mid);
                ctx.lineTo(width, mid);
                ctx.stroke();
            }

            ctx.strokeStyle = control.activeColor;
            ctx.beginPath();
            if (control.indeterminate) {
                var cycle = Math.max(1, 52 * control.themeGlobalScale);
                var progress = (phase % cycle) / cycle;
                var barWidth = width * 0.5;
                var startX = (width + barWidth) * progress - barWidth;
                var endX = startX + barWidth;
                var hasStarted = false;

                for (var ix = 0; ix <= width; ix += 3 * control.themeGlobalScale) {
                    if (ix >= startX && ix <= endX) {
                        var iy = mid + Math.sin((ix + phase) / wavelength * Math.PI * 2) * amp;
                        if (!hasStarted) {
                            ctx.moveTo(ix, iy);
                            hasStarted = true;
                        } else {
                            ctx.lineTo(ix, iy);
                        }
                    }
                }
            } else {
                for (var x = 0; x <= progressWidth; x += 3 * control.themeGlobalScale) {
                    var y = mid + Math.sin((x + phase) / wavelength * Math.PI * 2) * amp;
                    if (x === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                }
            }
            ctx.stroke();

            if (!control.indeterminate && progressWidth < width) {
                ctx.fillStyle = control.activeColor;
                ctx.beginPath();
                ctx.arc(width, mid, 2 * control.themeGlobalScale, 0, Math.PI * 2);
                ctx.fill();
            }
        }

        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()
        onPhaseChanged: requestPaint()
        Connections {
            target: control
            function onValueChanged() { wavyCanvas.requestPaint() }
            function onIsThickChanged() { wavyCanvas.requestPaint() }
        }

        NumberAnimation on phase {
            running: control.visible && control.wavy && control.indeterminate && control.type === "linear"
            from: 0
            to: 52 * control.themeGlobalScale
            duration: control.motionWaveDuration
            loops: Animation.Infinite
            easing.type: Easing.Linear
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
                ctx.strokeStyle = control.activeColor;
                ctx.lineWidth = strokeWidth;
                ctx.lineCap = "round";
                // MD3 circular indeterminate is a rotating arc that grows and shrinks
                ctx.arc(centerX, centerY, radius, startAngle * 2 * Math.PI, endAngle * 2 * Math.PI);
                ctx.stroke();
            } else {
                if (control.showTrack) {
                    ctx.beginPath();
                    ctx.strokeStyle = control.trackColor;
                    ctx.lineWidth = strokeWidth;
                    ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
                    ctx.stroke();
                }

                // Progress indicator
                ctx.beginPath();
                ctx.strokeStyle = control.activeColor;
                ctx.lineWidth = strokeWidth;
                ctx.lineCap = "round";
                var eA = Math.max(0.01, control.value) * 2 * Math.PI;
                ctx.arc(centerX, centerY, radius, -0.5 * Math.PI, eA - 0.5 * Math.PI);
                ctx.stroke();
            }
        }

        onStartAngleChanged: requestPaint()
        onEndAngleChanged: requestPaint()
        onRotationChanged: requestPaint()
        onWidthChanged: requestPaint()
        onHeightChanged: requestPaint()

        // 🌟 MD3 "Advance and Retreat" Animation logic
        SequentialAnimation {
            running: control.indeterminate && control.visible && control.type === "circular"
            loops: Animation.Infinite

            ParallelAnimation {
                NumberAnimation { target: canvas; property: "startAngle"; from: 0; to: 0.75; duration: control.motionCircularSweepDuration; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1] }
                NumberAnimation { target: canvas; property: "endAngle"; from: 0.2; to: 0.95; duration: control.motionCircularSweepDuration; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1] }
                NumberAnimation { target: canvas; property: "rotation"; from: 0; to: 180; duration: control.motionCircularRotationDuration; easing.type: Easing.Linear }
            }
            ParallelAnimation {
                NumberAnimation { target: canvas; property: "startAngle"; from: 0.75; to: 1.5; duration: control.motionCircularSweepDuration; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1] }
                NumberAnimation { target: canvas; property: "endAngle"; from: 0.95; to: 1.7; duration: control.motionCircularSweepDuration; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1] }
                NumberAnimation { target: canvas; property: "rotation"; from: 180; to: 360; duration: control.motionCircularRotationDuration; easing.type: Easing.Linear }
            }

            // Reset angles to prevent overflow while maintaining rotation continuity
            ScriptAction { script: { canvas.startAngle %= 1.0; canvas.endAngle %= 1.0; } }
        }
    }
}
