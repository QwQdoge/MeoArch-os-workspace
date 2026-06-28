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
                text: "Expressive Search Bar Expansion"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            ColumnLayout {
                spacing: 24 * MeoTheme.globalScale
                Layout.fillWidth: true

                MeoSearchBar {
                    placeholder: "Click to expand..."
                    onActiveChanged: if (active) text = "Expanded state active"
                }

                Text {
                    text: "Search morphs from pill (28dp) to contained (16dp) or full-screen (0dp) based on container width."
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
                text: "Expressive Button Sizes & Shapes"
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
                    MeoButton { text: "XS Round"; size: "xs"; type: "filled" }
                    MeoButton { text: "S Round"; size: "s"; type: "tonal" }
                    MeoButton { text: "M Round (Default)"; size: "m"; type: "outlined" }
                    MeoButton { text: "L Round"; size: "l"; type: "elevated" }
                    MeoButton { text: "XL Round"; size: "xl"; type: "filled"; isEmphasized: true }
                }

                // Square Sizes
                Flow {
                    Layout.fillWidth: true
                    spacing: 12 * MeoTheme.globalScale
                    MeoButton { text: "XS Square"; size: "xs"; shape: "square"; type: "filled" }
                    MeoButton { text: "S Square"; size: "s"; shape: "square"; type: "tonal" }
                    MeoButton { text: "M Square"; size: "m"; shape: "square"; type: "outlined" }
                    MeoButton { text: "L Square"; size: "l"; shape: "square"; type: "elevated" }
                    MeoButton { text: "XL Square"; size: "xl"; shape: "square"; type: "filled"; isEmphasized: true }
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
                }
                MeoListItem {
                    headline: "Standard Segmented"
                    supportingText: "Uses secondaryContainer roles"
                    isSegmented: true
                    selected: true
                    leadingIcon: "check_circle"
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
            MeoListHeader { text: "Expressive Menus"; type: "emphasized" }

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
                    text: "Show Segmented Menu"
                    type: "tonal"
                    onClicked: segmentedMenu.open()

                    MeoMenu {
                        id: segmentedMenu
                        y: parent.height + 8 * MeoTheme.globalScale
                        itemSpacing: 8 * MeoTheme.globalScale
                        model: [
                            { label: "Option 1", icon: "filter_1" },
                            { label: "Option 2", icon: "filter_2" },
                            { label: "Option 3", icon: "filter_3" }
                        ]
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
            MeoListHeader { text: "Expressive Shapes & Avatars"; type: "emphasized" }

            Flow {
                Layout.fillWidth: true
                spacing: 24 * MeoTheme.globalScale

                MeoAvatar { size: 64; variant: "squircle"; initials: "SQ" }
                MeoAvatar { size: 64; variant: "hexagon"; color: MeoTheme.secondaryContainer }
                MeoAvatar { size: 64; variant: "octagon"; color: MeoTheme.tertiaryContainer; initials: "OC" }
                MeoAvatar { size: 64; variant: "diamond"; color: MeoTheme.primaryContainer }
                MeoAvatar { size: 64; variant: "pentagon"; initials: "PT" }
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
