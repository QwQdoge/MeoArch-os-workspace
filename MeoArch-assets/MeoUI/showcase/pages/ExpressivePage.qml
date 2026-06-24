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
            }
        }

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
