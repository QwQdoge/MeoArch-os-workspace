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

        Text { text: "Widgets lab"; color: MeoTheme.onSurface; font.pixelSize: MeoTheme.headlineLargeEmphasized.size * MeoTheme.globalScale; font.weight: Font.Bold }
        Text { Layout.fillWidth: true; text: "Large, composed controls with real interaction and representative data."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 16 * MeoTheme.globalScale; wrapMode: Text.WordWrap }

        SectionTitle { text: "Identity & search" }
        MeoAccountHeader { Layout.fillWidth: true; name: "Meo User"; email: "hello@meoarch.dev" }
        MeoSearchBar { Layout.fillWidth: true; placeholder: "Search components" }
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
        MeoNavigationBar { Layout.fillWidth: true; model: page.navigationItems; currentIndex: 0 }
        RowLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 320 * MeoTheme.globalScale
            spacing: 16 * MeoTheme.globalScale
            MeoNavigationRail { Layout.preferredWidth: 96 * MeoTheme.globalScale; Layout.fillHeight: true; model: page.navigationItems; currentIndex: 1 }
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: MeoTheme.shapeLarge
                color: MeoTheme.surfaceContainerLow
                Column {
                    anchors.centerIn: parent
                    spacing: 12 * MeoTheme.globalScale
                    Text { anchors.horizontalCenter: parent.horizontalCenter; text: "Modal navigation drawer"; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    MeoButton { anchors.horizontalCenter: parent.horizontalCenter; text: "Open drawer"; onClicked: modalDrawer.open() }
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
            Text { anchors.centerIn: parent; text: "Standard bottom sheet host"; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
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
                        Text { text: "Standard bottom sheet"; color: MeoTheme.onSurface; font.pixelSize: 20 * MeoTheme.globalScale; font.weight: Font.DemiBold }
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
                Text { text: "Modal bottom sheet"; color: MeoTheme.onSurface; font.pixelSize: 22 * MeoTheme.globalScale }
                Text { text: "Use it for a focused, temporary task."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
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
                Text { text: "Modal side sheet content"; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                MeoSwitch { label: "Enable option"; checked: true }
            }
        }
    }

    component SectionTitle: Text {
        Layout.fillWidth: true
        color: MeoTheme.primary
        font.pixelSize: 20 * MeoTheme.globalScale
        font.weight: Font.DemiBold
    }
}
