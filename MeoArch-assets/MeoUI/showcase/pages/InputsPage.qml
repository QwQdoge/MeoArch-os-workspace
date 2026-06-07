import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    contentHeight: inputColumn.implicitHeight + 40
    clip: true
    Column {
        id: inputColumn
        padding: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale
        width: parent.width

        Text { text: "Text Fields"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Row {
            spacing: 24 * MeoTheme.globalScale
            MeoTextField { placeholderText: "Filled text field"; type: "filled" }
            MeoTextField { placeholderText: "Outlined text field"; type: "outlined" }
        }

        Text { text: "Text Area"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        MeoTextArea {
            width: 400 * MeoTheme.globalScale
            height: 120 * MeoTheme.globalScale
            placeholderText: "Enter multiline text..."
            type: "outlined"
        }
    }
}
