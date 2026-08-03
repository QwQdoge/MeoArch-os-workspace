import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Button {
    id: control

    // 🌟 核心属性
    property string size: "small" // "small" (56dp) | "medium" (80dp) | "large" (96dp)
    property bool collapsed: false
    property string colorStyle: "primary" // "primary" | "secondary" | "tertiary" | "surface"
    property string shape: "round" // "round" | "square" | "squircle" | "hexagon" | ...
    property bool isEmphasized: false // Bold typography option
    property bool vibrant: false // Vibrant background/outline option
    property bool bouncy: MeoTheme.isExpressive && MeoTheme.isBouncy

    icon.name: "add"

    // 🌟 尺寸与比例自适应
    readonly property real themeGlobalScale: MeoTheme.globalScale

    readonly property real baseHeight: size === "large" ? 96 * themeGlobalScale
                                     : size === "medium" ? 80 * themeGlobalScale
                                     : 56 * themeGlobalScale

    readonly property real restRadius: {
        if (shape === "square") return MeoTheme.shapeSquareRadius;
        return size === "large" ? MeoTheme.shapeExtraLarge
             : size === "medium" ? 22 * themeGlobalScale
             : MeoTheme.shapeLarge;
    }

    readonly property real interactiveRadius: pressed ? baseHeight / 2
                                             : hovered ? Math.min(baseHeight / 2, restRadius + 8 * themeGlobalScale)
                                                       : restRadius

    readonly property real iconSize: size === "large" ? 36 * themeGlobalScale
                                   : size === "medium" ? 28 * themeGlobalScale
                                   : 24 * themeGlobalScale

    // 🌟 间距与对齐
    readonly property real leadingSpace: size === "large" ? 30 * themeGlobalScale
                                       : size === "medium" ? 24 * themeGlobalScale
                                       : 16 * themeGlobalScale

    readonly property real trailingSpace: size === "large" ? 30 * themeGlobalScale
                                        : size === "medium" ? 24 * themeGlobalScale
                                        : 16 * themeGlobalScale

    readonly property real iconLabelGap: size === "large" ? 16 * themeGlobalScale
                                       : size === "medium" ? 12 * themeGlobalScale
                                       : 8 * themeGlobalScale

    // 🌟 字体排版
    readonly property var fontToken: {
        let token;
        if (size === "large") token = MeoTheme.headlineSmall;
        else if (size === "medium") token = MeoTheme.titleLarge;
        else token = MeoTheme.titleMedium;

        if (isEmphasized) {
            if (size === "large") return MeoTheme.headlineSmallEmphasized || token;
            if (size === "medium") return MeoTheme.titleLargeEmphasized || token;
            return MeoTheme.titleMediumEmphasized || token;
        }
        return token;
    }

    // 🌟 颜色语义映射
    readonly property color bgColor: {
        if (!enabled) {
            return MeoTheme.isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        }
        if (vibrant) {
            return MeoTheme.tertiaryContainer;
        }
        if (colorStyle === "secondary") return MeoTheme.secondaryContainer;
        if (colorStyle === "tertiary") return MeoTheme.tertiaryContainer;
        if (colorStyle === "surface") return MeoTheme.surfaceContainerHigh;
        return MeoTheme.primaryContainer;
    }

    readonly property color contentColor: {
        if (!enabled) {
            return MeoTheme.isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        }
        if (vibrant) {
            return MeoTheme.contentOnTertiaryContainer;
        }
        if (colorStyle === "secondary") return MeoTheme.contentOnSecondaryContainer;
        if (colorStyle === "tertiary") return MeoTheme.contentOnTertiaryContainer;
        if (colorStyle === "surface") return MeoTheme.primary;
        return MeoTheme.contentOnPrimaryContainer;
    }

    readonly property real elevationLevel: !enabled ? 0 : hovered ? 4 : 3

    implicitWidth: text.length > 0 && !collapsed
                   ? Math.max(baseHeight, fabContent.implicitWidth + leadingSpace + trailingSpace)
                   : baseHeight
    implicitHeight: baseHeight
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0
    hoverEnabled: true

    Behavior on implicitWidth {
        NumberAnimation {
            duration: MeoTheme.motionDurationSelection
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
    }

    background: MeoShape {
        id: fabBackground
        type: (control.shape === "round" || control.shape === "rect") ? "rect" : control.shape
        radius: control.interactiveRadius
        color: control.bgColor
        transformOrigin: Item.Center
        scale: control.pressed ? (control.bouncy ? 0.95 : 0.97) : control.hovered ? 1.025 : 1.0

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
            focused: control.visualFocus
            pressX: control.pressX
            pressY: control.pressY
            color: control.contentColor

            layer.enabled: control.shape !== "round" && control.shape !== "rect"
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: Item {
                    width: fabBackground.width
                    height: fabBackground.height
                    MeoShape {
                        anchors.fill: parent
                        type: fabBackground.type
                        radius: fabBackground.radius
                    }
                }
            }
        }

        Behavior on radius {
            NumberAnimation {
                duration: control.pressed || control.hovered
                          ? MeoTheme.motionDurationShapeEnter
                          : MeoTheme.motionDurationShapeSettle
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
        Behavior on scale {
            NumberAnimation {
                duration: MeoTheme.motionDurationState
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
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
            spacing: control.iconLabelGap * labelText.reveal

            MeoIcon {
                id: fabIcon
                icon: control.icon.name || control.icon.source.toString()
                size: control.iconSize
                color: control.contentColor
                anchors.verticalCenter: parent.verticalCenter
            }

            Text {
                id: labelText
                property real reveal: control.text.length > 0 && !control.collapsed ? 1 : 0
                width: implicitWidth * reveal
                height: implicitHeight
                clip: true
                visible: reveal > 0
                text: control.text
                font.family: MeoTheme.typefacePlain
                font.pixelSize: control.fontToken.size * control.themeGlobalScale
                font.weight: control.fontToken.weight
                color: control.contentColor
                lineHeightMode: Text.FixedHeight
                lineHeight: (control.fontToken.lineHeight || 20) * control.themeGlobalScale
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                opacity: reveal
                anchors.verticalCenter: parent.verticalCenter

                Behavior on reveal {
                    NumberAnimation {
                        duration: MeoTheme.motionDurationSelection
                        easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                    }
                }
            }
        }
    }
}
