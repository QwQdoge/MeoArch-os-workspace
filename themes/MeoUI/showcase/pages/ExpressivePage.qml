import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

ScrollView {
    id: root
    contentWidth: availableWidth

    component ExpressiveHighlightCard: Rectangle {
        id: card

        property string title: ""
        property string body: ""
        property bool large: false
        default property alias previewContent: previewHost.data

        Layout.fillWidth: true
        Layout.preferredHeight: large ? 344 * MeoTheme.globalScale : 268 * MeoTheme.globalScale
        radius: 28 * MeoTheme.globalScale
        color: MeoTheme.surfaceContainerHigh
        clip: true

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: large ? 210 * MeoTheme.globalScale : 150 * MeoTheme.globalScale
                color: MeoTheme.primaryContainer
                radius: card.radius

                Item {
                    id: previewHost
                    anchors.fill: parent
                    anchors.margins: 18 * MeoTheme.globalScale
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.margins: 22 * MeoTheme.globalScale
                spacing: 8 * MeoTheme.globalScale

                Text {
                    Layout.fillWidth: true
                    text: card.title
                    color: MeoTheme.contentOnSurface
                    font.pixelSize: MeoTheme.headlineSmall.size * MeoTheme.globalScale
                    font.weight: Font.Bold
                    wrapMode: Text.WordWrap
                }

                Text {
                    Layout.fillWidth: true
                    text: card.body
                    color: MeoTheme.contentOnSurfaceVariant
                    font.pixelSize: MeoTheme.bodyLarge.size * MeoTheme.globalScale
                    lineHeight: 1.16
                    wrapMode: Text.WordWrap
                }
            }
        }
    }

    ColumnLayout {
        width: parent.width
        spacing: 32 * MeoTheme.globalScale
        Layout.margins: 24 * MeoTheme.globalScale

        Text {
            text: "MD3 Expressive Components"
            font.pixelSize: MeoTheme.headlineMedium.size * MeoTheme.globalScale
            font.weight: Font.Bold
            color: MeoTheme.contentOnSurface
        }

        GridLayout {
            Layout.fillWidth: true
            columns: root.width > 1120 * MeoTheme.globalScale ? 2 : 1
            columnSpacing: 12 * MeoTheme.globalScale
            rowSpacing: 12 * MeoTheme.globalScale

            ExpressiveHighlightCard {
                large: true
                title: "New: Toolbars"
                body: "Flexible component to display frequently used actions. Toolbars hold controls like buttons and can pair with a FAB."

                MeoFloatingToolbar {
                    anchors.centerIn: parent
                    isVibrant: true
                    actions: [
                        Component { MeoIconButton { icon.name: "format_bold"; type: "tonal"; selected: true } },
                        Component { MeoIconButton { icon.name: "format_italic"; type: "standard" } },
                        Component { MeoIconButton { icon.name: "format_underlined"; type: "standard" } },
                        Component { MeoIconButton { icon.name: "format_color_text"; type: "standard" } },
                        Component { MeoIconButton { icon.name: "format_color_fill"; type: "standard" } }
                    ]
                }
            }

            ExpressiveHighlightCard {
                large: true
                title: "New: Split button"
                body: "Pair a button with related actions in a connected menu. Split buttons leverage expressive shape and motion strategies."

                MeoSplitButton {
                    anchors.centerIn: parent
                    size: "l"
                    type: "tonal"
                    text: "Share"
                    icon: "person_add"
                    menuModel: [
                        { label: "Copy link", icon: "link" },
                        { label: "Send invite", icon: "send" }
                    ]
                }
            }

            ExpressiveHighlightCard {
                title: "Updated: Progress indicators"
                body: "An eye-catching way to show status in real time. Customize waveform and thickness to show progress with style."

                Row {
                    anchors.centerIn: parent
                    spacing: 26 * MeoTheme.globalScale

                    MeoProgressBar {
                        width: 170 * MeoTheme.globalScale
                        height: 36 * MeoTheme.globalScale
                        value: 0.58
                        wavy: true
                        isThick: true
                        anchors.verticalCenter: parent.verticalCenter
                    }

                    MeoProgressBar {
                        type: "circular"
                        indeterminate: true
                        isThick: true
                        width: 56 * MeoTheme.globalScale
                        height: 56 * MeoTheme.globalScale
                    }
                }
            }

            ExpressiveHighlightCard {
                title: "New: Button groups"
                body: "A new way to organize related buttons with shape-shifting buttons that react to each other."

                MeoSegmentedButtons {
                    anchors.centerIn: parent
                    size: "l"
                    model: ["Day", "Week", "Month"]
                    currentIndex: 0
                }
            }

            ExpressiveHighlightCard {
                title: "See all expressive components"
                body: "Check out all new and updated M3 Expressive components in the sections below."

                Item {
                    anchors.fill: parent

                    Column {
                        anchors.left: parent.left
                        anchors.leftMargin: 20 * MeoTheme.globalScale
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 6 * MeoTheme.globalScale

                        MeoAssistChip { label: "Select"; icon: "check_circle"; size: "xs"; isEmphasized: true }
                        MeoAssistChip { label: "Add photos"; icon: "add_a_photo"; size: "xs" }
                        MeoAssistChip { label: "Share album"; icon: "share"; size: "xs" }
                        MeoAssistChip { label: "Search"; icon: "search"; size: "xs" }
                    }

                    MeoFAB {
                        anchors.centerIn: parent
                        icon.name: "close"
                        type: "small"
                    }

                    Row {
                        anchors.right: parent.right
                        anchors.rightMargin: 20 * MeoTheme.globalScale
                        anchors.top: parent.top
                        anchors.topMargin: 22 * MeoTheme.globalScale
                        spacing: 8 * MeoTheme.globalScale

                        MeoButton { text: "Going"; type: "filled"; size: "xs"; icon.name: "check_circle" }
                        MeoButton { text: "Not Going"; type: "tonal"; size: "xs"; icon.name: "block" }
                    }

                    MeoSlider {
                        width: 170 * MeoTheme.globalScale
                        anchors.right: parent.right
                        anchors.rightMargin: 26 * MeoTheme.globalScale
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 24 * MeoTheme.globalScale
                        value: 42
                    }
                }
            }
        }

        MeoDivider { topInset: 4; bottomInset: 4 }

        // --- Expressive Search Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Search App Bar"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            ColumnLayout {
                spacing: 24 * MeoTheme.globalScale
                Layout.fillWidth: true

                MeoSearchAppBar {
                    placeholder: "Search components..."
                    onActiveChanged: if (active) text = "Search mode active"
                }

                Text {
                    text: "Search App Bar morphs from a floating bar to a full-screen search view, following MD3 Expressive motion guidelines."
                    font.pixelSize: MeoTheme.bodySmall.size * MeoTheme.globalScale
                    color: MeoTheme.contentOnSurfaceVariant
                    Layout.maximumWidth: 400 * MeoTheme.globalScale
                    wrapMode: Text.WordWrap
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Expressive Buttons Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Button Sizes & Shapes (Bouncy)"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            ColumnLayout {
                spacing: 16 * MeoTheme.globalScale

                // Round Sizes
                Flow {
                    Layout.fillWidth: true
                    spacing: 12 * MeoTheme.globalScale
                    MeoButton { text: "XS Round"; size: "xs"; type: "filled"; bouncy: true }
                    MeoButton { text: "S Round"; size: "s"; type: "tonal"; bouncy: true }
                    MeoButton { text: "M Round"; size: "m"; type: "outlined"; bouncy: true }
                    MeoButton { text: "L Round"; size: "l"; type: "elevated"; bouncy: true }
                    MeoButton { text: "XL Round"; size: "xl"; type: "filled"; isEmphasized: true; bouncy: true }
                }

                // Square Sizes
                Flow {
                    Layout.fillWidth: true
                    spacing: 12 * MeoTheme.globalScale
                    MeoButton { text: "XS Square"; size: "xs"; shape: "square"; type: "filled"; bouncy: true }
                    MeoButton { text: "S Square"; size: "s"; shape: "square"; type: "tonal"; bouncy: true }
                    MeoButton { text: "M Square"; size: "m"; shape: "square"; type: "outlined"; bouncy: true }
                    MeoButton { text: "L Square"; size: "l"; shape: "square"; type: "elevated"; bouncy: true }
                    MeoButton { text: "XL Square"; size: "xl"; shape: "square"; type: "filled"; isEmphasized: true; bouncy: true }
                }
            }
        }

        // --- Expressive Lists Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Segmented & Dense Lists"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Column {
                Layout.fillWidth: true
                spacing: 8 * MeoTheme.globalScale

                MeoListItem {
                    headline: "Vibrant Selection"
                    supportingText: "Uses primaryContainer roles"
                    isSegmented: true
                    selected: true
                    vibrant: true
                    leadingIcon: "auto_awesome"
                    shape: "squircle"
                }
                MeoListItem {
                    headline: "Standard Segmented"
                    supportingText: "Uses secondaryContainer roles"
                    isSegmented: true
                    selected: true
                    leadingIcon: "check_circle"
                    shape: "hexagon"
                }
                MeoListItem {
                    headline: "Emphasized Typography"
                    supportingText: "Bold headline and demibold support text"
                    isEmphasized: true
                    leadingIcon: "format_bold"
                }
                MeoListItem {
                    headline: "Dense List Item"
                    supportingText: "Compact layout for high density"
                    isDense: true
                    leadingIcon: "compress"
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Segmented Buttons Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Segmented Buttons (XS to XL)"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            ColumnLayout {
                spacing: 16 * MeoTheme.globalScale
                MeoSegmentedButtons { size: "xs"; model: ["XS 1", "XS 2", "XS 3"] }
                MeoSegmentedButtons { size: "s"; model: ["Small 1", "Small 2"] }
                MeoSegmentedButtons { size: "m"; model: ["Medium 1", "Medium 2", "Medium 3"] }
                MeoSegmentedButtons { size: "l"; model: ["Large 1", "Large 2"] }
                MeoSegmentedButtons { size: "xl"; model: ["XL 1", "XL 2"] }
            }
        }

        // --- Expressive Chips Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Chips (XS to XL)"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Flow {
                Layout.fillWidth: true
                spacing: 12 * MeoTheme.globalScale
                MeoChip { label: "XS Chip"; size: "xs"; icon: "tag" }
                MeoChip { label: "S Chip"; size: "s"; selected: true }
                MeoChip { label: "M Chip"; size: "m"; closable: true }
                MeoChip { label: "L Chip"; size: "l"; icon: "face"; isEmphasized: true }
                MeoChip { label: "XL Chip"; size: "xl"; icon: "rocket_launch"; isEmphasized: true }
            }

            Flow {
                Layout.fillWidth: true
                spacing: 12 * MeoTheme.globalScale
                MeoAssistChip { label: "XS Assist"; size: "xs"; icon: "share" }
                MeoFilterChip { label: "S Filter"; size: "s"; selected: true }
                MeoInputChip { label: "M Input"; size: "m" }
                MeoSuggestionChip { label: "L Suggestion"; size: "l" }
                MeoAssistChip { label: "XL Assist"; size: "xl"; icon: "star"; isEmphasized: true }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Flexible Top App Bar Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Flexible Top App Bar"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            ColumnLayout {
                spacing: 24 * MeoTheme.globalScale
                Layout.fillWidth: true

                MeoTopAppBar {
                    type: "large"
                    title: "Flexible Header"
                    flexible: true
                    scrollProgress: slider.visualPosition
                    Layout.fillWidth: true
                }

                MeoSlider {
                    id: slider
                    width: 300 * MeoTheme.globalScale
                    from: 0; to: 1.0; value: 1.0
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Expressive Toolbars Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Page Toolbars"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            ColumnLayout {
                spacing: 16 * MeoTheme.globalScale
                Layout.fillWidth: true

                MeoTopAppBar {
                    title: "Standard Toolbar"
                    type: "small"
                    actions: [
                        Component { MeoIconButton { icon.name: "share" } },
                        Component { MeoIconButton { icon.name: "edit" } },
                        Component { MeoIconButton { icon.name: "delete" } }
                    ]
                }

                MeoTopAppBar {
                    title: "Compact Toolbar"
                    type: "center"
                    actions: [
                        Component { MeoIconButton { icon.name: "more_vert" } }
                    ]
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Expressive Progress Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Progress Indicators"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            ColumnLayout {
                spacing: 24 * MeoTheme.globalScale
                Layout.fillWidth: true

                RowLayout {
                    spacing: 24 * MeoTheme.globalScale
                    ColumnLayout {
                        Text { text: "Standard (4dp)"; font.weight: Font.Medium }
                        MeoProgressBar { value: 0.6; width: 200 * MeoTheme.globalScale }
                    }
                    ColumnLayout {
                        Text { text: "Thick (8dp)"; font.weight: Font.Medium }
                        MeoProgressBar { value: 0.6; isThick: true; width: 200 * MeoTheme.globalScale }
                    }
                    ColumnLayout {
                        Text { text: "Vibrant"; font.weight: Font.Medium }
                        MeoProgressBar { value: 0.8; vibrant: true; width: 200 * MeoTheme.globalScale }
                    }
                }

                RowLayout {
                    spacing: 48 * MeoTheme.globalScale
                    MeoProgressBar { type: "circular"; indeterminate: true }
                    MeoProgressBar { type: "circular"; indeterminate: true; isThick: true }
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Sliders Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Sliders & Range Sliders"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Column {
                Layout.fillWidth: true
                spacing: 32 * MeoTheme.globalScale

                Row {
                    spacing: 16 * MeoTheme.globalScale
                    Text { text: "XS"; width: 40 * MeoTheme.globalScale; anchors.verticalCenter: parent.verticalCenter }
                    MeoSlider { width: 300 * MeoTheme.globalScale; size: "xs"; value: 20 }
                    MeoRangeSlider { width: 300 * MeoTheme.globalScale; size: "xs"; firstValue: 10; secondValue: 30 }
                }
                Row {
                    spacing: 16 * MeoTheme.globalScale
                    Text { text: "S"; width: 40 * MeoTheme.globalScale; anchors.verticalCenter: parent.verticalCenter }
                    MeoSlider { width: 300 * MeoTheme.globalScale; size: "s"; value: 40 }
                    MeoRangeSlider { width: 300 * MeoTheme.globalScale; size: "s"; firstValue: 20; secondValue: 50 }
                }
                Row {
                    spacing: 16 * MeoTheme.globalScale
                    Text { text: "M"; width: 40 * MeoTheme.globalScale; anchors.verticalCenter: parent.verticalCenter }
                    MeoSlider { width: 300 * MeoTheme.globalScale; size: "m"; value: 60 }
                    MeoRangeSlider { width: 300 * MeoTheme.globalScale; size: "m"; firstValue: 30; secondValue: 70 }
                }
                Row {
                    spacing: 16 * MeoTheme.globalScale
                    Text { text: "L"; width: 40 * MeoTheme.globalScale; anchors.verticalCenter: parent.verticalCenter }
                    MeoSlider { width: 300 * MeoTheme.globalScale; size: "l"; value: 80 }
                    MeoRangeSlider { width: 300 * MeoTheme.globalScale; size: "l"; firstValue: 40; secondValue: 90 }
                }
                Row {
                    spacing: 16 * MeoTheme.globalScale
                    Text { text: "XL"; width: 40 * MeoTheme.globalScale; anchors.verticalCenter: parent.verticalCenter }
                    MeoSlider { width: 300 * MeoTheme.globalScale; size: "xl"; value: 100 }
                    MeoRangeSlider { width: 300 * MeoTheme.globalScale; size: "xl"; firstValue: 50; secondValue: 100 }
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Patterns & Split Buttons Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Split Buttons (XS to XL)"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Flow {
                Layout.fillWidth: true
                spacing: 16 * MeoTheme.globalScale

                MeoSplitButton { size: "xs"; text: "XS Split"; icon: "add" }
                MeoSplitButton { size: "s"; type: "tonal"; text: "Small Split"; icon: "edit" }
                MeoSplitButton { size: "m"; type: "outlined"; text: "Medium Split"; icon: "share" }
                MeoSplitButton { size: "l"; type: "elevated"; text: "Large Split"; icon: "favorite" }
                MeoSplitButton { size: "xl"; type: "filled"; text: "XL Split"; icon: "settings"; isEmphasized: true }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // 🌟 Vibrant & Segmented Menus
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            MeoListHeader { text: "Expressive Menus & Tooltips"; type: "emphasized" }

            Row {
                spacing: 24 * MeoTheme.globalScale

                MeoButton {
                    id: menuBtn
                    text: "Show Vibrant Menu"
                    type: "filled"
                    onClicked: vibrantMenu.open()

                    MeoMenu {
                        id: vibrantMenu
                        y: parent.height + 8 * MeoTheme.globalScale
                        vibrant: true
                        itemSpacing: 4 * MeoTheme.globalScale
                        model: [
                            { label: "High Priority", icon: "priority_high" },
                            { label: "Vibrant Action", icon: "bolt" },
                            { label: "Standard Action", icon: "settings", isVibrant: false }
                        ]
                    }
                }

                MeoButton {
                    text: "Show Illustrative Tooltip"
                    type: "tonal"
                    onClicked: illustrativeTooltip.open()

                    MeoRichTooltip {
                        id: illustrativeTooltip
                        y: parent.height + 8 * MeoTheme.globalScale
                        title: "Expressive Tooltips"
                        text: "Now supporting illustrative icons and expressive shapes."
                        icon: "auto_awesome"
                        shape: "squircle"
                        actions: [{ text: "Awesome" }]
                    }
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // 🌟 Expressive Sliders
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            MeoListHeader { text: "Expressive Sliders (XS to XL)"; type: "emphasized" }

            Column {
                width: parent.width
                spacing: 24 * MeoTheme.globalScale

                MeoSlider { width: parent.width * 0.8; size: "xs"; value: 20 }
                MeoSlider { width: parent.width * 0.8; size: "s"; value: 40 }
                MeoSlider { width: parent.width * 0.8; size: "m"; value: 60 }
                MeoSlider { width: parent.width * 0.8; size: "l"; value: 80 }
                MeoSlider { width: parent.width * 0.8; size: "xl"; value: 100 }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // 🌟 Expressive Carousels
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            MeoListHeader { text: "Expressive Carousels"; type: "emphasized" }

            Column {
                width: parent.width
                spacing: 24 * MeoTheme.globalScale

                Text { text: "Multi-browse Strategy"; font.weight: Font.Medium; color: MeoTheme.contentOnSurfaceVariant }
                MeoCarousel {
                    width: parent.width
                    height: 240 * MeoTheme.globalScale
                    itemHeight: 200 * MeoTheme.globalScale
                    type: "multi-browse"
                    model: [1, 2, 3, 4, 5, 6, 7, 8]
                    delegate: Rectangle {
                        property int modelIndex: 0
                        property var modelData: 0
                        color: modelIndex % 2 === 0 ? MeoTheme.primaryContainer : MeoTheme.secondaryContainer
                        Text {
                            anchors.centerIn: parent
                            text: "Item " + modelData
                            color: modelIndex % 2 === 0 ? MeoTheme.contentOnPrimaryContainer : MeoTheme.contentOnSecondaryContainer
                        }
                    }
                }

                Text { text: "Uncontained Strategy"; font.weight: Font.Medium; color: MeoTheme.contentOnSurfaceVariant }
                MeoCarousel {
                    width: parent.width
                    height: 240 * MeoTheme.globalScale
                    itemHeight: 200 * MeoTheme.globalScale
                    type: "uncontained"
                    model: [1, 2, 3, 4, 5]
                    delegate: Rectangle {
                        color: MeoTheme.tertiaryContainer
                        Text {
                            anchors.centerIn: parent
                            text: "Uncontained " + modelData
                            color: MeoTheme.contentOnTertiaryContainer
                        }
                    }
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // 🌟 Expressive Shapes
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            MeoListHeader { text: "Expressive Shapes & Cards"; type: "emphasized" }

            Flow {
                Layout.fillWidth: true
                spacing: 24 * MeoTheme.globalScale

                MeoAvatar { size: 64; variant: "squircle"; initials: "SQ" }
                MeoAvatar { size: 64; variant: "hexagon"; color: MeoTheme.secondaryContainer }
                MeoAvatar { size: 64; variant: "octagon"; color: MeoTheme.tertiaryContainer; initials: "OC" }
            }

            Flow {
                Layout.fillWidth: true
                spacing: 24 * MeoTheme.globalScale

                MeoCard {
                    width: 160 * MeoTheme.globalScale
                    height: 160 * MeoTheme.globalScale
                    shape: "squircle"
                    type: "filled"
                    interactive: true
                    Text { anchors.centerIn: parent; text: "Squircle Card"; color: MeoTheme.contentOnSurfaceVariant }
                }

                MeoCard {
                    width: 160 * MeoTheme.globalScale
                    height: 160 * MeoTheme.globalScale
                    shape: "hexagon"
                    type: "elevated"
                    interactive: true
                    Text { anchors.centerIn: parent; text: "Hexagon Card"; color: MeoTheme.contentOnSurface }
                }

                MeoCard {
                    width: 160 * MeoTheme.globalScale
                    height: 160 * MeoTheme.globalScale
                    shape: "octagon"
                    type: "outlined"
                    interactive: true
                    Text { anchors.centerIn: parent; text: "Octagon Card"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Expressive Selection Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Selection (Soul Motion)"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            RowLayout {
                spacing: 24 * MeoTheme.globalScale
                MeoSwitch { label: "Expressive Switch"; isExpressive: true }
                MeoCheckbox { label: "Soul Checkbox"; checked: true }
                MeoRadioButton { label: "Soul Radio"; checked: true }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- FAB Menu Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "FAB Menu (Expressive Speed Dial)"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Item {
                implicitHeight: 240 * MeoTheme.globalScale
                Layout.fillWidth: true

                Rectangle {
                    anchors.fill: parent
                    color: MeoTheme.surfaceContainerLow
                    radius: 12 * MeoTheme.globalScale
                    border.color: MeoTheme.outlineVariant

                    Text {
                        anchors.centerIn: parent
                        text: "Click FAB to see Menu"
                        color: MeoTheme.contentOnSurfaceVariant
                        font.italic: true
                    }

                    MeoFABMenu {
                        anchors.bottom: parent.bottom
                        anchors.right: parent.right
                        anchors.margins: 16 * MeoTheme.globalScale
                        model: [
                            { label: "New Task", icon: "assignment" },
                            { label: "New Event", icon: "event" },
                            { label: "Add Photo", icon: "photo_camera" }
                        ]
                    }
                }
            }
        }
    }
}
