import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    property var model: []
    property int currentIndex: 0
    signal clicked(int index)

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    x: 0
    y: 0
    height: parent ? parent.height : 0
    width: 360 * themeGlobalScale
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    background: Rectangle {
        color: control.themeSurfaceContainerLow
        radius: 0

        // Modal drawer has rounded corners only on the right
        Rectangle {
            anchors.right: parent.right
            width: 32 * control.themeGlobalScale
            height: parent.height
            radius: 16 * control.themeGlobalScale
            color: parent.color

            // Cover the left side of this rectangle to keep it only rounded on the right
            Rectangle {
                anchors.left: parent.left
                width: parent.width / 2
                height: parent.height
                color: parent.color
            }
        }
    }

    Overlay.modal: Rectangle {
        color: Qt.rgba(0,0,0,0.4)
    }

    contentItem: Column {
        padding: 12 * control.themeGlobalScale
        spacing: 4 * control.themeGlobalScale

        Text {
            text: "Navigation"
            padding: 16 * control.themeGlobalScale
            font.pixelSize: 14 * control.themeGlobalScale
            font.weight: Font.Medium
            color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
        }

        Repeater {
            model: control.model
            delegate: MeoListItem {
                width: parent.width - 24 * control.themeGlobalScale
                headline: modelData.label
                leadingIcon: modelData.icon
                interactive: true
                background: Rectangle {
                    radius: 28 * control.themeGlobalScale
                    color: control.currentIndex === index ?
                           ((typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8") :
                           "transparent"
                }
                onClicked: {
                    control.currentIndex = index
                    control.clicked(index)
                    control.close()
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "x"; from: -control.width; to: 0; duration: 300; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "x"; from: 0; to: -control.width; duration: 250; easing.type: Easing.InCubic }
    }
}
