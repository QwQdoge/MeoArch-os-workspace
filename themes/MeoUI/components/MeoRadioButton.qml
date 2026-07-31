import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control
    activeFocusOnTab: true

    // 🌟 核心属性
    property bool checked: false
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
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeError: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.error !== 'undefined') ? MeoTheme.error : "#B3261E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int motionStateDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationShort2 !== 'undefined') ? MeoTheme.motionDurationShort2 : 100
    readonly property int motionSelectDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationFast !== 'undefined') ? MeoTheme.motionDurationFast : 150

    // 📐 尺寸与比例自适应 (Sizes and Proportions)
    readonly property real radioOuterSize: {
        if (size === "xs") return 16 * themeGlobalScale
        if (size === "s") return 18 * themeGlobalScale
        if (size === "m") return 20 * themeGlobalScale
        if (size === "l") return 26 * themeGlobalScale
        if (size === "xl") return 34 * themeGlobalScale
        return 20 * themeGlobalScale
    }

    readonly property real radioBorderWidth: {
        const borderVal = (thickness === "thin" ? (typeof MeoTheme !== 'undefined' ? MeoTheme.strokeWidthThin : 1 * themeGlobalScale) :
                           (thickness === "thick" ? (typeof MeoTheme !== 'undefined' ? MeoTheme.strokeWidthThick : 3 * themeGlobalScale) :
                           (typeof MeoTheme !== 'undefined' ? MeoTheme.strokeWidthMedium : 2 * themeGlobalScale)))
        if (size === "xs") return Math.max(1, borderVal * 0.75)
        if (size === "xl") return borderVal * 1.5
        return borderVal
    }

    readonly property real radioInnerSize: {
        if (size === "xs") return 8 * themeGlobalScale
        if (size === "s") return 9 * themeGlobalScale
        if (size === "m") return 10 * themeGlobalScale
        if (size === "l") return 14 * themeGlobalScale
        if (size === "xl") return 18 * themeGlobalScale
        return 10 * themeGlobalScale
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

    implicitWidth: Math.max(radioOuter.width + (label !== "" ? spacing + labelText.implicitWidth : 0), 40 * themeGlobalScale)
    implicitHeight: Math.max(radioOuter.height, 40 * themeGlobalScale) + ((errorText !== "" && isError) || helperText !== "" ? 20 * themeGlobalScale : 0)

    padding: 8 * themeGlobalScale
    spacing: 12 * themeGlobalScale

    // 点击交互
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        enabled: control.enabled
        onClicked: {
            if (!control.checked) {
                control.checked = true
                control.toggled(true)
            }
        }
    }

    contentItem: Column {
        spacing: 4 * control.themeGlobalScale

        Row {
            spacing: control.spacing

            // 🎨 单选框外圈 (Radio outer ring)
            Rectangle {
                id: radioOuter
                width: control.radioOuterSize
                height: control.radioOuterSize
                anchors.verticalCenter: parent.verticalCenter
                radius: width / 2
                color: "transparent"
                border.color: {
                    if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38)
                    if (control.checked) return control.isError ? control.themeError : control.themePrimary
                    return control.isError ? control.themeError : control.themeOutline
                }
                border.width: control.radioBorderWidth

                // 🌟 核心选中原点 (Active inner point)
                Rectangle {
                    anchors.centerIn: parent
                    width: control.checked ? control.radioInnerSize : 0
                    height: width
                    radius: width / 2
                    color: control.isError ? control.themeError : control.themePrimary

                    Behavior on width {
                        NumberAnimation {
                            duration: control.motionSelectDuration
                            easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
                        }
                    }
                }

                // 🌟 状态层反馈 (Hover/Pressed/Focused states)
                Item {
                    anchors.centerIn: parent
                    width: control.radioOuterSize + 20 * control.themeGlobalScale
                    height: control.radioOuterSize + 20 * control.themeGlobalScale
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
            leftPadding: control.radioOuterSize + control.spacing
        }
    }
}
