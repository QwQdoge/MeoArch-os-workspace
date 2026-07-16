import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

MeoMotionPopup {
    id: control
    presentation: MeoMotionPopup.Dialog

    property string title: ""
    property string message: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"
    property string icon: ""
    property bool showAcceptButton: true
    property bool showRejectButton: true

    signal confirmed()
    signal cancelled()

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurfaceContainerHigh: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHigh !== 'undefined') ? MeoTheme.surfaceContainerHigh : "#ECE6F0"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeSecondary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondary !== 'undefined') ? MeoTheme.secondary : "#625B71"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int motionEnter: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationShort4 !== 'undefined') ? MeoTheme.motionDurationShort4 : 200
    readonly property int motionExit: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationShort3 !== 'undefined') ? MeoTheme.motionDurationShort3 : 150

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
        radius: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeExtraLarge !== 'undefined') ? MeoTheme.shapeExtraLarge : 28 * control.themeGlobalScale
        layer.enabled: control.visible
        layer.effect: MultiEffect { shadowEnabled: true; shadowBlur: 0.55; shadowVerticalOffset: 8; shadowColor: Qt.rgba(0, 0, 0, 0.22) }
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
            visible: control.showAcceptButton || control.showRejectButton

            MeoButton {
                text: control.confirmText
                type: "text"
                visible: control.showAcceptButton
                onClicked: {
                    control.confirmed()
                    control.close()
                }
            }

            MeoButton {
                text: control.cancelText
                type: "text"
                visible: control.showRejectButton
                onClicked: {
                    control.cancelled()
                    control.close()
                }
            }
        }
    }

}
