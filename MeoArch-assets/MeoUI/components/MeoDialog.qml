import QtQuick
import QtQuick.Controls

Popup {
    id: control

    // 🌟 核心属性
    property string title: ""
    property string message: ""
    property string confirmText: "Confirm"
    property string cancelText: "Cancel"

    signal confirmed()
    signal cancelled()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurfaceContainerHigh: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHigh !== 'undefined') ? MeoTheme.surfaceContainerHigh : "#ECE6F0"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

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

        Text {
            text: control.title
            width: parent.width - 48 * control.themeGlobalScale
            font.pixelSize: 24 * control.themeGlobalScale
            color: control.themeOnSurface
            wrapMode: Text.WordWrap
            visible: text !== ""
        }

        Text {
            text: control.message
            width: parent.width - 48 * control.themeGlobalScale
            font.pixelSize: 14 * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
            wrapMode: Text.WordWrap
        }

        Row {
            width: parent.width - 48 * control.themeGlobalScale
            layoutDirection: Qt.RightToLeft
            spacing: 8 * control.themeGlobalScale

            // Use our MeoButton for consistency
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

    // 🌟 进场出场动画
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 200 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 200; easing.type: Easing.OutBack }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 150 }
        NumberAnimation { property: "scale"; from: 1.0; to: 0.9; duration: 150 }
    }
}
