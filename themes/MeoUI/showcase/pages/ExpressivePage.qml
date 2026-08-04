import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: expressivePage
    categoryId: "expressive"

    // 🌟 M3 Expressive FAB Gallery
    ShowcaseSection {
        title: "M3 Expressive FAB Gallery"
        subtitle: "Showcasing modernized Extended FAB sizes, expressive shapes, vibrant colors, outlines, and selection states."
        width: parent.width

        Column {
            width: parent.width
            spacing: MeoTheme.space24

            // Row 1: Extended FAB Size Scale
            Column {
                width: parent.width
                spacing: MeoTheme.space12

                Text {
                    text: "1. Extended FAB Sizes (Small 56dp, Medium 80dp, Large 96dp)"
                    font.family: MeoTheme.typefacePlain
                    font.pixelSize: 14 * MeoTheme.globalScale
                    font.weight: Font.DemiBold
                    color: MeoTheme.contentOnSurface
                }

                Flow {
                    width: parent.width
                    spacing: MeoTheme.space16

                    MeoFAB {
                        type: "extended"
                        size: "small"
                        text: "Small Extended (56dp)"
                        icon.name: "add"
                    }

                    MeoFAB {
                        type: "extended"
                        size: "medium"
                        text: "Medium Extended (80dp)"
                        icon.name: "palette"
                    }

                    MeoFAB {
                        type: "extended"
                        size: "large"
                        text: "Large Extended (96dp)"
                        icon.name: "brush"
                    }
                }
            }

            // Row 2: Expressive Shape library applied to FABs
            Column {
                width: parent.width
                spacing: MeoTheme.space12

                Text {
                    text: "2. Expressive Shapes (Squircle, Clover, Star, Hexagon)"
                    font.family: MeoTheme.typefacePlain
                    font.pixelSize: 14 * MeoTheme.globalScale
                    font.weight: Font.DemiBold
                    color: MeoTheme.contentOnSurface
                }

                Flow {
                    width: parent.width
                    spacing: MeoTheme.space16

                    MeoFAB {
                        type: "regular"
                        shape: "squircle"
                        icon.name: "auto_awesome"
                        ToolTip.visible: hovered
                        ToolTip.text: "Squircle Shape"
                    }

                    MeoFAB {
                        type: "regular"
                        shape: "clover"
                        icon.name: "favorite"
                        ToolTip.visible: hovered
                        ToolTip.text: "Clover Shape"
                    }

                    MeoFAB {
                        type: "regular"
                        shape: "star"
                        icon.name: "star"
                        ToolTip.visible: hovered
                        ToolTip.text: "Star Shape"
                    }

                    MeoFAB {
                        type: "regular"
                        shape: "hexagon"
                        icon.name: "settings"
                        ToolTip.visible: hovered
                        ToolTip.text: "Hexagon Shape"
                    }
                }
            }

            // Row 3: Styling Variants & Toggle States
            Column {
                width: parent.width
                spacing: MeoTheme.space12

                Text {
                    text: "3. Styling Variants & Toggle/Selected States"
                    font.family: MeoTheme.typefacePlain
                    font.pixelSize: 14 * MeoTheme.globalScale
                    font.weight: Font.DemiBold
                    color: MeoTheme.contentOnSurface
                }

                Flow {
                    width: parent.width
                    spacing: MeoTheme.space16

                    MeoFAB {
                        type: "extended"
                        size: "small"
                        text: "Vibrant Gradient"
                        icon.name: "bolt"
                        vibrant: true
                    }

                    MeoFAB {
                        type: "extended"
                        size: "small"
                        text: "Outlined Style"
                        icon.name: "edit"
                        outlined: true
                    }

                    MeoFAB {
                        type: "extended"
                        size: "small"
                        text: "Toggled / Selected"
                        icon.name: "check"
                        selected: true
                    }
                }
            }
        }
    }

    // 🌟 Sizing scale variants (XS to XL)
    ShowcaseSection {
        title: "Expressive XS-XL Sizing Scale"
        subtitle: "A 5-step expressive scale for buttons and chips mapping container heights from 24dp to 72dp."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoText {
                text: "MeoButton Sizing Scale"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                MeoButton { text: "XS Button"; size: "xs"; type: "filled" }
                MeoButton { text: "S Button"; size: "s"; type: "filled" }
                MeoButton { text: "M Button"; size: "m"; type: "filled" }
                MeoButton { text: "L Button"; size: "l"; type: "filled" }
                MeoButton { text: "XL Button"; size: "xl"; type: "filled" }
            }

            MeoText {
                text: "MeoChip Sizing Scale"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                MeoChip { label: "XS Chip"; size: "xs"; icon: "tag" }
                MeoChip { label: "S Chip"; size: "s"; icon: "tag" }
                MeoChip { label: "M Chip"; size: "m"; icon: "tag" }
                MeoChip { label: "L Chip"; size: "l"; icon: "tag" }
                MeoChip { label: "XL Chip"; size: "xl"; icon: "tag" }
            }
        }
    }

    // 🌟 Comprehensive Shape Gallery
    ShowcaseSection {
        title: "Comprehensive Shape Gallery"
        subtitle: "MD3 Expressive shapes configured via MeoShape, supporting organic curves and unique geometries."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            readonly property var shapes: [
                { name: "Squircle", type: "squircle" },
                { name: "Clover", type: "clover" },
                { name: "Star", type: "star" },
                { name: "Heart", type: "heart" },
                { name: "Sparkle", type: "sparkle" },
                { name: "Shield", type: "shield" },
                { name: "Flower", type: "flower" },
                { name: "Bubble", type: "bubble" },
                { name: "Tag", type: "tag" },
                { name: "Pill", type: "pill" },
                { name: "Circle", type: "circle" },
                { name: "Hexagon", type: "hexagon" },
                { name: "Octagon", type: "octagon" },
                { name: "Diamond", type: "diamond" },
                { name: "Pentagon", type: "pentagon" }
            ]

            Repeater {
                model: parent.shapes
                delegate: Column {
                    spacing: MeoTheme.space4
                    width: 80 * MeoTheme.globalScale

                    MeoShape {
                        width: 72 * MeoTheme.globalScale
                        height: 72 * MeoTheme.globalScale
                        type: modelData.type
                        color: MeoTheme.primaryContainer
                        radius: 16 * MeoTheme.globalScale

                        MeoText {
                            anchors.centerIn: parent
                            text: modelData.type.substring(0, 2).toUpperCase()
                            typeRole: "label"
                            typeSize: "small"
                            emphasized: true
                            color: MeoTheme.contentOnPrimaryContainer
                        }
                    }

                    MeoText {
                        width: parent.width
                        text: modelData.name
                        typeRole: "label"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurfaceVariant
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    // 🌟 Thickness Variants Section
    ShowcaseSection {
        title: "Thickness Variants"
        subtitle: "Visual examples of semantic outline thickness tokens from MeoTheme."
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Thin Box
            Rectangle {
                Layout.fillWidth: true
                height: 100 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.primary
                border.width: MeoTheme.strokeWidthThin

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText {
                        text: "strokeWidthThin"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    MeoText {
                        text: "Value: 1dp"
                        typeRole: "body"
                        typeSize: "small"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Medium Box
            Rectangle {
                Layout.fillWidth: true
                height: 100 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.primary
                border.width: MeoTheme.strokeWidthMedium

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText {
                        text: "strokeWidthMedium"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    MeoText {
                        text: "Value: 2dp"
                        typeRole: "body"
                        typeSize: "small"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Thick Box
            Rectangle {
                Layout.fillWidth: true
                height: 100 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.primary
                border.width: MeoTheme.strokeWidthThick

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText {
                        text: "strokeWidthThick"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                        horizontalAlignment: Text.AlignHCenter
                    }
                    MeoText {
                        text: "Value: 3dp"
                        typeRole: "body"
                        typeSize: "small"
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }
        }
    }

    // 🌟 Bouncy Interactive Cards
    ShowcaseSection {
        title: "Bouncy Interactive Cards"
        subtitle: "MD3 Cards with bouncy=true scale smoothly on hover and press, utilizing standard overshoot curves."
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoCard {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "elevated"
                interactive: true
                bouncy: true

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Elevated Card"; typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: "Interactive & Bouncy"; typeRole: "body"; typeSize: "small" }
                }
            }

            MeoCard {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "filled"
                interactive: true
                bouncy: true

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Filled Card"; typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: "Interactive & Bouncy"; typeRole: "body"; typeSize: "small" }
                }
            }

            MeoCard {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "outlined"
                interactive: true
                bouncy: true

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Outlined Card"; typeRole: "title"; typeSize: "small"; emphasized: true }
                    MeoText { text: "Interactive & Bouncy"; typeRole: "body"; typeSize: "small" }
                }
            }
        }
    }

    // 🌟 Account Switcher Widget Integration
    ShowcaseSection {
        title: "Account Switcher Widget"
        subtitle: "MD3 Expressive account identity and switching component with dynamic menu states."
        width: parent.width

        RowLayout {
            width: parent.width
            Layout.alignment: Qt.AlignHCenter

            MeoAccountSwitcher {
                Layout.alignment: Qt.AlignHCenter
                model: [
                    { name: "Meo Developer", email: "dev@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Meo" },
                    { name: "Design Lead", email: "design@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Design" }
                ]
            }
        }
    }

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
