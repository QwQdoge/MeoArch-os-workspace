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

        // --- Buttons Section ---
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
            }
        }
    }
}
