import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control
    width: 360 * themeGlobalScale
    height: parent ? parent.height : 0
    padding: 0
    margins: 0
    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

    property var model: []
    property int currentIndex: 0
    property Component header: null
    signal clicked(int index)

    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // MD3 Modal Drawer appearance
    background: Rectangle {
        color: themeSurfaceContainerLow
        radius: 0
        // Rounded corner on the right side only
        Rectangle {
            width: 16 * control.themeGlobalScale
            height: parent.height
            anchors.right: parent.right
            color: "transparent"
            Rectangle {
                width: 32 * control.themeGlobalScale
                height: parent.height
                anchors.right: parent.right
                color: themeSurfaceContainerLow
                radius: 16 * control.themeGlobalScale
                clip: true
                Item { anchors.fill: parent } // Trick to hide left side radius
            }
        }
    }

    // Windows/WinUI-style directional motion. Motion is disabled centrally for
    // users that request reduced motion.
    enter: Transition {
        NumberAnimation {
            property: "x"
            from: -control.width
            to: 0
            duration: MeoTheme.motionDurationSheetEnter
            easing.bezierCurve: MeoTheme.motionEasingEnter
        }
    }
    exit: Transition {
        NumberAnimation {
            property: "x"
            from: 0
            to: -control.width
            duration: MeoTheme.motionDurationSheetExit
            easing.bezierCurve: MeoTheme.motionEasingExit
        }
    }

    Column {
        anchors.fill: parent
        anchors.margins: 12 * control.themeGlobalScale

        Loader {
            width: parent.width
            sourceComponent: control.header
            visible: control.header !== null
        }

        Item {
            width: parent.width
            height: 17 * control.themeGlobalScale
            visible: control.header !== null

            MeoDivider {
                width: parent.width
                anchors.verticalCenter: parent.verticalCenter
            }
        }

        Repeater {
            model: control.model
            delegate: MeoNavigationDrawerItem {
                width: parent.width
                icon: modelData.icon
                label: modelData.label
                badgeText: modelData.badgeText || (modelData.badgeCount !== undefined ? modelData.badgeCount.toString() : "")
                badgeDot: modelData.badgeDot || false
                selected: control.currentIndex === index
                onClicked: {
                    control.clicked(index)
                }
            }
        }
    }
}
