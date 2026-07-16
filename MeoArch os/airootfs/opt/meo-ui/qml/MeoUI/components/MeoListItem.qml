import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string headline: ""
    property string supportingText: ""
    property string overline: ""
    property int supportingTextLines: 1 // 1, 2 or 3
    property string leadingIcon: ""
    property string leadingImage: "" // 🖼️ New: MD3 Expressive Large Image/Avatar
    property string leadingImageVariant: "square" // "square" | "circle"
    property real leadingImageSize: 40 // 40 (Avatar) | 56 (Small Image) | 64 (Large Image)

    // Trailing Area Properties
    property string badgeText: ""
    property color badgeColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.error !== 'undefined') ? MeoTheme.error : "#B3261E"
    property Component leadingComponent: null
    property Component trailingComponent: null
    property list<Component> actions

    property bool interactive: true
    property bool isSegmented: false // MD3 Expressive: Segmented list style
    property string roundingStrategy: "all" // "all" | "top" | "bottom" | "middle" | "none"
    property bool isDense: false // MD3 Expressive: Compact list style
    property bool isEmphasized: false // MD3 Expressive: Use bold typography
    property bool vibrant: false // 🌟 MD3 Expressive: Vibrant selection style
    property bool selected: false
    readonly property bool pressed: mouseArea.pressed
    property string shape: "rect" // 🌟 MD3 Expressive: "rect" | "squircle" | "hexagon" | ...

    signal clicked()

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ? MeoTheme.contentOnPrimaryContainer : "#21005D"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontBodyLarge: {
        if (typeof MeoTheme === 'undefined') return { "size": 16, "weight": Font.Normal };
        return isEmphasized ? (MeoTheme.bodyLargeEmphasized || MeoTheme.bodyLarge) : MeoTheme.bodyLarge;
    }
    readonly property var fontBodyMedium: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Normal };
        return isEmphasized ? (MeoTheme.bodyMediumEmphasized || MeoTheme.bodyMedium) : MeoTheme.bodyMedium;
    }

    implicitWidth: 360 * themeGlobalScale
    // MD3 Heights: 1-line (56/72), 2-line (72/88), 3-line (88)
    implicitHeight: {
        let h = isDense ? 48 : 56;
        if (supportingText !== "") {
            h = (supportingTextLines > 1 || overline !== "") ? (isDense ? 72 : 88) : (isDense ? 64 : 72);
        }
        if (leadingImage !== "" && leadingImageSize > 40) h = Math.max(h, leadingImageSize + (isDense ? 8 : 16));
        if (isSegmented) h += 8;
        return Math.max(h * themeGlobalScale, contentRow.implicitHeight + padding * 2);
    }

    padding: {
        if (isDense) return 8 * themeGlobalScale;
        return isSegmented ? 12 * themeGlobalScale : 16 * themeGlobalScale;
    }
    spacing: 16 * themeGlobalScale // Standardized MD3 spacing
    activeFocusOnTab: interactive
    Accessible.role: Accessible.ListItem
    Accessible.name: headline
    Accessible.description: supportingText
    Accessible.selected: selected
    Accessible.focusable: interactive
    Accessible.onPressAction: if (interactive) control.clicked()
    Keys.onReturnPressed: if (interactive) control.clicked()
    Keys.onEnterPressed: if (interactive) control.clicked()
    Keys.onSpacePressed: if (interactive) control.clicked()

    background: Item {
        width: control.width - (control.isSegmented ? 16 * control.themeGlobalScale : 0)
        height: control.height
        x: control.isSegmented ? 8 * control.themeGlobalScale : 0

        Rectangle {
            id: shapeBg
            anchors.fill: parent
            radius: {
                if (!isSegmented) return 0;
                if (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive && selected) return MeoTheme.shapeLargeIncreased;
                return (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeLarge : 16 * themeGlobalScale);
            }
            color: {
                if (!isSegmented || !selected) return "transparent";
                if (vibrant && typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive) return themePrimary;
                return vibrant ? themePrimaryContainer : themeSecondaryContainer;
            }

            // MD3 Expressive: Rounding strategies for connected items in a group
            topLeftRadius: (roundingStrategy === "all" || roundingStrategy === "top") ? radius : 0
            topRightRadius: (roundingStrategy === "all" || roundingStrategy === "top") ? radius : 0
            bottomLeftRadius: (roundingStrategy === "all" || roundingStrategy === "bottom") ? radius : 0
            bottomRightRadius: (roundingStrategy === "all" || roundingStrategy === "bottom") ? radius : 0

            MeoStateLayer {
                anchors.fill: parent
                visible: control.interactive
                pressed: mouseArea.pressed
                hovered: mouseArea.containsMouse
                focused: control.activeFocus
                pressX: mouseArea.mouseX
                pressY: mouseArea.mouseY
                radius: (control.isSegmented && control.roundingStrategy === "all" && control.shape === "rect") ? shapeBg.radius : 0
                color: {
                    if (vibrant && selected) return control.themeOnPrimaryContainer;
                    if (selected) return control.themeOnSecondaryContainer;
                    return control.themeOnSurface;
                }
            }

            Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
        }

        // Overlay for complex shapes if using MeoShape (Note: MeoShape doesn't support partial rounding as easily as Rectangle)
        MeoShape {
            anchors.fill: parent
            visible: isSegmented && control.shape !== "rect"
            type: control.shape
            radius: shapeBg.radius
            color: shapeBg.color
            opacity: selected ? 1.0 : 0.0
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: control.interactive
        hoverEnabled: true
        onClicked: {
            control.forceActiveFocus(Qt.MouseFocusReason)
            control.clicked()
        }
    }

    contentItem: Row {
        id: contentRow
        spacing: control.spacing
        width: control.availableWidth
        height: control.availableHeight

        // 🖼️ Leading Visuals Area
        Item {
            width: {
                if (control.leadingImage !== "") return control.leadingImageSize * control.themeGlobalScale;
                if (control.leadingIcon !== "" || control.leadingComponent !== null) return 24 * control.themeGlobalScale;
                return 0;
            }
            height: width > 0 ? Math.max(24 * control.themeGlobalScale, control.leadingImageSize * control.themeGlobalScale) : 0
            anchors.verticalCenter: parent.verticalCenter
            visible: width > 0

            Loader {
                anchors.centerIn: parent
                sourceComponent: control.leadingComponent
                visible: control.leadingComponent !== null
            }

            MeoIcon {
                anchors.centerIn: parent
                icon: control.leadingIcon
                size: isDense ? 20 : 24
                color: control.themeOnSurfaceVariant
                visible: control.leadingIcon !== "" && control.leadingComponent === null && control.leadingImage === ""
            }

            MeoShape {
                anchors.fill: parent
                type: control.leadingImageVariant === "circle" ? "circle" : control.leadingImageVariant
                radius: 8 * control.themeGlobalScale
                clip: true
                visible: control.leadingImage !== ""
                color: control.themeSecondaryContainer

                Image {
                    anchors.fill: parent
                    source: control.leadingImage
                    fillMode: Image.PreserveAspectCrop
                }
            }
        }

        // 🔤 Content Area
        Column {
            width: parent.width - (leadingRowItemWidth() > 0 ? leadingRowItemWidth() + control.spacing : 0) - trailingRowItemWidth()
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: control.overline
                width: parent.width
                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelSmall !== 'undefined' ? MeoTheme.labelSmall.size : 11) * control.themeGlobalScale
                font.weight: Font.Normal
                color: control.themeOnSurfaceVariant
                visible: text !== ""
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            Text {
                text: control.headline
                width: parent.width
                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: fontBodyLarge.size * control.themeGlobalScale
                font.weight: (control.selected && !isSegmented) ? Font.Bold : fontBodyLarge.weight
                font.letterSpacing: (fontBodyLarge.letterSpacing || 0) * control.themeGlobalScale
                lineHeight: (fontBodyLarge.lineHeight ? (fontBodyLarge.lineHeight / fontBodyLarge.size) : 1.2)
                color: {
                    if (control.selected && isSegmented) {
                        return vibrant ? control.themeOnPrimaryContainer : control.themeOnSecondaryContainer;
                    }
                    return control.themeOnSurface;
                }
                elide: Text.ElideRight
                Behavior on color { ColorAnimation { duration: 150 } }
            }

            Text {
                text: control.supportingText
                width: parent.width
                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: fontBodyMedium.size * control.themeGlobalScale
                font.weight: fontBodyMedium.weight
                font.letterSpacing: (fontBodyMedium.letterSpacing || 0) * control.themeGlobalScale
                lineHeight: (fontBodyMedium.lineHeight ? (fontBodyMedium.lineHeight / fontBodyMedium.size) : 1.2)
                color: control.themeOnSurfaceVariant
                visible: text !== ""
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: Math.min(3, control.supportingTextLines)
            }
        }

        // 🏷️ Trailing Area
        Row {
            id: trailingActionsRow
            spacing: 12 * control.themeGlobalScale // Keeping 12 for compact action row
            anchors.verticalCenter: parent.verticalCenter
            visible: control.badgeText !== "" || control.trailingComponent !== null || control.actions.length > 0

            MeoBadge {
                text: control.badgeText
                visible: control.badgeText !== ""
                color: control.badgeColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Loader {
                width: 24 * control.themeGlobalScale
                height: 24 * control.themeGlobalScale
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: control.trailingComponent
                visible: control.trailingComponent !== null
            }

            // 🌟 Multiple Actions
            Repeater {
                model: control.actions
                delegate: Loader {
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: modelData
                }
            }
        }
    }

    // Helper functions for dynamic width calculation
    function leadingRowItemWidth() {
        if (control.leadingImage !== "") return control.leadingImageSize * control.themeGlobalScale;
        if (control.leadingIcon !== "" || control.leadingComponent !== null) return 24 * control.themeGlobalScale;
        return 0;
    }

    function trailingRowItemWidth() {
        let w = 0;
        if (control.badgeText !== "") w += 24 * control.themeGlobalScale;
        if (control.trailingComponent !== null) w += 24 * control.themeGlobalScale;

        // Actions width estimation
        if (control.actions.length > 0) {
            w += control.actions.length * 40 * control.themeGlobalScale; // estimated button width
            w += (control.actions.length - 1) * (12 * control.themeGlobalScale);
        }

        if (w > 0) w += control.spacing;
        return w;
    }
}
