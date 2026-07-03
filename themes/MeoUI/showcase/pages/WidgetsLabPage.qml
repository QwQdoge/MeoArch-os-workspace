import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Flickable {
    id: page
    contentWidth: width
    contentHeight: column.implicitHeight + 48 * MeoTheme.globalScale
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}

    readonly property var navigationItems: [
        { "label": "Home", "icon": "home" },
        { "label": "Explore", "icon": "explore" },
        { "label": "Profile", "icon": "person" }
    ]

    ColumnLayout {
        id: column
        width: page.width - 48 * MeoTheme.globalScale
        x: 24 * MeoTheme.globalScale
        y: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale

        MeoText { text: "Widgets lab"; typeRole: "title"; typeSize: "big"; emphasized: true; color: MeoTheme.contentOnSurface }
        MeoText { Layout.fillWidth: true; text: "Large, composed controls with real interaction and representative data."; typeRole: "body"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }

        SectionTitle { text: "Identity & search" }
        MeoAccountHeader { Layout.fillWidth: true; name: "Meo User"; email: "hello@meoarch.dev" }
        MeoText { text: "Search bar"; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant }
        MeoSearchBar { Layout.preferredWidth: Math.min(560 * MeoTheme.globalScale, parent.width); placeholder: "Search components" }
        MeoText { text: "Docked search bar"; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant }
        MeoDockedSearchBar { Layout.fillWidth: true; placeholder: "Docked search" }
        MeoSearchSuggestions {
            Layout.fillWidth: true
            highlightText: "meo"
            model: [
                { "label": "MeoTheme tokens", "icon": "palette" },
                { "label": "MeoButton usage", "icon": "smart_button" },
                { "label": "Material expressive", "icon": "auto_awesome" }
            ]
        }

        SectionTitle { text: "Adaptive navigation" }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 360 * MeoTheme.globalScale
            spacing: 16 * MeoTheme.globalScale

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: MeoTheme.shapeLarge
                color: MeoTheme.surfaceContainerLow
                Column {
                    anchors.fill: parent
                    anchors.margins: 16 * MeoTheme.globalScale
                    spacing: 12 * MeoTheme.globalScale
                    MeoText { text: "Mobile preview"; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant }
                    Rectangle {
                        width: parent.width
                        height: parent.height - 32 * MeoTheme.globalScale
                        radius: MeoTheme.shapeLarge
                        color: MeoTheme.surface
                        clip: true
                        MeoText { anchors.centerIn: parent; text: "Bottom navigation"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                        MeoNavigationBar { anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom; model: page.navigationItems; currentIndex: 0 }
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: MeoTheme.shapeLarge
                color: MeoTheme.surfaceContainerLow
                Row {
                    anchors.fill: parent
                    anchors.margins: 16 * MeoTheme.globalScale
                    spacing: 16 * MeoTheme.globalScale
                    MeoNavigationRail { width: 96 * MeoTheme.globalScale; height: parent.height; model: page.navigationItems; currentIndex: 1 }
                    Rectangle {
                        width: parent.width - 112 * MeoTheme.globalScale
                        height: parent.height
                        radius: MeoTheme.shapeLarge
                        color: MeoTheme.surface
                        Column {
                            anchors.centerIn: parent
                            spacing: 12 * MeoTheme.globalScale
                            MeoText { anchors.horizontalCenter: parent.horizontalCenter; text: "Desktop preview"; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant }
                            MeoButton { anchors.horizontalCenter: parent.horizontalCenter; text: "Open drawer"; onClicked: modalDrawer.open() }
                        }
                    }
                }
            }
        }

        SectionTitle { text: "Pickers" }
        Flow {
            Layout.fillWidth: true
            spacing: 16 * MeoTheme.globalScale
            MeoDatePicker { width: 340 * MeoTheme.globalScale }
            MeoTimePicker { width: 340 * MeoTheme.globalScale }
            MeoDateRangePicker { width: 420 * MeoTheme.globalScale }
        }

        SectionTitle { text: "Media & app bars" }
        MeoMediaController { Layout.fillWidth: true; title: "Soul Curve"; artist: "MeoUI Sessions"; isPlaying: true }
        MeoBottomAppBar {
            Layout.fillWidth: true
            navigationIcons: ["menu", "search", "favorite"]
            fab: Component { MeoFAB { icon.name: "add" } }
        }

        SectionTitle { text: "Sheets" }
        Flow {
            Layout.fillWidth: true
            spacing: 8 * MeoTheme.globalScale
            MeoButton { text: "Modal bottom sheet"; onClicked: bottomSheet.open() }
            MeoButton { text: "Modal side sheet"; type: "outlined"; onClicked: sideSheet.open() }
        }
        Rectangle {
            id: standardSheetHost
            Layout.fillWidth: true
            implicitHeight: 260 * MeoTheme.globalScale
            radius: MeoTheme.shapeLarge
            color: MeoTheme.surfaceContainer
            clip: true
            MeoText { anchors.centerIn: parent; text: "Standard bottom sheet host"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
            MeoStandardBottomSheet {
                id: standardSheet
                anchors.fill: parent
                isOpen: false
                peekHeight: 72 * MeoTheme.globalScale
                expandedHeight: 210 * MeoTheme.globalScale
                content: Component {
                    Column {
                        padding: 20 * MeoTheme.globalScale
                        spacing: 12 * MeoTheme.globalScale
                        MeoText { text: "Standard bottom sheet"; typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
                        MeoButton { text: standardSheet.isOpen ? "Collapse" : "Expand"; onClicked: standardSheet.isOpen = !standardSheet.isOpen }
                    }
                }
            }
        }
    }

    MeoNavigationDrawerModal { id: modalDrawer; model: page.navigationItems; currentIndex: 0; header: Component { MeoAccountHeader { name: "Meo User"; email: "hello@meoarch.dev" } } }
    MeoBottomSheet {
        id: bottomSheet
        content: Component {
            Column {
                padding: 24 * MeoTheme.globalScale
                spacing: 12 * MeoTheme.globalScale
                MeoText { text: "Modal bottom sheet"; typeRole: "title"; typeSize: "medium"; color: MeoTheme.contentOnSurface }
                MeoText { text: "Use it for a focused, temporary task."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
            }
        }
    }
    MeoSideSheetModal {
        id: sideSheet
        title: "Details"
        content: Component {
            Column {
                padding: 24 * MeoTheme.globalScale
                spacing: 12 * MeoTheme.globalScale
                MeoText { text: "Modal side sheet content"; typeRole: "body"; typeSize: "big"; color: MeoTheme.contentOnSurface }
                MeoSwitch { label: "Enable option"; checked: true }
            }
        }
    }

    component SectionTitle: MeoText {
        Layout.fillWidth: true
        typeRole: "title"
        typeSize: "medium"
        emphasized: true
        color: MeoTheme.primary
    }
}
