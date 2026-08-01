import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: buttonsPage
    categoryId: "actions"

    // 🌟 Sizing scale variants (XS to XL) for Buttons and Icon Buttons
    ShowcaseSection {
        title: "Button XS-XL Sizing Scale (大小变体)"
        subtitle: "A 5-step sizing scale mapped from compact to expansive layouts, utilizing variable labels."
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
                text: "MeoIconButton Sizing Scale"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                MeoIconButton { icon.name: "favorite"; size: "xs"; type: "filled" }
                MeoIconButton { icon.name: "favorite"; size: "s"; type: "filled" }
                MeoIconButton { icon.name: "favorite"; size: "m"; type: "filled" }
                MeoIconButton { icon.name: "favorite"; size: "l"; type: "filled" }
                MeoIconButton { icon.name: "favorite"; size: "xl"; type: "filled" }
            }
        }
    }

    // 🌟 Proportions & Shape Gallery
    ShowcaseSection {
        title: "Expressive Shapes & Proportions (比例与形状)"
        subtitle: "MD3 Expressive shapes configured via shape property, supporting different organic curves and geometries."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            MeoText {
                text: "MeoButton Shape Variants"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                MeoButton { text: "Round Shape"; shape: "round"; type: "filled" }
                MeoButton { text: "Square Shape"; shape: "square"; type: "filled" }
                MeoButton { text: "Squircle Shape"; shape: "squircle"; type: "filled" }
                MeoButton { text: "Hexagon Shape"; shape: "hexagon"; type: "filled" }
                MeoButton { text: "Clover Shape"; shape: "clover"; type: "filled" }
                MeoButton { text: "Heart Shape"; shape: "heart"; type: "filled" }
            }

            MeoText {
                text: "MeoIconButton Shape Variants"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                MeoIconButton { icon.name: "palette"; shape: "circle"; type: "tonal" }
                MeoIconButton { icon.name: "palette"; shape: "square"; type: "tonal" }
                MeoIconButton { icon.name: "palette"; shape: "squircle"; type: "tonal" }
                MeoIconButton { icon.name: "palette"; shape: "hexagon"; type: "tonal" }
                MeoIconButton { icon.name: "palette"; shape: "clover"; type: "tonal" }
                MeoIconButton { icon.name: "palette"; shape: "sparkle"; type: "tonal" }
                MeoIconButton { icon.name: "palette"; shape: "heart"; type: "tonal" }
            }
        }
    }

    // 🌟 Thickness Variants (Thin, Medium, Thick)
    ShowcaseSection {
        title: "Outline Thickness Variants (粗细变体)"
        subtitle: "Visualizes the semantic outline thickness tokens from MeoTheme applied directly to Outlined action controls."
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Thin Panel
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.primary
                border.width: MeoTheme.strokeWidthThin

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space12

                    MeoText {
                        text: "Thin (strokeWidthThin: 1dp)"
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: true
                    }
                    MeoButton {
                        text: "Thin Outline"
                        type: "outlined"
                        thickness: "thin"
                    }
                    MeoIconButton {
                        icon.name: "share"
                        type: "outlined"
                        thickness: "thin"
                    }
                }
            }

            // Medium Panel
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.primary
                border.width: MeoTheme.strokeWidthMedium

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space12

                    MeoText {
                        text: "Medium (strokeWidthMedium: 2dp)"
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: true
                    }
                    MeoButton {
                        text: "Medium Outline"
                        type: "outlined"
                        thickness: "medium"
                    }
                    MeoIconButton {
                        icon.name: "share"
                        type: "outlined"
                        thickness: "medium"
                    }
                }
            }

            // Thick Panel
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 180 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainerLow
                border.color: MeoTheme.primary
                border.width: MeoTheme.strokeWidthThick

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space12

                    MeoText {
                        text: "Thick (strokeWidthThick: 3dp)"
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: true
                    }
                    MeoButton {
                        text: "Thick Outline"
                        type: "outlined"
                        thickness: "thick"
                    }
                    MeoIconButton {
                        icon.name: "share"
                        type: "outlined"
                        thickness: "thick"
                    }
                }
            }
        }
    }

    // 🌟 Interaction States Matrix (Normal, Hovered, Pressed, Selected, Checked, Disabled, Loading)
    ShowcaseSection {
        title: "Button States & Interactive Feedback (多维度状态)"
        subtitle: "A detailed matrix highlighting complete state coverage for MD3 actions compliance."
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 3
            columnSpacing: MeoTheme.space24
            rowSpacing: MeoTheme.space24

            // Filled Button States Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText { text: "MeoButton (Filled) States"; typeRole: "title"; typeSize: "small"; emphasized: true }
                MeoButton { text: "Normal State"; type: "filled" }
                MeoButton { text: "Selected State"; type: "filled"; selected: true }
                MeoButton { text: "Vibrant State"; type: "filled"; vibrant: true }
                MeoButton { text: "Disabled State"; type: "filled"; enabled: false }
                MeoButton { text: "Loading State"; type: "filled"; loading: true; loadingWithContainer: true }
            }

            // Outlined Button States Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText { text: "MeoButton (Outlined) States"; typeRole: "title"; typeSize: "small"; emphasized: true }
                MeoButton { text: "Normal State"; type: "outlined" }
                MeoButton { text: "Selected State"; type: "outlined"; selected: true }
                MeoButton { text: "Disabled State"; type: "outlined"; enabled: false }
                MeoButton { text: "Loading State"; type: "outlined"; loading: true }
                MeoButton { text: "Bouncy & Interactive"; type: "outlined"; bouncy: true }
            }

            // Icon Button States Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText { text: "MeoIconButton States"; typeRole: "title"; typeSize: "small"; emphasized: true }
                RowLayout {
                    spacing: MeoTheme.space12
                    MeoIconButton { icon.name: "favorite"; type: "filled" }
                    MeoText { text: "Filled Normal"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
                RowLayout {
                    spacing: MeoTheme.space12
                    MeoIconButton { icon.name: "favorite"; type: "tonal"; badgeText: "5" }
                    MeoText { text: "Tonal with Badge"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
                RowLayout {
                    spacing: MeoTheme.space12
                    MeoIconButton { icon.name: "notifications"; type: "standard"; badgeDot: true }
                    MeoText { text: "Standard with Badge Dot"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
                RowLayout {
                    spacing: MeoTheme.space12
                    MeoIconButton { icon.name: "settings"; type: "standard"; enabled: false }
                    MeoText { text: "Disabled State"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }
        }
    }
}
