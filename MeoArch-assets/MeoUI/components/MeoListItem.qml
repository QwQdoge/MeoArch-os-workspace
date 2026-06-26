import QtQuick
import QtQuick.Controls
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
    property var actions: [] // 🌟 New: Multiple trailing actions support (Array of Components)

    property bool interactive: true
    property bool isSegmented: false // MD3 Expressive: Segmented list style
    property bool isEmphasized: false // MD3 Expressive: Use bold typography
    property bool vibrant: false // 🌟 MD3 Expressive: Vibrant selection style
    property bool selected: false

    signal clicked()

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimaryContainer !== 'undefined') ? MeoTheme.onPrimaryContainer : "#21005D"
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
        let h = 56;
        if (supportingText !== "") {
            h = (supportingTextLines > 1 || overline !== "") ? 88 : 72;
        }
        if (leadingImage !== "" && leadingImageSize > 40) h = Math.max(h, leadingImageSize + 16);
        if (isSegmented) h += 8;
        return Math.max(h * themeGlobalScale, contentRow.implicitHeight + padding * 2);
    }

    padding: isSegmented ? 12 * themeGlobalScale : 16 * themeGlobalScale
    spacing: 16 * themeGlobalScale // Standardized MD3 spacing

    background: Rectangle {
        color: {
            if (!isSegmented || !selected) return "transparent";
            return vibrant ? themePrimaryContainer : themeSecondaryContainer;
        }
        radius: isSegmented ? (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeLarge : 16 * themeGlobalScale) : 0

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: isSegmented ? 8 * themeGlobalScale : 0
        anchors.rightMargin: isSegmented ? 8 * themeGlobalScale : 0

        Rectangle {
            anchors.fill: parent
            visible: control.interactive
            radius: parent.radius
            color: {
                let overlayColor = (vibrant && selected) ? control.themeOnPrimaryContainer : control.themeOnSurface;
                if (mouseArea.pressed) return Qt.rgba(overlayColor.r, overlayColor.g, overlayColor.b, 0.12)
                if (mouseArea.containsMouse) return Qt.rgba(overlayColor.r, overlayColor.g, overlayColor.b, 0.08)
                return "transparent"
            }
            Behavior on color { ColorAnimation { duration: 150 } }
        }
        Behavior on color { ColorAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]) } }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: control.interactive
        onClicked: control.clicked()
    }

    contentItem: Row {
        id: contentRow
        spacing: control.spacing
        width: parent.width

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
                size: 24
                color: control.themeOnSurfaceVariant
                visible: control.leadingIcon !== "" && control.leadingComponent === null && control.leadingImage === ""
            }

            Rectangle {
                anchors.fill: parent
                radius: control.leadingImageVariant === "circle" ? width / 2 : 8 * control.themeGlobalScale
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
