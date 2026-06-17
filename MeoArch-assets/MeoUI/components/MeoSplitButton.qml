import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string text: ""
    property string icon: ""
    property string type: "filled" // "filled" | "tonal" | "outlined" | "elevated" | "text"
    property bool isEmphasized: false
    property var menuModel: []

    // Size variants (simplified from MD3 XL-XS)
    // small | medium (default) | large
    property string sizeVariant: "medium"

    signal clicked()
    signal menuOpened()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false

    readonly property color textColor: {
        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF";
        if (type === "tonal") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B";
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
    }

    readonly property color bgColor: {
        if (!control.enabled) {
            if (type === "outlined" || type === "text") return "transparent";
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        }
        if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
        if (type === "tonal") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8";
        if (type === "elevated") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA";
        return "transparent";
    }

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitHeight: (sizeVariant === "small" ? 32 : (sizeVariant === "large" ? 48 : 40)) * themeGlobalScale
    implicitWidth: mainAction.implicitWidth + menuAction.implicitWidth + 1 * themeGlobalScale

    background: Rectangle {
        radius: control.height / 2
        color: control.bgColor
        border.color: {
            if (control.type !== "outlined") return "transparent";
            if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
            return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E";
        }
        border.width: control.type === "outlined" ? 1 * themeGlobalScale : 0

        // MD3 Elevation for 'elevated' type
        layer.enabled: control.type === "elevated" && control.enabled
        layer.effect: DropShadow {
            radius: 0.2
            verticalOffset: 1 * themeGlobalScale
            color: Qt.rgba(0,0,0,0.2)
        }

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    contentItem: Row {
        spacing: 0

        // Main Action Area
        Item {
            id: mainAction
            height: control.height
            implicitWidth: contentRow.implicitWidth + (sizeVariant === "small" ? 16 : 24) * control.themeGlobalScale

            Rectangle {
                id: mainState
                anchors.fill: parent
                radius: parent.height / 2
                color: "transparent"

                // Mask the right side to keep the split look
                clip: true
                Rectangle {
                    anchors.fill: parent
                    anchors.rightMargin: -parent.radius
                    color: "transparent"

                    MeoStateLayer {
                        radius: mainState.radius
                        pressed: mainMouse.pressed
                        hovered: mainMouse.containsMouse
                        color: control.textColor
                    }
                }
            }

            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: 8 * control.themeGlobalScale

                MeoIcon {
                    icon: control.icon
                    visible: icon !== ""
                    size: sizeVariant === "small" ? 16 : 18
                    color: control.textColor
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: control.text
                    font.pixelSize: (sizeVariant === "small" ? 12 : 14) * control.themeGlobalScale
                    font.weight: control.isEmphasized ? Font.Bold : Font.Medium
                    color: control.textColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MouseArea {
                id: mainMouse
                anchors.fill: parent
                onClicked: control.clicked()
            }
        }

        // Vertical Divider
        Rectangle {
            width: 1 * control.themeGlobalScale
            height: control.height * 0.6
            anchors.verticalCenter: parent.verticalCenter
            color: control.textColor
            opacity: 0.2
            visible: control.type !== "text"
        }

        // Menu Action Area
        Item {
            id: menuAction
            height: control.height
            implicitWidth: (sizeVariant === "small" ? 32 : 40) * control.themeGlobalScale

            Rectangle {
                id: menuState
                anchors.fill: parent
                radius: parent.height / 2
                color: "transparent"
                clip: true

                // Mask the left side
                Rectangle {
                    anchors.fill: parent
                    anchors.leftMargin: -parent.radius
                    color: "transparent"

                    MeoStateLayer {
                        radius: menuState.radius
                        pressed: menuMouse.pressed
                        hovered: menuMouse.containsMouse
                        color: control.textColor
                    }
                }
            }

            MeoIcon {
                id: menuIcon
                anchors.centerIn: parent
                icon: "arrow_drop_down"
                size: sizeVariant === "small" ? 18 : 24
                color: control.textColor

                // MD3 Expressive: Rotate icon when menu is open
                rotation: menuPopup.opened ? 180 : 0
                Behavior on rotation { NumberAnimation { duration: 200; easing.type: Easing.OutQuad } }
            }

            MouseArea {
                id: menuMouse
                anchors.fill: parent
                onClicked: {
                    menuPopup.open()
                    control.menuOpened()
                }
            }

            MeoMenu {
                id: menuPopup
                y: parent.height + 4 * control.themeGlobalScale
                x: parent.width - width
                model: control.menuModel
            }
        }
    }
}
