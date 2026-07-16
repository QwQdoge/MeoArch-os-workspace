import QtQuick
import QtQuick.Controls

Control {
    id: control

    // 🌟 核心属性
    property real from: 0.0
    property real to: 100.0
    property real value: 0.0
    property bool discrete: false
    property real stepSize: 1.0
    property bool snapMode: false
    property bool tickMarksEnabled: discrete
    property bool valueLabelEnabled: true
    property bool isThick: false // 🌟 MD3 Expressive: Thicker track variant
    property bool wavy: false // 🌟 MD3 Expressive: Wavy track variant
    property bool expressive: true // Legacy support
    property string size: expressive ? "m" : "xs" // "xs" | "s" | "m" | "l" | "xl"
    readonly property bool pressed: internalSlider.pressed

    signal moved(real value)

    function normalizedValue(rawValue) {
        var nextValue = Math.max(from, Math.min(to, rawValue))
        if ((discrete || snapMode || tickMarksEnabled) && stepSize > 0) {
            var steps = Math.round((nextValue - from) / stepSize)
            nextValue = from + steps * stepSize
        }
        return Math.max(from, Math.min(to, nextValue))
    }

    function setValue(rawValue) {
        var nextValue = normalizedValue(rawValue)
        if (value !== nextValue) {
            value = nextValue
            moved(value)
        }
    }

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int motionStateDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationFast !== 'undefined') ? MeoTheme.motionDurationFast : 150
    readonly property int motionTrackDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationMedium1 !== 'undefined') ? MeoTheme.motionDurationMedium1 : 250
    readonly property int motionLabelDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationShort2 !== 'undefined') ? MeoTheme.motionDurationShort2 : 100
    readonly property int motionWaveDuration: MeoTheme.reduceMotion ? 0 : 720
    readonly property var fontLabelSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelSmall !== 'undefined') ? MeoTheme.labelSmall : { "size": 12, "weight": Font.Medium }
    // The wave remains expressive while a pointer or keyboard focus is on the
    // slider, but does not repaint an idle page at display refresh rate.
    readonly property bool waveAnimationActive: wavy && visible && enabled
                                                && width > 0 && height > 0
                                                && (internalSlider.hovered || internalSlider.pressed || internalSlider.activeFocus)
                                                && !MeoTheme.reduceMotion

    // 📐 尺寸映射 (MD3 Expressive Slider)
    readonly property real trackHeight: {
        if (size === "xs") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderTrackHeightXS !== 'undefined') ? MeoTheme.sliderTrackHeightXS : 4 * themeGlobalScale
        if (size === "s") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderTrackHeightS !== 'undefined') ? MeoTheme.sliderTrackHeightS : 16 * themeGlobalScale
        if (size === "m") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderTrackHeightM !== 'undefined') ? MeoTheme.sliderTrackHeightM : 28 * themeGlobalScale
        if (size === "l") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderTrackHeightL !== 'undefined') ? MeoTheme.sliderTrackHeightL : 36 * themeGlobalScale
        if (size === "xl") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderTrackHeightXL !== 'undefined') ? MeoTheme.sliderTrackHeightXL : 44 * themeGlobalScale
        return 4 * themeGlobalScale
    }

    readonly property real activeTrackHeight: trackHeight

    readonly property real thumbWidth: {
        if (size === "xs") return 20 * themeGlobalScale
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderThumbWidthExpressive !== 'undefined') ? MeoTheme.sliderThumbWidthExpressive : 4 * themeGlobalScale
    }

    readonly property real thumbHeight: {
        if (size === "xs") return 20 * themeGlobalScale
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderThumbHeightExpressive !== 'undefined') ? MeoTheme.sliderThumbHeightExpressive : 44 * themeGlobalScale
    }

    readonly property real thumbGap: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.sliderThumbGapExpressive !== 'undefined') ? MeoTheme.sliderThumbGapExpressive : 6 * themeGlobalScale
    readonly property real visualThumbWidth: {
        if (size === "xs") return internalSlider.pressed ? 2 * themeGlobalScale : thumbWidth
        return internalSlider.pressed ? 2 * themeGlobalScale : thumbWidth
    }
    readonly property real trackEndX: internalSlider.visualPosition * internalSlider.availableWidth
    readonly property real activeTrackWidth: Math.max(0, trackEndX - thumbGap - visualThumbWidth / 2)

    implicitWidth: 200 * themeGlobalScale
    implicitHeight: wavy ? 44 * themeGlobalScale : Math.max(thumbHeight + 8 * themeGlobalScale, 44 * themeGlobalScale)

    // 内部逻辑：计算百分比
    readonly property real visualPosition: (value - from) / (to - from)

    Slider {
        id: internalSlider
        anchors.fill: parent
        from: control.from
        to: control.to
        value: control.value
        stepSize: (control.discrete || control.snapMode || control.tickMarksEnabled) ? control.stepSize : 0.0
        live: true
        enabled: control.enabled

        onMoved: {
            control.setValue(value)
        }

        background: Item {
            x: internalSlider.leftPadding
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: internalSlider.availableWidth
            height: Math.max(control.implicitHeight, trackRect.height + 8 * control.themeGlobalScale)

            // 轨道背景
            Rectangle {
                id: trackRect
                visible: !control.wavy
                anchors.centerIn: parent
                width: parent.width
                height: control.isThick ? 16 * control.themeGlobalScale : control.trackHeight
                radius: height / 2
                color: Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.12)

                Behavior on height { NumberAnimation { duration: control.motionTrackDuration } }

                // Tick marks for discrete slider
                Repeater {
                    model: (control.discrete || control.tickMarksEnabled) && control.stepSize > 0 ? Math.floor((control.to - control.from) / control.stepSize) + 1 : 0
                    delegate: Rectangle {
                        x: index * (parent.width / (model - 1)) - width / 2
                        y: (parent.height - height) / 2
                        width: (control.size !== "xs" ? 4 : 2) * control.themeGlobalScale
                        height: (control.size !== "xs" ? 4 : 2) * control.themeGlobalScale
                        radius: width / 2
                        color: control.themeOnSurfaceVariant
                        opacity: 0.38
                    }
                }
            }

            // 已填充部分
            Rectangle {
                visible: !control.wavy
                y: (parent.height - height) / 2
                width: control.activeTrackWidth
                height: trackRect.height
                radius: height / 2
                color: control.themePrimary

                Behavior on width {
                    enabled: !internalSlider.pressed
                    NumberAnimation {
                        duration: control.motionTrackDuration
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                    }
                }
                Behavior on height { NumberAnimation { duration: control.motionTrackDuration } }
            }

            Canvas {
                id: wavyCanvas
                visible: control.wavy
                anchors.fill: parent
                property real phase: 0

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();

                    var strokeWidth = (control.isThick ? 10 : (control.size === "xs" ? 4 : 8)) * control.themeGlobalScale;
                    var mid = height / 2;
                    var progressWidth = Math.max(0, Math.min(width, width * internalSlider.visualPosition));
                    var amp = Math.min(strokeWidth * 0.34, 3.5 * control.themeGlobalScale);
                    var wavelength = 40 * control.themeGlobalScale;
                    var sampleStep = Math.max(1, 1.25 * control.themeGlobalScale);

                    ctx.lineCap = "round";
                    ctx.lineJoin = "round";
                    ctx.lineWidth = strokeWidth;

                    // Inactive wavy track (standard straight line in MD3 if not active?)
                    // MD3 Expressive Wavy Progress uses wave for active and line for inactive.
                    ctx.strokeStyle = Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.12);
                    ctx.beginPath();
                    ctx.moveTo(0, mid);
                    ctx.lineTo(width, mid);
                    ctx.stroke();

                    // Active wavy track
                    ctx.strokeStyle = control.themePrimary;
                    ctx.beginPath();
                    for (var x = 0; x < progressWidth; x += sampleStep) {
                        var y = mid + Math.sin((x + phase) / wavelength * Math.PI * 2) * amp;
                        if (x === 0) ctx.moveTo(x, y); else ctx.lineTo(x, y);
                    }
                    if (progressWidth > 0) {
                        var endY = mid + Math.sin((progressWidth + phase) / wavelength * Math.PI * 2) * amp;
                        if (progressWidth < sampleStep) ctx.moveTo(0, mid);
                        ctx.lineTo(progressWidth, endY);
                    }
                    ctx.stroke();

                    // Active dot at the end of wavy part if needed? MeoProgressBar has it.
                }

                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                onPhaseChanged: requestPaint()

                Connections {
                    target: internalSlider
                    function onVisualPositionChanged() { wavyCanvas.requestPaint() }
                }

                NumberAnimation on phase {
                    running: control.waveAnimationActive
                    from: 0
                    // Advance exactly one wavelength. The loop endpoints are
                    // therefore visually identical instead of snapping back.
                    to: 40 * control.themeGlobalScale
                    duration: control.motionWaveDuration
                    loops: Animation.Infinite
                    easing.type: Easing.Linear
                }
            }
        }

        handle: Item {
            x: internalSlider.leftPadding + internalSlider.visualPosition * (internalSlider.availableWidth - width)
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: control.thumbWidth
            height: control.thumbHeight

            // 🌟 滑块主体 (Thumb)
            Rectangle {
                anchors.centerIn: parent
                width: {
                    if (control.size !== "xs") return (internalSlider.pressed ? 2 : control.thumbWidth)
                    return (internalSlider.pressed ? 2 : control.thumbWidth)
                }
                radius: width / 2
                color: control.size !== "xs" ? control.themeOnPrimary : control.themePrimary

                border.color: control.size !== "xs" ? control.themePrimary : "transparent"
                border.width: control.size !== "xs" ? 1 * control.themeGlobalScale : 0

                Behavior on width { NumberAnimation { duration: control.motionStateDuration; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]) } }
            }

            // 🌟 Value Label (MD3 Tooltip style)
            Rectangle {
                id: valueLabel
                anchors.bottom: parent.top
                anchors.bottomMargin: 12 * control.themeGlobalScale
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(32 * control.themeGlobalScale, labelText.implicitWidth + 16 * control.themeGlobalScale)
                height: 28 * control.themeGlobalScale
                radius: height / 2
                color: control.themePrimary
                visible: control.valueLabelEnabled && (internalSlider.pressed || internalSlider.hovered)

                Text {
                    id: labelText
                    anchors.centerIn: parent
                    text: control.discrete ? control.value.toFixed(0) : control.value.toFixed(1)
                    color: control.themeOnPrimary
                    font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                    font.pixelSize: control.fontLabelSmall.size * control.themeGlobalScale
                    font.weight: control.fontLabelSmall.weight
                }

                // Small arrow down
                Rectangle {
                    anchors.top: parent.bottom
                    anchors.topMargin: -4 * control.themeGlobalScale
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: 8 * control.themeGlobalScale
                    height: 8 * control.themeGlobalScale
                    rotation: 45
                    color: control.themePrimary
                }

                scale: (internalSlider.pressed || internalSlider.hovered) ? 1.0 : 0.0
                opacity: (internalSlider.pressed || internalSlider.hovered) ? 1.0 : 0.0
                Behavior on scale { NumberAnimation { duration: control.motionStateDuration; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on opacity { NumberAnimation { duration: control.motionStateDuration } }
            }

            // 🌟 状态层反馈
            Rectangle {
                anchors.centerIn: parent
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                radius: 20 * control.themeGlobalScale
                z: -1
                color: {
                    if (internalSlider.pressed) return Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.12)
                    if (internalSlider.hovered) return Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.08)
                    return "transparent"
                }
                Behavior on color { ColorAnimation { duration: control.motionStateDuration } }
            }
        }
    }
}
