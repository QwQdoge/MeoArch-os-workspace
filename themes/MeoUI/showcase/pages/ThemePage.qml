import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: themePage
    categoryId: "foundations"

    // 🌟 1. Material 3 Color Scheme & Content Pairs (色彩角色与内容配对)
    ShowcaseSection {
        title: "Material 3 Color Roles & Content Pairs"
        subtitle: "A comprehensive grid demonstrating semantic color roles with their corresponding on-color content pairs."
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 4
            columnSpacing: MeoTheme.space16
            rowSpacing: MeoTheme.space16

            // Row 1: Brand Accent Colors (Primary & Secondary)
            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.primary
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Primary"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnPrimary; emphasized: true }
                    MeoText { text: MeoTheme.primary; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnPrimary }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.primaryContainer
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Primary Container"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnPrimaryContainer; emphasized: true }
                    MeoText { text: MeoTheme.primaryContainer; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnPrimaryContainer }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.secondary
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Secondary"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnSecondary; emphasized: true }
                    MeoText { text: MeoTheme.secondary; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSecondary }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.secondaryContainer
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Secondary Container"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnSecondaryContainer; emphasized: true }
                    MeoText { text: MeoTheme.secondaryContainer; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSecondaryContainer }
                }
            }

            // Row 2: Tertiary & Error Colors
            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.tertiary
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Tertiary"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnTertiary; emphasized: true }
                    MeoText { text: MeoTheme.tertiary; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnTertiary }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.tertiaryContainer
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Tertiary Container"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnTertiaryContainer; emphasized: true }
                    MeoText { text: MeoTheme.tertiaryContainer; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnTertiaryContainer }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.error
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Error"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnError; emphasized: true }
                    MeoText { text: MeoTheme.error; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnError }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.errorContainer
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Error Container"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnErrorContainer; emphasized: true }
                    MeoText { text: MeoTheme.errorContainer; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnErrorContainer }
                }
            }

            // Row 3: Surface Containers
            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.surfaceContainerLowest
                radius: MeoTheme.shapeMedium
                border.color: MeoTheme.outlineVariant
                border.width: MeoTheme.strokeWidthThin
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Surface Lowest"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnSurface; emphasized: true }
                    MeoText { text: MeoTheme.surfaceContainerLowest; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.surfaceContainerLow
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Surface Low"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnSurface; emphasized: true }
                    MeoText { text: MeoTheme.surfaceContainerLow; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.surfaceContainer
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Surface Standard"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnSurface; emphasized: true }
                    MeoText { text: MeoTheme.surfaceContainer; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 80 * MeoTheme.globalScale
                color: MeoTheme.surfaceContainerHighest
                radius: MeoTheme.shapeMedium
                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Surface Highest"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnSurface; emphasized: true }
                    MeoText { text: MeoTheme.surfaceContainerHighest; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }
        }
    }

    // 🌟 2. Typography Scale & Variable Weights (排版系统与字重阶梯)
    ShowcaseSection {
        title: "Typography Scale & Brand Identity"
        subtitle: "MD3 type scale mapping brand headers and clean plain text layouts. Highlighting variable weights."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            // Typography Samples
            ColumnLayout {
                spacing: MeoTheme.space12

                MeoText {
                    text: "Brand / Display Font (Comfortaa)"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                MeoText {
                    text: "Comfortaa Brand Title"
                    typeRole: "title"
                    typeSize: "big"
                    color: MeoTheme.primary
                }
            }

            ColumnLayout {
                spacing: MeoTheme.space12

                MeoText {
                    text: "Standard UI Scales (Roboto Plain)"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                RowLayout {
                    spacing: MeoTheme.space24
                    MeoText { text: "Title Big"; typeRole: "title"; typeSize: "big"; Layout.preferredWidth: 150 * MeoTheme.globalScale }
                    MeoText { text: "MeoUI Material Design Typography System"; typeRole: "title"; typeSize: "big"; color: MeoTheme.contentOnSurface }
                }

                RowLayout {
                    spacing: MeoTheme.space24
                    MeoText { text: "Title Medium"; typeRole: "title"; typeSize: "medium"; Layout.preferredWidth: 150 * MeoTheme.globalScale }
                    MeoText { text: "Modern typography transitions and scale scales."; typeRole: "title"; typeSize: "medium"; color: MeoTheme.contentOnSurface }
                }

                RowLayout {
                    spacing: MeoTheme.space24
                    MeoText { text: "Body Big"; typeRole: "body"; typeSize: "big"; Layout.preferredWidth: 150 * MeoTheme.globalScale }
                    MeoText { text: "The primary body reading size designed for optimal readability and balanced paragraph sizing."; typeRole: "body"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant }
                }

                RowLayout {
                    spacing: MeoTheme.space24
                    MeoText { text: "Body Medium"; typeRole: "body"; typeSize: "medium"; Layout.preferredWidth: 150 * MeoTheme.globalScale }
                    MeoText { text: "The default body description text. Excellent clean layout presentation across multiple lines."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                }

                RowLayout {
                    spacing: MeoTheme.space24
                    MeoText { text: "Label Big"; typeRole: "label"; typeSize: "big"; Layout.preferredWidth: 150 * MeoTheme.globalScale }
                    MeoText { text: "BUTTON / COMMAND LABEL"; typeRole: "label"; typeSize: "big"; color: MeoTheme.primary; emphasized: true }
                }

                RowLayout {
                    spacing: MeoTheme.space24
                    MeoText { text: "Label Small"; typeRole: "label"; typeSize: "small"; Layout.preferredWidth: 150 * MeoTheme.globalScale }
                    MeoText { text: "CAPTIONS AND DENSE GRAPH METADATA"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }
        }
    }

    // 🌟 3. Spacing Grid System (网格间距系统)
    ShowcaseSection {
        title: "Spacing Grid System"
        subtitle: "A baseline visualizer representing precise spacing values scaled by global scale to enforce consistency."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            readonly property var spaceTokens: [
                { name: "space4", value: MeoTheme.space4, pixels: "4dp" },
                { name: "space8", value: MeoTheme.space8, pixels: "8dp" },
                { name: "space12", value: MeoTheme.space12, pixels: "12dp" },
                { name: "space16", value: MeoTheme.space16, pixels: "16dp" },
                { name: "space24", value: MeoTheme.space24, pixels: "24dp" },
                { name: "space32", value: MeoTheme.space32, pixels: "32dp" },
                { name: "space40", value: MeoTheme.space40, pixels: "40dp" },
                { name: "space48", value: MeoTheme.space48, pixels: "48dp" }
            ]

            Repeater {
                model: parent.spaceTokens
                delegate: Rectangle {
                    width: 110 * MeoTheme.globalScale
                    height: 120 * MeoTheme.globalScale
                    color: MeoTheme.surfaceContainerLow
                    radius: MeoTheme.shapeSmall
                    border.color: MeoTheme.outlineVariant

                    Column {
                        anchors.centerIn: parent
                        spacing: MeoTheme.space8

                        // Spacing block representation
                        Rectangle {
                            width: modelData.value
                            height: modelData.value
                            color: MeoTheme.primary
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MeoText {
                            text: modelData.name
                            typeRole: "label"
                            typeSize: "small"
                            emphasized: true
                            anchors.horizontalCenter: parent.horizontalCenter
                        }

                        MeoText {
                            text: modelData.pixels
                            typeRole: "body"
                            typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                            anchors.horizontalCenter: parent.horizontalCenter
                        }
                    }
                }
            }
        }
    }

    // 🌟 4. State Layer Opacity & Interactive States (交互状态度量)
    ShowcaseSection {
        title: "MD3 State Layer Opacities"
        subtitle: "Demonstrates baseline opacity values applied interactively to standard content cards."
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Normal
            Rectangle {
                Layout.fillWidth: true
                height: 100 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainer
                border.color: MeoTheme.outlineVariant
                border.width: MeoTheme.strokeWidthThin

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Normal Base"; typeRole: "label"; typeSize: "medium"; emphasized: true }
                    MeoText { text: "No State Layer"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }

            // Hovered
            Rectangle {
                Layout.fillWidth: true
                height: 100 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainer
                border.color: MeoTheme.outlineVariant
                border.width: MeoTheme.strokeWidthThin

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: MeoTheme.primary
                    opacity: MeoTheme.stateOpacityHover
                }

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Hovered"; typeRole: "label"; typeSize: "medium"; emphasized: true }
                    MeoText { text: "Opacity: 10%"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }

            // Focused
            Rectangle {
                Layout.fillWidth: true
                height: 100 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainer
                border.color: MeoTheme.outlineVariant
                border.width: MeoTheme.strokeWidthThin

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: MeoTheme.primary
                    opacity: MeoTheme.stateOpacityFocus
                }

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Focused"; typeRole: "label"; typeSize: "medium"; emphasized: true }
                    MeoText { text: "Opacity: 12%"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }

            // Pressed
            Rectangle {
                Layout.fillWidth: true
                height: 100 * MeoTheme.globalScale
                radius: MeoTheme.shapeMedium
                color: MeoTheme.surfaceContainer
                border.color: MeoTheme.outlineVariant
                border.width: MeoTheme.strokeWidthThin

                Rectangle {
                    anchors.fill: parent
                    radius: parent.radius
                    color: MeoTheme.primary
                    opacity: MeoTheme.stateOpacityPressed
                }

                Column {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "Pressed"; typeRole: "label"; typeSize: "medium"; emphasized: true }
                    MeoText { text: "Opacity: 14%"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }
        }
    }
}
