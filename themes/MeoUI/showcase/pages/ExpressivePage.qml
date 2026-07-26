import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    categoryId: "expressive"

    // 🌟 Additional Expressive Samples
    ShowcaseSection {
        title: "Adaptive Segmented Groups"
        subtitle: "Items with connected corner radii forming unified containers."
        width: parent.width

        MeoGroupedList {
            width: parent.width
            title: "System Settings"
            subtitle: "Grouped with adaptive corners"
            model: [
                { label: "Wi-Fi", icon: "wifi", trailingText: "Connected" },
                { label: "Bluetooth", icon: "bluetooth", trailingText: "On" },
                { label: "Mobile Network", icon: "signal_cellular_4_bar" }
            ]
        }
    }

    ShowcaseSection {
        title: "Expressive Search Morphing"
        subtitle: "Fluid expansion from bar to full surface."
        width: parent.width

        MeoSearchBar {
            id: demoSearchBar
            width: parent.width
            placeholder: "Click to see morphing..."
            onActivated: searchView.open()
        }

        MeoSearchView {
            id: searchView
            width: parent.width
            height: 400 * MeoTheme.globalScale
            suggestions: [
                { label: "Material Design 3", icon: "history" },
                { label: "Expressive Motion", icon: "history" },
                { label: "QML Components", icon: "search" }
            ]
        }
    }

    ShowcaseSection {
        title: "Expressive Icon Toggle Buttons"
        subtitle: "MD3 Icon Toggle Buttons supporting five size variants (XS to XL), multiple visual styles, checked/toggled states, and annotations."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Size Variants Row
            RowLayout {
                spacing: MeoTheme.space12
                Layout.alignment: Qt.AlignLeft

                MeoText {
                    text: "Sizes (XS to XL):"
                    typeRole: "label"
                    typeSize: "medium"
                    Layout.preferredWidth: 120 * MeoTheme.globalScale
                }

                MeoIconToggleButton {
                    size: "xs"
                    icon.name: "favorite_border"
                    checkedIcon: "favorite"
                }
                MeoIconToggleButton {
                    size: "s"
                    icon.name: "star_border"
                    checkedIcon: "star"
                }
                MeoIconToggleButton {
                    size: "m"
                    icon.name: "bookmark_border"
                    checkedIcon: "bookmark"
                    badgeText: "3"
                }
                MeoIconToggleButton {
                    size: "l"
                    icon.name: "notifications_none"
                    checkedIcon: "notifications_active"
                    badgeDot: true
                }
                MeoIconToggleButton {
                    size: "xl"
                    icon.name: "thumb_up_off_alt"
                    checkedIcon: "thumb_up"
                }
            }

            // Style Variants Row
            RowLayout {
                spacing: MeoTheme.space12
                Layout.alignment: Qt.AlignLeft

                MeoText {
                    text: "Styles & States:"
                    typeRole: "label"
                    typeSize: "medium"
                    Layout.preferredWidth: 120 * MeoTheme.globalScale
                }

                ColumnLayout {
                    spacing: MeoTheme.space8

                    RowLayout {
                        spacing: MeoTheme.space12
                        MeoIconToggleButton {
                            type: "standard"
                            icon.name: "favorite_border"
                            checkedIcon: "favorite"
                        }
                        MeoText { text: "Standard"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                    }

                    RowLayout {
                        spacing: MeoTheme.space12
                        MeoIconToggleButton {
                            type: "filled"
                            icon.name: "favorite_border"
                            checkedIcon: "favorite"
                        }
                        MeoText { text: "Filled"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                    }

                    RowLayout {
                        spacing: MeoTheme.space12
                        MeoIconToggleButton {
                            type: "tonal"
                            icon.name: "favorite_border"
                            checkedIcon: "favorite"
                        }
                        MeoText { text: "Tonal"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                    }

                    RowLayout {
                        spacing: MeoTheme.space12
                        MeoIconToggleButton {
                            type: "outlined"
                            icon.name: "favorite_border"
                            checkedIcon: "favorite"
                        }
                        MeoText { text: "Outlined"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                    }
                }
            }
        }
    }

    ShowcaseSection {
        title: "Expressive Chip Dropdowns (Multi-Select)"
        subtitle: "Exposed multi-select dropdown field displaying selected items as removable input chips. Expands dynamically to wrap multiple items."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            RowLayout {
                spacing: MeoTheme.space24
                Layout.fillWidth: true

                // Filled style
                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    MeoText {
                        text: "Filled Dropdown with Counter:"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                    }

                    MeoChipDropdown {
                        Layout.fillWidth: true
                        type: "filled"
                        size: "m"
                        label: "Interests"
                        placeholder: "Choose categories..."
                        model: ["Design", "Engineering", "Arts", "Music", "Science", "Business"]
                        selectedIndices: [0, 2, 3]
                        showCounter: true
                        helperText: "Choose multiple options from the menu"
                    }
                }

                // Outlined style with error state
                ColumnLayout {
                    spacing: MeoTheme.space8
                    Layout.fillWidth: true

                    MeoText {
                        text: "Outlined Dropdown with Error State:"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                    }

                    MeoChipDropdown {
                        Layout.fillWidth: true
                        type: "outlined"
                        size: "m"
                        label: "Tags"
                        placeholder: "Add tags..."
                        model: ["Important", "Feature", "Regression", "UI/UX", "Backend"]
                        selectedIndices: [0, 1]
                        isError: true
                        errorText: "Tag selection is invalid or contains errors"
                        showCounter: false
                    }
                }
            }

            // Size variants
            ColumnLayout {
                spacing: MeoTheme.space8
                Layout.fillWidth: true

                MeoText {
                    text: "Size Scale (S to XL):"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                RowLayout {
                    spacing: MeoTheme.space12
                    Layout.fillWidth: true

                    MeoChipDropdown {
                        Layout.fillWidth: true
                        size: "s"
                        label: "Small"
                        model: ["Option 1", "Option 2"]
                        selectedIndices: [0]
                    }

                    MeoChipDropdown {
                        Layout.fillWidth: true
                        size: "l"
                        label: "Large"
                        model: ["Option 1", "Option 2"]
                        selectedIndices: [0]
                    }

                    MeoChipDropdown {
                        Layout.fillWidth: true
                        size: "xl"
                        label: "Extra Large"
                        model: ["Option 1", "Option 2"]
                        selectedIndices: [0]
                    }
                }
            }
        }
    }
}
