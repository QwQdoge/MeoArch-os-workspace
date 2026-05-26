import QtQuick
import QtQuick.Controls

Control {
    id: control

    // 🌟 核心属性
    property real value: 0.0 // 0.0 ~ 1.0
    property bool indeterminate: false
    property string type: "linear" // "linear" | "circular"

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: type === "linear" ? 240 * themeGlobalScale : 48 * themeGlobalScale
    implicitHeight: type === "linear" ? 4 * themeGlobalScale : 48 * themeGlobalScale

    // Linear Progress
    Rectangle {
        visible: control.type === "linear"
        anchors.fill: parent
        color: control.themeSurfaceContainerHighest
        radius: height / 2
        clip: true

        Rectangle {
            id: indicator
            height: parent.height
            width: control.indeterminate ? parent.width * 0.3 : parent.width * control.value
            radius: height / 2
            color: control.themePrimary

            // Indeterminate animation
            SequentialAnimation on x {
                running: control.indeterminate && control.visible
                loops: Animation.Infinite
                NumberAnimation { from: -indicator.width; to: control.width; duration: 1000; easing.type: Easing.InOutSine }
            }

            Behavior on width {
                enabled: !control.indeterminate
                NumberAnimation { duration: 250; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] }
            }
        }
    }

    // Circular Progress (Simplified using Canvas)
    Canvas {
        id: canvas
        visible: control.type === "circular"
        anchors.fill: parent
        rotation: control.indeterminate ? 0 : -90

        onPaint: {
            var ctx = getContext("2d");
            ctx.reset();

            var centerX = width / 2;
            var centerY = height / 2;
            var radius = (width - 4 * control.themeGlobalScale) / 2;

            // Background track
            ctx.beginPath();
            ctx.strokeStyle = control.themeSurfaceContainerHighest;
            ctx.lineWidth = 4 * control.themeGlobalScale;
            ctx.arc(centerX, centerY, radius, 0, 2 * Math.PI);
            ctx.stroke();

            // Progress indicator
            ctx.beginPath();
            ctx.strokeStyle = control.themePrimary;
            ctx.lineWidth = 4 * control.themeGlobalScale;
            ctx.lineCap = "round";
            var endAngle = control.indeterminate ? 0.25 * 2 * Math.PI : control.value * 2 * Math.PI;
            ctx.arc(centerX, centerY, radius, 0, endAngle);
            ctx.stroke();
        }

        onValueChanged: requestPaint()

        RotationAnimation on rotation {
            running: control.indeterminate && control.visible
            loops: Animation.Infinite
            from: 0; to: 360; duration: 1000
        }
    }
}
