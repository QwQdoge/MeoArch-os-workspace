import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Flickable {
    anchors.fill: parent
    contentHeight: column.implicitHeight + 64 * MeoTheme.globalScale
    clip: true

    Column {
        id: column
        width: parent.width - 48 * MeoTheme.globalScale
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 32 * MeoTheme.globalScale
        topPadding: 32 * MeoTheme.globalScale

        Text { text: "Navigation Drawer with Sections"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }

        MeoNavigationDrawer {
            width: parent.width
            height: 450 * MeoTheme.globalScale
            title: "Mail"
            model: [
                { label: "Inbox", icon: "inbox", badgeText: "24" },
                { label: "Outbox", icon: "send" },
                { label: "Labels", type: "header" },
                { label: "Favorites", icon: "favorite" },
                { label: "Trash", icon: "delete" }
            ]
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        Text { text: "Vertical Divider Example"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }

        Row {
            width: parent.width
            height: 100 * MeoTheme.globalScale
            spacing: 16 * MeoTheme.globalScale

            Rectangle { Layout.fillWidth: true; height: parent.height; color: MeoTheme.surfaceContainer; radius: 8 }
            MeoDivider { orientation: "vertical"; height: parent.height }
            Rectangle { Layout.fillWidth: true; height: parent.height; color: MeoTheme.surfaceContainer; radius: 8 }
        }
    }
}
