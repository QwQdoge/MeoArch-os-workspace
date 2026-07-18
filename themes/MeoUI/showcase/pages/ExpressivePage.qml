import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: expressivePage
    categoryId: "expressive"

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
}
