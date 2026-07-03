import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    // 🌟 核心属性
    property string title: "Actions"
    property var model: [] // [{ label: "Action", icon: "add", action: function }]

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property real shapeExtraLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeExtraLarge !== 'undefined') ? MeoTheme.shapeExtraLarge : 28 * themeGlobalScale

    x: (parent.width - width) / 2
    y: parent.height - height
    width: parent.width
    height: contentColumn.implicitHeight + padding * 2

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    padding: 0

    background: Rectangle {
        color: control.themeSurfaceContainerLow
        radius: control.shapeExtraLarge

        // Only round top corners (MD3 Sheet pattern)
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: control.shapeExtraLarge
            color: parent.color
        }

        // Drag handle decoration
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

    contentItem: Column {
        id: contentColumn
        width: parent.width
        topPadding: 48 * control.themeGlobalScale
        bottomPadding: 24 * control.themeGlobalScale

        Text {
            text: control.title
            font.pixelSize: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleLarge !== 'undefined' ? MeoTheme.titleLarge.size : 22) * control.themeGlobalScale
            font.weight: Font.Medium
            color: control.themeOnSurface
            anchors.left: parent.left
            anchors.leftMargin: 24 * control.themeGlobalScale
            bottomPadding: 16 * control.themeGlobalScale
            visible: text !== ""
        }

        Repeater {
            model: control.model
            delegate: MeoListItem {
                width: parent.width
                headline: modelData.label
                leadingIcon: modelData.icon || ""
                onClicked: {
                    if (modelData.action) modelData.action()
                    control.close()
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "y"; from: parent.height; to: control.y; duration: 300; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]) }
    }
    exit: Transition {
        NumberAnimation { property: "y"; from: control.y; to: parent.height; duration: 250; easing.type: Easing.InCubic }
    }
}
