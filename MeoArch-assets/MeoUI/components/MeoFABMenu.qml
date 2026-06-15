import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string icon: "add"
    property string text: ""
    property var model: [] // [{ label: "", icon: "", action: function }]
    readonly property alias isOpen: menuPopup.opened

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 56 * themeGlobalScale
    implicitHeight: 56 * themeGlobalScale

    // Overlay to catch clicks outside the menu
    Popup {
        id: menuPopup
        padding: 0
        margins: 0
        modal: false
        focus: true
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        parent: Overlay.overlay
        x: control.mapToItem(Overlay.overlay, 0, 0).x - (menuContainer.width - control.width)
        y: control.mapToItem(Overlay.overlay, 0, 0).y - menuContainer.height - 8 * themeGlobalScale

        background: Item {}

        contentItem: Item {
            id: menuContainer
            width: 240 * themeGlobalScale
            height: menuColumn.implicitHeight + 16 * themeGlobalScale
            clip: true

            Rectangle {
                anchors.fill: parent
                radius: 16 * themeGlobalScale
                color: (typeof MeoTheme !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"

                layer.enabled: true
                layer.effect: DropShadow {
                    radius: 0.2
                    verticalOffset: 2 * themeGlobalScale
                    color: Qt.rgba(0,0,0,0.2)
                }
            }

            Column {
                id: menuColumn
                anchors.fill: parent
                anchors.margins: 8 * themeGlobalScale
                spacing: 4 * themeGlobalScale

                Repeater {
                    model: control.model
                    delegate: MeoListItem {
                        width: parent.width
                        headline: modelData.label
                        leadingIcon: modelData.icon || ""
                        padding: 12 * themeGlobalScale
                        implicitHeight: 48 * themeGlobalScale
                        interactive: true
                        onClicked: {
                            if (modelData.action) modelData.action()
                            menuPopup.close()
                        }
                    }
                }
            }
        }

        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 250; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] }
            NumberAnimation { property: "scale"; from: 0.8; to: 1.0; duration: 250; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] }
            NumberAnimation { property: "y"; from: menuPopup.y + 20; to: menuPopup.y; duration: 250; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] }
        }

        exit: Transition {
            NumberAnimation { property: "opacity"; to: 0.0; duration: 150 }
            NumberAnimation { property: "scale"; to: 0.8; duration: 150 }
        }
    }

    MeoFAB {
        id: fab
        anchors.fill: parent
        icon.name: control.icon
        text: control.text
        type: control.text !== "" ? "extended" : "regular"
        onClicked: {
            if (menuPopup.opened) menuPopup.close()
            else menuPopup.open()
        }

        // Icon rotation animation
        contentItem: Item {
            anchors.fill: parent
            Row {
                anchors.centerIn: parent
                spacing: 8 * themeGlobalScale

                MeoIcon {
                    icon: fab.icon.name
                    size: 24
                    color: fab.themeOnPrimaryContainer
                    rotation: control.isOpen ? 45 : 0
                    Behavior on rotation { NumberAnimation { duration: 200 } }
                }

                Text {
                    text: fab.text
                    visible: fab.type === "extended" && text !== ""
                    font.pixelSize: 14 * themeGlobalScale
                    color: fab.themeOnPrimaryContainer
                }
            }
        }
    }
}
