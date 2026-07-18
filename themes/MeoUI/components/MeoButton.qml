import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Effects
import MeoUI 1.0

pragma ComponentBehavior: Bound

Button {
    id: control

    // 🌟 核心开关
    property string type: "filled" // "filled" (默认) | "tonal" | "outlined" | "elevated" | "text"
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string shape: "round" // "round" | "square" | "squircle" | "hexagon" | ...
    property bool isEmphasized: false // MD3 Expressive: Use bold typography
    property bool loading: false // 🌟 MD3: Loading state with progress indicator
    property bool loadingWithContainer: false
    property bool selected: false // 🌟 MD3: Toggle state support
    property bool vibrant: false // 🌟 MD3 Expressive: Vibrant gradient background
    property bool bouncy: MeoTheme.isExpressive && MeoTheme.isBouncy
    property real contentSpacing: (size === "xs" ? 4 : 8) * MeoTheme.globalScale
    readonly property string effectiveType: type === "filledTonal" ? "tonal" : type

    // Toggle Support
    checkable: false
    checked: false

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationFast !== "undefined") ? MeoTheme.motionDurationFast : 150
    readonly property int motionMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationMedium !== "undefined") ? MeoTheme.motionDurationMedium : 300

    readonly property var fontToken: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        let token;
        if (size === "xs") token = MeoTheme.labelSmall;
        else if (size === "s") token = MeoTheme.labelMedium;
        else if (size === "l") token = MeoTheme.titleSmall;
        else if (size === "xl") token = MeoTheme.titleMedium;
        else token = MeoTheme.labelLarge;

        if (isEmphasized) {
            if (size === "xs") return MeoTheme.labelSmallEmphasized || token;
            if (size === "s") return MeoTheme.labelMediumEmphasized || token;
            if (size === "l") return MeoTheme.titleSmallEmphasized || token;
            if (size === "xl") return MeoTheme.titleMediumEmphasized || token;
            return MeoTheme.labelLargeEmphasized || token;
        }
        return token;
    }

    readonly property color bgColor: {
        if (!control.enabled) {
            if (effectiveType === "outlined" || effectiveType === "text")
                return Qt.rgba(textColor.r, textColor.g, textColor.b, 0);
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        }

        let base;
        if (effectiveType === "filled") base = (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
        else if (effectiveType === "tonal") base = (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8";
        else if (effectiveType === "elevated") base = (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA";
        else base = Qt.rgba(0, 0, 0, 0);

        if (control.checked || control.selected) {
            if (effectiveType === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : base;
            if (effectiveType === "outlined") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : base;
        }
        return base;
    }

    readonly property color vibrantColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.tertiary !== 'undefined') ? MeoTheme.tertiary : "#7D5260"

    readonly property real elevation: {
        if (!control.enabled || effectiveType === "text" || effectiveType === "outlined") return 0;
        if (effectiveType === "elevated") return control.pressed ? 1 : (control.hovered ? 2 : 1);
        if (effectiveType === "filled" || effectiveType === "tonal") return (control.pressed || control.checked || control.selected) ? 0 : (control.hovered ? 1 : 0);
        return 0;
    }

    readonly property int iconSize: {
        if (size === "xs" || size === "s") return 18;
        if (size === "xl") return 32;
        return 24;
    }

    readonly property color textColor: {
        if (!control.enabled) {
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        }
        if (control.checked || control.selected) {
             if (effectiveType === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ? MeoTheme.contentOnPrimaryContainer : "#21005D";
             if (effectiveType === "outlined") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B";
        }
        if (effectiveType === "filled") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? MeoTheme.contentOnPrimary : "#FFFFFF";
        if (effectiveType === "tonal") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B";
        return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
    }

    leftPadding: {
        let base;
        if (size === "xs") base = 12;
        else if (size === "s") base = 16;
        else if (size === "l") base = 32;
        else if (size === "xl") base = 48;
        else base = 24;

        if (control.icon.name !== "" || control.icon.source.toString() !== "" || control.checked || control.selected) return (base * 0.66) * MeoTheme.globalScale;
        return (control.effectiveType === "text" ? base * 0.5 : base) * MeoTheme.globalScale;
    }
    rightPadding: {
        let base;
        if (size === "xs") base = 12;
        else if (size === "s") base = 16;
        else if (size === "l") base = 32;
        else if (size === "xl") base = 48;
        else base = 24;
        return (control.effectiveType === "text" ? base * 0.5 : base) * MeoTheme.globalScale;
    }
    topPadding: 0
    bottomPadding: 0
    implicitHeight: {
        if (size === "xs") return MeoTheme.buttonHeightXS || 32 * MeoTheme.globalScale;
        if (size === "s") return MeoTheme.buttonHeightS || 40 * MeoTheme.globalScale;
        if (size === "l") return MeoTheme.buttonHeightL || 56 * MeoTheme.globalScale;
        if (size === "xl") return MeoTheme.buttonHeightXL || 72 * MeoTheme.globalScale;
        return MeoTheme.buttonHeightM || 48 * MeoTheme.globalScale;
    }

    contentItem: Item {
        implicitWidth: Math.max(contentRow.implicitWidth, (iconSize + 6) * MeoTheme.globalScale)
        implicitHeight: Math.max(contentRow.implicitHeight, (iconSize + 6) * MeoTheme.globalScale)
        // Press feedback remains perceptible in the regular theme too; the
        // expressive theme merely gets a slightly stronger compression.
        scale: control.pressed ? (control.bouncy ? 0.985 : 0.99) : 1.0
        Behavior on scale { NumberAnimation { duration: control.motionFast; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }

        Row {
            id: contentRow
            spacing: control.contentSpacing
            anchors.centerIn: parent
            opacity: control.loading ? 0.0 : 1.0
            visible: opacity > 0
            Behavior on opacity { NumberAnimation { duration: control.motionFast } }

            MeoIcon {
                icon: (control.checked || control.selected) ? "check" : (control.icon.name || control.icon.source.toString())
                visible: control.checked || control.selected || control.icon.name !== "" || control.icon.source.toString() !== ""
                size: control.iconSize
                color: control.textColor
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: control.motionFast } }

                Behavior on icon {
                    enabled: control.checkable || control.selected
                    SequentialAnimation {
                        NumberAnimation { target: parent; property: "scale"; to: 0; duration: control.motionFast }
                        PropertyAction { target: parent; property: "icon" }
                        NumberAnimation { target: parent; property: "scale"; to: 1; duration: control.motionFast }
                    }
                }
            }

            Text {
                text: control.text
                font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: fontToken.size * MeoTheme.globalScale
                font.weight: fontToken.weight
                font.letterSpacing: (fontToken.letterSpacing || 0) * MeoTheme.globalScale
                lineHeightMode: Text.FixedHeight
                lineHeight: fontToken.lineHeight ? fontToken.lineHeight * MeoTheme.globalScale : font.pixelSize * 1.2
                color: control.textColor
                verticalAlignment: Text.AlignVCenter
                anchors.verticalCenter: parent.verticalCenter
                Behavior on color { ColorAnimation { duration: control.motionFast } }
            }
        }

        MeoLoadingIndicator {
            indeterminate: true
            color: control.textColor
            vibrant: control.vibrant
            withContainer: control.loadingWithContainer
            anchors.centerIn: parent
            width: (control.iconSize + 6) * MeoTheme.globalScale
            height: (control.iconSize + 6) * MeoTheme.globalScale
            visible: control.loading
            opacity: control.loading ? 1.0 : 0.0
            scale: control.loading ? 1.0 : 0.82
            Behavior on opacity { NumberAnimation { duration: control.motionFast; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
            Behavior on scale { NumberAnimation { duration: control.motionMedium; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1] } }
        }
    }

    background: Item {
        implicitWidth: Math.max((control.effectiveType === "text" ? 48 : 64) * MeoTheme.globalScale, contentItem.implicitWidth + leftPadding + rightPadding)
        // Avoid circular dependency by using explicit height logic instead of control.implicitHeight
        implicitHeight: {
            if (control.size === "xs") return MeoTheme.buttonHeightXS || 32 * MeoTheme.globalScale;
            if (control.size === "s") return MeoTheme.buttonHeightS || 40 * MeoTheme.globalScale;
            if (control.size === "l") return MeoTheme.buttonHeightL || 56 * MeoTheme.globalScale;
            if (control.size === "xl") return MeoTheme.buttonHeightXL || 72 * MeoTheme.globalScale;
            return MeoTheme.buttonHeightM || 48 * MeoTheme.globalScale;
        }

        readonly property real baseRadius: {
            if (control.pressed) {
                if (control.size === "xs" || control.size === "s") return MeoTheme.shapeSmall;
                return MeoTheme.shapeMedium;
            }
            // Hover owns the first shape response.  This gives mouse users an
            // immediate affordance before a click instead of morphing only on
            // press.
            if (control.hovered) {
                if (control.size === "xs" || control.size === "s") return MeoTheme.shapeMedium;
                return MeoTheme.shapeLargeIncreased;
            }
            if (shape === "square") {
                if (size === "xs" || size === "s") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeMedium !== 'undefined') ? MeoTheme.shapeMedium : 12 * MeoTheme.globalScale;
                return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeLarge !== 'undefined') ? MeoTheme.shapeLarge : 16 * MeoTheme.globalScale;
            }
            if (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive) return MeoTheme.expressiveShapeCornerRadius;
            return height / 2;
        }

        MeoShape {
            id: shapeBg
            anchors.fill: parent
            type: (control.shape === "round" || control.shape === "square") ? "rect" : control.shape
            radius: parent.baseRadius
            color: control.vibrant && control.effectiveType === "filled" ? "transparent" : control.bgColor

            // Vibrant Gradient Overlay
            Rectangle {
                anchors.fill: parent
                radius: shapeBg.radius
                visible: control.vibrant && control.effectiveType === "filled"
                gradient: Gradient {
                    orientation: Gradient.Horizontal
                    GradientStop { position: 0.0; color: control.bgColor }
                    GradientStop { position: 1.0; color: control.vibrantColor }
                }

                layer.enabled: control.shape !== "round" && control.shape !== "square" && control.shape !== "rect"
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: shapeBg.width
                        height: shapeBg.height
                        MeoShape {
                            anchors.fill: parent
                            type: shapeBg.type
                            radius: shapeBg.radius
                        }
                    }
                }
            }

            // Surface Tint for Elevation
            Rectangle {
                anchors.fill: parent
                radius: shapeBg.radius
                color: (control.effectiveType === "elevated" && typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceTint !== 'undefined') ? MeoTheme.surfaceTint(control.elevation) : "transparent"
                visible: control.effectiveType === "elevated"
                Behavior on color { ColorAnimation { duration: control.motionFast } }

                layer.enabled: control.shape !== "round" && control.shape !== "square" && control.shape !== "rect"
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: shapeBg.width
                        height: shapeBg.height
                        MeoShape {
                            anchors.fill: parent
                            type: shapeBg.type
                            radius: shapeBg.radius
                        }
                    }
                }
            }

            MeoStateLayer {
                radius: shapeBg.radius
                shape: shapeBg.type
                pressed: control.pressed
                hovered: control.hovered
                focused: control.visualFocus
                color: control.textColor

                layer.enabled: control.shape !== "round" && control.shape !== "square" && control.shape !== "rect"
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: shapeBg.width
                        height: shapeBg.height
                        MeoShape {
                            anchors.fill: parent
                            type: shapeBg.type
                            radius: shapeBg.radius
                        }
                    }
                }
            }

            strokeColor: {
                if (control.effectiveType !== "outlined") return "transparent";
                if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
                if (control.activeFocus) return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4";
                return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E";
            }
            strokeWidth: (control.effectiveType === "outlined" && (control.activeFocus || control.selected || (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive))) ? ((typeof MeoTheme !== 'undefined' && typeof MeoTheme.strokeWidthMedium !== 'undefined') ? MeoTheme.strokeWidthMedium : 2) : (control.effectiveType === "outlined" ? ((typeof MeoTheme !== 'undefined' && typeof MeoTheme.strokeWidthThin !== 'undefined') ? MeoTheme.strokeWidthThin : 1) : 0)

            // Simplified Elevation Shadow
            layer.enabled: control.elevation > 0 || (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive && control.effectiveType === "filled" && isEmphasized)
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive && control.effectiveType === "filled" && isEmphasized) ? 0.4 : 0.2
                shadowVerticalOffset: (control.elevation > 0 ? control.elevation : (typeof MeoTheme !== 'undefined' && MeoTheme.isExpressive && control.effectiveType === "filled" && isEmphasized ? 2 : 0)) * MeoTheme.globalScale
                shadowColor: Qt.rgba(0,0,0,0.2)
            }

            Behavior on color { ColorAnimation { duration: control.motionFast; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
            Behavior on radius {
                NumberAnimation {
                    // Get into the new silhouette quickly, then decelerate
                    // into its final contour so the end never snaps.
                    duration: control.hovered || control.pressed ? MeoTheme.motionDurationShapeEnter : MeoTheme.motionDurationShapeSettle
                    easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
                }
            }
        }

        scale: control.pressed ? 0.985 : (control.hovered && control.effectiveType !== "text" ? 1.006 : 1.0)
        Behavior on scale { NumberAnimation { duration: control.motionFast; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1.0]) } }
    }
}
