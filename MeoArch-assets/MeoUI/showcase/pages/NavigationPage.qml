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

        // Navigation Drawer
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Navigation Drawer (Scrollable + Footer)"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }

            MeoNavigationDrawer {
                width: parent.width
                height: 400 * MeoTheme.globalScale
                title: "Mail"
                model: [
                    { label: "Inbox", icon: "inbox", badgeText: "24" },
                    { label: "Outbox", icon: "send" },
                    { label: "Labels", type: "header" },
                    { label: "Favorites", icon: "favorite" },
                    { label: "Trash", icon: "delete" },
                    { label: "Archive", icon: "archive" },
                    { label: "Spam", icon: "report" }
                ]
                footer: Column {
                    width: parent.width
                    MeoNavigationDrawerItem {
                        width: parent.width - 24 * MeoTheme.globalScale
                        anchors.horizontalCenter: parent.horizontalCenter
                        label: "Settings"
                        icon: "settings"
                    }
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // Top App Bar Variants
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Top App Bar Modes"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }

            MeoTopAppBar {
                width: parent.width
                title: "Small App Bar"
                type: "small"
                navigationIcon: MeoIconButton { icon.name: "menu"; type: "standard" }
                actions: [
                    Component { MeoIconButton { icon.name: "search"; type: "standard" } },
                    Component { MeoIconButton { icon.name: "more_vert"; type: "standard" } }
                ]
            }

            MeoTopAppBar {
                width: parent.width
                title: "Selected"
                isContextual: true
                selectionCount: 3
                actions: [
                    Component { MeoIconButton { icon.name: "delete"; type: "standard" } },
                    Component { MeoIconButton { icon.name: "share"; type: "standard" } }
                ]
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        Text { text: "Layout Components"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }

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
