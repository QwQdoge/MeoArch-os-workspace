import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property bool checked: false
    property bool indeterminate: false // 🌟 New: Indeterminate state support
    property string label: ""
    signal toggled(bool checked)

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: Math.max(checkboxRect.width + (label !== "" ? spacing + labelText.implicitWidth : 0), 40 * themeGlobalScale)
    implicitHeight: Math.max(checkboxRect.height, 40 * themeGlobalScale)

    padding: 8 * themeGlobalScale
    spacing: 12 * themeGlobalScale

    // 点击交互
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: {
            control.checked = !control.checked
            control.toggled(control.checked)
        }
    }

    contentItem: Row {
        spacing: control.spacing

        // 🎨 复选框容器
        Rectangle {
            id: checkboxRect
            width: 18 * control.themeGlobalScale
            height: 18 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            radius: 2 * control.themeGlobalScale

            color: {
                if (!control.enabled) return "transparent"
                if (control.checked || control.indeterminate) return control.themePrimary
                return "transparent"
            }

            border.color: {
                if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38)
                if (control.checked || control.indeterminate) return control.themePrimary
                return control.themeOutline
            }
            border.width: 2 * control.themeGlobalScale

            // 🌟 状态层反馈 (Hover/Pressed)
            Item {
                anchors.centerIn: parent
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                z: -1

                MeoStateLayer {
                    radius: width / 2
                    pressed: mouseArea.pressed
                    hovered: mouseArea.containsMouse
                    color: control.checked ? control.themePrimary : control.themeOnSurface
                }
            }

            // 🌟 对勾/不确定态图标 (Animated Canvas Path)
            Canvas {
                id: checkmarkCanvas
                anchors.fill: parent
                anchors.margins: 2 * control.themeGlobalScale
                property real animationProgress: (control.checked || control.indeterminate) ? 1.0 : 0.0

                onAnimationProgressChanged: requestPaint()

                Connections {
                    target: control
                    function onIndeterminateChanged() { checkmarkCanvas.requestPaint() }
                }

                Behavior on animationProgress {
                    NumberAnimation { duration: 200; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] }
                }

                onPaint: {
                    var ctx = getContext("2d");
                    ctx.reset();
                    ctx.strokeStyle = control.themeOnPrimary;
                    ctx.lineWidth = 2.5 * control.themeGlobalScale;
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

            Behavior on color { ColorAnimation { duration: 200; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
            Behavior on border.color { ColorAnimation { duration: 200; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
        }

        // 🔤 标签文本
        Text {
            id: labelText
            text: control.label
            font.pixelSize: 14 * control.themeGlobalScale
            color: control.enabled ? control.themeOnSurface : (isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38))
            anchors.verticalCenter: parent.verticalCenter
            visible: text !== ""
        }
    }
}
