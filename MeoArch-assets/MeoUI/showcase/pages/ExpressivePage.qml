import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

ScrollView {
    anchors.fill: parent
    contentHeight: column.implicitHeight + 64 * MeoTheme.globalScale

    Column {
        id: column
        width: parent.width - 32 * MeoTheme.globalScale
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 32 * MeoTheme.globalScale
        topPadding: 32 * MeoTheme.globalScale

        // 🌟 Split Button Section
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            MeoListHeader { text: "Split Buttons"; type: "emphasized" }

            Flow {
                width: parent.width
                spacing: 16 * MeoTheme.globalScale

                MeoSplitButton {
                    text: "Filled Split"
                    type: "filled"
                    icon: "send"
                    menuModel: [
                        { label: "Send later", icon: "schedule" },
                        { label: "Send as draft", icon: "drafts" }
                    ]
                }

                MeoSplitButton {
                    text: "Tonal Split"
                    type: "tonal"
                    icon: "download"
                    menuModel: [
                        { label: "Download ZIP", icon: "folder_zip" },
                        { label: "Download PDF", icon: "picture_as_pdf" }
                    ]
                }

                MeoSplitButton {
                    text: "Outlined"
                    type: "outlined"
                    icon: "share"
                    menuModel: [
                        { label: "Copy link", icon: "link" },
                        { label: "Email", icon: "email" }
                    ]
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // 🌟 Button Group Section
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            MeoListHeader { text: "Button Groups"; type: "emphasized" }

            Column {
                spacing: 24 * MeoTheme.globalScale

                MeoButtonGroup {
                    model: [
                        { label: "Day", icon: "calendar_view_day" },
                        { label: "Week", icon: "calendar_view_week" },
                        { label: "Month", icon: "calendar_view_month" }
                    ]
                    type: "outlined"
                }

                MeoButtonGroup {
                    model: [
                        { label: "Left", icon: "format_align_left" },
                        { label: "Center", icon: "format_align_center" },
                        { label: "Right", icon: "format_align_right" }
                    ]
                    type: "tonal"
                }

                MeoButtonGroup {
                    orientation: Qt.Vertical
                    model: [
                        { label: "High", icon: "signal_cellular_alt" },
                        { label: "Medium", icon: "signal_cellular_alt_2_bar" },
                        { label: "Low", icon: "signal_cellular_alt_1_bar" }
                    ]
                    type: "elevated"
                }
            }
        }

        MeoDivider { topInset: 16; bottomInset: 16 }

        // 🌟 FAB Menu Section
        Column {
            width: parent.width
            spacing: 16 * MeoTheme.globalScale
            MeoListHeader { text: "FAB Menus"; type: "emphasized" }

            Row {
                spacing: 32 * MeoTheme.globalScale

                MeoFABMenu {
                    icon: "add"
                    model: [
                        { label: "New Message", icon: "chat" },
                        { label: "New Post", icon: "article" },
                        { label: "New Event", icon: "event" }
                    ]
                }

                MeoFABMenu {
                    icon: "share"
                    text: "Share"
                    model: [
                        { label: "WhatsApp", icon: "share" },
                        { label: "Facebook", icon: "facebook" },
                        { label: "Twitter", icon: "close" }
                    ]
                }
            }
        }
    }
}
