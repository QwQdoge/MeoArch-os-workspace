import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    property string title: ""
    property string message: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property string icon: ""

    signal confirmed()
    signal cancelled()

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurfaceContainerHigh: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHigh !== 'undefined') ? MeoTheme.surfaceContainerHigh : "#ECE6F0"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeSecondary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondary !== 'undefined') ? MeoTheme.secondary : "#625B71"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontHeadlineSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.headlineSmall !== 'undefined') ? MeoTheme.headlineSmall : { "size": 24, "weight": Font.Normal }
    readonly property var fontBodyMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyMedium !== 'undefined') ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal }

    x: (parent.width - width) / 2
    y: (parent.height - height) / 2
    width: Math.min(parent.width - 48 * themeGlobalScale, 320 * themeGlobalScale)
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: control.themeSurfaceContainerHigh
        radius: 28 * control.themeGlobalScale
    }

    contentItem: Column {
        spacing: 16 * control.themeGlobalScale
        padding: 24 * control.themeGlobalScale

        MeoIcon {
            icon: control.icon
            visible: control.icon !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            color: control.themeSecondary
            size: 24
        }

        Text {
            text: control.title
            width: parent.width - 48 * control.themeGlobalScale
            font.pixelSize: fontHeadlineSmall.size * control.themeGlobalScale
            font.weight: fontHeadlineSmall.weight
            color: control.themeOnSurface
            wrapMode: Text.WordWrap
            visible: text !== ""
            horizontalAlignment: control.icon !== "" ? Text.AlignHCenter : Text.AlignLeft
        }

        Text {
            text: control.message
            width: parent.width - 48 * control.themeGlobalScale
            font.pixelSize: fontBodyMedium.size * control.themeGlobalScale
            font.weight: fontBodyMedium.weight
            color: control.themeOnSurfaceVariant
            wrapMode: Text.WordWrap
        }

        Row {
            width: parent.width - 48 * control.themeGlobalScale
            layoutDirection: Qt.RightToLeft
            spacing: 8 * control.themeGlobalScale

            MeoButton {
                text: control.confirmText
                type: "text"
                onClicked: {
                    control.confirmed()
                    control.close()
                }
            }

            MeoButton {
                text: control.cancelText
                type: "text"
                onClicked: {
                    control.cancelled()
                    control.close()
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150 }
    }
}
