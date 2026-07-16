import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control

    // Connected single-selection action group.
    property var model: []
    property string type: "tonal" // filled | tonal | outlined | elevated
    property string size: "m" // xs | s | m | l | xl
    property int currentIndex: 0
    signal selected(int index, var data)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property color themePrimary: MeoTheme.primary
    readonly property color themeOnPrimary: MeoTheme.contentOnPrimary
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property color themeSecondaryContainer: MeoTheme.secondaryContainer
    readonly property color themeOnSecondaryContainer: MeoTheme.contentOnSecondaryContainer
    readonly property color themeSurfaceContainer: MeoTheme.surfaceContainer
    readonly property color themeSurfaceContainerLow: MeoTheme.surfaceContainerLow
    readonly property color themeOutline: MeoTheme.outline
    readonly property color themeOutlineVariant: MeoTheme.outlineVariant
    readonly property real groupRadius: height / 2
    readonly property real inset: 2 * themeGlobalScale
    readonly property bool outlined: type === "outlined"

    readonly property var fontToken: size === "xs" ? MeoTheme.labelSmall
                                     : size === "s" ? MeoTheme.labelMedium
                                     : size === "l" ? MeoTheme.titleSmall
                                     : size === "xl" ? MeoTheme.titleMedium
                                     : MeoTheme.labelLarge
    readonly property color idleBackground: {
        if (!enabled) return MeoTheme.isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12)
        if (type === "filled") return themePrimaryContainer
        if (type === "tonal") return themeSecondaryContainer
        if (type === "elevated") return themeSurfaceContainerLow
        return themeSurfaceContainer
    }
    readonly property color idleForeground: type === "tonal" ? themeOnSecondaryContainer
                                        : type === "filled" ? themeOnPrimaryContainer
                                        : themePrimary

    implicitHeight: size === "xs" ? MeoTheme.buttonHeightXS
                  : size === "s" ? MeoTheme.buttonHeightS
                  : size === "l" ? MeoTheme.buttonHeightL
                  : size === "xl" ? MeoTheme.buttonHeightXL
                  : MeoTheme.buttonHeightM
    implicitWidth: groupRow.implicitWidth
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    contentItem: Item {
        implicitWidth: groupRow.implicitWidth
        implicitHeight: control.implicitHeight
        clip: true

        Rectangle {
            id: groupSurface
            anchors.fill: parent
            radius: control.groupRadius
            color: control.idleBackground
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

        Row {
            id: groupRow
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: control.model

                delegate: Button {
                    id: groupButton
                    property var itemData: modelData
                    readonly property string itemLabel: typeof itemData === "string" ? itemData : (itemData.label || "")
                    readonly property string itemIcon: typeof itemData === "object" ? (itemData.icon || "") : ""
                    readonly property bool selected: index === control.currentIndex
                    readonly property bool isFirst: index === 0
                    readonly property bool isLast: index === control.model.length - 1
                    readonly property real segmentRadius: isFirst || isLast ? control.groupRadius - control.inset : 10 * control.themeGlobalScale
                    readonly property color foreground: selected ? control.themeOnPrimary : control.idleForeground

                    implicitWidth: Math.max((control.size === "xs" ? 56 : 72) * control.themeGlobalScale,
                                            groupButtonContent.implicitWidth + (control.size === "xs" ? 20 : 28) * control.themeGlobalScale)
                    implicitHeight: control.implicitHeight
                    leftPadding: 0
                    rightPadding: 0
                    topPadding: 0
                    bottomPadding: 0
                    hoverEnabled: true

                    background: Item {
                        clip: true

                        Rectangle {
                            id: selectionSurface
                            anchors.fill: parent
                            anchors.margins: control.inset
                            radius: groupButton.segmentRadius
                            color: control.themePrimary
                            opacity: groupButton.selected ? 1 : 0
                            transformOrigin: Item.Center
                            scale: groupButton.pressed ? 0.96 : groupButton.selected ? 1 : 0.92

                            Behavior on opacity {
                                NumberAnimation {
                                    duration: groupButton.selected ? MeoTheme.motionDurationSelection : MeoTheme.motionDurationState
                                    easing.bezierCurve: groupButton.selected ? MeoTheme.motionEasingEmphasizedDecelerate : MeoTheme.motionEasingEmphasizedAccelerate
                                }
                            }
                            Behavior on scale {
                                NumberAnimation {
                                    duration: groupButton.pressed ? MeoTheme.motionDurationState : MeoTheme.motionDurationSelection
                                    easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                                }
                            }
                        }

                        MeoStateLayer {
                            anchors.fill: parent
                            radius: groupButton.segmentRadius
                            pressed: groupButton.pressed
                            hovered: groupButton.hovered
                            pressX: groupButton.pressX
                            pressY: groupButton.pressY
                            color: groupButton.foreground
                        }

                        Rectangle {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            width: Math.max(1, control.themeGlobalScale)
                            height: parent.height - 16 * control.themeGlobalScale
                            color: control.outlined ? control.themeOutline : control.themeOutlineVariant
                            opacity: index > 0 && !groupButton.selected ? 0.78 : 0
                            Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationState } }
                        }
                    }

                    contentItem: Item {
                        Row {
                            id: groupButtonContent
                            anchors.centerIn: parent
                            spacing: (control.size === "xs" ? 4 : 8) * control.themeGlobalScale

                            MeoIcon {
                                icon: groupButton.itemIcon
                                visible: icon.length > 0
                                size: control.size === "xs" ? 16 * control.themeGlobalScale
                                      : control.size === "xl" ? 24 * control.themeGlobalScale
                                      : 18 * control.themeGlobalScale
                                color: groupButton.foreground
                                anchors.verticalCenter: parent.verticalCenter
                            }

                            Text {
                                text: groupButton.itemLabel
                                visible: text.length > 0
                                font.family: MeoTheme.typefacePlain
                                font.pixelSize: control.fontToken.size * control.themeGlobalScale
                                font.weight: groupButton.selected ? Font.Bold : control.fontToken.weight
                                color: groupButton.foreground
                                lineHeightMode: Text.FixedHeight
                                lineHeight: (control.fontToken.lineHeight || 20) * control.themeGlobalScale
                                verticalAlignment: Text.AlignVCenter
                                anchors.verticalCenter: parent.verticalCenter
                                Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationState } }
                            }
                        }
                    }

                    onClicked: {
                        control.currentIndex = index
                        if (typeof groupButton.itemData === "object" && groupButton.itemData.action)
                            groupButton.itemData.action()
                        control.selected(index, groupButton.itemData)
                    }
                }
            }
        }
    }
}
