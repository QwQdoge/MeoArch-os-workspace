import QtQuick
import QtQuick.Controls
import MeoUI

ScrollView {
    id: root
    anchors.fill: parent
    contentHeight: column.implicitHeight + 64 * MeoTheme.globalScale

    property bool isSideSheetOpen: false

    Column {
        id: column
        width: parent.width - 32 * MeoTheme.globalScale
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 32 * MeoTheme.globalScale
        topPadding: 32 * MeoTheme.globalScale

        // Expressive Search Pattern
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            MeoListHeader { text: "Expressive Search View"; type: "emphasized" }

            MeoButton {
                text: "Open Search View"
                onClicked: searchView.open()
            }

            MeoSearchView {
                id: searchView
                placeholder: "Search anything..."
                suggestions: [
                    { label: "Material Design 3", isHistory: true },
                    { label: "QML Animation", isHistory: true },
                    { label: "MD3 Icons", isHistory: false },
                    { label: "Expressive Layouts", isHistory: false }
                ]
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

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

        MeoListHeader { text: "Scaffold with Side Sheet"; type: "emphasized" }

        Rectangle {
            width: parent.width
            height: 400 * MeoTheme.globalScale
            color: MeoTheme.surfaceContainerLow
            border.color: MeoTheme.outlineVariant
            radius: 12 * MeoTheme.globalScale
            clip: true

            MeoScaffold {
                anchors.fill: parent
                sideSheetOpen: root.isSideSheetOpen

                topBar: MeoTopAppBar {
                    title: "Side Sheet Demo"
                    navigationIcon: MeoIconButton { icon.name: "menu"; type: "standard" }
                    actions: [
                        Component {
                            MeoSwitch {
                                label: "Side Sheet"
                                checked: root.isSideSheetOpen
                                onToggled: (isChecked) => root.isSideSheetOpen = isChecked
                            }
                        }
                    ]
                }

                content: Item {
                    anchors.fill: parent
                    Text {
                        anchors.centerIn: parent
                        text: "Main Content Area"
                        color: MeoTheme.onSurfaceVariant
                    }
                }

                sideSheet: MeoSideSheet {
                    title: "Details"
                    isOpen: root.isSideSheetOpen
                    content: Column {
                        padding: 16 * MeoTheme.globalScale
                        spacing: 12 * MeoTheme.globalScale
                        Text { text: "Metadata"; font: MeoTheme.titleSmall; color: MeoTheme.onSurface }
                        Text { text: "File: report.pdf\nSize: 2.4 MB\nModified: Jan 12"; color: MeoTheme.onSurfaceVariant }
                    }
                }
            }
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
