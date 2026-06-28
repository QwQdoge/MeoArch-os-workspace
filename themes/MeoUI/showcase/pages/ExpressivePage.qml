import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

ScrollView {
    id: root
    contentWidth: availableWidth

    ColumnLayout {
        width: parent.width
        spacing: 32 * MeoTheme.globalScale
        Layout.margins: 24 * MeoTheme.globalScale

        Text {
            text: "MD3 Expressive Components"
            font.pixelSize: MeoTheme.headlineMedium.size * MeoTheme.globalScale
            font.weight: Font.Bold
            color: MeoTheme.onSurface
        }

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
                    color: MeoTheme.onSurfaceVariant
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
                text: "Expressive Segmented Lists"
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
                    label: "Scroll Progress"
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

                MeoToolbar {
                    title: "Standard Toolbar"
                    actions: [
                        Component { MeoIconButton { icon.name: "share" } },
                        Component { MeoIconButton { icon.name: "edit" } },
                        Component { MeoIconButton { icon.name: "delete" } }
                    ]
                }

                MeoToolbar {
                    title: "Compact Toolbar"
                    isCompact: true
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

                Text { text: "Multi-browse Strategy"; font.weight: Font.Medium; color: MeoTheme.onSurfaceVariant }
                MeoCarousel {
                    width: parent.width
                    height: 240 * MeoTheme.globalScale
                    itemHeight: 200 * MeoTheme.globalScale
                    type: "multi-browse"
                    model: [1, 2, 3, 4, 5, 6, 7, 8]
                    delegate: Rectangle {
                        color: index % 2 === 0 ? MeoTheme.primaryContainer : MeoTheme.secondaryContainer
                        Text {
                            anchors.centerIn: parent
                            text: "Item " + modelData
                            color: index % 2 === 0 ? MeoTheme.onPrimaryContainer : MeoTheme.onSecondaryContainer
                        }
                    }
                }

                Text { text: "Uncontained Strategy"; font.weight: Font.Medium; color: MeoTheme.onSurfaceVariant }
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
                            color: MeoTheme.onTertiaryContainer
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
                    Text { anchors.centerIn: parent; text: "Squircle Card"; color: MeoTheme.onSurfaceVariant }
                }

                MeoCard {
                    width: 160 * MeoTheme.globalScale
                    height: 160 * MeoTheme.globalScale
                    shape: "hexagon"
                    type: "elevated"
                    interactive: true
                    Text { anchors.centerIn: parent; text: "Hexagon Card"; color: MeoTheme.onSurface }
                }

                MeoCard {
                    width: 160 * MeoTheme.globalScale
                    height: 160 * MeoTheme.globalScale
                    shape: "octagon"
                    type: "outlined"
                    interactive: true
                    Text { anchors.centerIn: parent; text: "Octagon Card"; color: MeoTheme.onSurfaceVariant }
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
                        color: MeoTheme.onSurfaceVariant
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
