import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property var model: [] // [{ label: "Action", icon: "add", action: function }]
    property bool opened: false
    property string icon: "add"
    property string activeIcon: "close"
    property color color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    property color onColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimaryContainer !== 'undefined') ? MeoTheme.onPrimaryContainer : "#21005D"

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    width: 56 * themeGlobalScale
    height: 56 * themeGlobalScale

    // FAB Menu Container (the part that expands)
    // Using a Popup for better MD3 compliance and full-screen dismissal
    Popup {
        id: menuPopup
        x: control.width - width
        y: control.height - height
        width: control.opened ? (200 * themeGlobalScale) : (56 * themeGlobalScale)
        height: control.opened ? (model.length * 56 * themeGlobalScale + 64 * themeGlobalScale) : (56 * themeGlobalScale)
        padding: 0
        visible: control.opened
        onClosed: control.opened = false
        modal: true
        closePolicy: Popup.CloseOnPressOutside | Popup.CloseOnEscape

        background: Rectangle {
            radius: control.opened ? 28 * themeGlobalScale : 16 * themeGlobalScale
            color: control.color

            // Elevation Shadow
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.2
                shadowVerticalOffset: (control.opened ? 4 : 3) * themeGlobalScale
                shadowColor: Qt.rgba(0,0,0,0.2)
            }

            Behavior on radius { NumberAnimation { duration: 300 } }
        }

        contentItem: Column {
            anchors.fill: parent
            anchors.margins: 4 * control.themeGlobalScale
            spacing: 0

            // Placeholder for the main FAB position at bottom right
            Item {
                Layout.fillHeight: true
                width: 1
            }

            Repeater {
                model: control.model
                delegate: MeoListItem {
                    width: parent.width
                    headline: modelData.label
                    leadingIcon: modelData.icon || ""
                    padding: 12 * control.themeGlobalScale
                    implicitHeight: 56 * control.themeGlobalScale
                    isEmphasized: true
                    background: Rectangle {
                        color: "transparent"
                        radius: 24 * control.themeGlobalScale
                        MeoStateLayer {
                            radius: parent.radius
                            pressed: mouseArea.pressed
                            hovered: mouseArea.containsMouse
                            color: control.onColor
                        }
                    }
                    onClicked: {
                        if (modelData.action) modelData.action();
                        control.opened = false;
                    }
                }
            }

            // Spacer at bottom
            Item {
                implicitHeight: 56 * control.themeGlobalScale
                width: 1
            }
        }

        enter: Transition {
            NumberAnimation { property: "width"; from: 56 * themeGlobalScale; to: 200 * themeGlobalScale; duration: 300; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] }
            NumberAnimation { property: "height"; from: 56 * themeGlobalScale; to: model.length * 56 * themeGlobalScale + 64 * themeGlobalScale; duration: 300; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] }
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100 }
        }
    }

    // The Main FAB Button (triggers the menu)
    MeoFAB {
        id: fabButton
        anchors.fill: parent
        icon.name: control.opened ? control.activeIcon : control.icon
        onClicked: control.opened = !control.opened
        z: 100 // Ensure it's above the popup background if needed

        // Hide shadow when menu is open because the container has it
        layer.enabled: !control.opened
    }
}
