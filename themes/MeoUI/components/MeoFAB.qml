import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Button {
    id: control

    // type: "small" | "regular" | "large" | "extended"
    property string type: "regular"
    property bool collapsed: false
    readonly property string effectiveType: type === "standard" ? "regular" : type
    icon.name: "add"

    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property var fontLabelLarge: MeoTheme.labelLarge
    readonly property bool showsLabel: effectiveType === "extended" && text.length > 0
    readonly property real baseSize: effectiveType === "small" ? 40 * themeGlobalScale
                                      : effectiveType === "large" ? 96 * themeGlobalScale
                                      : 56 * themeGlobalScale
    readonly property real restRadius: effectiveType === "small" ? 12 * themeGlobalScale
                                      : effectiveType === "large" ? 28 * themeGlobalScale
                                      : 16 * themeGlobalScale
    readonly property real interactiveRadius: pressed ? baseSize / 2
                                             : hovered ? Math.min(baseSize / 2, restRadius + 8 * themeGlobalScale)
                                                       : restRadius
    readonly property real elevationLevel: !enabled ? 0 : hovered ? 4 : 3

    implicitWidth: showsLabel && !collapsed
                   ? Math.max(112 * themeGlobalScale, fabContent.implicitWidth + 32 * themeGlobalScale)
                   : baseSize
    implicitHeight: baseSize
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

    background: Rectangle {
        id: fabBackground
        radius: control.interactiveRadius
        color: control.themePrimaryContainer
        transformOrigin: Item.Center
        scale: control.pressed ? 0.96 : control.hovered ? 1.025 : 1.0

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
            pressed: control.pressed
            hovered: control.hovered
            pressX: control.pressX
            pressY: control.pressY
            color: control.themeOnPrimaryContainer
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
            spacing: 8 * control.themeGlobalScale * labelText.reveal

            MeoIcon {
                id: fabIcon
                icon: control.icon.name || control.icon.source.toString()
                size: control.effectiveType === "large" ? 36 * control.themeGlobalScale : 24 * control.themeGlobalScale
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
                font.family: MeoTheme.typefacePlain
                font.pixelSize: control.fontLabelLarge.size * control.themeGlobalScale
                font.weight: control.fontLabelLarge.weight
                color: control.themeOnPrimaryContainer
                lineHeightMode: Text.FixedHeight
                lineHeight: (control.fontLabelLarge.lineHeight || 20) * control.themeGlobalScale
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
