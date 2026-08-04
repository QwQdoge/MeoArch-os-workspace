import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心对外属性
    property string type: "filled" // "filled" (默认) | "outlined"
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string label: "" // 悬浮标签文本
    property string helperText: "" // 底部辅助文本
    property bool isError: false // 错误状态开关
    property string errorText: "" // 错误提示文本（开启 isError 时优先显示）
    property string placeholder: "" // 占位文本
    property var model: [] // 菜单所有可选项列表, 例如 ["A", "B", "C"]
    property var selectedIndices: [] // 当前选中项的索引数组, 例如 [0, 2]
    property bool showCounter: false // 是否显示选中计数
    property bool error: isError

    onErrorChanged: isError = error
    onIsErrorChanged: {
        if (error !== isError)
            error = isError
    }

    // 🌟 作用域与主题安全防御
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
    implicitWidth: 280 * themeGlobalScale
    implicitHeight: Math.max(control.containerHeight, contentFlow.implicitHeight + (control.type === "filled" ? (control.label !== "" ? 28 : 16) : 16) * themeGlobalScale) + (size === "xs" ? 0 : helperSpace)

    opacity: control.enabled ? 1.0 : 0.62
    Behavior on opacity { NumberAnimation { duration: control.motionFast } }

    readonly property var currentFont: {
        if (size === "xs") return fontBodySmall;
        if (size === "s") return fontBodyMedium;
        return fontBodyLarge;
    }

    // 🌟 内边距自适应优化
    readonly property real sidePadding: {
        if (size === "xs") return 8 * themeGlobalScale;
        if (size === "s") return 12 * themeGlobalScale;
        return 16 * themeGlobalScale;
    }

    readonly property color transparentBg: Qt.rgba(themePrimary.r, themePrimary.g, themePrimary.b, 0)

    readonly property color containerColor: {
        if (!control.enabled) return type === "filled" ? Qt.rgba(themeOnSurface.r, themeOnSurface.g, themeOnSurface.b, 0.04) : transparentBg;
        return type === "filled" ? themeSurfaceContainerHighest : transparentBg;
    }

    readonly property color indicatorColor: {
        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        if (isError) return themeError;
        if (control.activeFocus) return themePrimary;
        if (bgMouseArea.containsMouse) return themeOnSurface;
        return type === "filled" ? themeOnSurfaceVariant : themeOutline;
    }

    // 🌟 Background MouseArea positioned at the top of the content hierarchy visually
    // to avoid blocking clicks on child chip actions.
    MouseArea {
        id: bgMouseArea
        anchors.fill: parent
        anchors.bottomMargin: (control.size === "xs" ? 0 : control.helperSpace)
        enabled: control.enabled
        hoverEnabled: true
        onClicked: {
            control.forceActiveFocus()
            menu.open()
        }
    }

    background: Item {
        Rectangle {
            id: containerRect
            width: parent.width
            height: control.height - (control.size === "xs" ? 0 : control.helperSpace)
            radius: control.type === "filled"
                    ? 12 * control.themeGlobalScale
                    : (control.activeFocus ? 16 : 12) * control.themeGlobalScale
            topLeftRadius: control.activeFocus ? 16 * control.themeGlobalScale : 12 * control.themeGlobalScale
            topRightRadius: control.activeFocus ? 16 * control.themeGlobalScale : 12 * control.themeGlobalScale
            color: {
                let base = control.containerColor;
                if (control.enabled && bgMouseArea.containsMouse && control.type === "filled") {
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

    // 🌟 Responsive Wrapping Flow of Removable Chips
    Flow {
        id: contentFlow
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.leftMargin: control.sidePadding
        anchors.rightMargin: control.sidePadding + 32 * control.themeGlobalScale // space for trailing icon
        anchors.topMargin: (control.type === "filled" && control.label !== "" && overlayLayer.isCollapsed)
                           ? (control.size === "xl" ? 28 : 20) * control.themeGlobalScale
                           : (control.size === "xs" ? 4 : 8) * control.themeGlobalScale
        anchors.bottomMargin: (control.size === "xs" ? 4 : 8) * control.themeGlobalScale
        spacing: 6 * control.themeGlobalScale
        rowSpacing: 6 * control.themeGlobalScale

        Repeater {
            model: control.selectedIndices
            delegate: MeoChip {
                required property var modelData
                label: control.model[modelData] || ""
                type: "input"
                closable: true
                size: {
                    if (control.size === "xs" || control.size === "s") return "xs";
                    if (control.size === "xl") return "l";
                    return "s";
                }
                selected: true
                onClosed: {
                    let arr = []
                    for (let i = 0; i < control.selectedIndices.length; i++) {
                        if (control.selectedIndices[i] !== modelData) {
                            arr.push(control.selectedIndices[i])
                        }
                    }
                    control.selectedIndices = arr
                    control.selectedIndicesChanged()
                }
            }
        }
    }

    // Trailing Dropdown Icon
    MeoIcon {
        anchors.right: parent.right
        anchors.rightMargin: control.sidePadding
        anchors.top: parent.top
        anchors.topMargin: (control.containerHeight - height) / 2
        icon: menu.opened ? "arrow_drop_up" : "arrow_drop_down"
        size: control.size === "xs" ? 18 : 24
        color: control.isError ? control.themeError : control.themeOnSurfaceVariant
    }

    // Placeholder
    MeoText {
        anchors.left: parent.left
        anchors.leftMargin: control.sidePadding
        anchors.verticalCenter: parent.top
        anchors.verticalCenterOffset: control.containerHeight / 2
        text: control.placeholder
        visible: (!control.selectedIndices || control.selectedIndices.length === 0) && overlayLayer.isCollapsed && control.placeholder !== ""
        typeRole: "body"
        typeSize: control.size === "xs" ? "small" : "medium"
        color: control.themeOnSurfaceVariant
        opacity: 0.6
    }

    // Sliding / Floating Label Layer
    Item {
        id: overlayLayer
        width: parent.width
        height: control.containerHeight
        visible: control.label !== "" && control.size !== "xs"
        enabled: false

        readonly property bool isCollapsed: control.activeFocus || (control.selectedIndices && control.selectedIndices.length > 0) || menu.opened

        Item {
            id: labelContainer
            x: control.sidePadding
            y: overlayLayer.isCollapsed
               ? (control.type === "filled" ? 6 * control.themeGlobalScale : -10 * control.themeGlobalScale)
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

    // Supporting Text Area
    Item {
        id: helperItem
        anchors.top: containerRect.bottom
        anchors.topMargin: 4 * control.themeGlobalScale
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
            text: control.selectedIndices ? (control.selectedIndices.length + " selected") : "0 selected"
            font.pixelSize: control.fontBodySmall.size * control.themeGlobalScale
            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
            color: control.themeOnSurfaceVariant
        }
    }

    // Dropdown Selection Menu
    MeoMenu {
        id: menu
        width: control.width
        y: containerRect.height
        model: {
            let m = []
            let selMap = {}
            if (control.selectedIndices) {
                for (let j = 0; j < control.selectedIndices.length; j++) {
                    selMap[control.selectedIndices[j]] = true;
                }
            }
            for (let i = 0; i < control.model.length; i++) {
                let isSel = selMap[i] === true;
                m.push({
                    label: control.model[i],
                    icon: isSel ? "check" : "",
                    isVibrant: isSel,
                    action: (function(idx) {
                        return function() {
                            let arr = []
                            let sel = control.selectedIndices || []
                            let idxInSel = sel.indexOf(idx);
                            if (idxInSel !== -1) {
                                // Remove option
                                for (let j = 0; j < sel.length; j++) {
                                    if (sel[j] !== idx) arr.push(sel[j])
                                }
                            } else {
                                // Add option
                                arr = sel.concat([idx])
                            }
                            control.selectedIndices = arr
                            control.selectedIndicesChanged()
                        }
                    })(i)
                })
            }
            return m
        }
    }
}
