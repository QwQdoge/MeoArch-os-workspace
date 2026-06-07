import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    contentHeight: feedbackColumn.implicitHeight + 40
    clip: true
    Column {
        id: feedbackColumn
        padding: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale
        width: parent.width

        Text { text: "Feedback"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }

        MeoBanner {
            text: "This is a banner with important information."
            confirmText: "Action"
            cancelText: "Dismiss"
            width: 400 * MeoTheme.globalScale
        }
    }
}
