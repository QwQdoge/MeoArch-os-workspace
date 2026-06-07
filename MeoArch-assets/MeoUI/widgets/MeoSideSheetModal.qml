import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MeoUI

Popup {
    id: control

    // 🌟 核心属性
    property string title: ""
    property Component content: null
    property bool showCloseButton: true

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontTitleLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleLarge !== 'undefined') ? MeoTheme.titleLarge : { "size": 22, "weight": Font.Normal }

    x: parent ? parent.width - width : 0
    y: 0
    width: Math.min(parent ? parent.width : 400 * themeGlobalScale, 400 * themeGlobalScale)
    height: parent ? parent.height : 600 * themeGlobalScale

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.4)
        Behavior on opacity { NumberAnimation { duration: 250 } }
    }

    background: Rectangle {
        color: control.themeSurfaceContainerLow
        // MD3 Modal Side Sheet: 28dp radius on the side facing the main content
        topLeftRadius: 28 * control.themeGlobalScale
        bottomLeftRadius: 28 * control.themeGlobalScale

        // Elevation Shadow (Standard MD3 Sheet Elevation)
        layer.enabled: true
        layer.effect: DropShadow {

            radius: 0.2
            horizontalOffset: -2 * control.themeGlobalScale
            color: Qt.rgba(0,0,0,0.2)
        }
    }

    contentItem: Column {
        anchors.fill: parent

        // Header
        Item {
            width: parent.width
            height: 64 * control.themeGlobalScale
            visible: control.title !== "" || control.showCloseButton

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16 * control.themeGlobalScale
                anchors.rightMargin: 16 * control.themeGlobalScale
                spacing: 12 * control.themeGlobalScale

                MeoIconButton {
                    icon.name: "close"
                    visible: control.showCloseButton
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: control.close()
                }

                Text {
                    text: control.title
                    visible: text !== ""
                    font.pixelSize: fontTitleLarge.size * control.themeGlobalScale
                    font.weight: fontTitleLarge.weight
                    color: control.themeOnSurface
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }

        // Content
        Loader {
            id: contentLoader
            width: parent.width
            height: parent.height - (control.title !== "" || control.showCloseButton ? 64 * control.themeGlobalScale : 0)
            sourceComponent: control.content
        }
    }

    enter: Transition {
        NumberAnimation { property: "x"; from: parent.width; to: parent.width - control.width; duration: 400; easing.bezierCurve: [0.05, 0.7, 0.1, 1.0] }
    }
    exit: Transition {
        NumberAnimation { property: "x"; from: parent.width - control.width; to: parent.width; duration: 300; easing.bezierCurve: [0.3, 0, 0.8, 0.15] }
    }
}
