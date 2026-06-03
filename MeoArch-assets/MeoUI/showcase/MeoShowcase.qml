import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

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
        { label: "Patterns", icon: "grid_view" }
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

    Row {
        anchors.fill: parent

        MeoNavigationRail {
            id: navRail
            model: window.categories
            currentIndex: window.currentCategoryIndex
            onClicked: (index) => {
                window.currentCategoryIndex = index
            }
        }

        MeoDivider {
            width: 1
            height: parent.height
        }

        Column {
            width: parent.width - navRail.width
            height: parent.height

            MeoTopAppBar {
                title: window.categories[window.currentCategoryIndex].label
                type: "small"
            }

            StackLayout {
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
                            MeoFAB { icon: "add"; type: "small" }
                            MeoFAB { icon: "add"; type: "regular" }
                            MeoFAB { icon: "add"; type: "large" }
                            MeoFAB { icon: "add"; text: "Create New"; type: "extended" }
                        }

                        Text { text: "Icon Buttons"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 12 * MeoTheme.globalScale
                            MeoIconButton { icon: "settings"; type: "standard" }
                            MeoIconButton { icon: "favorite"; type: "filled"; selected: true }
                            MeoIconButton { icon: "share"; type: "tonal" }
                            MeoIconButton { icon: "search"; type: "outlined" }
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

                        Text { text: "Search Bars"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        Row {
                            spacing: 12 * MeoTheme.globalScale
                            MeoSearchBar { placeholder: "Search mail"; leadingIcon: "menu"; trailingIcon: "account_circle"; width: 300 * MeoTheme.globalScale }
                            MeoSearchBar { placeholder: "Search maps"; leadingIcon: "search"; trailingIcon: "mic"; width: 300 * MeoTheme.globalScale }
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
                            MeoFilterChip { label: "Filter"; selected: true }
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
                                Text { text: "Label: Always"; font.pixelSize: 12 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
                                MeoNavigationBar {
                                    width: 320 * MeoTheme.globalScale
                                    labelType: "always"
                                    model: [
                                        { label: "Mail", icon: "mail" },
                                        { label: "Chat", icon: "chat" },
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
                                    header: MeoFAB { type: "small"; icon: "edit" }
                                    model: [
                                        { label: "Inbox", icon: "inbox" },
                                        { label: "Outbox", icon: "send" },
                                        { label: "Drafts", icon: "drafts" }
                                    ]
                                }
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
                            MeoCheckbox { label: "Checkbox"; checked: true }
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
                        MeoCard {
                            width: 320 * MeoTheme.globalScale
                            Column {
                                anchors.fill: parent
                                spacing: 8 * MeoTheme.globalScale
                                Text { text: "Expressive List Item"; font.weight: Font.Bold; color: MeoTheme.onSurface }
                                MeoListItem { overline: "OVERLINE"; headline: "3-Line Item"; supportingText: "Supporting text that spans multiple lines to demonstrate the new MD3 layout capabilities."; supportingTextLines: 2; width: parent.width - 32 }
                                MeoListItem { headline: "Segmented Item"; supportingText: "New MD3 Expressive style"; isSegmented: true; selected: true; width: parent.width - 32 }
                                MeoListItem { headline: "Standard Item"; supportingText: "Classic MD3 style"; width: parent.width - 32 }
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

                        Text { text: "Carousel"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
                        MeoCarousel {
                            width: 500 * MeoTheme.globalScale
                            itemWidth: 150 * MeoTheme.globalScale
                            itemHeight: 200 * MeoTheme.globalScale
                            model: ["#FFB3B3", "#B3FFB3", "#B3B3FF", "#FFFFB3", "#FFB3FF"]
                            delegate: Rectangle {
                                color: modelData
                                radius: 12 * MeoTheme.globalScale
                                Text { anchors.centerIn: parent; text: "Item"; color: "white" }
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
                                { label: "Search", icon: "search" },
                                { label: "Settings", icon: "settings" }
                            ]
                            footer: MeoIconButton { icon: "logout"; type: "standard" }
                        }
                        content: Rectangle {
                            color: MeoTheme.surfaceContainer
                            radius: 16 * MeoTheme.globalScale
                            anchors.fill: parent
                            anchors.margins: 16 * MeoTheme.globalScale
                            Text { anchors.centerIn: parent; text: "Main Content in Scaffold"; color: MeoTheme.onSurfaceVariant }
                        }
                        fab: MeoFAB { icon: "add" }
                    }
                }
            }
        }
    }
}
