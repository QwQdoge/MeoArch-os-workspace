import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control
    activeFocusOnTab: true

    // 🌟 核心属性
    property bool checked: false
    property bool indeterminate: false // 🌟 New: Indeterminate state support
    property string label: ""
    property string text: label
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string thickness: "medium" // "thin" | "medium" | "thick"
    property bool isError: false
    property string errorText: ""
    property string helperText: ""

    signal toggled(bool checked)

    onTextChanged: {
        if (label !== text)
            label = text
    }
    onLabelChanged: {
        if (text !== label)
            text = label
    }

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeError: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.error !== 'undefined') ? MeoTheme.error : "#B3261E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int motionStateDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationShort2 !== 'undefined') ? MeoTheme.motionDurationShort2 : 100
    readonly property int motionCheckDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationMedium1 !== 'undefined') ? MeoTheme.motionDurationMedium1 : 250

    // 📐 尺寸与比例自适应 (Sizes and Proportions)
    readonly property real checkboxSize: {
        if (size === "xs") return 14 * themeGlobalScale
        if (size === "s") return 16 * themeGlobalScale
        if (size === "m") return 18 * themeGlobalScale
        if (size === "l") return 24 * themeGlobalScale
        if (size === "xl") return 32 * themeGlobalScale
        return 18 * themeGlobalScale
    }

    readonly property real checkboxBorderWidth: {
        const borderVal = (thickness === "thin" ? (typeof MeoTheme !== 'undefined' ? MeoTheme.strokeWidthThin : 1 * themeGlobalScale) :
                           (thickness === "thick" ? (typeof MeoTheme !== 'undefined' ? MeoTheme.strokeWidthThick : 3 * themeGlobalScale) :
                           (typeof MeoTheme !== 'undefined' ? MeoTheme.strokeWidthMedium : 2 * themeGlobalScale)))
        if (size === "xs") return Math.max(1, borderVal * 0.75)
        if (size === "xl") return borderVal * 1.5
        return borderVal
    }

    readonly property var fontLabel: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium }
        if (size === "xs") return MeoTheme.labelSmallUi
        if (size === "s") return MeoTheme.labelMediumUi
        if (size === "m") return MeoTheme.labelBig
        if (size === "l") return MeoTheme.bodyMediumUi
        if (size === "xl") return MeoTheme.bodyBig
        return MeoTheme.labelBig
    }

    implicitWidth: Math.max(checkboxRect.width + (label !== "" ? spacing + labelText.implicitWidth : 0), 40 * themeGlobalScale)
    implicitHeight: Math.max(checkboxRect.height, 40 * themeGlobalScale) + ((errorText !== "" && isError) || helperText !== "" ? 20 * themeGlobalScale : 0)

    padding: 8 * themeGlobalScale
    spacing: 12 * themeGlobalScale

    // 点击交互
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: control.enabled
        onClicked: {
            control.checked = !control.checked
            control.toggled(control.checked)
        }
    }

    contentItem: Column {
        spacing: 4 * control.themeGlobalScale

        Row {
            spacing: control.spacing

            // 🎨 复选框容器 (Checkbox container)
            Rectangle {
                id: checkboxRect
                width: control.checkboxSize
                height: control.checkboxSize
                anchors.verticalCenter: parent.verticalCenter
                radius: 2 * control.themeGlobalScale

                color: {
                    if (!control.enabled) return "transparent"
                    if (control.checked || control.indeterminate) return control.isError ? control.themeError : control.themePrimary
                    return "transparent"
                }

                border.color: {
                    if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38)
                    if (control.checked || control.indeterminate) return control.isError ? control.themeError : control.themePrimary
                    return control.isError ? control.themeError : control.themeOutline
                }
                border.width: control.checkboxBorderWidth

                // 🌟 状态层反馈 (Hover/Pressed/Focused states)
                Item {
                    anchors.centerIn: parent
                    width: control.checkboxSize + 22 * control.themeGlobalScale
                    height: control.checkboxSize + 22 * control.themeGlobalScale
                    z: -1

                    MeoStateLayer {
                        radius: width / 2
                        shape: "circle"
                        pressed: mouseArea.pressed
                        hovered: mouseArea.containsMouse
                        focused: control.activeFocus
                        pressX: mouseArea.mouseX - parent.x
                        pressY: mouseArea.mouseY - parent.y
                        color: control.checked ? (control.isError ? control.themeError : control.themePrimary) : control.themeOnSurface
                    }
                }

                // 🌟 对勾/不确定态图标 (Animated Canvas Path)
                Canvas {
                    id: checkmarkCanvas
                    anchors.fill: parent
                    anchors.margins: Math.max(1, 2 * control.themeGlobalScale)
                    property real animationProgress: (control.checked || control.indeterminate) ? 1.0 : 0.0

                    onAnimationProgressChanged: requestPaint()

                    Connections {
                        target: control
                        function onIndeterminateChanged() { checkmarkCanvas.requestPaint() }
                    }

                    Behavior on animationProgress {
                        NumberAnimation { duration: control.motionCheckDuration; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] }
                    }

                    onPaint: {
                        var ctx = getContext("2d");
                        ctx.reset();
                        ctx.strokeStyle = control.themeOnPrimary;
                        ctx.lineWidth = Math.max(1.5, 2.5 * control.themeGlobalScale * (control.size === "xs" ? 0.75 : (control.size === "xl" ? 1.5 : 1.0)));
                        ctx.lineCap = "round";
                        ctx.lineJoin = "round";

                        var w = width;
                        var h = height;

                        if (control.indeterminate) {
                            // Horizontal line for indeterminate
                            ctx.beginPath();
                            ctx.moveTo(w * 0.2, h * 0.5);
                            ctx.lineTo(w * 0.2 + (w * 0.6) * animationProgress, h * 0.5);
                            ctx.stroke();
                        } else {
                            // Checkmark points
                            var p1 = { x: w * 0.15, y: h * 0.5 };
                            var p2 = { x: w * 0.4, y: h * 0.75 };
                            var p3 = { x: w * 0.85, y: h * 0.2 };

                            ctx.beginPath();
                            if (animationProgress > 0) {
                                ctx.moveTo(p1.x, p1.y);
                                if (animationProgress <= 0.4) {
                                    var t = animationProgress / 0.4;
                                    ctx.lineTo(p1.x + (p2.x - p1.x) * t, p1.y + (p2.y - p1.y) * t);
                                } else {
                                    ctx.lineTo(p2.x, p2.y);
                                    var t = (animationProgress - 0.4) / 0.6;
                                    ctx.lineTo(p2.x + (p3.x - p2.x) * t, p2.y + (p3.y - p2.y) * t);
                                }
                            }
                            ctx.stroke();
                        }
                    }
                }

                Behavior on color { ColorAnimation { duration: control.motionStateDuration; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
                Behavior on border.color { ColorAnimation { duration: control.motionStateDuration; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
            }

            // 🔤 标签文本
            Text {
                id: labelText
                text: control.label
                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: control.fontLabel.size * control.themeGlobalScale
                font.weight: control.fontLabel.weight
                color: {
                    if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38)
                    if (control.isError) return control.themeError
                    return control.themeOnSurface
                }
                anchors.verticalCenter: parent.verticalCenter
                visible: text !== ""
            }
        }

        // Helper / Error Text Block (MD3 Specification)
        Text {
            id: feedbackText
            visible: (control.isError && control.errorText !== "") || control.helperText !== ""
            text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
            font.pixelSize: (control.fontLabel.size - 2) * control.themeGlobalScale
            color: control.isError ? control.themeError : control.themeOnSurfaceVariant
            leftPadding: control.checkboxSize + control.spacing
        }
    }
}
