import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    property string text: ""
    property string icon: ""
    property string type: "tonal" // filled | tonal | outlined | elevated | text
    property bool isEmphasized: false
    property var menuModel: []
    property string size: "m"
    signal clicked()
    signal menuOpened()

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeForeground: !enabled ? MeoTheme.contentOnSurfaceVariant
                                       : type === "filled" ? themeOnPrimary
                                       : type === "tonal" ? themeOnPrimaryContainer
                                       : themePrimary
    readonly property color themeBackground: {
        if (!enabled) return MeoTheme.isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
        if (type === "filled") return themePrimary
        if (type === "tonal") return themePrimaryContainer
        if (type === "elevated") return themeSurfaceContainerLow
        return "transparent"
    }
    readonly property var fontToken: size === "xs" ? MeoTheme.labelSmall
                                     : size === "s" ? MeoTheme.labelMedium
                                     : size === "l" ? MeoTheme.titleSmall
                                     : size === "xl" ? MeoTheme.titleMedium
                                     : MeoTheme.labelLarge
    readonly property real groupRadius: height / 2
    readonly property bool outlined: type === "outlined"

    implicitHeight: size === "xs" ? MeoTheme.buttonHeightXS
                  : size === "s" ? MeoTheme.buttonHeightS
                  : size === "l" ? MeoTheme.buttonHeightL
                  : size === "xl" ? MeoTheme.buttonHeightXL
                  : MeoTheme.buttonHeightM
    implicitWidth: primaryAction.implicitWidth + menuAction.implicitWidth
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    background: Rectangle {
        radius: control.groupRadius
        color: control.themeBackground
        border.width: control.outlined ? Math.max(1, control.themeGlobalScale) : 0
        border.color: control.themeOutline

        layer.enabled: control.type === "elevated" && control.enabled
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.16
            shadowVerticalOffset: control.themeGlobalScale
            shadowOpacity: 0.16
            shadowColor: Qt.rgba(0, 0, 0, 0.22)
        }

        Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationState } }
    }

    contentItem: Row {
        id: splitRow
        spacing: 0
        clip: true

        Button {
            id: primaryAction
            implicitWidth: primaryContent.implicitWidth + (control.size === "xs" ? 20 : 28) * control.themeGlobalScale
            implicitHeight: control.implicitHeight
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            hoverEnabled: true

            background: Item {
                clip: true
                MeoStateLayer {
                    anchors.fill: parent
                    radius: control.groupRadius
                    pressed: primaryAction.pressed
                    hovered: primaryAction.hovered
                    pressX: primaryAction.pressX
                    pressY: primaryAction.pressY
                    color: control.themeForeground
                }
            }

            contentItem: Item {
                Row {
                    id: primaryContent
                    anchors.centerIn: parent
                    spacing: (control.size === "xs" ? 4 : 8) * control.themeGlobalScale

                    MeoIcon {
                        icon: control.icon
                        visible: icon.length > 0
                        size: control.size === "xs" ? 16 * control.themeGlobalScale
                              : control.size === "xl" ? 24 * control.themeGlobalScale
                              : 18 * control.themeGlobalScale
                        color: control.themeForeground
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    Text {
                        text: control.text
                        font.family: MeoTheme.typefacePlain
                        font.pixelSize: control.fontToken.size * control.themeGlobalScale
                        font.weight: control.isEmphasized ? Font.Bold : control.fontToken.weight
                        color: control.themeForeground
                        lineHeightMode: Text.FixedHeight
                        lineHeight: (control.fontToken.lineHeight || 20) * control.themeGlobalScale
                        verticalAlignment: Text.AlignVCenter
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }

            onClicked: control.clicked()
        }

        Rectangle {
            width: Math.max(1, control.themeGlobalScale)
            height: parent.height - 14 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            color: control.outlined ? control.themeOutline : Qt.rgba(control.themeForeground.r, control.themeForeground.g, control.themeForeground.b, 0.28)
        }

        Button {
            id: menuAction
            implicitWidth: (control.size === "xs" ? 36 : control.size === "xl" ? 52 : 44) * control.themeGlobalScale
            implicitHeight: control.implicitHeight
            leftPadding: 0
            rightPadding: 0
            topPadding: 0
            bottomPadding: 0
            hoverEnabled: true

            background: Item {
                clip: true
                MeoStateLayer {
                    anchors.fill: parent
                    radius: control.groupRadius
                    pressed: menuAction.pressed
                    hovered: menuAction.hovered
                    pressX: menuAction.pressX
                    pressY: menuAction.pressY
                    color: control.themeForeground
                }
            }

            contentItem: Item {
                MeoIcon {
                    anchors.centerIn: parent
                    icon: "arrow_drop_down"
                    size: control.size === "xs" ? 18 * control.themeGlobalScale
                          : control.size === "xl" ? 28 * control.themeGlobalScale
                          : 24 * control.themeGlobalScale
                    color: control.themeForeground
                    rotation: menuPopup.opened ? 180 : 0
                    Behavior on rotation {
                        NumberAnimation {
                            duration: MeoTheme.motionDurationSelection
                            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                        }
                    }
                }
            }

            onClicked: {
                menuPopup.open()
                control.menuOpened()
            }

            MeoMenu {
                id: menuPopup
                y: menuAction.height + 4 * control.themeGlobalScale
                x: menuAction.width - width
                model: control.menuModel
            }
        }
    }
}
