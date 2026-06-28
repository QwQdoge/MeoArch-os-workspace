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
    property bool expressive: true // Legacy support
    property string size: expressive ? "m" : "xs" // "xs" | "s" | "m" | "l" | "xl"

    signal moved(real value)

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

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

    implicitWidth: 200 * themeGlobalScale
    implicitHeight: Math.max(thumbHeight + 8 * themeGlobalScale, 44 * themeGlobalScale)

    // 内部逻辑：计算百分比
    readonly property real visualPosition: (value - from) / (to - from)

    Slider {
        id: internalSlider
        anchors.fill: parent
        from: control.from
        to: control.to
        value: control.value
        stepSize: control.discrete ? control.stepSize : 0.0
        live: true

        onMoved: {
            control.value = value
            control.moved(value)
        }

        background: Item {
            x: internalSlider.leftPadding
            y: internalSlider.topPadding + (internalSlider.availableHeight - height) / 2
            width: internalSlider.availableWidth
            height: Math.max(control.implicitHeight, trackRect.height + 8 * control.themeGlobalScale)

            // 轨道背景
            Rectangle {
                id: trackRect
                anchors.centerIn: parent
                width: parent.width
                height: {
                    if (size === "xs") return MeoTheme.sliderTrackHeightXS || 4 * control.themeGlobalScale;
                    if (size === "s") return MeoTheme.sliderTrackHeightS || 16 * control.themeGlobalScale;
                    if (size === "m") return MeoTheme.sliderTrackHeightM || 28 * control.themeGlobalScale;
                    if (size === "l") return MeoTheme.sliderTrackHeightL || 36 * control.themeGlobalScale;
                    if (size === "xl") return MeoTheme.sliderTrackHeightXL || 44 * control.themeGlobalScale;
                    return 4 * control.themeGlobalScale;
                }
                radius: height / 2
                color: Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.12)

                Behavior on height { NumberAnimation { duration: 200 } }

                // Tick marks for discrete slider
                Repeater {
                    model: control.discrete ? Math.floor((control.to - control.from) / control.stepSize) + 1 : 0
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
                y: (parent.height - height) / 2
                width: internalSlider.visualPosition * parent.width
                height: trackRect.height
                radius: height / 2
                color: control.themePrimary

                Behavior on height { NumberAnimation { duration: 200 } }
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

                Behavior on width { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]) } }
            }

            // 🌟 Value Label (MD3 Tooltip style)
            Rectangle {
                id: valueLabel
                anchors.bottom: parent.top
                anchors.bottomMargin: 12 * control.themeGlobalScale
                anchors.horizontalCenter: parent.horizontalCenter
                width: Math.max(32 * control.themeGlobalScale, labelText.implicitWidth + 12 * control.themeGlobalScale)
                height: 28 * control.themeGlobalScale
                radius: 4 * control.themeGlobalScale
                color: control.themePrimary
                visible: internalSlider.pressed

                Text {
                    id: labelText
                    anchors.centerIn: parent
                    text: control.discrete ? control.value.toFixed(0) : control.value.toFixed(1)
                    color: control.themeOnPrimary
                    font.pixelSize: 12 * control.themeGlobalScale
                    font.weight: Font.Medium
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

                scale: internalSlider.pressed ? 1.0 : 0.0
                opacity: internalSlider.pressed ? 1.0 : 0.0
                Behavior on scale { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on opacity { NumberAnimation { duration: 150 } }
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
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }
}
