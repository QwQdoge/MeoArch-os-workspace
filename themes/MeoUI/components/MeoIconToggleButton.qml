import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Button {
    id: control

    // 🌟 核心对外属性
    property string type: "standard" // "standard" | "filled" | "tonal" | "outlined"
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    property string shape: "circle" // "circle" | "square" | "squircle" | "hexagon" | ...
    property string checkedIcon: "" // Icon to show when checked
    property string selectedIcon: checkedIcon // Alias for checkedIcon
    property string badgeText: ""
    property bool badgeDot: false

    checkable: true // By default, it's a toggle button

    readonly property string effectiveType: type === "filledTonal" ? "tonal" : type

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property int iconSize: {
        if (size === "xs" || size === "s") return 18;
        if (size === "xl") return 40;
        return 24; // m, l
    }

    implicitWidth: {
        if (size === "xs") return 28 * themeGlobalScale;
        if (size === "s") return 32 * themeGlobalScale;
        if (size === "l") return 48 * themeGlobalScale;
        if (size === "xl") return 56 * themeGlobalScale;
        return 40 * themeGlobalScale; // m
    }
    implicitHeight: implicitWidth

    padding: 0

    background: Item {

        readonly property real baseRadius: {
            if (control.pressed)
                return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeMedium !== 'undefined') ? MeoTheme.shapeMedium : 12 * control.themeGlobalScale;
            if (control.hovered && shape === "square")
                return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeLargeIncreased !== 'undefined') ? MeoTheme.shapeLargeIncreased : 20 * control.themeGlobalScale;
            if (shape === "square") {
                if (size === "xs" || size === "s") return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeMedium !== 'undefined') ? MeoTheme.shapeMedium : 12 * MeoTheme.globalScale;
                return (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeLarge !== 'undefined') ? MeoTheme.shapeLarge : 16 * MeoTheme.globalScale;
            }
            return height / 2;
        }

        MeoShape {
            id: shapeBg
            anchors.fill: parent
            type: (control.shape === "circle" || control.shape === "square") ? "rect" : control.shape
            radius: parent.baseRadius
            color: {
                if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
                if (control.checked) {
                    if (type === "standard") return "transparent";
                    if (type === "outlined") return control.themeSecondaryContainer;
                    if (type === "filled") return control.themePrimary;
                    return control.themeSecondaryContainer; // tonal
                }
                // Unchecked states
                if (control.effectiveType === "filled" || control.effectiveType === "tonal") return control.themeSecondaryContainer;
                return "transparent";
            }

            strokeColor: {
                if (control.effectiveType !== "outlined" || control.checked) return "transparent";
                if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
                return control.themeOutline;
            }
            strokeWidth: (control.effectiveType === "outlined" && !control.checked) ? 1 * themeGlobalScale : 0

            Behavior on radius {
                NumberAnimation {
                    duration: control.hovered || control.pressed ? MeoTheme.motionDurationShapeEnter : MeoTheme.motionDurationShapeSettle
                    easing.bezierCurve: (typeof MeoTheme !== "undefined" ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1])
                }
            }

            MeoStateLayer {
                radius: shapeBg.radius
                shape: shapeBg.type
                pressed: control.pressed
                hovered: control.hovered
                focused: control.visualFocus
                color: {
                    if (control.checked) {
                        if (control.effectiveType === "filled") return control.themeOnPrimary;
                        return control.themeOnSecondaryContainer;
                    }
                    if (control.effectiveType === "filled") return control.themePrimary;
                    return control.themeOnSurface;
                }

                layer.enabled: control.shape !== "circle" && control.shape !== "square" && control.shape !== "rect"
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
        }

        scale: control.pressed ? 0.96 : (control.hovered ? 1.035 : 1.0)
        Behavior on scale {
            NumberAnimation {
                duration: control.pressed ? MeoTheme.motionDurationFast : MeoTheme.motionDurationShapeEnter
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
    }

    contentItem: Item {
        scale: control.pressed ? 0.94 : (control.hovered ? 1.02 : 1)
        Behavior on scale { NumberAnimation { duration: (typeof MeoTheme !== "undefined" ? MeoTheme.motionDurationFast : 120); easing.bezierCurve: (typeof MeoTheme !== "undefined" ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]) } }
        MeoIcon {
            anchors.centerIn: parent
            icon: control.checked ? (control.checkedIcon || control.icon.name || control.icon.source.toString()) : (control.icon.name || control.icon.source.toString())
            fill: control.checked
            size: control.iconSize
            color: {
                if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
                if (control.checked) {
                    if (control.effectiveType === "filled") return control.themeOnPrimary;
                    return control.themePrimary;
                }
                // Unchecked states
                if (control.effectiveType === "filled") return control.themePrimary;
                return control.themeOnSurfaceVariant;
            }
            Behavior on color { ColorAnimation { duration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationFast !== "undefined") ? MeoTheme.motionDurationFast : 150 } }
        }

        MeoBadge {
            text: control.badgeText
            isDot: control.badgeDot
            visible: text !== "" || isDot
            anchors.horizontalCenter: parent.right
            anchors.verticalCenter: parent.top
            anchors.horizontalCenterOffset: -4 * control.themeGlobalScale
            anchors.verticalCenterOffset: 4 * control.themeGlobalScale
        }
    }
}
