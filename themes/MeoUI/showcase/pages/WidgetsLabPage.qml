import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: widgetsLabPage
    categoryId: "search"

    // 🌟 1. Account Management Section
    ShowcaseSection {
        title: "Account Switching & Identity Management"
        subtitle: "MD3 Expressive account switcher widget with animated toggle states, selection lists, and inline avatar indicators."
        width: parent.width

        RowLayout {
            width: parent.width
            Layout.alignment: Qt.AlignHCenter

            MeoAccountSwitcher {
                Layout.alignment: Qt.AlignHCenter
                model: [
                    { name: "Meo Developer", email: "dev@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Meo" },
                    { name: "Design Lead", email: "design@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Design" },
                    { name: "Product Manager", email: "pm@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=PM" }
                ]
            }
        }
    }

    // 🌟 2. Interactive Date & Time Pickers Section (大小、比例、状态)
    ShowcaseSection {
        title: "Date & Time Picker Widgets (日期与时间选择器)"
        subtitle: "Visualizing standard calendar pickers and clock-face time controllers supporting full focus and touch inputs."
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space24
            Layout.alignment: Qt.AlignHCenter

            // Date Picker Card Box
            ColumnLayout {
                spacing: MeoTheme.space12
                Layout.preferredWidth: 328 * MeoTheme.globalScale

                MeoText {
                    text: "MeoDatePicker (Calendar)"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                MeoDatePicker {
                    Layout.alignment: Qt.AlignHCenter
                    selectedDate: new Date()
                }
            }

            // Time Picker Card Box
            ColumnLayout {
                spacing: MeoTheme.space12
                Layout.preferredWidth: 320 * MeoTheme.globalScale

                MeoText {
                    text: "MeoTimePicker (Clock Face)"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                    horizontalAlignment: Text.AlignHCenter
                    Layout.fillWidth: true
                }

                MeoTimePicker {
                    Layout.alignment: Qt.AlignHCenter
                    hours: 10
                    minutes: 45
                    isPM: true
                }
            }
        }
    }

    // 🌟 3. Expressive Media Playback Controls (比例与控制状态)
    ShowcaseSection {
        title: "Media Controller & Proportions (媒体控制与比例结构)"
        subtitle: "A standard media controller widget with custom track progress thickness, wavy styles, and interactive state indicators."
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Media Controller Left: Wavy/Thick Progress
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText {
                    text: "Play / Pause Active State"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                MeoMediaController {
                    Layout.fillWidth: true
                    title: "Synthesized Dreamscape"
                    artist: "The QML Collective"
                    isPlaying: true
                    progress: 0.38
                }
            }

            // Media Controller Right: Disabled state / Alternate style
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText {
                    text: "Paused / Stopped State"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                MeoMediaController {
                    Layout.fillWidth: true
                    title: "Atmospheric Acoustics"
                    artist: "Acoustics Lab"
                    isPlaying: false
                    progress: 0.12
                }
            }
        }
    }

    // 🌟 4. Adaptive Toolbars & Search Bars (粗细变体与检索状态)
    ShowcaseSection {
        title: "Search Bars & Adaptive App Toolbars"
        subtitle: "Standalone or docked search containers showing various border thicknesses, container sizes, and action items."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            // Row 1: Search Bars Variants (XS to XL Sizes)
            ColumnLayout {
                spacing: MeoTheme.space12
                Layout.fillWidth: true

                MeoText {
                    text: "Search Bar Sizing and Style Scale"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                RowLayout {
                    spacing: MeoTheme.space16
                    Layout.fillWidth: true

                    MeoSearchBar {
                        Layout.fillWidth: true
                        placeholder: "Standard Contained..."
                        active: false
                    }

                    MeoDockedSearchBar {
                        Layout.fillWidth: true
                        placeholder: "Docked Search Bar style..."
                    }
                }
            }

            // Row 2: Toolbars with different semantic outlines
            ColumnLayout {
                spacing: MeoTheme.space12
                Layout.fillWidth: true

                MeoText {
                    text: "Bottom App Bar Integration"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                MeoBottomAppBar {
                    Layout.fillWidth: true
                    actions: [
                        { icon: "menu", label: "Menu" },
                        { icon: "search", label: "Search" },
                        { icon: "archive", label: "Archive" },
                        { icon: "mail", label: "Email" }
                    ]
                }
            }
        }
    }
}
