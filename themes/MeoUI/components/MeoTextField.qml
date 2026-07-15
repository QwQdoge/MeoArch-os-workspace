import QtQuick
import QtQuick.Controls
import MeoUI

TextField {
    id: control

    // 🌟 核心对外属性
    property string type: "filled" // "filled" (默认) | "outlined"
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string label: "" // 悬浮标签文本
    property string helperText: "" // 底部辅助文本
    property bool isError: false // 错误状态开关
    property string errorText: "" // 错误提示文本（开启 isError 时优先显示）
    property bool showClearButton: false // 是否显示一键清除按钮
    property string placeholder: "" // 代替 placeholderText 以防止 Binding Loop 的占位文本
    property string supportingText: "" // Reference-compatible alias for helper text.
    property bool error: isError
    property bool isPassword: false
    property bool passwordVisible: false

    // MD3 扩展属性
    property string leadingIcon: "" // 前置图标
    property string trailingIcon: "" // 后置图标
    property string prefixText: "" // 前缀文本
    property string suffixText: "" // 后缀文本
    property int maxLength: -1 // 最大长度，用于计数器
    property bool showCounter: false // 是否显示计数器

    signal trailingIconClicked()

    onSupportingTextChanged: helperText = supportingText
    onHelperTextChanged: {
        if (supportingText !== helperText)
            supportingText = helperText
    }
    onErrorChanged: isError = error
    onIsErrorChanged: {
        if (error !== isError)
            error = isError
    }

    // 🌟 作用域防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationFast !== "undefined") ? MeoTheme.motionDurationFast : 150
    readonly property int motionMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationMedium !== "undefined") ? MeoTheme.motionDurationMedium : 300
    
    // 安全的主题属性转发
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeError: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.error !== 'undefined') ? MeoTheme.error : "#B3261E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // Typography
    readonly property var fontBodyLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyLarge !== 'undefined') ? MeoTheme.bodyLarge : { "size": 16, "weight": Font.Normal }
    readonly property var fontBodyMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyMedium !== 'undefined') ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal }
    readonly property var fontBodySmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodySmall !== 'undefined') ? MeoTheme.bodySmall : { "size": 12, "weight": Font.Normal }
    readonly property var fontLabelSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelSmall !== 'undefined') ? MeoTheme.labelSmall : { "size": 11, "weight": Font.Medium }

    // 🌟 尺寸定义
    readonly property real containerHeight: {
        if (size === "xs") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.buttonHeightXS !== 'undefined') ? MeoTheme.buttonHeightXS : 32 * themeGlobalScale;
        if (size === "s") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.buttonHeightS !== 'undefined') ? MeoTheme.buttonHeightS : 40 * themeGlobalScale;
        if (size === "m") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.buttonHeightM !== 'undefined') ? MeoTheme.buttonHeightM : 48 * themeGlobalScale;
        if (size === "l") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.buttonHeightL !== 'undefined') ? MeoTheme.buttonHeightL : 56 * themeGlobalScale;
        if (size === "xl") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.buttonHeightXL !== 'undefined') ? MeoTheme.buttonHeightXL : 72 * themeGlobalScale;
        return 56 * themeGlobalScale;
    }
    readonly property real helperSpace: (helperText !== "" || (isError && errorText !== "") || showCounter) ? 20 * themeGlobalScale : 0

    padding: 0
    implicitHeight: containerHeight + (size === "xs" ? 0 : helperSpace)
    implicitWidth: 280 * themeGlobalScale

    color: {
        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        return isError ? themeError : themeOnSurface;
    }
    selectionColor: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0.3)
    selectedTextColor: themeOnSurface

    readonly property var currentFont: {
        if (size === "xs") return fontBodySmall;
        if (size === "s") return fontBodyMedium;
        return fontBodyLarge;
    }

    font.pixelSize: currentFont.size * themeGlobalScale
    font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
    font.weight: currentFont.weight
    echoMode: control.isPassword && !control.passwordVisible ? TextInput.Password : TextInput.Normal
    selectByMouse: true
    
    placeholderText: (label === "" || overlayLayer.isCollapsed) ? placeholder : ""
    placeholderTextColor: {
        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        return isError ? themeError : themeOnSurfaceVariant;
    }

    // 🌟 内边距自适应优化
    readonly property real sidePadding: {
        if (size === "xs") return 8 * themeGlobalScale;
        if (size === "s") return 12 * themeGlobalScale;
        return 16 * themeGlobalScale;
    }

    leftPadding: (leadingIcon !== "" ? (sidePadding + 24 * themeGlobalScale + 8 * themeGlobalScale) : sidePadding) + (prefixText !== "" ? prefixLabel.implicitWidth + 4 * themeGlobalScale : 0)
    rightPadding: ((trailingIcon !== "" || (showClearButton && text !== "")) ? (sidePadding + 24 * themeGlobalScale + 8 * themeGlobalScale) : sidePadding) + (suffixText !== "" ? suffixLabel.implicitWidth + 4 * themeGlobalScale : 0)
    topPadding: type === "filled" 
                ? (label !== "" ? (size === "xs" ? 16 : 24) * themeGlobalScale : (size === "xs" ? 8 : (size === "xl" ? 24 : 16)) * themeGlobalScale)
                : (size === "xs" ? 8 : (size === "xl" ? 24 : 16)) * themeGlobalScale
    bottomPadding: (type === "filled" 
                    ? (label !== "" ? (size === "xs" ? 4 : 8) * themeGlobalScale : (size === "xs" ? 8 : (size === "xl" ? 24 : 16)) * themeGlobalScale)
                    : (size === "xs" ? 8 : (size === "xl" ? 24 : 16)) * themeGlobalScale) + (size === "xs" ? 0 : helperSpace)

    readonly property color transparentBg: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0)

    readonly property color containerColor: {
        if (!control.enabled) return type === "filled" ? Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.04) : transparentBg;
        return type === "filled" ? themeSurfaceContainerHighest : transparentBg;
    }

    readonly property color indicatorColor: {
        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        if (isError) return themeError;
        if (control.activeFocus) return themePrimary;
        if (control.hovered) return themeOnSurface;
        return type === "filled" ? themeOnSurfaceVariant : themeOutline;
    }

    background: Item {
        Rectangle {
            id: containerRect
            width: parent.width
            height: control.containerHeight
            radius: control.type === "filled"
                    ? 12 * control.themeGlobalScale
                    : (control.activeFocus ? 16 : 12) * control.themeGlobalScale
            topLeftRadius: control.activeFocus ? 16 * control.themeGlobalScale : 12 * control.themeGlobalScale
            topRightRadius: control.activeFocus ? 16 * control.themeGlobalScale : 12 * control.themeGlobalScale
            color: {
                let base = control.containerColor;
                if (control.enabled && control.hovered && control.type === "filled") {
                    return Qt.tint(base, Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08));
                }
                return base;
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 4 * control.themeGlobalScale
                color: containerRect.color
                visible: control.type === "filled"
            }

            Behavior on color { ColorAnimation { duration: control.motionFast; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }

            border.color: control.type === "outlined" ? control.indicatorColor : "transparent"
            border.width: control.type === "outlined" ? (control.activeFocus ? 2 : 1) : 0
            
            Behavior on border.color { ColorAnimation { duration: control.motionFast } }
            Behavior on radius { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: (typeof MeoTheme !== "undefined" ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]) } }
            Behavior on topLeftRadius { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: (typeof MeoTheme !== "undefined" ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]) } }
            Behavior on topRightRadius { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: (typeof MeoTheme !== "undefined" ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]) } }

            Rectangle {
                id: activeIndicator
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: control.activeFocus ? 2 * control.themeGlobalScale : 1 * control.themeGlobalScale
                color: control.indicatorColor
                visible: control.type === "filled"

                Behavior on height { NumberAnimation { duration: control.motionFast; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on color { ColorAnimation { duration: control.motionFast } }
            }
        }
    }

    // Leading Content
    Row {
        id: leadingRow
        anchors.left: parent.left
        anchors.leftMargin: control.sidePadding
        height: control.containerHeight
        spacing: 8 * control.themeGlobalScale
        visible: control.leadingIcon !== "" || control.prefixText !== ""

        MeoIcon {
            icon: control.leadingIcon
            visible: control.leadingIcon !== ""
            size: control.size === "xs" ? 18 : 24
            anchors.verticalCenter: parent.verticalCenter
            color: control.enabled ? control.themeOnSurfaceVariant : Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.38)
        }

        MeoText {
            id: prefixLabel
            text: control.prefixText
            visible: control.prefixText !== ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: (control.type === "filled" && control.label !== "") ? 8 * control.themeGlobalScale : 0
            typeRole: "body"
            typeSize: control.size === "xs" ? "small" : "large"
            color: control.themeOnSurfaceVariant
        }
    }

    // Trailing Content
    Row {
        id: trailingRow
        anchors.right: parent.right
        anchors.rightMargin: control.sidePadding
        height: control.containerHeight
        spacing: 8 * control.themeGlobalScale

        MeoText {
            id: suffixLabel
            text: control.suffixText
            visible: control.suffixText !== ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: (control.type === "filled" && control.label !== "") ? 8 * control.themeGlobalScale : 0
            typeRole: "body"
            typeSize: control.size === "xs" ? "small" : "large"
            color: control.themeOnSurfaceVariant
        }

        MeoIcon {
            icon: control.trailingIcon
            visible: control.trailingIcon !== "" && !control.isPassword
            size: control.size === "xs" ? 18 : 24
            anchors.verticalCenter: parent.verticalCenter
            color: control.isError ? control.themeError : control.themeOnSurfaceVariant

            MouseArea {
                anchors.fill: parent
                anchors.margins: -12 * control.themeGlobalScale
                enabled: control.enabled
                cursorShape: Qt.PointingHandCursor
                onClicked: control.trailingIconClicked()
            }
        }

        MeoIconButton {
            visible: control.isPassword
            icon.name: control.passwordVisible ? "visibility_off" : "visibility"
            anchors.verticalCenter: parent.verticalCenter
            width: (control.size === "xs" ? 24 : 32) * control.themeGlobalScale
            height: width
            size: control.size === "xs" ? "xs" : "s"
            type: "standard"
            onClicked: control.passwordVisible = !control.passwordVisible
        }

        // Clear Button
        MeoIconButton {
            visible: control.showClearButton && control.text !== "" && control.enabled && control.trailingIcon === ""
            icon.name: "close"
            anchors.verticalCenter: parent.verticalCenter
            width: (control.size === "xs" ? 24 : 28) * control.themeGlobalScale
            height: width
            size: control.size === "xs" ? "xs" : "s"
            padding: 4 * control.themeGlobalScale
            onClicked: {
                control.text = "";
                control.forceActiveFocus();
            }
        }
    }

    // Label Layer
    Item {
        id: overlayLayer
        width: parent.width
        height: control.containerHeight
        visible: control.label !== "" && control.size !== "xs"
        enabled: false
        
        readonly property bool isCollapsed: control.activeFocus || control.text !== "" || control.prefixText !== ""

        Item {
            id: labelContainer
            x: control.leftPadding - (control.prefixText !== "" ? prefixLabel.implicitWidth + 4 * control.themeGlobalScale : 0)
            y: overlayLayer.isCollapsed 
               ? (control.type === "filled" ? 8 * control.themeGlobalScale : -12 * control.themeGlobalScale)
               : (control.containerHeight - labelText.implicitHeight) / 2
            width: labelText.implicitWidth
            height: labelText.implicitHeight
            scale: {
                let targetSize = overlayLayer.isCollapsed ? (MeoTheme.labelSmallEmphasized ? MeoTheme.labelSmallEmphasized.size : control.fontLabelSmall.size) : control.currentFont.size;
                return targetSize / control.currentFont.size;
            }
            transformOrigin: Item.Left

            readonly property var labelFont: overlayLayer.isCollapsed ? (MeoTheme.labelSmallEmphasized || control.fontLabelSmall) : control.currentFont

            Behavior on y { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
            Behavior on scale { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -4 * control.themeGlobalScale
                anchors.rightMargin: -4 * control.themeGlobalScale
                color: control.themeSurface
                visible: control.type === "outlined" && overlayLayer.isCollapsed
            }

            Text {
                id: labelText
                text: control.label
                anchors.fill: parent
                font.pixelSize: control.currentFont.size * control.themeGlobalScale
                font.weight: labelContainer.labelFont.weight
                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                color: {
                    if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
                    if (control.isError) return control.themeError;
                    if (control.activeFocus) return control.themePrimary;
                    return control.themeOnSurfaceVariant;
                }

                Behavior on color { ColorAnimation { duration: control.motionFast } }
            }
        }
    }

    // Supporting text area
    Item {
        anchors.top: parent.top
        anchors.topMargin: control.containerHeight + 4 * control.themeGlobalScale
        anchors.left: parent.left
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.right: parent.right
        anchors.rightMargin: 16 * control.themeGlobalScale
        height: 16 * control.themeGlobalScale
        visible: (helperLabel.text !== "" || counterLabel.visible) && control.size !== "xs"

        Text {
            id: helperLabel
            anchors.left: parent.left
            anchors.right: counterLabel.left
            anchors.rightMargin: 16 * control.themeGlobalScale
            text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
            font.pixelSize: control.fontBodySmall.size * control.themeGlobalScale
            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
            color: {
                if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
                return control.isError ? control.themeError : control.themeOnSurfaceVariant;
            }
            elide: Text.ElideRight
            Behavior on color { ColorAnimation { duration: control.motionFast } }
        }

        Text {
            id: counterLabel
            anchors.right: parent.right
            visible: control.showCounter
            text: control.maxLength > 0 ? (control.text.length + " / " + control.maxLength) : control.text.length
            font.pixelSize: control.fontBodySmall.size * control.themeGlobalScale
            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
            color: control.themeOnSurfaceVariant
        }
    }
}
