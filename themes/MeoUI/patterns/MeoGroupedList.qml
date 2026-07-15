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
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outlineVariant !== "undefined") ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property color themeSurfaceContainerLowest: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surfaceContainerLowest !== "undefined") ? MeoTheme.surfaceContainerLowest : "#FFFFFF"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.secondaryContainer !== "undefined") ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSecondaryContainer !== "undefined") ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property var fontTitleMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.titleMedium !== "undefined") ? MeoTheme.titleMedium : { "size": 16, "weight": Font.Medium, "lineHeight": 24, "letterSpacing": 0.15 }
    readonly property var fontBodyMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodyMedium !== "undefined") ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal, "lineHeight": 20, "letterSpacing": 0.25 }
    readonly property int animationDuration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationMedium2 !== "undefined") ? MeoTheme.motionDurationMedium2 : 250
    readonly property var emphasizedCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasized !== "undefined") ? MeoTheme.motionEasingEmphasized : [0.2, 0.0, 0.0, 1.0]

    width: parent ? parent.width : 680 * themeGlobalScale
    spacing: 12 * themeGlobalScale

    Column {
        width: parent.width
        spacing: 2 * control.themeGlobalScale
        visible: control.title !== "" || control.subtitle !== ""

        MeoText {
            width: parent.width
            text: control.title
            typeRole: "title"
            typeSize: "small"
            emphasized: true
            visible: text !== ""
        }

        MeoText {
            width: parent.width
            text: control.subtitle
            typeRole: "body"
            typeSize: "medium"
            color: control.themeOnSurfaceVariant
            visible: text !== ""
        }
    }

    Column {
        width: parent.width
        spacing: 0

        Repeater {
            model: control.model

            delegate: MeoListItem {
                id: rowItem

                readonly property bool isFirst: index === 0
                readonly property bool isLast: index === control.model.length - 1

                width: control.width
                headline: modelData.label || modelData.title || ""
                supportingText: modelData.supportingText || modelData.subtitle || ""
                leadingIcon: modelData.icon || ""
                selected: control.selectedIndex === index
                isSegmented: true
                roundingStrategy: isFirst && isLast ? "all" : (isFirst ? "top" : (isLast ? "bottom" : "none"))

                // Use default background radius logic from MeoListItem which now supports roundingStrategy
                // But we want the GroupedList surface to be unified

                background: Item {
                    width: rowItem.width
                    height: rowItem.height

                    Rectangle {
                        id: groupSurface
                        anchors.fill: parent
                        color: control.themeSurfaceContainerLowest
                        radius: control.containerRadius

                        topLeftRadius: (rowItem.roundingStrategy === "all" || rowItem.roundingStrategy === "top") ? radius : 0
                        topRightRadius: (rowItem.roundingStrategy === "all" || rowItem.roundingStrategy === "top") ? radius : 0
                        bottomLeftRadius: (rowItem.roundingStrategy === "all" || rowItem.roundingStrategy === "bottom") ? radius : 0
                        bottomRightRadius: (rowItem.roundingStrategy === "all" || rowItem.roundingStrategy === "bottom") ? radius : 0
                    }

                    Rectangle {
                        id: selectedLayer
                        anchors.fill: parent
                        anchors.margins: 4 * control.themeGlobalScale
                        radius: groupSurface.radius - 4 * control.themeGlobalScale
                        color: rowItem.selected ? control.themeSecondaryContainer : "transparent"

                        topLeftRadius: (rowItem.roundingStrategy === "all" || rowItem.roundingStrategy === "top") ? radius : 0
                        topRightRadius: (rowItem.roundingStrategy === "all" || rowItem.roundingStrategy === "top") ? radius : 0
                        bottomLeftRadius: (rowItem.roundingStrategy === "all" || rowItem.roundingStrategy === "bottom") ? radius : 0
                        bottomRightRadius: (rowItem.roundingStrategy === "all" || rowItem.roundingStrategy === "bottom") ? radius : 0

                        MeoStateLayer {
                            anchors.fill: parent
                            radius: parent.radius
                            hovered: rowItem.hovered || false
                            pressed: rowItem.pressed || false
                            color: rowItem.selected ? control.themeOnSecondaryContainer : control.themeOnSurface
                        }

                        Behavior on color { ColorAnimation { duration: control.animationDuration; easing.bezierCurve: control.emphasizedCurve } }
                    }
                }

                trailingComponent: Component {
                    Row {
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
                            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                            font.pixelSize: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodyMedium !== "undefined" ? MeoTheme.bodyMedium.size : 14) * control.themeGlobalScale
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

                onClicked: {
                    control.selectedIndex = index
                    control.clicked(index)
                }

                // Divider implementation within delegate
                Rectangle {
                    visible: control.showDividers && !rowItem.isLast
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.leftMargin: control.dividerInset
                    height: Math.max(1, 1 * control.themeGlobalScale)
                    color: control.themeOutlineVariant
                }
            }
        }
    }

    Component {
        id: chevronComp
        MeoIcon {
            icon: "chevron_right"
            size: 24
            color: control.themeOnSurfaceVariant
        }
    }
}
