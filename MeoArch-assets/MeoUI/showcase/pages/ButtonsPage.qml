import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    contentHeight: buttonColumn.implicitHeight + 40
    clip: true
    Column {
        id: buttonColumn
        padding: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale
        width: parent.width

        Text { text: "Common Buttons"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Row {
            spacing: 12 * MeoTheme.globalScale
            MeoButton { text: "Filled"; type: "filled" }
            MeoButton { text: "Tonal"; type: "tonal" }
            MeoButton { text: "Outlined"; type: "outlined" }
            MeoButton { text: "Text"; type: "text" }
            MeoButton { text: "Elevated"; type: "elevated" }
        }

        Text { text: "Icon Buttons & States"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Row {
            spacing: 12 * MeoTheme.globalScale
            MeoIconButton { icon.name: "settings"; type: "standard" }
            MeoIconButton { icon.name: "favorite"; type: "filled" }
            MeoIconButton { icon.name: "share"; type: "tonal" }
            MeoIconButton { icon.name: "search"; type: "outlined" }

            // Dragged State Example
            Item {
                width: 40 * MeoTheme.globalScale; height: 40 * MeoTheme.globalScale
                Rectangle {
                    anchors.fill: parent
                    radius: 20 * MeoTheme.globalScale
                    color: "transparent"
                    MeoIcon {
                        anchors.centerIn: parent
                        icon: "drag_handle"
                        size: 24
                        color: MeoTheme.primary
                    }
                    MeoStateLayer {
                        radius: parent.radius
                        dragged: true
                        color: MeoTheme.primary
                    }
                }
            }
        }

        Text { text: "Fixed Color Roles"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Row {
            spacing: 16 * MeoTheme.globalScale
            Rectangle {
                width: 100 * MeoTheme.globalScale; height: 50 * MeoTheme.globalScale
                color: MeoTheme.primaryFixed
                radius: 8 * MeoTheme.globalScale
                Text { text: "Primary Fixed"; anchors.centerIn: parent; color: MeoTheme.onPrimaryFixed; font.pixelSize: 12 * MeoTheme.globalScale }
            }
            Rectangle {
                width: 100 * MeoTheme.globalScale; height: 50 * MeoTheme.globalScale
                color: MeoTheme.secondaryFixed
                radius: 8 * MeoTheme.globalScale
                Text { text: "Secondary Fixed"; anchors.centerIn: parent; color: MeoTheme.onSecondaryFixed; font.pixelSize: 12 * MeoTheme.globalScale }
            }
            Rectangle {
                width: 100 * MeoTheme.globalScale; height: 50 * MeoTheme.globalScale
                color: MeoTheme.tertiaryFixed
                radius: 8 * MeoTheme.globalScale
                Text { text: "Tertiary Fixed"; anchors.centerIn: parent; color: MeoTheme.onTertiaryFixed; font.pixelSize: 12 * MeoTheme.globalScale }
            }
        }

        Text { text: "Floating Action Buttons (FAB)"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Row {
            spacing: 24 * MeoTheme.globalScale
            MeoFAB { icon.name: "add"; size: "small" }
            MeoFAB { icon.name: "edit"; size: "standard" }
            MeoFAB { icon.name: "navigate_next"; size: "large" }
            MeoFAB { icon.name: "add"; text: "Create"; extended: true }
        }

        Text { text: "Segmented Buttons"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        MeoSegmentedButtons {
            model: ["Day", "Week", "Month"]
        }
    }
}
