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

                // Toggle Buttons
                Flow {
                    Layout.fillWidth: true
                    spacing: 12 * MeoTheme.globalScale
                    MeoButton { text: "Toggle Me"; checkable: true; type: "outlined"; icon: "favorite" }
                    MeoButton { text: "Always On"; checkable: true; checked: true; type: "filled"; icon: "notifications" }

                    MeoIconButton { size: "xs"; icon.name: "settings"; type: "standard" }
                    MeoIconButton { size: "s"; icon.name: "settings"; type: "tonal" }
                    MeoIconButton { size: "m"; icon.name: "settings"; type: "filled" }
                    MeoIconButton { size: "l"; icon.name: "settings"; type: "outlined" }
                    MeoIconButton { size: "xl"; icon.name: "settings"; type: "filled" }
                }
            }
        }

        // --- Split Buttons Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Buttons (XS to XL)"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Flow {
                Layout.fillWidth: true
                spacing: 16 * MeoTheme.globalScale

                MeoButton { text: "XS Filled"; size: "xs"; type: "filled"; icon: "add" }
                MeoButton { text: "Small Tonal"; size: "s"; type: "tonal"; icon: "edit" }
                MeoButton { text: "Medium Outlined"; size: "m"; type: "outlined"; icon: "share" }
                MeoButton { text: "Large Elevated"; size: "l"; type: "elevated"; icon: "favorite" }
                MeoButton { text: "XL Text"; size: "xl"; type: "text"; icon: "settings" }
            }

            Text {
                text: "Square Buttons & Toggle States"
                font.pixelSize: MeoTheme.titleMedium.size * MeoTheme.globalScale
                font.weight: Font.Medium
                color: MeoTheme.onSurfaceVariant
            }

            Flow {
                Layout.fillWidth: true
                spacing: 16 * MeoTheme.globalScale

                MeoButton { text: "Square XS"; size: "xs"; shape: "square"; type: "filled" }
                MeoButton { text: "Square M"; size: "m"; shape: "square"; type: "tonal" }

                MeoButton {
                    text: selected ? "Selected" : "Toggle Me"
                    type: "outlined"
                    selected: false
                    onClicked: selected = !selected
                }

                MeoButton {
                    icon: "star"
                    text: "Favorite"
                    type: "text"
                    selected: true
                    onClicked: selected = !selected
                }
            }
        }

        // --- Icon Buttons Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Icon Buttons"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Flow {
                Layout.fillWidth: true
                spacing: 16 * MeoTheme.globalScale

                MeoIconButton { icon: "home"; size: "xs"; type: "standard" }
                MeoIconButton { icon: "search"; size: "s"; type: "filled" }
                MeoIconButton { icon: "notifications"; size: "m"; type: "tonal" }
                MeoIconButton { icon: "person"; size: "l"; type: "outlined" }
                MeoIconButton { icon: "menu"; size: "xl"; type: "standard"; shape: "square" }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Sliders Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Sliders"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Column {
                Layout.fillWidth: true
                spacing: 24 * MeoTheme.globalScale

                Row {
                    spacing: 16 * MeoTheme.globalScale
                    Text { text: "XS"; width: 40 * MeoTheme.globalScale; anchors.verticalCenter: parent.verticalCenter }
                    MeoSlider { width: 300 * MeoTheme.globalScale; size: "xs"; value: 20 }
                }
                Row {
                    spacing: 16 * MeoTheme.globalScale
                    Text { text: "S"; width: 40 * MeoTheme.globalScale; anchors.verticalCenter: parent.verticalCenter }
                    MeoSlider { width: 300 * MeoTheme.globalScale; size: "s"; value: 40 }
                }
                Row {
                    spacing: 16 * MeoTheme.globalScale
                    Text { text: "M"; width: 40 * MeoTheme.globalScale; anchors.verticalCenter: parent.verticalCenter }
                    MeoSlider { width: 300 * MeoTheme.globalScale; size: "m"; value: 60 }
                }
                Row {
                    spacing: 16 * MeoTheme.globalScale
                    Text { text: "L"; width: 40 * MeoTheme.globalScale; anchors.verticalCenter: parent.verticalCenter }
                    MeoSlider { width: 300 * MeoTheme.globalScale; size: "l"; value: 80 }
                }
                Row {
                    spacing: 16 * MeoTheme.globalScale
                    Text { text: "XL"; width: 40 * MeoTheme.globalScale; anchors.verticalCenter: parent.verticalCenter }
                    MeoSlider { width: 300 * MeoTheme.globalScale; size: "xl"; value: 100 }
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Split Buttons & Other Patterns ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Patterns & Layouts"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Flow {
                Layout.fillWidth: true
                spacing: 16 * MeoTheme.globalScale

                MeoSplitButton {
                    text: "Filled Split"
                    type: "filled"
                    icon: "save"
                    menuModel: [
                        { label: "Save as...", icon: "content_copy" },
                        { label: "Export to PDF", icon: "picture_as_pdf" }
                    ]
                }

                MeoFABMenu {
                    model: [
                        { label: "New Task", icon: "assignment" },
                        { label: "New Event", icon: "event" }
                    ]
                }

                MeoButtonGroup {
                    type: "tonal"
                    sizeVariant: "small"
                    model: [
                        { icon: "format_align_left" },
                        { icon: "format_align_center" },
                        { icon: "format_align_right" }
                    ]
                }
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
                width: parent.width
                spacing: 24 * MeoTheme.globalScale

                MeoAvatar { size: 64; variant: "squircle"; initials: "SQ" }
                MeoAvatar { size: 64; variant: "hexagon"; color: MeoTheme.secondaryContainer }
                MeoAvatar { size: 64; variant: "diamond"; color: MeoTheme.tertiaryContainer }
                MeoAvatar { size: 64; variant: "pentagon"; initials: "PT" }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // 🌟 FAB Menu Section
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "FAB Menu (Expressive Speed Dial Replacement)"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Item {
                implicitHeight: 300 * MeoTheme.globalScale
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
