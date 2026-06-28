import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    // model: [{ label: "Action", icon: "add", action: function }]
    property var model: []
    property string type: "outlined" // "filled" | "tonal" | "outlined" | "elevated"
    property string sizeVariant: "medium" // small | medium | large

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitHeight: (sizeVariant === "small" ? 32 : (sizeVariant === "large" ? 48 : 40)) * themeGlobalScale
    implicitWidth: contentRow.implicitWidth

    contentItem: Row {
        id: contentRow
        spacing: -1 * themeGlobalScale // Overlap borders

        Repeater {
            model: control.model
            delegate: Button {
                id: btn
                property var itemData: modelData

                implicitHeight: control.height
                implicitWidth: contentItem.implicitWidth + (sizeVariant === "small" ? 16 : 24) * control.themeGlobalScale

                background: Rectangle {
                    // Overall radius for state layer and interaction
                    radius: control.height / 2
                    color: "transparent"

                    // MD3: start has left round, end has right round, middle is square
                    Rectangle {
                        id: mainBg
                        anchors.fill: parent
                        radius: (index === 0 || index === control.model.length - 1) ? parent.radius : 0
                        color: {
                            if (!control.enabled) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined' && MeoTheme.isDarkMode) ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
                            if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
                            if (type === "tonal") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8";
                            if (type === "elevated") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA";
                            return "transparent";
                        }
                        border.color: {
                            if (control.type !== "outlined") return "transparent";
                            return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E";
                        }
                        border.width: control.type === "outlined" ? 1 * themeGlobalScale : 0

                        // Squaring off logic
                        Rectangle {
                            anchors.right: parent.right
                            width: parent.radius
                            height: parent.height
                            color: parent.color
                            visible: index === 0 && control.model.length > 1
                        }
                        Rectangle {
                            anchors.left: parent.left
                            width: parent.radius
                            height: parent.height
                            color: parent.color
                            visible: index === control.model.length - 1 && control.model.length > 1
                        }
                    }

                    MeoStateLayer {
                        radius: parent.radius
                        pressed: btn.pressed
                        hovered: btn.hovered
                        color: {
                            if (type === "filled") return "white";
                            return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
                        }
                    }
                }

                contentItem: Row {
                    spacing: 8 * control.themeGlobalScale
                    anchors.centerIn: parent

                    MeoIcon {
                        icon: btn.itemData.icon || ""
                        visible: icon !== ""
                        size: sizeVariant === "small" ? 16 : 18
                        color: {
                            if (type === "filled") return "white";
                            return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: btn.itemData.label || ""
                        visible: text !== ""
                        font.pixelSize: (sizeVariant === "small" ? 12 : 14) * control.themeGlobalScale
                        font.weight: Font.Medium
                        color: {
                            if (type === "filled") return "white";
                            return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: {
                    if (btn.itemData.action) btn.itemData.action();
                }
            }
        }
    }
}
