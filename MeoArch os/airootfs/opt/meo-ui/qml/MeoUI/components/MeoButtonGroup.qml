import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    // model: [{ label: "Action", icon: "add", action: function }]
    property var model: []
    property string type: "tonal" // "filled" | "tonal" | "outlined" | "elevated"
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property int currentIndex: 0

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ? MeoTheme.contentOnPrimaryContainer : "#21005D"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"

    readonly property var fontToken: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        if (size === "xs") return MeoTheme.labelSmall;
        if (size === "s") return MeoTheme.labelMedium;
        if (size === "l") return MeoTheme.titleSmall;
        if (size === "xl") return MeoTheme.titleMedium;
        return MeoTheme.labelLarge;
    }

    implicitHeight: {
        if (size === "xs") return MeoTheme.buttonHeightXS || 32 * themeGlobalScale;
        if (size === "s") return MeoTheme.buttonHeightS || 40 * themeGlobalScale;
        if (size === "l") return MeoTheme.buttonHeightL || 56 * themeGlobalScale;
        if (size === "xl") return MeoTheme.buttonHeightXL || 72 * themeGlobalScale;
        return MeoTheme.buttonHeightM || 48 * themeGlobalScale;
    }

    implicitWidth: contentRow.implicitWidth

    contentItem: Row {
        id: contentRow
        spacing: 0

        Repeater {
            model: control.model
            delegate: Button {
                id: btn
                property var itemData: modelData
                property bool selected: index === control.currentIndex

                implicitHeight: control.height
                implicitWidth: Math.max((control.size === "xs" ? 48 : 64) * control.themeGlobalScale, btnContent.implicitWidth + (control.size === "xs" ? 16 : 24) * control.themeGlobalScale)
                z: selected ? 2 : 1

                background: Item {
                    clip: true // 🌟 This is the key to connected shapes

                    Rectangle {
                        id: mainBg
                        // Make the rectangle wider than the container to "hide" rounded corners
                        x: index === 0 ? 0 : -height / 2
                        width: parent.width + (index === 0 ? (index === control.model.length - 1 ? 0 : height / 2) : (index === control.model.length - 1 ? height / 2 : height))
                        height: parent.height
                        radius: height / 2

                        color: {
                            if (!control.enabled) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined' && MeoTheme.isDarkMode) ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
                            if (btn.selected) return control.themePrimary;
                            if (control.type === "filled") return control.themePrimaryContainer;
                            if (control.type === "tonal") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8";
                            if (control.type === "elevated") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA";
                            return "transparent";
                        }
                        border.color: control.themeOutline
                        border.width: (control.type === "outlined") ? 1 * themeGlobalScale : 0

                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    MeoStateLayer {
                        // Match the mainBg geometry for consistent state layer behavior
                        x: index === 0 ? 0 : -parent.height / 2
                        width: parent.width + (index === 0 ? (index === control.model.length - 1 ? 0 : parent.height / 2) : (index === control.model.length - 1 ? parent.height / 2 : parent.height))
                        radius: parent.height / 2
                        pressed: btn.pressed
                        hovered: btn.hovered
                        color: btn.selected ? control.themeOnPrimary : control.themePrimary
                    }
                }

                contentItem: Row {
                    id: btnContent
                    spacing: (control.size === "xs" ? 4 : 8) * control.themeGlobalScale
                    anchors.centerIn: parent

                    MeoIcon {
                        icon: btn.itemData.icon || ""
                        visible: icon !== ""
                        size: (control.size === "xs" ? 16 : (control.size === "xl" ? 24 : 18))
                        color: btn.selected ? control.themeOnPrimary : (control.type === "filled" ? control.themeOnPrimaryContainer : control.themePrimary)
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: btn.itemData.label || ""
                        visible: text !== ""
                        font.pixelSize: control.fontToken.size * control.themeGlobalScale
                        font.weight: btn.selected ? Font.Bold : control.fontToken.weight
                        color: btn.selected ? control.themeOnPrimary : (control.type === "filled" ? control.themeOnPrimaryContainer : control.themePrimary)
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }

                onClicked: {
                    control.currentIndex = index;
                    if (btn.itemData.action) btn.itemData.action();
                }
            }
        }
    }
}
