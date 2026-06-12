import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Flickable {
    id: scrollArea
    anchors.fill: parent
    contentHeight: column.implicitHeight + 64 * MeoTheme.globalScale
    clip: true

    Column {
        id: column
        width: parent.width - 48 * MeoTheme.globalScale
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 32 * MeoTheme.globalScale
        topPadding: 32 * MeoTheme.globalScale

        // Standard Buttons
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Common Buttons (Standard & Emphasized)"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
            Flow {
                width: parent.width
                spacing: 12 * MeoTheme.globalScale
                MeoButton { text: "Filled"; type: "filled" }
                MeoButton { text: "Tonal"; type: "tonal" }
                MeoButton { text: "Outlined"; type: "outlined" }
                MeoButton { text: "Elevated"; type: "elevated" }
                MeoButton { text: "Text"; type: "text" }
            }
            Flow {
                width: parent.width
                spacing: 12 * MeoTheme.globalScale
                MeoButton { text: "Filled Emphasized"; type: "filled"; isEmphasized: true }
                MeoButton { text: "Tonal Emphasized"; type: "tonal"; isEmphasized: true }
                MeoButton { text: "Outlined Emphasized"; type: "outlined"; isEmphasized: true }
            }
        }

        // Segmented Buttons (Enhanced)
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Segmented Buttons (Icons + Text)"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }

            MeoSegmentedButtons {
                width: 400 * MeoTheme.globalScale
                model: [
                    { label: "Day", icon: "wb_sunny" },
                    { label: "Night", icon: "dark_mode" }
                ]
            }

            MeoSegmentedButtons {
                width: parent.width
                multiSelect: true
                model: [
                    { label: "Bold", icon: "format_bold" },
                    { label: "Italic", icon: "format_italic" },
                    { label: "Underline", icon: "format_underlined" }
                ]
                selectedIndices: [0]
            }
        }

        // Floating Action Buttons
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Floating Action Buttons (Scroll to Collapse)"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
            Row {
                spacing: 16 * MeoTheme.globalScale
                MeoFAB { type: "small"; icon.name: "edit" }
                MeoFAB { type: "regular"; icon.name: "add" }
                MeoFAB { type: "large"; icon.name: "palette" }
                MeoFAB {
                    id: fabExtended
                    type: "extended"
                    icon.name: "mail"
                    text: "Compose"
                    collapsed: scrollArea.contentY > 100
                }
                MeoButton {
                    text: fabExtended.collapsed ? "Expand FAB" : "Collapse FAB"
                    onClicked: fabExtended.collapsed = !fabExtended.collapsed
                }
            }
        }

        // Icon Buttons
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Icon Buttons"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
            Row {
                spacing: 16 * MeoTheme.globalScale
                MeoIconButton { type: "standard"; icon.name: "settings" }
                MeoIconButton { type: "filled"; icon.name: "favorite"; selected: true }
                MeoIconButton { type: "tonal"; icon.name: "bookmark" }
                MeoIconButton { type: "outlined"; icon.name: "share" }
            }
        }
    }
}
