import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    property string title: ""
    property Component content: null
    property var actions: [] // Array of { text: "", action: function }

    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontTitleLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleLarge !== 'undefined') ? MeoTheme.titleLarge : { "size": 22, "weight": Font.Normal }

    x: 0
    y: 0
    width: parent ? parent.width : 0
    height: parent ? parent.height : 0
    modal: true
    focus: true
    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        color: control.themeSurface
    }

    contentItem: Item {
        anchors.fill: parent

        // Top App Bar
        Rectangle {
            id: topBar
            width: parent.width
            height: 64 * control.themeGlobalScale
            color: "transparent"

            MeoIconButton {
                id: closeBtn
                icon.name: "close"
                anchors.left: parent.left
                anchors.leftMargin: 4 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                onClicked: control.close()
            }

            Text {
                id: titleText
                text: control.title
                anchors.left: closeBtn.right
                anchors.leftMargin: 16 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                font.pixelSize: fontTitleLarge.size * control.themeGlobalScale
                font.weight: fontTitleLarge.weight
                color: control.themeOnSurface
            }

            Row {
                id: actionsRow
                anchors.right: parent.right
                anchors.rightMargin: 16 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                spacing: 8 * control.themeGlobalScale
                Repeater {
                    model: control.actions
                    MeoButton {
                        text: modelData.text
                        type: "text"
                        onClicked: {
                            if (modelData.action) modelData.action()
                            control.close()
                        }
                    }
                }
            }
        }

        Loader {
            anchors.top: topBar.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            sourceComponent: control.content
        }
    }

    enter: Transition {
        NumberAnimation { property: "y"; from: control.height; to: 0; duration: 300; easing.type: Easing.OutCubic }
    }
    exit: Transition {
        NumberAnimation { property: "y"; from: 0; to: control.height; duration: 250; easing.type: Easing.InCubic }
    }
}
