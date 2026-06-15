import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string type: "filled" // "filled" | "tonal" | "outlined" | "elevated"
    property string text: ""
    property string icon: ""
    property var menuModel: [] // [{ label: "", icon: "", action: function }]
    property bool isEmphasized: false

    signal clicked()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        return isEmphasized ? (MeoTheme.labelLargeEmphasized || MeoTheme.labelLarge) : MeoTheme.labelLarge;
    }

    readonly property color bgColor: {
        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        if (type === "filled") return (typeof MeoTheme !== 'undefined') ? MeoTheme.primary : "#6750A4";
        if (type === "tonal") return (typeof MeoTheme !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8";
        if (type === "elevated") return (typeof MeoTheme !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA";
        return "transparent";
    }

    readonly property color textColor: {
        if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        if (type === "filled") return (typeof MeoTheme !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF";
        if (type === "tonal") return (typeof MeoTheme !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B";
        return (typeof MeoTheme !== 'undefined') ? MeoTheme.primary : "#6750A4";
    }

    implicitHeight: 40 * themeGlobalScale
    implicitWidth: mainButton.implicitWidth + menuButton.implicitWidth

    background: Rectangle {
        radius: 20 * control.themeGlobalScale
        color: control.bgColor
        border.color: (control.type === "outlined") ? ((typeof MeoTheme !== 'undefined') ? MeoTheme.outline : "#79747E") : "transparent"
        border.width: (control.type === "outlined") ? 1 : 0

        // Surface Tint for Elevation
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: (control.type === "elevated" && typeof MeoTheme !== 'undefined') ? MeoTheme.surfaceTint(1) : "transparent"
            visible: control.type === "elevated"
        }

        layer.enabled: control.type === "elevated"
        layer.effect: DropShadow {
            radius: 0.2
            verticalOffset: 1 * control.themeGlobalScale
            color: Qt.rgba(0,0,0,0.2)
        }
    }

    contentItem: Row {
        spacing: 0

        // Leading Action Button
        Item {
            id: mainButton
            height: parent.height
            implicitWidth: contentRow.implicitWidth + 24 * control.themeGlobalScale

            Row {
                id: contentRow
                anchors.centerIn: parent
                spacing: 8 * control.themeGlobalScale

                MeoIcon {
                    icon: control.icon
                    size: 18
                    color: control.textColor
                    visible: control.icon !== ""
                    anchors.verticalCenter: parent.verticalCenter
                }

                Text {
                    text: control.text
                    font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
                    font.weight: fontLabelLarge.weight
                    color: control.textColor
                    anchors.verticalCenter: parent.verticalCenter
                }
            }

            MeoStateLayer {
                anchors.fill: parent
                // Custom radius for split parts
                Rectangle {
                    anchors.fill: parent
                    radius: 20 * control.themeGlobalScale
                    // Hide right part of radius
                    Rectangle {
                        width: parent.width / 2
                        height: parent.height
                        anchors.right: parent.right
                        color: parent.color
                        visible: false // Just conceptual
                    }
                }
                // Simplified: use a clip mask or just let it be
                radius: 20 * control.themeGlobalScale
                clip: true
                pressed: mainMouse.pressed
                hovered: mainMouse.containsMouse
                color: control.textColor
            }

            MouseArea {
                id: mainMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: control.clicked()
            }
        }

        // Divider
        Rectangle {
            width: 1 * control.themeGlobalScale
            height: 24 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            color: Qt.rgba(control.textColor.r, control.textColor.g, control.textColor.b, 0.38)
        }

        // Trailing Menu Button
        Item {
            id: menuButton
            height: parent.height
            implicitWidth: 36 * control.themeGlobalScale

            MeoIcon {
                id: chevronIcon
                anchors.centerIn: parent
                icon: "arrow_drop_down"
                size: 20
                color: control.textColor

                Behavior on rotation {
                    NumberAnimation { duration: 200; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] }
                }
            }

            MeoStateLayer {
                anchors.fill: parent
                radius: 20 * control.themeGlobalScale
                pressed: menuMouse.pressed
                hovered: menuMouse.containsMouse
                color: control.textColor
            }

            MouseArea {
                id: menuMouse
                anchors.fill: parent
                hoverEnabled: true
                onClicked: {
                    menu.open()
                }
            }

            MeoMenu {
                id: menu
                model: control.menuModel
                x: parent.width - width
                y: parent.height + 4 * control.themeGlobalScale
                onOpened: chevronIcon.rotation = 180
                onClosed: chevronIcon.rotation = 0
            }
        }
    }
}
