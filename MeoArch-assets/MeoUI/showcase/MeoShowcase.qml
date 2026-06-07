import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Layouts 1.15
import MeoUI 1.0

ApplicationWindow {
    id: window
    width: 1024
    height: 768
    visible: true
    title: "MeoUI MD3 Expressive Showcase"
    color: MeoTheme.background

    property int currentCategoryIndex: 0

    readonly property var categories: [
        { label: "Buttons", icon: "smart_button" },
        { label: "Inputs", icon: "edit" },
        { label: "Navigation", icon: "explore" },
        { label: "Selection", icon: "check_box" },
        { label: "Display", icon: "layers" },
        { label: "Feedback", icon: "info" },
        { label: "Patterns", icon: "grid_view" },
        { label: "Data Table", icon: "table_chart" }
    ]

    MeoDialog {
        id: mainDialog
        title: "Standard Dialog"
        message: "This is a Material Design 3 standard dialog demonstration."
        confirmText: "Accept"
        cancelText: "Decline"
    }

    MeoSnackbar {
        id: snackbar
        message: "Message sent successfully."
        actionText: "Undo"
    }

    RowLayout {
        anchors.fill: parent
        spacing: 0

        MeoNavigationRail {
            id: navRail
            model: window.categories
            currentIndex: window.currentCategoryIndex
            onClicked: (index) => {
                window.currentCategoryIndex = index
            }
        }

        MeoDivider {
            Layout.fillHeight: true
            width: 1
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 0

            MeoTopAppBar {
                Layout.fillWidth: true
                title: window.categories[window.currentCategoryIndex].label
                type: "small"
            }

            StackLayout {
                id: stackLayout
                currentIndex: window.currentCategoryIndex
                Layout.fillWidth: true
                Layout.fillHeight: true


                // Buttons Page
                Flickable {
                    contentHeight: buttonColumn.implicitHeight + 40
                    clip: true
                    Column {
                        id: buttonColumn
                        padding: 24 * MeoTheme.globalScale
                        spacing: 24 * MeoTheme.globalScale
                        width: parent.width

                        Text { text: "Common Buttons"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 12 * MeoTheme.globalScale
                            MeoButton { text: "Filled"; type: "filled" }
                            MeoButton { text: "Tonal"; type: "tonal" }
                            MeoButton { text: "Outlined"; type: "outlined" }
                            MeoButton { text: "Elevated"; type: "elevated" }
                            MeoButton { text: "Text"; type: "text" }
                        }

                        Text { text: "FABs"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 16 * MeoTheme.globalScale
                            MeoFAB { icon.name: "add"; type: "small" }
                            MeoFAB { icon.name: "add"; type: "regular" }
                            MeoFAB { icon.name: "add"; type: "large" }
                            MeoFAB { icon.name: "add"; text: "Create New"; type: "extended" }
                        }

                        Text { text: "Icon Buttons"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 12 * MeoTheme.globalScale
                            MeoIconButton { icon.name: "settings"; type: "standard" }
                            MeoIconButton { icon.name: "favorite"; type: "filled"; selected: true }
                            MeoIconButton { icon.name: "share"; type: "tonal" }
                            MeoIconButton { icon.name: "search"; type: "outlined" }
                        }

                        Text { text: "Segmented Buttons"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        MeoSegmentedButtons {
                            model: ["Day", "Week", "Month", "Year"]
                        }
                    }
                }

                // Inputs Page
                Flickable {
                    contentHeight: inputColumn.implicitHeight + 40
                    clip: true
                    Column {
                        id: inputColumn
                        padding: 24 * MeoTheme.globalScale
                        spacing: 24 * MeoTheme.globalScale
                        width: parent.width

                        Text { text: "Search Bars (Expressive Expanding)"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 12 * MeoTheme.globalScale
                            MeoButton {
                                text: "Open Expanding Search"
                                onClicked: searchView.open()
                            }
                            MeoSearchView {
                                id: searchView
                                width: parent.width
                                height: parent.height
                            }
                            MeoSearchBar { placeholder: "Static Search"; leadingIcon: "search"; trailingIcon: "mic"; width: 300 * MeoTheme.globalScale }
                        }

                        Text { text: "Text Fields"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        MeoTextField { label: "Filled Label"; placeholder: "Type something..."; type: "filled" }
                        MeoTextField { label: "Outlined Label"; placeholder: "Type something..."; type: "outlined"; leadingIcon: "person" }
                        MeoTextField { label: "With Counter"; maxLength: 20; showCounter: true; type: "outlined" }

                        Text { text: "Sliders"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Column {
                            spacing: 12 * MeoTheme.globalScale
                            Text { text: "Continuous Slider"; font.pixelSize: 12 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
                            MeoSlider { value: 50; width: 300 * MeoTheme.globalScale }
                            Text { text: "Discrete Slider (Steps of 10)"; font.pixelSize: 12 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
                            MeoSlider { from: 0; to: 100; value: 30; discrete: true; stepSize: 10; width: 300 * MeoTheme.globalScale }
                        }
                        MeoRangeSlider { from: 0; to: 100; firstValue: 20; secondValue: 80; width: 300 * MeoTheme.globalScale }

                        Text { text: "Filter Group"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        MeoFilterGroup {
                            width: parent.width
                            multiSelect: true
                            model: [
                                { label: "Travel", icon: "flight" },
                                { label: "Food", icon: "restaurant" },
                                { label: "Music", icon: "music_note" },
                                { label: "Health", icon: "medical_services" }
                            ]
                        }

                        Text { text: "Individual Chips"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Flow {
                            width: parent.width
                            spacing: 8 * MeoTheme.globalScale
                            MeoAssistChip { label: "Assist"; icon: "event" }
                            MeoAssistChip { label: "Avatar Assist"; avatarSource: "https://api.dicebear.com/7.x/avataaars/svg?seed=Felix" }
                            MeoFilterChip { label: "Filter"; selected: true }
                            MeoFilterChip { label: "Avatar Filter"; avatarSource: "https://api.dicebear.com/7.x/avataaars/svg?seed=Aria" }
                            MeoInputChip { label: "Input"; onDeleted: {} }
                            MeoSuggestionChip { label: "Suggestion" }
                        }
                    }
                }

                // Navigation Page
                Flickable {
                    contentHeight: navColumn.implicitHeight + 40
                    clip: true
                    Column {
                        id: navColumn
                        padding: 24 * MeoTheme.globalScale
                        spacing: 24 * MeoTheme.globalScale
                        width: parent.width

                        Text { text: "Breadcrumbs"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        MeoBreadcrumbs {
                            model: [
                                { label: "Home", icon: "home" },
                                { label: "Library" },
                                { label: "Components" }
                            ]
                        }

                        Text { text: "Tabs"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        MeoTabs {
                            model: ["Video", "Audio", "Photos"]
                        }

                        Text { text: "Navigation Bar Variants"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 24 * MeoTheme.globalScale
                            Column {
                                spacing: 8 * MeoTheme.globalScale
                                Text { text: "Label: Always + Badges"; font.pixelSize: 12 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
                                MeoNavigationBar {
                                    width: 320 * MeoTheme.globalScale
                                    labelType: "always"
                                    model: [
                                        { label: "Mail", icon: "mail", badgeCount: 3 },
                                        { label: "Chat", icon: "chat", badgeDot: true },
                                        { label: "Meet", icon: "videocam" }
                                    ]
                                }
                            }
                            Column {
                                spacing: 8 * MeoTheme.globalScale
                                Text { text: "Label: Selected"; font.pixelSize: 12 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
                                MeoNavigationBar {
                                    width: 320 * MeoTheme.globalScale
                                    labelType: "selected"
                                    model: [
                                        { label: "Mail", icon: "mail" },
                                        { label: "Chat", icon: "chat" },
                                        { label: "Meet", icon: "videocam" }
                                    ]
                                }
                            }
                        }

                        Text { text: "Navigation Rail Variants"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 40 * MeoTheme.globalScale
                            Column {
                                spacing: 8 * MeoTheme.globalScale
                                Text { text: "With Header & Selected Labels"; font.pixelSize: 12 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
                                MeoNavigationRail {
                                    height: 300 * MeoTheme.globalScale
                                    labelType: "selected"
                                    header: MeoFAB { type: "small"; icon.name: "edit" }
                                    model: [
                                        { label: "Inbox", icon: "inbox" },
                                        { label: "Outbox", icon: "send" },
                                        { label: "Drafts", icon: "drafts" }
                                    ]
                                }
                            }
                        }

                        Text { text: "Menus"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        MeoButton {
                            id: menuBtn
                            text: "Show MD3 Menu"
                            onClicked: md3Menu.open()
                            MeoMenu {
                                id: md3Menu
                                y: menuBtn.height
                                model: [
                                    { label: "Refresh", icon: "refresh" },
                                    { label: "Settings", icon: "settings" },
                                    { label: "Help", icon: "help" }
                                ]
                            }
                        }
                    }
                }

                // Selection Page
                Flickable {
                    contentHeight: selectionColumn.implicitHeight + 40
                    clip: true
                    Column {
                        id: selectionColumn
                        padding: 24 * MeoTheme.globalScale
                        spacing: 24 * MeoTheme.globalScale
                        width: parent.width

                        Text { text: "Pickers"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 16 * MeoTheme.globalScale
                            MeoDatePicker {}
                            MeoDateRangePicker {}
                        }

                        Text { text: "Controls"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 24 * MeoTheme.globalScale
                            Column {
                                spacing: 8 * MeoTheme.globalScale
                                MeoCheckbox { label: "Checked"; checked: true }
                                MeoCheckbox { label: "Indeterminate"; indeterminate: true }
                                MeoCheckbox { label: "Unchecked"; checked: false }
                            }
                            MeoSwitch { label: "Switch"; checked: true }
                            MeoRadioButton { label: "Radio Button"; checked: true }
                        }
                    }
                }

                // Display Page
                Flickable {
                    contentHeight: displayColumn.implicitHeight + 40
                    clip: true
                    Column {
                        id: displayColumn
                        padding: 24 * MeoTheme.globalScale
                        spacing: 24 * MeoTheme.globalScale
                        width: parent.width

                        Text { text: "Cards & Items"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Flow {
                            width: parent.width
                            spacing: 24 * MeoTheme.globalScale
                            MeoCard {
                                width: 320 * MeoTheme.globalScale
                                Column {
                                    anchors.fill: parent
                                    spacing: 8 * MeoTheme.globalScale
                                    Text { text: "Expressive List Items"; font.weight: Font.Bold; color: MeoTheme.onSurface }
                                    MeoListItem { headline: "With Badge"; badgeText: "New"; width: parent.width - 32 }
                                    MeoListItem {
                                        headline: "With Large Image"
                                        supportingText: "MD3 Expressive layout"
                                        leadingImage: "https://api.dicebear.com/7.x/shapes/svg?seed=Felix"
                                        leadingImageSize: 56
                                        width: parent.width - 32
                                    }
                                    MeoListItem { overline: "OVERLINE"; headline: "3-Line Item"; supportingText: "Supporting text that spans multiple lines to demonstrate the new MD3 layout capabilities."; supportingTextLines: 2; width: parent.width - 32 }
                                    MeoListItem { headline: "Segmented Item"; supportingText: "New MD3 Expressive style"; isSegmented: true; selected: true; width: parent.width - 32 }
                                }
                            }
                        }

                        Text { text: "Progress & Indicators"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 24 * MeoTheme.globalScale
                            MeoProgressBar { type: "circular"; indeterminate: true }
                            MeoProgressBar { type: "linear"; value: 0.7 }
                            MeoPageIndicator { count: 5; currentIndex: 2 }
                        }

                        Text { text: "Pull to Refresh"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 24 * MeoTheme.globalScale
                            MeoPullToRefresh { refreshing: false; pullDistance: 0.7 }
                            MeoPullToRefresh { refreshing: true }
                        }

                        Text { text: "Carousel Variants"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Column {
                            spacing: 24 * MeoTheme.globalScale
                            Text { text: "Hero Mode"; font.pixelSize: 14 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
                            MeoCarousel {
                                type: "hero"
                                width: 500 * MeoTheme.globalScale
                                itemHeight: 200 * MeoTheme.globalScale
                                model: ["#FFB3B3", "#B3FFB3", "#B3B3FF", "#FFFFB3", "#FFB3FF"]
                                delegate: Rectangle {
                                    color: modelData
                                    radius: 28 * MeoTheme.globalScale
                                    Text { anchors.centerIn: parent; text: "Hero Item"; color: "white"; font.bold: true }
                                }
                            }
                            Text { text: "Uncontained (Peeking) Mode"; font.pixelSize: 14 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
                            MeoCarousel {
                                type: "uncontained"
                                width: 500 * MeoTheme.globalScale
                                itemHeight: 150 * MeoTheme.globalScale
                                model: ["#FFD8E4", "#EADDFF", "#E8DEF8", "#D0BCFF", "#B3261E"]
                                delegate: Rectangle {
                                    color: modelData
                                    radius: 16 * MeoTheme.globalScale
                                    Text { anchors.centerIn: parent; text: "Peek Item"; color: "white" }
                                }
                            }
                        }
                    }
                }

                // Feedback Page
                Flickable {
                    contentHeight: feedbackColumn.implicitHeight + 40
                    clip: true
                    Column {
                        id: feedbackColumn
                        padding: 24 * MeoTheme.globalScale
                        spacing: 24 * MeoTheme.globalScale
                        width: parent.width

                        Text { text: "Dialogs"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 12 * MeoTheme.globalScale
                            MeoButton {
                                text: "Show Dialog"
                                onClicked: mainDialog.open()
                            }
                        }

                        Text { text: "Snackbars & Banners"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 12 * MeoTheme.globalScale
                            MeoButton {
                                text: "Show Snackbar"
                                onClicked: snackbar.open()
                            }
                        }
                        MeoBanner {
                            text: "This is a banner with important information."
                            confirmText: "Action"
                            cancelText: "Dismiss"
                            width: 400 * MeoTheme.globalScale
                        }

                        Text { text: "Tooltips"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 40 * MeoTheme.globalScale
                            MeoButton {
                                id: tooltipBtn
                                text: "Hover for Tooltip"
                                MeoTooltip {
                                    text: "This is a simple tooltip"
                                    visible: tooltipBtn.hovered
                                }
                            }
                            MeoButton {
                                id: richTooltipBtn
                                text: "Click for Rich Tooltip"
                                onClicked: richTooltip.open()
                                MeoRichTooltip {
                                    id: richTooltip
                                    title: "Rich Tooltip"
                                    text: "This tooltip contains more content and actions."
                                    actions: [{ text: "Learn More" }]
                                }
                            }
                        }
                    }
                }

                // Patterns Page
                Item {
                    id: patternsPage
                    MeoScaffold {
                        anchors.fill: parent
                        topBar: MeoTopAppBar { title: "Scaffold Title"; type: "small" }
                        navigationRail: MeoNavigationRail {
                            model: [
                                { label: "Home", icon: "home" },
                                { label: "Search", icon: "search", badgeDot: true },
                                { label: "Settings", icon: "settings" }
                            ]
                            footer: MeoIconButton { icon.name: "logout"; type: "standard" }
                        }
                        content: Item {
                            anchors.fill: parent

                            Rectangle {
                                color: MeoTheme.surfaceContainer
                                radius: 16 * MeoTheme.globalScale
                                anchors.fill: parent
                                anchors.margins: 16 * MeoTheme.globalScale

                                Column {
                                    anchors.centerIn: parent
                                    spacing: 24 * MeoTheme.globalScale
                                    Text { text: "Main Content in Scaffold"; color: MeoTheme.onSurfaceVariant; anchors.horizontalCenter: parent.horizontalCenter }
                                    MeoButton {
                                        text: "Toggle Standard Bottom Sheet"
                                        onClicked: persistentSheet.isOpen = !persistentSheet.isOpen
                                    }
                                }
                            }

                            MeoStandardBottomSheet {
                                id: persistentSheet
                                width: parent.width
                                expandedHeight: 300 * MeoTheme.globalScale
                                content: Column {
                                    padding: 24 * MeoTheme.globalScale
                                    spacing: 16 * MeoTheme.globalScale
                                    Text { text: "Standard Bottom Sheet"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                                    Text { text: "This is a non-modal bottom sheet that co-exists with the main content."; color: MeoTheme.onSurfaceVariant; width: parent.width - 48 }
                                }
                            }
                        }
                        fab: MeoFAB { icon.name: "add" }
                    }
                }

                // Data Table Page
                Flickable {
                    contentHeight: tableColumn.implicitHeight + 40
                    clip: true
                    Column {
                        id: tableColumn
                        padding: 24 * MeoTheme.globalScale
                        spacing: 24 * MeoTheme.globalScale
                        width: parent.width

                        Text { text: "MD3 Data Table"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        MeoDataTable {
                            width: parent.width - 48
                            selectable: true
                            columns: [
                                { label: "Dessert (100g serving)", property: "name", width: 250, sortable: true },
                                { label: "Calories", property: "calories", width: 100, sortable: true },
                                { label: "Fat (g)", property: "fat", width: 100, sortable: true },
                                { label: "Carbs (g)", property: "carbs", width: 100, sortable: true }
                            ]
                            model: [
                                { name: "Frozen yogurt", calories: 159, fat: 6.0, carbs: 24, selected: false },
                                { name: "Ice cream sandwich", calories: 237, fat: 9.0, carbs: 37, selected: false },
                                { name: "Eclair", calories: 262, fat: 16.0, carbs: 24, selected: false },
                                { name: "Cupcake", calories: 305, fat: 3.7, carbs: 67, selected: false },
                                { name: "Gingerbread", calories: 356, fat: 16.0, carbs: 49, selected: false }
                            ]
                        }
                    }
                }
            }
        }
    }
}

