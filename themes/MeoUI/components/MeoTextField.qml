import QtQuick
import QtQuick.Controls
import MeoUI

TextField {
    id: control

    // 🌟 核心对外属性
    property string type: "filled" // "filled" (默认) | "outlined"
    property string label: "" // 悬浮标签文本
    property string helperText: "" // 底部辅助文本
    property bool isError: false // 错误状态开关
    property string errorText: "" // 错误提示文本（开启 isError 时优先显示）
    property bool showClearButton: false // 是否显示一键清除按钮
    property string placeholder: "" // 代替 placeholderText 以防止 Binding Loop 的占位文本

    // MD3 扩展属性
    property string leadingIcon: "" // 前置图标
    property string trailingIcon: "" // 后置图标
    property string prefixText: "" // 前缀文本
    property string suffixText: "" // 后缀文本
    property int maxLength: -1 // 最大长度，用于计数器
    property bool showCounter: false // 是否显示计数器

    // 🌟 作用域防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    
    // 安全的主题属性转发
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeError: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.error !== 'undefined') ? MeoTheme.error : "#B3261E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // Typography
    readonly property var fontBodyLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyLarge !== 'undefined') ? MeoTheme.bodyLarge : { "size": 16, "weight": Font.Normal }
    readonly property var fontBodySmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodySmall !== 'undefined') ? MeoTheme.bodySmall : { "size": 12, "weight": Font.Normal }
    readonly property var fontLabelSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelSmall !== 'undefined') ? MeoTheme.labelSmall : { "size": 11, "weight": Font.Medium }

    // 🌟 尺寸定义
    readonly property real containerHeight: 56 * themeGlobalScale
    readonly property real helperSpace: (helperText !== "" || (isError && errorText !== "") || showCounter) ? 20 * themeGlobalScale : 0

    padding: 0
    implicitHeight: containerHeight + helperSpace
    implicitWidth: 280 * themeGlobalScale

    color: {
        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        return isError ? themeError : themeOnSurface;
    }
    selectionColor: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0.3)
    selectedTextColor: themeOnSurface
    font.pixelSize: fontBodyLarge.size * themeGlobalScale
    font.weight: fontBodyLarge.weight
    selectByMouse: true
    
    placeholderText: (label === "" || overlayLayer.isCollapsed) ? placeholder : ""
    placeholderTextColor: {
        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        return isError ? themeError : themeOnSurfaceVariant;
    }

    // 🌟 内边距自适应优化 (Corrected to account for icon width and internal spacing)
    leftPadding: (leadingIcon !== "" ? (12 + 24 + 16) : 16) * themeGlobalScale + (prefixText !== "" ? prefixLabel.implicitWidth + 4 * themeGlobalScale : 0)
    rightPadding: ((trailingIcon !== "" || (showClearButton && text !== "")) ? (12 + 24 + 16) : 16) * themeGlobalScale + (suffixText !== "" ? suffixLabel.implicitWidth + 4 * themeGlobalScale : 0)
    topPadding: type === "filled" 
                ? (label !== "" ? 24 * themeGlobalScale : 16 * themeGlobalScale) 
                : 16 * themeGlobalScale
    bottomPadding: (type === "filled" 
                    ? (label !== "" ? 8 * themeGlobalScale : 16 * themeGlobalScale) 
                    : 16 * themeGlobalScale) + helperSpace

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
            radius: control.type === "filled" ? 0 : 4 * control.themeGlobalScale
            // MD3: Filled text fields have rounded top corners (4dp) but flat bottom
            topLeftRadius: 4 * control.themeGlobalScale
            topRightRadius: 4 * control.themeGlobalScale
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

            Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }

            border.color: control.type === "outlined" ? control.indicatorColor : "transparent"
            border.width: control.type === "outlined" ? (control.activeFocus ? 2 : 1) : 0
            
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Rectangle {
                id: activeIndicator
                anchors.bottom: parent.bottom
                anchors.horizontalCenter: parent.horizontalCenter
                width: control.activeFocus ? parent.width : 0
                height: control.activeFocus ? 2 * control.themeGlobalScale : 1 * control.themeGlobalScale
                color: control.indicatorColor
                visible: control.type === "filled"

                Behavior on width { NumberAnimation { duration: 200; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    // Leading Content
    Row {
        id: leadingRow
        anchors.left: parent.left
        anchors.leftMargin: 12 * control.themeGlobalScale
        height: control.containerHeight
        spacing: 16 * control.themeGlobalScale
        visible: control.leadingIcon !== "" || control.prefixText !== ""

        MeoIcon {
            icon: control.leadingIcon
            visible: control.leadingIcon !== ""
            anchors.verticalCenter: parent.verticalCenter
            color: control.enabled ? control.themeOnSurfaceVariant : Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.38)
        }

        Text {
            id: prefixLabel
            text: control.prefixText
            visible: control.prefixText !== ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: (control.type === "filled" && control.label !== "") ? 8 * control.themeGlobalScale : 0
            font.pixelSize: control.fontBodyLarge.size * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
        }
    }

    // Trailing Content
    Row {
        id: trailingRow
        anchors.right: parent.right
        anchors.rightMargin: 12 * control.themeGlobalScale
        height: control.containerHeight
        spacing: 16 * control.themeGlobalScale

        Text {
            id: suffixLabel
            text: control.suffixText
            visible: control.suffixText !== ""
            anchors.verticalCenter: parent.verticalCenter
            anchors.verticalCenterOffset: (control.type === "filled" && control.label !== "") ? 8 * control.themeGlobalScale : 0
            font.pixelSize: control.fontBodyLarge.size * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
        }

        MeoIcon {
            icon: control.trailingIcon
            visible: control.trailingIcon !== ""
            anchors.verticalCenter: parent.verticalCenter
            color: control.isError ? control.themeError : control.themeOnSurfaceVariant
        }

        // Clear Button
        MeoIconButton {
            visible: control.showClearButton && control.text !== "" && control.enabled && control.trailingIcon === ""
            icon.name: "close"
            anchors.verticalCenter: parent.verticalCenter
            width: 28 * control.themeGlobalScale
            height: 28 * control.themeGlobalScale
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
        visible: control.label !== ""
        enabled: false
        
        readonly property bool isCollapsed: control.activeFocus || control.text !== "" || control.prefixText !== ""

        Item {
            id: labelContainer
            x: (control.leadingIcon !== "" ? (12 + 24 + 16) : 16) * control.themeGlobalScale
            y: overlayLayer.isCollapsed 
               ? (control.type === "filled" ? 8 * control.themeGlobalScale : -12 * control.themeGlobalScale)
               : 16 * control.themeGlobalScale
            width: labelText.implicitWidth
            height: labelText.implicitHeight
            scale: overlayLayer.isCollapsed ? (control.fontLabelSmall.size / control.fontBodyLarge.size) : 1.0
            transformOrigin: Item.Left

            Behavior on y { NumberAnimation { duration: 200; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
            Behavior on scale { NumberAnimation { duration: 200; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }

            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -4 * control.themeGlobalScale
                anchors.rightMargin: -4 * control.themeGlobalScale
                color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.background !== 'undefined') ? MeoTheme.background : (isDarkMode ? "#121212" : "#FFFFFF")
                visible: control.type === "outlined" && overlayLayer.isCollapsed
            }

            Text {
                id: labelText
                text: control.label
                anchors.fill: parent
                font.pixelSize: control.fontBodyLarge.size * control.themeGlobalScale
                font.weight: overlayLayer.isCollapsed ? control.fontLabelSmall.weight : control.fontBodyLarge.weight
                color: {
                    if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
                    if (control.isError) return control.themeError;
                    if (control.activeFocus) return control.themePrimary;
                    return control.themeOnSurfaceVariant;
                }

                Behavior on color { ColorAnimation { duration: 150 } }
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
        visible: helperLabel.text !== "" || counterLabel.visible

        Text {
            id: helperLabel
            anchors.left: parent.left
            anchors.right: counterLabel.left
            anchors.rightMargin: 16 * control.themeGlobalScale
            text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
            font.pixelSize: control.fontBodySmall.size * control.themeGlobalScale
            color: {
                if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
                return control.isError ? control.themeError : control.themeOnSurfaceVariant;
            }
            elide: Text.ElideRight
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Text {
            id: counterLabel
            anchors.right: parent.right
            visible: control.showCounter
            text: control.maxLength > 0 ? (control.text.length + " / " + control.maxLength) : control.text.length
            font.pixelSize: control.fontBodySmall.size * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
        }
    }
}
