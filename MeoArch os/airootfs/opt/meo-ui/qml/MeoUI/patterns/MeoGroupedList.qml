import QtQuick
import QtQuick.Controls
import MeoUI

Column {
    id: control

    property string title: ""
    property string subtitle: ""
    property var model: []
    property int selectedIndex: -1
    property bool showDividers: true
    property bool showChevron: true
    property real dividerInset: 72 * themeGlobalScale
    property real containerRadius: 24 * themeGlobalScale

    signal clicked(int index)

    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property color themeSurfaceContainerLowest: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLowest !== "undefined") ? MeoTheme.surfaceContainerLowest : "#FFFFFF"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.secondaryContainer !== "undefined") ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSecondaryContainer !== "undefined") ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outlineVariant !== "undefined") ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property var fontTitleMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.titleMedium !== "undefined") ? MeoTheme.titleMedium : { "size": 16, "weight": Font.Medium, "lineHeight": 24, "letterSpacing": 0.15 }
    readonly property var fontBodyLarge: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodyLarge !== "undefined") ? MeoTheme.bodyLarge : { "size": 16, "weight": Font.Normal, "lineHeight": 24, "letterSpacing": 0.5 }
    readonly property var fontBodyMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodyMedium !== "undefined") ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal, "lineHeight": 20, "letterSpacing": 0.25 }
    readonly property int animationDuration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationMedium2 !== "undefined") ? MeoTheme.motionDurationMedium2 : 300
    readonly property var emphasizedCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]

    width: parent ? parent.width : 680 * themeGlobalScale
    spacing: 12 * themeGlobalScale

    Column {
        width: parent.width
        spacing: 2 * control.themeGlobalScale
        visible: control.title !== "" || control.subtitle !== ""

        Text {
            width: parent.width
            text: control.title
            visible: text !== ""
            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
            font.pixelSize: control.fontTitleMedium.size * control.themeGlobalScale
            font.weight: control.fontTitleMedium.weight
            font.letterSpacing: (control.fontTitleMedium.letterSpacing || 0) * control.themeGlobalScale
            lineHeight: control.fontTitleMedium.lineHeight / control.fontTitleMedium.size
            color: control.themeOnSurface
            wrapMode: Text.WordWrap
        }

        Text {
            width: parent.width
            text: control.subtitle
            visible: text !== ""
            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
            font.pixelSize: control.fontBodyMedium.size * control.themeGlobalScale
            font.weight: control.fontBodyMedium.weight
            font.letterSpacing: (control.fontBodyMedium.letterSpacing || 0) * control.themeGlobalScale
            lineHeight: control.fontBodyMedium.lineHeight / control.fontBodyMedium.size
            color: control.themeOnSurfaceVariant
            wrapMode: Text.WordWrap
        }
    }

    Column {
        width: parent.width
        spacing: 0

        Repeater {
            model: control.model

            delegate: Item {
                id: rowItem

                readonly property bool isSelected: control.selectedIndex === index
                readonly property bool hasSupporting: (modelData.supportingText || modelData.subtitle || "") !== ""
                readonly property bool isFirst: index === 0
                readonly property bool isLast: index === control.model.length - 1
                readonly property string secondaryText: modelData.supportingText || modelData.subtitle || ""

                width: control.width
                height: (hasSupporting ? 72 : 56) * control.themeGlobalScale

                Rectangle {
                    id: groupSurface
                    anchors.fill: parent
                    color: control.themeSurfaceContainerLowest
                    radius: control.containerRadius

                    Rectangle { visible: !rowItem.isFirst; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: parent.radius; color: parent.color }
                    Rectangle { visible: !rowItem.isLast; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: parent.radius; color: parent.color }
                }

                Rectangle {
                    id: selectedLayer
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.leftMargin: 8 * control.themeGlobalScale
                    anchors.rightMargin: 8 * control.themeGlobalScale
                    height: 48 * control.themeGlobalScale
                    radius: height / 2
                    color: rowItem.isSelected ? control.themeSecondaryContainer : "transparent"
                    clip: true

                    MeoStateLayer {
                        radius: selectedLayer.radius
                        hovered: hitArea.containsMouse
                        pressed: hitArea.pressed
                        pressX: hitArea.mouseX - selectedLayer.x
                        pressY: hitArea.mouseY - selectedLayer.y
                        color: rowItem.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurface
                    }

                    Behavior on color { ColorAnimation { duration: control.animationDuration; easing.bezierCurve: control.emphasizedCurve } }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 24 * control.themeGlobalScale
                    anchors.rightMargin: 16 * control.themeGlobalScale
                    spacing: 24 * control.themeGlobalScale

                    MeoIcon {
                        icon: modelData.icon || ""
                        size: 24
                        color: rowItem.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                        anchors.verticalCenter: parent.verticalCenter
                        visible: icon !== ""
                    }

                    Column {
                        width: parent.width
                               - (modelData.icon ? 48 * control.themeGlobalScale : 0)
                               - (trailingRow.visible ? trailingRow.width + parent.spacing : 0)
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 0

                        Text {
                            width: parent.width
                            text: modelData.label || modelData.title || ""
                            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                            font.pixelSize: control.fontBodyLarge.size * control.themeGlobalScale
                            font.weight: control.fontBodyLarge.weight
                            font.letterSpacing: (control.fontBodyLarge.letterSpacing || 0) * control.themeGlobalScale
                            lineHeight: control.fontBodyLarge.lineHeight / control.fontBodyLarge.size
                            color: rowItem.isSelected ? control.themeOnSecondaryContainer : control.themeOnSurface
                            elide: Text.ElideRight
                        }

                        Text {
                            width: parent.width
                            text: rowItem.secondaryText
                            visible: text !== ""
                            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                            font.pixelSize: control.fontBodyMedium.size * control.themeGlobalScale
                            font.weight: control.fontBodyMedium.weight
                            font.letterSpacing: (control.fontBodyMedium.letterSpacing || 0) * control.themeGlobalScale
                            lineHeight: control.fontBodyMedium.lineHeight / control.fontBodyMedium.size
                            color: control.themeOnSurfaceVariant
                            elide: Text.ElideRight
                        }
                    }

                    Row {
                        id: trailingRow
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 8 * control.themeGlobalScale
                        visible: (modelData.badgeText || modelData.trailingText || "") !== "" || control.showChevron

                        MeoBadge {
                            text: modelData.badgeText || ""
                            visible: text !== ""
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.trailingText || ""
                            visible: text !== ""
                            font.pixelSize: control.fontBodyMedium.size * control.themeGlobalScale
                            font.weight: control.fontBodyMedium.weight
                            color: control.themeOnSurfaceVariant
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        MeoIcon {
                            icon: "chevron_right"
                            size: 24
                            color: control.themeOnSurfaceVariant
                            visible: control.showChevron
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                Rectangle {
                    visible: control.showDividers && !rowItem.isLast
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: control.dividerInset
                    height: Math.max(1, 1 * control.themeGlobalScale)
                    color: control.themeOutlineVariant
                }

                MouseArea {
                    id: hitArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        control.selectedIndex = index
                        control.clicked(index)
                    }
                }
            }
        }
    }
}
