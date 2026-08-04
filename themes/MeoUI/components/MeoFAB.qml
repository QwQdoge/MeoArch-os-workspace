import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Button {
    id: control

    // 🌟 Backwards Compatibility & New Expressive Size Options
    property string type: "regular" // "small" | "regular" | "large" | "extended" | "collapsed"
    property string size: "small"    // "small" | "medium" | "large"
    property string shape: "rect"    // "rect" | "squircle" | "circle" | "clover" | "star" | "hexagon" | ...
    property bool collapsed: false
    property bool vibrant: false     // Vibrant background gradient support
    property bool outlined: false    // Outlined border support
    property bool selected: false    // Selection/checked toggle state support
    property bool isEmphasized: false // Bolder text typography
    property bool bouncy: (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive && MeoTheme.isBouncy) || true

    // Toggle Support
    checkable: false
    checked: false

    readonly property bool isExtended: type === "extended" || (text.length > 0 && type !== "small" && type !== "regular" && type !== "large")
    readonly property bool showsLabel: isExtended && text.length > 0

    readonly property color themePrimaryContainer: {
        if (outlined) return "transparent";
        if (vibrant) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.tertiaryContainer !== 'undefined') ? MeoTheme.tertiaryContainer : "#FFD8E4";
        if (control.checked || control.selected) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF";
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF";
    }

    readonly property color themeOnPrimaryContainer: {
        if (outlined) {
            if (control.checked || control.selected) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
            return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F";
        }
        if (vibrant) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnTertiaryContainer !== 'undefined') ? MeoTheme.contentOnTertiaryContainer : "#31111D";
        if (control.checked || control.selected) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ? MeoTheme.contentOnPrimaryContainer : "#21005D";
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ? MeoTheme.contentOnPrimaryContainer : "#21005D";
    }

    readonly property color vibrantGradientColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.tertiary !== 'undefined') ? MeoTheme.tertiary : "#7D5260"

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property real baseHeight: {
        if (showsLabel) {
            // Extended FAB Sizes
            if (size === "large" || size === "l") return 96 * themeGlobalScale;
            if (size === "medium" || size === "m" || size === "regular") return 80 * themeGlobalScale;
            return 56 * themeGlobalScale; // default / small
        } else {
            // Standard FAB Sizes
            if (type === "small" || size === "small" || size === "s") {
                if (type === "regular" || type === "large") return type === "large" ? 96 * themeGlobalScale : 56 * themeGlobalScale;
                return 40 * themeGlobalScale;
            }
            if (type === "large" || size === "large" || size === "l") return 96 * themeGlobalScale;
            return 56 * themeGlobalScale; // regular / medium
        }
    }

    readonly property real restRadius: {
        if (showsLabel) {
            if (size === "large" || size === "l") return 32 * themeGlobalScale; // Extra Large Increased (32dp)
            if (size === "medium" || size === "m" || size === "regular") return 28 * themeGlobalScale; // Extra Large (28dp)
            return 16 * themeGlobalScale; // Large (16dp)
        } else {
            if (type === "small" || size === "small" || size === "s") {
                if (type === "regular" || type === "large") return type === "large" ? 28 * themeGlobalScale : 16 * themeGlobalScale;
                return 12 * themeGlobalScale;
            }
            if (type === "large" || size === "large" || size === "l") return 28 * themeGlobalScale;
            return 16 * themeGlobalScale;
        }
    }

    readonly property real interactiveRadius: pressed ? baseHeight / 2
                                             : hovered ? Math.min(baseHeight / 2, restRadius + 8 * themeGlobalScale)
                                                       : restRadius
    readonly property real elevationLevel: !enabled ? 0 : hovered ? 4 : 3

    readonly property int effectiveIconSize: {
        if (showsLabel) {
            if (size === "large" || size === "l") return 36 * themeGlobalScale;
            if (size === "medium" || size === "m" || size === "regular") return 28 * themeGlobalScale;
            return 24 * themeGlobalScale;
        } else {
            if (type === "large" || size === "large" || size === "l") return 36 * themeGlobalScale;
            return 24 * themeGlobalScale;
        }
    }

    readonly property var fontToken: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        let token;
        if (showsLabel) {
            if (size === "large" || size === "l") token = MeoTheme.headlineSmall;
            else if (size === "medium" || size === "m" || size === "regular") token = MeoTheme.titleLarge;
            else token = MeoTheme.titleMedium; // Small Extended FAB typography is Title Medium
        } else {
            token = MeoTheme.labelLarge;
        }

        if (isEmphasized) {
            if (showsLabel) {
                if (size === "large" || size === "l") return MeoTheme.headlineSmallEmphasized || token;
                if (size === "medium" || size === "m" || size === "regular") return MeoTheme.titleLargeEmphasized || token;
                return MeoTheme.titleMediumEmphasized || token;
            }
            return MeoTheme.labelLargeEmphasized || token;
        }
        return token;
    }

    // Paddings and Gaps per M3 specs
    readonly property real leadingSpace: {
        if (showsLabel) {
            if (size === "large" || size === "l") return 24 * themeGlobalScale;
            if (size === "medium" || size === "m" || size === "regular") return 20 * themeGlobalScale;
            return 16 * themeGlobalScale; // small
        }
        return 0;
    }

    readonly property real iconLabelSpace: {
        if (showsLabel) {
            if (size === "large" || size === "l") return 12 * themeGlobalScale;
            if (size === "medium" || size === "m" || size === "regular") return 10 * themeGlobalScale;
            return 8 * themeGlobalScale; // small
        }
        return 0;
    }

    readonly property real trailingSpace: {
        if (showsLabel) {
            if (size === "large" || size === "l") return 24 * themeGlobalScale;
            if (size === "medium" || size === "m" || size === "regular") return 20 * themeGlobalScale;
            return 16 * themeGlobalScale; // small
        }
        return 0;
    }

    implicitWidth: showsLabel && !collapsed
                   ? Math.max(112 * themeGlobalScale, fabContent.implicitWidth + leadingSpace + trailingSpace)
                   : baseHeight
    implicitHeight: baseHeight
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationSelection !== 'undefined') ? MeoTheme.motionDurationSelection : 300
            easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingEmphasizedDecelerate !== 'undefined') ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
        }
    }

    background: Item {
        // MultiEffect mask requires an intermediary Item to wrap the shape background to avoid circular dependencies
        MeoShape {
            id: fabBackground
            anchors.fill: parent
            type: (control.shape === "rect" || control.shape === "round") ? "rect" : control.shape
            radius: control.interactiveRadius
            color: control.vibrant ? "transparent" : control.themePrimaryContainer
            transformOrigin: Item.Center
            scale: control.pressed ? (control.bouncy ? 0.96 : 0.99) : control.hovered ? 1.025 : 1.0

            // Outlined Stroke support
            strokeColor: {
                if (!control.outlined) return "transparent";
                if (!control.enabled) return Qt.rgba(0, 0, 0, 0.12);
                if (control.activeFocus || control.checked || control.selected) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
                return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E";
            }
            strokeWidth: control.outlined ? ((control.activeFocus || control.checked || control.selected || (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive)) ? 2 : 1) * control.themeGlobalScale : 0

            // Vibrant Gradient Overlay
            Rectangle {
                anchors.fill: parent
                radius: fabBackground.radius
                visible: control.vibrant
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: control.themePrimaryContainer }
                    GradientStop { position: 1.0; color: control.vibrantGradientColor }
                }

                layer.enabled: control.shape !== "rect" && control.shape !== "round"
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: vibrantMask
                }
            }

            // Sibling Item for Vibrant Mask (prevents inline QML parser errors)
            Item {
                id: vibrantMask
                width: fabBackground.width
                height: fabBackground.height
                visible: false
                MeoShape {
                    anchors.fill: parent
                    type: fabBackground.type
                    radius: fabBackground.radius
                }
            }

            layer.enabled: control.elevationLevel > 0
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: control.elevationLevel * 0.2
                shadowVerticalOffset: control.elevationLevel * 1.15 * control.themeGlobalScale
                shadowOpacity: control.elevationLevel > 0 ? 0.16 + control.elevationLevel * 0.018 : 0
                shadowColor: Qt.rgba(0, 0, 0, 0.24)
            }

            MeoStateLayer {
                anchors.fill: parent
                radius: parent.radius
                shape: fabBackground.type
                pressed: control.pressed
                hovered: control.hovered
                pressX: control.pressX
                pressY: control.pressY
                color: control.themeOnPrimaryContainer

                layer.enabled: control.shape !== "rect" && control.shape !== "round"
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: stateLayerMask
                }
            }

            // Sibling Item for State Layer Mask (prevents inline QML parser errors)
            Item {
                id: stateLayerMask
                width: fabBackground.width
                height: fabBackground.height
                visible: false
                MeoShape {
                    anchors.fill: parent
                    type: fabBackground.type
                    radius: fabBackground.radius
                }
            }

            Behavior on radius {
                NumberAnimation {
                    duration: control.pressed || control.hovered
                              ? ((typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationShapeEnter !== 'undefined') ? MeoTheme.motionDurationShapeEnter : 150)
                              : ((typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationShapeSettle !== 'undefined') ? MeoTheme.motionDurationShapeSettle : 150)
                    easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingEmphasizedDecelerate !== 'undefined') ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                }
            }
            Behavior on scale {
                NumberAnimation {
                    duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationState !== 'undefined') ? MeoTheme.motionDurationState : 100
                    easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingEmphasizedDecelerate !== 'undefined') ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                }
            }
        }
    }

    contentItem: Item {
        id: contentRoot
        implicitWidth: fabContent.implicitWidth
        implicitHeight: fabContent.implicitHeight
        clip: true

        Row {
            id: fabContent
            anchors.centerIn: parent
            height: Math.max(fabIcon.height, labelText.height)
            spacing: labelText.reveal ? control.iconLabelSpace : 0

            MeoIcon {
                id: fabIcon
                icon: (control.checked || control.selected) ? "check" : (control.icon.name || control.icon.source.toString())
                size: control.effectiveIconSize
                color: control.themeOnPrimaryContainer
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: labelText
                property real reveal: control.showsLabel && !control.collapsed ? 1 : 0
                width: implicitWidth * reveal
                height: implicitHeight
                clip: true
                visible: reveal > 0
                text: control.text
                font.family: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.typefacePlain !== 'undefined') ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: fontToken.size * control.themeGlobalScale
                font.weight: fontToken.weight
                color: control.themeOnPrimaryContainer
                lineHeightMode: Text.FixedHeight
                lineHeight: (fontToken.lineHeight || 20) * control.themeGlobalScale
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                opacity: reveal
                anchors.verticalCenter: parent.verticalCenter

                Behavior on reveal {
                    NumberAnimation {
                        duration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationSelection !== 'undefined') ? MeoTheme.motionDurationSelection : 300
                        easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingEmphasizedDecelerate !== 'undefined') ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                    }
                }
            }
        }
    }
}