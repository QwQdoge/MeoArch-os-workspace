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

        // --- FAB Menu Section ---
        ColumnLayout {
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
