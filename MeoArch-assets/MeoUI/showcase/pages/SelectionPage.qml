import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    contentHeight: selectionColumn.implicitHeight + 40
    clip: true
    Column {
        id: selectionColumn
        padding: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale
        width: parent.width

        Text { text: "Checkboxes"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Row {
            spacing: 12 * MeoTheme.globalScale
            MeoCheckbox { checked: true; text: "Checked" }
            MeoCheckbox { checked: false; text: "Unchecked" }
        }

        Text { text: "Switches"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Row {
            spacing: 12 * MeoTheme.globalScale
            MeoSwitch { checked: true }
            MeoSwitch { checked: false }
        }

        Text { text: "Radio Buttons"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Row {
            spacing: 12 * MeoTheme.globalScale
            MeoRadioButton { checked: true; text: "Option A" }
            MeoRadioButton { checked: false; text: "Option B" }
        }

        Text { text: "Sliders"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Column {
            spacing: 12 * MeoTheme.globalScale
            MeoSlider { width: 300 * MeoTheme.globalScale; value: 0.5 }
            MeoRangeSlider { width: 300 * MeoTheme.globalScale; first.value: 0.2; second.value: 0.8 }
        }
    }
}
