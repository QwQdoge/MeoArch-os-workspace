import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property Component content: null
    property Component leftAction: null
    property Component rightAction: null
    property real swipeThreshold: 0.4
    property bool dismissed: false

    signal leftActionTriggered()
    signal rightActionTriggered()

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: contentLoader.implicitHeight

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // 🎨 Background Actions Layer
    Item {
        id: backgroundActions
        anchors.fill: parent
        visible: contentItem.x !== 0

        // Left Action Background (e.g. Archive)
        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.horizontalCenter
            height: parent.height
            color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#4CAF50"
            visible: contentItem.x > 0

            Loader {
                anchors.left: parent.left
                anchors.leftMargin: 24 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: control.leftAction
            }
        }

        // Right Action Background (e.g. Delete)
        Rectangle {
            anchors.left: parent.horizontalCenter
            anchors.right: parent.right
            height: parent.height
            color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.error !== 'undefined') ? MeoTheme.error : "#F44336"
            visible: contentItem.x < 0

            Loader {
                anchors.right: parent.right
                anchors.rightMargin: 24 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: control.rightAction
            }
        }
    }

    // 📦 Foreground Content Layer
    Item {
        id: contentItem
        width: parent.width
        height: parent.height
        clip: true

        Rectangle {
            anchors.fill: parent
            color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFFFF"
        }

        Loader {
            id: contentLoader
            anchors.fill: parent
            sourceComponent: control.content
        }

        MouseArea {
            id: dragArea
            anchors.fill: parent
            drag.target: contentItem
            drag.axis: Drag.XAxis
            drag.minimumX: -control.width
            drag.maximumX: control.width

            onReleased: {
                if (contentItem.x > control.width * control.swipeThreshold) {
                    // Trigger Left Action & Dismiss
                    dismissToRight.start()
                } else if (contentItem.x < -control.width * control.swipeThreshold) {
                    // Trigger Right Action & Dismiss
                    dismissToLeft.start()
                } else {
                    // Snap back
                    snapBack.start()
                }
            }
        }

        NumberAnimation {
            id: snapBack
            target: contentItem
            property: "x"
            to: 0
            duration: 200
            easing.type: Easing.OutQuad
        }

        NumberAnimation {
            id: dismissToRight
            target: contentItem
            property: "x"
            to: control.width
            duration: 200
            easing.type: Easing.OutQuad
            onFinished: {
                control.leftActionTriggered()
                control.dismissed = true
            }
        }

        NumberAnimation {
            id: dismissToLeft
            target: contentItem
            property: "x"
            to: -control.width
            duration: 200
            easing.type: Easing.OutQuad
            onFinished: {
                control.rightActionTriggered()
                control.dismissed = true
            }
        }
    }

    // Optional: Auto-hide height when dismissed
    Behavior on implicitHeight {
        NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
    }

    states: [
        State {
            name: "dismissed"
            when: control.dismissed
            PropertyChanges { target: control; implicitHeight: 0; opacity: 0; visible: false }
        }
    ]
}
