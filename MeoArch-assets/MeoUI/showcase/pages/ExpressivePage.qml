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

        // --- Split Buttons Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Split Buttons"
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

                MeoSplitButton {
                    text: "Tonal Split"
                    type: "tonal"
                    icon: "share"
                    menuModel: [
                        { label: "Copy Link", icon: "link" },
                        { label: "Share via Email", icon: "email" }
                    ]
                }

                MeoSplitButton {
                    text: "Outlined"
                    type: "outlined"
                    sizeVariant: "small"
                    menuModel: [
                        { label: "Quick Action 1" },
                        { label: "Quick Action 2" }
                    ]
                }
            }
        }

        // --- Button Groups Section ---
        ColumnLayout {
            spacing: 16 * MeoTheme.globalScale

            Text {
                text: "Button Groups"
                font.pixelSize: MeoTheme.titleLarge.size * MeoTheme.globalScale
                font.weight: Font.DemiBold
                color: MeoTheme.primary
            }

            ColumnLayout {
                spacing: 12 * MeoTheme.globalScale

                MeoButtonGroup {
                    type: "outlined"
                    model: [
                        { label: "Day", icon: "light_mode" },
                        { label: "Week", icon: "calendar_view_week" },
                        { label: "Month", icon: "calendar_month" }
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
            MeoListHeader { text: "Expressive Sliders"; type: "emphasized" }

            Column {
                width: parent.width
                spacing: 24 * MeoTheme.globalScale

                MeoSlider {
                    width: parent.width * 0.8
                    expressive: true
                    value: 40
                }

                MeoSlider {
                    width: parent.width * 0.8
                    expressive: true
                    discrete: true
                    stepSize: 20
                    value: 60
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
