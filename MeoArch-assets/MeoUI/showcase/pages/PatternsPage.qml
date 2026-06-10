import QtQuick
import QtQuick.Controls
import MeoUI

ScrollView {
    anchors.fill: parent
    contentHeight: column.implicitHeight + 64 * MeoTheme.globalScale

    Column {
        id: column
        width: parent.width - 32 * MeoTheme.globalScale
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 32 * MeoTheme.globalScale
        topPadding: 32 * MeoTheme.globalScale

        MeoListHeader { text: "Search & Filter Pattern"; type: "emphasized" }

        MeoSearchFilterBar {
            width: parent.width
            filterModel: [
                { label: "All", icon: "select_all" },
                { label: "Unread", icon: "mark_as_unread" },
                { label: "Important", icon: "label_important" },
                { label: "Starred", icon: "star" },
                { label: "Recent", icon: "history" }
            ]
            selectedFilterIndices: [0]
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        MeoListHeader { text: "Empty State Pattern"; type: "emphasized" }

        MeoEmptyState {
            width: parent.width
            icon: "inbox"
            title: "No Data"
            description: "There is nothing to show here. Try searching for something else or check back later."
            actionText: "Refresh"
        }
    }
}
