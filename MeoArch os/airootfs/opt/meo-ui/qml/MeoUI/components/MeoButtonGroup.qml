import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    // model: [{ label: "Action", icon: "add", action: function }]
    property var model: []
    property string type: "tonal" // "filled" | "tonal" | "outlined" | "elevated"
    property string sizeVariant: "medium" // small | medium | large
    property int currentIndex: 0

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ? MeoTheme.contentOnPrimaryContainer : "#21005D"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationFast !== "undefined") ? MeoTheme.motionDurationFast : 150
    readonly property int motionMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationMedium !== "undefined") ? MeoTheme.motionDurationMedium : 300
    readonly property int motionExit: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationShort2 !== "undefined") ? MeoTheme.motionDurationShort2 : 100
    readonly property var fontLabelBig: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelBig !== 'undefined') ? MeoTheme.labelBig : { "size": 14, "weight": Font.Medium }
    readonly property var fontLabelMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelMediumUi !== 'undefined') ? MeoTheme.labelMediumUi : { "size": 12, "weight": Font.Medium }

    implicitHeight: (sizeVariant === "small" ? 32 : (sizeVariant === "large" ? 48 : 40)) * themeGlobalScale
    implicitWidth: contentRow.implicitWidth

    contentItem: Row {
        id: contentRow
        spacing: 2 * themeGlobalScale

        Repeater {
            model: control.model
            delegate: Button {
                id: btn
                property var itemData: modelData
                property bool selected: index === control.currentIndex

                implicitHeight: control.height
                implicitWidth: contentItem.implicitWidth + (sizeVariant === "small" ? 16 : 24) * control.themeGlobalScale
                z: selected ? 2 : 1

                background: Rectangle {
                    // Overall radius for state layer and interaction
                    radius: height / 2
                    color: "transparent"

                    Rectangle {
                        id: mainBg
                        anchors.fill: parent
                        radius: height / 2
                        color: {
                            if (!control.enabled) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined' && MeoTheme.isDarkMode) ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
                            if (type === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF";
                            if (type === "tonal") return control.themePrimaryContainer;
                            if (type === "elevated") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA";
                            return "transparent";
                        }
                        border.color: {
                            if (control.type !== "outlined") return "transparent";
                            return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E";
                        }
                        border.width: control.type === "outlined" ? 1 * themeGlobalScale : 0

                        Behavior on color { ColorAnimation { duration: control.motionFast } }
                    }

                    Rectangle {
                        anchors.fill: parent
                        radius: height / 2
                        color: type === "filled" ? control.themePrimary : control.themePrimary
                        opacity: btn.selected ? 1 : 0
                        scale: btn.pressed ? 0.98 : (btn.selected ? 1 : 0.92)

                        Behavior on opacity {
                            NumberAnimation {
                                duration: btn.selected ? control.motionMedium : control.motionExit
                                easing.bezierCurve: btn.selected
                                                    ? ((typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1])
                                                    : ((typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedAccelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedAccelerate : [0.3, 0, 0.8, 0.15])
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: btn.selected ? control.motionMedium : control.motionFast
                                easing.bezierCurve: btn.selected
                                                    ? ((typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1])
                                                    : ((typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedAccelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedAccelerate : [0.3, 0, 0.8, 0.15])
                            }
                        }
                    }

                    MeoStateLayer {
                        radius: parent.radius
                        pressed: btn.pressed
                        hovered: btn.hovered
                        color: {
                            if (type === "filled") return control.themeOnPrimary;
                            return control.themePrimary;
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
                            if (type === "filled") return control.themeOnPrimary;
                            if (type === "tonal") return btn.selected ? control.themeOnPrimary : control.themeOnPrimaryContainer;
                            return control.themePrimary;
                        }
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: btn.itemData.label || ""
                        visible: text !== ""
                        font.pixelSize: (sizeVariant === "small" ? control.fontLabelMedium.size : control.fontLabelBig.size) * control.themeGlobalScale
                        font.weight: (sizeVariant === "small" ? control.fontLabelMedium.weight : control.fontLabelBig.weight)
                        color: {
                            if (type === "filled") return control.themeOnPrimary;
                            if (type === "tonal") return btn.selected ? control.themeOnPrimary : control.themeOnPrimaryContainer;
                            return control.themePrimary;
                        }
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
