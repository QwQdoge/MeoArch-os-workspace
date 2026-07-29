import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control
    activeFocusOnTab: true

    // 🌟 核心属性
    property bool checked: false
    property bool isExpressive: MeoTheme.isExpressive
    property string label: ""
    property string text: label
    property bool showIcon: true
    property string icon: "check"
    property string uncheckedIcon: ""
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string thickness: "medium" // "thin" | "medium" | "thick"
    property bool isError: false
    property string errorText: ""
    property string helperText: ""

    signal toggled(bool checked)

    onTextChanged: label = text
    onLabelChanged: {
        if (text !== label)
            text = label
    }

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeError: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.error !== 'undefined') ? MeoTheme.error : "#B3261E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int motionFast: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationFast !== 'undefined') ? MeoTheme.motionDurationFast : 150
    readonly property int motionShort: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationShort4 !== 'undefined') ? MeoTheme.motionDurationShort4 : 200
    readonly property int motionMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationMedium1 !== 'undefined') ? MeoTheme.motionDurationMedium1 : 250

    // 📐 尺寸与比例自适应 (Sizes and Proportions)
    readonly property real trackWidth: {
        if (size === "xs") return 32 * themeGlobalScale
        if (size === "s") return 40 * themeGlobalScale
        if (size === "m") return 52 * themeGlobalScale
        if (size === "l") return 64 * themeGlobalScale
        if (size === "xl") return 80 * themeGlobalScale
        return 52 * themeGlobalScale
    }

    readonly property real trackHeight: {
        if (size === "xs") return 20 * themeGlobalScale
        if (size === "s") return 24 * themeGlobalScale
        if (size === "m") return 32 * themeGlobalScale
        if (size === "l") return 40 * themeGlobalScale
        if (size === "xl") return 48 * themeGlobalScale
        return 32 * themeGlobalScale
    }

    readonly property real switchBorderWidth: {
        if (checked) return 0
        const borderVal = (thickness === "thin" ? (typeof MeoTheme !== 'undefined' ? MeoTheme.strokeWidthThin : 1 * themeGlobalScale) :
                           (thickness === "thick" ? (typeof MeoTheme !== 'undefined' ? MeoTheme.strokeWidthThick : 3 * themeGlobalScale) :
                           (typeof MeoTheme !== 'undefined' ? MeoTheme.strokeWidthMedium : 2 * themeGlobalScale)))
        if (size === "xs") return Math.max(1, borderVal * 0.75)
        if (size === "xl") return borderVal * 1.5
        return borderVal
    }

    readonly property real thumbSizeUnchecked: {
        if (size === "xs") return 10 * themeGlobalScale
        if (size === "s") return 12 * themeGlobalScale
        if (size === "m") return 16 * themeGlobalScale
        if (size === "l") return 20 * themeGlobalScale
        if (size === "xl") return 24 * themeGlobalScale
        return 16 * themeGlobalScale
    }

    readonly property real thumbSizeChecked: {
        if (size === "xs") return 14 * themeGlobalScale
        if (size === "s") return 18 * themeGlobalScale
        if (size === "m") return 24 * themeGlobalScale
        if (size === "l") return 30 * themeGlobalScale
        if (size === "xl") return 36 * themeGlobalScale
        return 24 * themeGlobalScale
    }

    readonly property real thumbPadding: {
        if (size === "xs") return 2 * themeGlobalScale
        if (size === "s") return 3 * themeGlobalScale
        if (size === "m") return 4 * themeGlobalScale
        if (size === "l") return 5 * themeGlobalScale
        if (size === "xl") return 6 * themeGlobalScale
        return 4 * themeGlobalScale
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

    implicitWidth: Math.max(switchTrack.width + (label !== "" ? spacing + labelText.implicitWidth : 0), 52 * themeGlobalScale)
    implicitHeight: Math.max(switchTrack.height, 40 * themeGlobalScale) + ((errorText !== "" && isError) || helperText !== "" ? 20 * themeGlobalScale : 0)

    padding: 8 * themeGlobalScale
    spacing: 12 * themeGlobalScale

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

            Rectangle {
                id: switchTrack
                width: control.trackWidth
                height: control.trackHeight
                anchors.verticalCenter: parent.verticalCenter
                radius: height / 2
                clip: true

                color: {
                    if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
                    if (control.checked) return control.isError ? control.themeError : control.themePrimary
                    return control.themeSurfaceContainerHighest
                }

                border.color: {
                    if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
                    if (control.checked) return control.isError ? control.themeError : control.themePrimary
                    return control.isError ? control.themeError : control.themeOutline
                }
                border.width: control.switchBorderWidth

                Rectangle {
                    id: thumb
                    width: {
                        if (mouseArea.pressed) return (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive ? control.thumbSizeChecked * 1.33 : control.thumbSizeChecked * 1.15)
                        if (mouseArea.containsMouse) return control.thumbSizeChecked * 1.15
                        return (control.checked || control.showIcon) ? control.thumbSizeChecked : control.thumbSizeUnchecked
                    }
                    height: width
                    radius: width / 2
                    anchors.verticalCenter: parent.verticalCenter
                    x: control.checked ? (parent.width - width - control.thumbPadding) : (control.thumbPadding + (control.thumbSizeChecked - width) / 2)

                    MeoIcon {
                        id: thumbIcon
                        anchors.centerIn: parent
                        icon: control.checked ? (control.showIcon ? (control.icon || "check") : "") : control.uncheckedIcon
                        size: Math.max(10, control.thumbSizeChecked * 0.64)
                        color: control.checked ? (control.isError ? control.themeError : control.themePrimary) : control.themeOnSurfaceVariant
                        visible: icon !== ""
                        scale: (control.checked ? control.showIcon : control.uncheckedIcon !== "") ? 1.0 : 0.0
                        Behavior on scale {
                            NumberAnimation {
                                duration: control.motionMedium
                                easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.05, 0.7, 0.1, 1]
                            }
                        }
                    }

                    color: {
                        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38)
                        if (control.checked) return control.themeOnPrimary
                        return control.isError ? control.themeError : control.themeOutline
                    }

                    Item {
                        anchors.centerIn: parent
                        width: control.trackHeight + 8 * control.themeGlobalScale
                        height: width

                        MeoStateLayer {
                            radius: width / 2
                            shape: "circle"
                            pressed: mouseArea.pressed
                            hovered: mouseArea.containsMouse
                            focused: control.activeFocus
                            pressX: mouseArea.mouseX - thumb.x
                            pressY: mouseArea.mouseY - thumb.y
                            color: control.checked ? (control.isError ? control.themeError : control.themePrimary) : control.themeOnSurface
                        }
                    }

                    Behavior on x {
                        NumberAnimation {
                            duration: control.motionMedium
                            easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]
                        }
                    }
                    Behavior on width {
                        NumberAnimation {
                            duration: control.motionShort
                            easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                        }
                    }
                    Behavior on height {
                        NumberAnimation {
                            duration: control.motionShort
                            easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1]
                        }
                    }
                    Behavior on color { ColorAnimation { duration: control.motionFast; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                }

                Behavior on color { ColorAnimation { duration: control.motionShort; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on border.color { ColorAnimation { duration: control.motionShort; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
            }

            Text {
                id: labelText
                text: control.label
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
            leftPadding: control.trackWidth + control.spacing
        }
    }
}
