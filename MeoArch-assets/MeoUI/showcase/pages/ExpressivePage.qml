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

                // Icon Buttons
                Flow {
                    Layout.fillWidth: true
                    spacing: 12 * MeoTheme.globalScale
                    MeoIconButton { size: "xs"; icon.name: "settings"; type: "standard" }
                    MeoIconButton { size: "s"; icon.name: "settings"; type: "tonal" }
                    MeoIconButton { size: "m"; icon.name: "settings"; type: "filled" }
                    MeoIconButton { size: "l"; icon.name: "settings"; type: "outlined" }
                    MeoIconButton { size: "xl"; icon.name: "settings"; type: "filled"; shape: "square" }
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Selection Controls Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Selection Controls (Expressive Motion)"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Flow {
                Layout.fillWidth: true
                spacing: 24 * MeoTheme.globalScale

                Column {
                    spacing: 8 * MeoTheme.globalScale
                    MeoSwitch { label: "Expressive Switch"; checked: true; icon: "check" }
                    MeoSwitch { label: "Off State"; checked: false }
                }

                Column {
                    spacing: 8 * MeoTheme.globalScale
                    MeoCheckbox { label: "Checkbox On"; checked: true }
                    MeoCheckbox { label: "Indeterminate"; indeterminate: true }
                    MeoCheckbox { label: "Checkbox Off"; checked: false }
                }

                Column {
                    spacing: 8 * MeoTheme.globalScale
                    MeoRadioButton { label: "Radio Selected"; checked: true }
                    MeoRadioButton { label: "Radio Unselected"; checked: false }
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // --- Sliders Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Sliders (XS to XL)"
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

        // --- Patterns & Split Buttons Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Patterns & Split Buttons"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Flow {
                Layout.fillWidth: true
                spacing: 16 * MeoTheme.globalScale

                MeoSplitButton {
                    text: "Save"
                    size: "m"
                    type: "filled"
                    icon: "save"
                    menuModel: [
                        { label: "Save as...", icon: "content_copy" },
                        { label: "Export to PDF", icon: "picture_as_pdf" }
                    ]
                }

                MeoSplitButton {
                    text: "XS Split"
                    size: "xs"
                    type: "outlined"
                    icon: "add"
                }

                MeoSplitButton {
                    text: "XL Expressive"
                    size: "xl"
                    type: "tonal"
                    isEmphasized: true
                    icon: "rocket_launch"
                }
            }

            Row {
                spacing: 24 * MeoTheme.globalScale
                Layout.topMargin: 16 * MeoTheme.globalScale

                MeoButton {
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

        // --- Shapes & Avatars Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Expressive Shapes & Avatars"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            Flow {
                Layout.fillWidth: true
                spacing: 24 * MeoTheme.globalScale

                MeoAvatar { size: 64; variant: "squircle"; initials: "SQ" }
                MeoAvatar { size: 64; variant: "hexagon"; color: MeoTheme.secondaryContainer }
                MeoAvatar { size: 64; variant: "diamond"; color: MeoTheme.tertiaryContainer }
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
