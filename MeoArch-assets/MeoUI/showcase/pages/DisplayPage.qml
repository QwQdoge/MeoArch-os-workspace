import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    contentHeight: displayColumn.implicitHeight + 40
    clip: true
    Column {
        id: displayColumn
        padding: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale
        width: parent.width

        Text { text: "Cards"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        Row {
            spacing: 24 * MeoTheme.globalScale
            MeoCard { type: "elevated"; width: 200 * MeoTheme.globalScale; height: 150 * MeoTheme.globalScale }
            MeoCard { type: "filled"; width: 200 * MeoTheme.globalScale; height: 150 * MeoTheme.globalScale }
            MeoCard { type: "outlined"; width: 200 * MeoTheme.globalScale; height: 150 * MeoTheme.globalScale }
        }
    }
}
