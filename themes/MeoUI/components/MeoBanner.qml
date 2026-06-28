import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property string text: ""
    property string icon: ""
    property string confirmText: ""
    property string cancelText: ""

    signal confirmed()
    signal cancelled()

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontBodyMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyMedium !== 'undefined') ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal }

    implicitWidth: parent ? parent.width : 360 * themeGlobalScale
    implicitHeight: contentColumn.implicitHeight + padding * 2

    padding: 16 * themeGlobalScale

    background: Rectangle {
        color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : control.themeSurfaceContainerLow
    }

    contentItem: Column {
        id: contentColumn
        spacing: 16 * control.themeGlobalScale

        Row {
            width: parent.width
            spacing: 16 * control.themeGlobalScale

            Item {
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                visible: control.icon !== ""
                anchors.verticalCenter: parent.verticalCenter

                MeoIcon {
                    icon: control.icon
                    size: 24
                    anchors.centerIn: parent
                    color: control.themePrimary
                }
            }

            Text {
                text: control.text
                width: parent.width - (control.icon !== "" ? 56 * control.themeGlobalScale : 0)
                font.pixelSize: control.fontBodyMedium.size * control.themeGlobalScale
                font.weight: control.fontBodyMedium.weight
                color: control.themeOnSurface
                wrapMode: Text.WordWrap
            }
        }

        Row {
            anchors.right: parent.right
            spacing: 8 * control.themeGlobalScale

            MeoButton {
                text: control.cancelText
                type: "text"
                visible: control.cancelText !== ""
                onClicked: control.cancelled()
            }

            MeoButton {
                text: control.confirmText
                type: "text"
                visible: control.confirmText !== ""
                onClicked: control.confirmed()
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1 * control.themeGlobalScale
        color: Qt.rgba(0,0,0,0.1)
    }
}
