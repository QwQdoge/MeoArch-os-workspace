import QtQuick
import QtQuick.Controls
import MeoUI

TextArea {
    id: control

    // 🌟 核心对外属性
    property string type: "filled" // "filled" (默认) | "outlined"
    property string label: ""
    property string helperText: ""
    property bool isError: false
    property string errorText: ""
    property string placeholder: ""
    property int maxLength: -1
    property bool showCounter: false

    // 🌟 作用域防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false

    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeError: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.error !== 'undefined') ? MeoTheme.error : "#B3261E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontBodyLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyLarge !== 'undefined') ? MeoTheme.bodyLarge : { "size": 16, "weight": Font.Normal }
    readonly property var fontBodySmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodySmall !== 'undefined') ? MeoTheme.bodySmall : { "size": 12, "weight": Font.Normal }
    readonly property var fontLabelSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelSmall !== 'undefined') ? MeoTheme.labelSmall : { "size": 11, "weight": Font.Medium }

    readonly property real helperSpace: (helperText !== "" || (isError && errorText !== "") || showCounter) ? 20 * themeGlobalScale : 0

    padding: 0
    implicitHeight: Math.max(100 * themeGlobalScale, contentHeight + topPadding + bottomPadding)
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
    wrapMode: TextArea.Wrap

    placeholderText: (label === "" || overlayLayer.isCollapsed) ? placeholder : ""
    placeholderTextColor: {
        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        return isError ? themeError : themeOnSurfaceVariant;
    }

    leftPadding: 16 * themeGlobalScale
    rightPadding: 16 * themeGlobalScale
    topPadding: type === "filled"
                ? (label !== "" ? 24 * themeGlobalScale : 16 * themeGlobalScale)
                : 16 * themeGlobalScale
    bottomPadding: 16 * themeGlobalScale + helperSpace

    background: Item {
        Rectangle {
            id: containerRect
            anchors.fill: parent
            anchors.bottomMargin: control.helperSpace
            radius: control.type === "filled" ? 0 : 4 * control.themeGlobalScale
            topLeftRadius: 4 * control.themeGlobalScale
            topRightRadius: 4 * control.themeGlobalScale
            color: {
                if (!control.enabled) return control.type === "filled" ? Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.04) : "transparent";
                if (control.type === "filled") return control.themeSurfaceContainerHighest;
                return "transparent";
            }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: 4 * control.themeGlobalScale
                color: containerRect.color
                visible: control.type === "filled"
            }

            border.color: {
                if (!control.enabled) return control.isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
                if (control.isError) return control.themeError;
                if (control.activeFocus) return control.themePrimary;
                if (control.hovered) return control.themeOnSurface;
                return control.type === "filled" ? control.themeOnSurfaceVariant : control.themeOutline;
            }
            border.width: control.type === "outlined" ? (control.activeFocus ? 2 : 1) : 0

            Behavior on border.color { ColorAnimation { duration: 150 } }

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: control.activeFocus ? 2 : 1
                color: parent.border.color
                visible: control.type === "filled"
                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }
    }

    Item {
        id: overlayLayer
        width: parent.width
        height: parent.height - control.helperSpace
        visible: control.label !== ""
        enabled: false

        readonly property bool isCollapsed: control.activeFocus || control.text !== ""

        Item {
            x: 16 * control.themeGlobalScale
            y: overlayLayer.isCollapsed
               ? (control.type === "filled" ? 8 * control.themeGlobalScale : -8 * control.themeGlobalScale)
               : 16 * control.themeGlobalScale
            width: labelText.implicitWidth
            height: labelText.implicitHeight

            Behavior on y { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }

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
                font.pixelSize: (overlayLayer.isCollapsed ? control.fontLabelSmall.size : control.fontBodyLarge.size) * control.themeGlobalScale
                font.weight: overlayLayer.isCollapsed ? control.fontLabelSmall.weight : control.fontBodyLarge.weight
                color: {
                    if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
                    if (control.isError) return control.themeError;
                    if (control.activeFocus) return control.themePrimary;
                    return control.themeOnSurfaceVariant;
                }
                Behavior on font.pixelSize { NumberAnimation { duration: 150; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
            }
        }
    }

    Item {
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.right: parent.right
        anchors.rightMargin: 16 * control.themeGlobalScale
        height: 16 * control.themeGlobalScale
        visible: control.helperSpace > 0

        Text {
            anchors.left: parent.left
            anchors.right: counterLabel.left
            anchors.rightMargin: 16 * control.themeGlobalScale
            text: (control.isError && control.errorText !== "") ? control.errorText : control.helperText
            font.pixelSize: control.fontBodySmall.size * control.themeGlobalScale
            color: control.isError ? control.themeError : control.themeOnSurfaceVariant
            elide: Text.ElideRight
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
