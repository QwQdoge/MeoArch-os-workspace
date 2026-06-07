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

        Text { text: "Icon Buttons"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Row {
            spacing: 12 * MeoTheme.globalScale
            MeoIconButton { icon.name: "settings"; type: "standard" }
            MeoIconButton { icon.name: "favorite"; type: "filled" }
            MeoIconButton { icon.name: "share"; type: "tonal" }
            MeoIconButton { icon.name: "search"; type: "outlined" }
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
