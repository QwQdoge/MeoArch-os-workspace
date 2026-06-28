import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    // 🌟 核心属性
    property Component content: null

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    x: (parent.width - width) / 2
    y: parent.height - height
    width: parent.width
    height: Math.min(parent.height * 0.6, contentLoader.implicitHeight + 48 * themeGlobalScale)

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: control.themeSurfaceContainerLow
        radius: 28 * control.themeGlobalScale
        // Only round top corners
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 28 * control.themeGlobalScale
            color: parent.color
        }

        // Drag handle
        Rectangle {
            anchors.top: parent.top
            anchors.topMargin: 22 * control.themeGlobalScale
            anchors.horizontalCenter: parent.horizontalCenter
            width: 32 * control.themeGlobalScale
            height: 4 * control.themeGlobalScale
            radius: 2 * control.themeGlobalScale
            color: control.themeOutlineVariant
        }
    }

    contentItem: Item {
        Loader {
            id: contentLoader
            anchors.top: parent.top
            anchors.topMargin: 48 * control.themeGlobalScale
            anchors.left: parent.left
            anchors.right: parent.right
            sourceComponent: control.content
        }
    }

    enter: Transition {
        NumberAnimation { property: "y"; from: parent.height; to: control.y; duration: 300; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "y"; from: control.y; to: parent.height; duration: 250; easing.type: Easing.InCubic }
    }
}
