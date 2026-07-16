import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property var model: ["option1", "option2", "option3"]
    property int currentIndex: 0
    property bool multiSelect: false
    property var selectedIndices: []
    property string size: "m" // xs | s | m | l | xl
    signal selected(int index, var data)

    readonly property real themeGlobalScale: MeoTheme.globalScale
    readonly property color themePrimary: MeoTheme.primary
    readonly property color themePrimaryContainer: MeoTheme.primaryContainer
    readonly property color themeOnPrimaryContainer: MeoTheme.contentOnPrimaryContainer
    readonly property color themeOnSurfaceVariant: MeoTheme.contentOnSurfaceVariant
    readonly property color themeSurface: MeoTheme.surface
    readonly property color themeOutline: MeoTheme.outline
    readonly property real groupRadius: height / 2
    readonly property real inset: 2 * themeGlobalScale
    readonly property bool hasAnyIcon: {
        for (let i = 0; i < model.length; ++i) {
            if (typeof model[i] === "object" && model[i].icon)
                return true
        }
        return false
    }
    readonly property var fontToken: size === "xs" ? MeoTheme.labelSmall
                                     : size === "s" ? MeoTheme.labelMedium
                                     : size === "l" ? MeoTheme.titleSmall
                                     : size === "xl" ? MeoTheme.titleMedium
                                     : MeoTheme.labelLarge

    implicitHeight: size === "xs" ? MeoTheme.buttonHeightXS
                  : size === "s" ? MeoTheme.buttonHeightS
                  : size === "l" ? MeoTheme.buttonHeightL
                  : size === "xl" ? MeoTheme.buttonHeightXL
                  : MeoTheme.buttonHeightM
    implicitWidth: {
        let total = 0
        for (let i = 0; i < model.length; ++i) {
            const item = model[i]
            const label = typeof item === "string" ? item : (item.label || "")
            total += Math.max(84 * themeGlobalScale,
                              label.length * control.fontToken.size * 0.72 * themeGlobalScale
                              + (hasAnyIcon ? 56 : 36) * themeGlobalScale)
        }
        return Math.max(1, total)
    }
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    function isIndexSelected(index) {
        return multiSelect ? selectedIndices.indexOf(index) !== -1 : currentIndex === index
    }

    function activateIndex(index, itemData) {
        if (multiSelect) {
            const next = selectedIndices.slice(0)
            const selectedAt = next.indexOf(index)
            if (selectedAt === -1)
                next.push(index)
            else
                next.splice(selectedAt, 1)
            selectedIndices = next
        } else {
            currentIndex = index
        }
        selected(index, itemData)
    }

    background: Rectangle {
        radius: control.groupRadius
        color: control.themeSurface
        border.color: control.themeOutline
        border.width: Math.max(1, control.themeGlobalScale)
    }

    contentItem: Row {
        id: segmentRow
        spacing: 0
        clip: true

        Repeater {
            model: control.model

            delegate: Button {
                id: segmentButton
                property var itemData: modelData
                readonly property string itemLabel: typeof itemData === "string" ? itemData : (itemData.label || "")
                readonly property string itemIcon: typeof itemData === "object" ? (itemData.icon || "") : ""
                readonly property bool selected: control.isIndexSelected(index)
                readonly property bool previousSelected: index > 0 && control.isIndexSelected(index - 1)
                readonly property bool isFirst: index === 0
                readonly property bool isLast: index === control.model.length - 1
                readonly property real segmentRadius: isFirst || isLast ? control.groupRadius - control.inset : 10 * control.themeGlobalScale
                readonly property color foreground: selected ? control.themeOnPrimaryContainer : control.themeOnSurfaceVariant

                width: Math.max(1, segmentRow.width / Math.max(1, control.model.length))
                height: control.height
                leftPadding: 0
                rightPadding: 0
                topPadding: 0
                bottomPadding: 0
                hoverEnabled: true

                background: Item {
                    clip: true

                    Rectangle {
                        id: selectedSurface
                        anchors.fill: parent
                        anchors.margins: control.inset
                        radius: segmentButton.segmentRadius
                        color: control.themePrimaryContainer
                        opacity: segmentButton.selected ? 1 : 0
                        transformOrigin: Item.Center
                        scale: segmentButton.pressed ? 0.96 : segmentButton.selected ? 1 : 0.92

                        Behavior on opacity {
                            NumberAnimation {
                                duration: segmentButton.selected ? MeoTheme.motionDurationSelection : MeoTheme.motionDurationState
                                easing.bezierCurve: segmentButton.selected ? MeoTheme.motionEasingEmphasizedDecelerate : MeoTheme.motionEasingEmphasizedAccelerate
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: segmentButton.pressed ? MeoTheme.motionDurationState : MeoTheme.motionDurationSelection
                                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                            }
                        }
                    }

                    MeoStateLayer {
                        anchors.fill: parent
                        radius: segmentButton.segmentRadius
                        pressed: segmentButton.pressed
                        hovered: segmentButton.hovered
                        pressX: segmentButton.pressX
                        pressY: segmentButton.pressY
                        color: segmentButton.foreground
                    }

                    Rectangle {
                        anchors.left: parent.left
                        anchors.verticalCenter: parent.verticalCenter
                        width: Math.max(1, control.themeGlobalScale)
                        height: parent.height - 12 * control.themeGlobalScale
                        color: control.themeOutline
                        opacity: index > 0 && !segmentButton.selected && !segmentButton.previousSelected ? 1 : 0
                        Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationState } }
                    }
                }

                contentItem: Item {
                    Row {
                        anchors.centerIn: parent
                        spacing: 6 * control.themeGlobalScale

                        Item {
                            width: control.hasAnyIcon || segmentButton.selected ? 18 * control.themeGlobalScale : 0
                            height: width
                            clip: true

                            MeoIcon {
                                anchors.centerIn: parent
                                icon: segmentButton.selected ? "check" : segmentButton.itemIcon
                                size: control.size === "xl" ? 24 * control.themeGlobalScale : 18 * control.themeGlobalScale
                                color: segmentButton.foreground
                                opacity: segmentButton.selected || segmentButton.itemIcon.length > 0 ? 1 : 0
                                scale: segmentButton.selected ? 1 : 0.82
                                Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationState } }
                                Behavior on scale {
                                    NumberAnimation {
                                        duration: MeoTheme.motionDurationSelection
                                        easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                                    }
                                }
                            }
                        }

                        Text {
                            text: segmentButton.itemLabel
                            font.family: MeoTheme.typefacePlain
                            font.pixelSize: control.fontToken.size * control.themeGlobalScale
                            font.weight: segmentButton.selected ? Font.Medium : control.fontToken.weight
                            color: segmentButton.foreground
                            lineHeightMode: Text.FixedHeight
                            lineHeight: (control.fontToken.lineHeight || 20) * control.themeGlobalScale
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            anchors.verticalCenter: parent.verticalCenter
                            Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationState } }
                        }
                    }
                }

                onClicked: control.activateIndex(index, segmentButton.itemData)
            }
        }
    }
}
