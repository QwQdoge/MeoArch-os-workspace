import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    // 🌟 核心属性
    property string title: ""
    property string message: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property string icon: ""
    property Component content: null // Custom content slot

    signal confirmed()
    signal cancelled()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurfaceContainerHigh: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHigh !== 'undefined') ? MeoTheme.surfaceContainerHigh : "#ECE6F0"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeSecondary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondary !== 'undefined') ? MeoTheme.secondary : "#625B71"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // MD3 Expressive Typography
    readonly property var fontHeadlineSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.headlineSmallEmphasized !== 'undefined') ? MeoTheme.headlineSmallEmphasized : { "size": 24, "weight": Font.Bold }
    readonly property var fontBodyMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyMedium !== 'undefined') ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal }

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: Math.min(parent.width - 32 * themeGlobalScale, 400 * themeGlobalScale) // Slightly wider than standard
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: control.themeSurfaceContainerHigh
        radius: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeExtraLargeIncreased !== 'undefined') ? MeoTheme.shapeExtraLargeIncreased : 32 * control.themeGlobalScale
    }

    contentItem: Column {
        spacing: 24 * control.themeGlobalScale // Increased spacing for expressive feel
        padding: 32 * control.themeGlobalScale // Increased padding

        // Icon Header
        MeoIcon {
            icon: control.icon
            visible: control.icon !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            color: control.themePrimary // Use primary color for expressive icons
            size: 32 * control.themeGlobalScale
        }

        // Text Content
        Column {
            width: parent.width - 64 * control.themeGlobalScale
            spacing: 16 * control.themeGlobalScale
            anchors.horizontalCenter: parent.horizontalCenter

            Text {
                text: control.title
                width: parent.width
                font.pixelSize: fontHeadlineSmall.size * control.themeGlobalScale
                font.weight: fontHeadlineSmall.weight
                color: control.themeOnSurface
                wrapMode: Text.WordWrap
                visible: text !== ""
                horizontalAlignment: Text.AlignHCenter // Expressive dialogs often center text
            }

            Text {
                text: control.message
                width: parent.width
                font.pixelSize: fontBodyMedium.size * control.themeGlobalScale
                font.weight: fontBodyMedium.weight
                color: control.themeOnSurfaceVariant
                wrapMode: Text.WordWrap
                visible: text !== ""
                horizontalAlignment: Text.AlignHCenter
                lineHeight: 1.5
            }
        }

        // Custom Content Slot
        Loader {
            width: parent.width - 64 * control.themeGlobalScale
            anchors.horizontalCenter: parent.horizontalCenter
            sourceComponent: control.content
            visible: control.content !== null
        }

        // Action Buttons
        Row {
            width: parent.width - 64 * control.themeGlobalScale
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 12 * control.themeGlobalScale

            MeoButton {
                text: control.confirmText
                type: "filled" // Filled button for emphasis
                isEmphasized: true
                width: (parent.width - 12 * control.themeGlobalScale) / 2
                onClicked: {
                    control.confirmed()
                    control.close()
                }
            }

            MeoButton {
                text: control.cancelText
                type: "outlined" // Outlined for secondary action
                width: (parent.width - 12 * control.themeGlobalScale) / 2
                onClicked: {
                    control.cancelled()
                    control.close()
                }
            }
        }
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 400; easing.type: Easing.OutQuint }
            NumberAnimation { property: "scale"; from: 0.8; to: 1.0; duration: 400; easing.bezierCurve: [0.34, 1.56, 0.64, 1] } // Bouncy entrance
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 250; easing.type: Easing.InQuint }
            NumberAnimation { property: "scale"; from: 1.0; to: 0.8; duration: 250; easing.type: Easing.InQuint }
        }
    }
}
