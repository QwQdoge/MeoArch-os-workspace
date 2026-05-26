import QtQuick
import QtQuick.Controls

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

    // 🌟 作用域防御：将外部变量封装成内部属性，确保作为原子组件的独立性
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    
    // 安全的主题属性转发与默认备用值
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeError: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.error !== 'undefined') ? MeoTheme.error : "#B3261E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // 🌟 分辨率/缩放自适应尺寸定义
    readonly property real containerHeight: 56 * themeGlobalScale
    readonly property real helperSpace: (helperText !== "" || (isError && errorText !== "")) ? 20 * themeGlobalScale : 0

    padding: 0
    // 🌟 MD3 尺寸规范：高度采用 containerHeight + 辅助空间，完美支持高分屏缩放
    implicitHeight: containerHeight + helperSpace
    implicitWidth: 280

    // 光标与选区颜色
    color: {
        if (!control.enabled) {
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        }
        return isError ? themeError : themeOnSurface;
    }
    selectionColor: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0.3)
    selectedTextColor: themeOnSurface
    font.pixelSize: 16 * themeGlobalScale
    font.weight: Font.Normal
    selectByMouse: true
    
    // 避免重叠：只有在没有 Label 或者 Label 已经上浮收起时，才显示占位符
    placeholderText: (label === "" || overlayLayer.isCollapsed) ? placeholder : ""
    placeholderTextColor: {
        if (!control.enabled) {
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        }
        return isError ? themeError : themeOnSurfaceVariant;
    }

    // 🌟 内边距自适应优化：所有 Padding 均乘上 themeGlobalScale，彻底杜绝高分屏光标抖动与挤压
    topPadding: type === "filled" 
                ? (label !== "" ? 24 * themeGlobalScale : 16 * themeGlobalScale) 
                : 16 * themeGlobalScale
    bottomPadding: (type === "filled" 
                    ? (label !== "" ? 8 * themeGlobalScale : 16 * themeGlobalScale) 
                    : 16 * themeGlobalScale) + helperSpace
    leftPadding: 16 * themeGlobalScale
    rightPadding: (showClearButton && text !== "") ? 40 * themeGlobalScale : 16 * themeGlobalScale

    // 🌟 抹平 transparent 边缘黑影 Bug 的透明背景色
    readonly property color transparentBg: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0)

    // 背景色计算
    readonly property color containerColor: {
        if (!control.enabled) {
            return type === "filled" ? Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.04) : transparentBg;
        }
        if (type === "filled") {
            return themeSurfaceContainerHighest;
        }
        return transparentBg;
    }

    // 边框/底部激活线颜色计算
    readonly property color indicatorColor: {
        if (!control.enabled) {
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        }
        if (isError) {
            return themeError;
        }
        if (control.activeFocus) {
            return themePrimary;
        }
        if (control.hovered) {
            return themeOnSurface;
        }
        return type === "filled" ? themeOnSurfaceVariant : themeOutline;
    }

    // 文本输入区的外观背景
    background: Item {
        Rectangle {
            id: containerRect
            width: parent.width
            height: control.containerHeight // 使用缩放后的视觉高度
            radius: 4 * control.themeGlobalScale
            color: {
                let base = control.containerColor;
                // 状态层叠加 (State Layer 8% opacity)
                if (control.enabled && control.hovered && control.type === "filled") {
                    return Qt.tint(base, Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08));
                }
                return base;
            }

            // 🌟 底部直角覆盖物：MD3 规范中 Filled 输入框只有顶部是圆角，底部是直角
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 4 * control.themeGlobalScale
                color: containerRect.color
                visible: control.type === "filled"
            }

            // 🌟 灵魂变色动效 (150ms Bezier)
            Behavior on color {
                ColorAnimation {
                    duration: 150
                    easing.bezierCurve: [0.34, 0.8, 0.34, 1.0]
                }
            }

            // Outlined 模式下的完整边框
            border.color: control.type === "outlined" ? control.indicatorColor : "transparent"
            border.width: control.type === "outlined" ? (control.activeFocus ? 2 : 1) : 0
            
            Behavior on border.color {
                ColorAnimation {
                    duration: 150
                }
            }

            // Filled 模式下的底部激活指示线 (Active Indicator)
            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: control.activeFocus ? 2 : 1
                color: control.indicatorColor
                visible: control.type === "filled"

                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }
    }

    // 🌟 标签层：浮动 Label
    Item {
        id: overlayLayer
        width: parent.width
        height: control.containerHeight
        visible: control.label !== ""
        enabled: false // 🌟 彻底禁用鼠标事件，让点击完全穿透到地下的 TextField，防御点击失效的隐蔽地雷
        
        // 浮动 Label 的核心判断：有焦点或有输入文本时收缩至上方
        readonly property bool isCollapsed: control.activeFocus || control.text !== ""

        Item {
            id: labelContainer
            x: 16 * control.themeGlobalScale
            y: overlayLayer.isCollapsed 
               ? (control.type === "filled" ? 8 * control.themeGlobalScale : -8 * control.themeGlobalScale) 
               : 16 * control.themeGlobalScale
            width: labelText.implicitWidth
            height: labelText.implicitHeight

            Behavior on y {
                NumberAnimation {
                    duration: 150
                    easing.bezierCurve: [0.34, 0.8, 0.34, 1.0]
                }
            }

            // 遮挡 Outlined 边框的底色块，使标签浮起时有截断线线效果
            Rectangle {
                anchors.fill: parent
                anchors.leftMargin: -4 * control.themeGlobalScale
                anchors.rightMargin: -4 * control.themeGlobalScale
                color: {
                    if (typeof MeoTheme !== 'undefined' && typeof MeoTheme.windowBg !== 'undefined')
                        return MeoTheme.windowBg;
                    if (typeof MeoTheme !== 'undefined' && typeof MeoTheme.background !== 'undefined')
                        return MeoTheme.background;
                    return isDarkMode ? "#121212" : "#FFFFFF";
                }
                visible: control.type === "outlined" && overlayLayer.isCollapsed
            }

            Text {
                id: labelText
                text: control.label
                anchors.fill: parent
                font.pixelSize: overlayLayer.isCollapsed ? (12 * control.themeGlobalScale) : (16 * control.themeGlobalScale)
                font.weight: overlayLayer.isCollapsed ? Font.Medium : Font.Normal
                color: {
                    if (!control.enabled) {
                        return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
                    }
                    if (control.isError) return control.themeError;
                    if (control.activeFocus) return control.themePrimary;
                    return control.themeOnSurfaceVariant;
                }

                Behavior on font.pixelSize {
                    NumberAnimation {
                        duration: 150
                        easing.bezierCurve: [0.34, 0.8, 0.34, 1.0]
                    }
                }
                Behavior on color {
                    ColorAnimation {
                        duration: 150
                    }
                }
            }
        }
    }

    // 🌟 一键清除按钮：改造成符合 MD3 IconButton 交互标准的设计
    Button {
        id: clearButton
        anchors.right: parent.right
        anchors.rightMargin: 8 * control.themeGlobalScale
        y: (control.containerHeight - height) / 2
        width: 32 * control.themeGlobalScale
        height: 32 * control.themeGlobalScale
        visible: control.showClearButton && control.text !== "" && control.enabled
        hoverEnabled: true

        background: Rectangle {
            implicitWidth: 32 * control.themeGlobalScale
            implicitHeight: 32 * control.themeGlobalScale
            radius: width / 2
            // 🌟 动态状态层背景反馈 (Hover 8%, Pressed 12%)
            color: {
                if (clearButton.pressed)
                    return Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.12);
                if (clearButton.hovered)
                    return Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.08);
                return "transparent";
            }
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
        }
        
        contentItem: Text {
            text: "×"
            font.pixelSize: 20 * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
            opacity: clearButton.hovered ? 1.0 : 0.7 // 悬浮时微动高亮
            
            Behavior on opacity {
                NumberAnimation { duration: 150 }
            }
        }

        onClicked: {
            control.text = "";
            control.forceActiveFocus();
        }
    }

    // 🌟 辅助文本与错误文本区 (Supporting text)
    Text {
        id: helperLabel
        anchors.top: parent.top
        anchors.topMargin: control.containerHeight + 2 * control.themeGlobalScale // 严格贴在输入框下方
        anchors.left: parent.left
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.right: parent.right
        anchors.rightMargin: 16 * control.themeGlobalScale
        height: 16 * control.themeGlobalScale
        
        text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
        font.pixelSize: 12 * control.themeGlobalScale
        color: {
            if (!control.enabled) {
                return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
            }
            return control.isError ? control.themeError : control.themeOnSurfaceVariant;
        }
        visible: text !== ""
        elide: Text.ElideRight

        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
