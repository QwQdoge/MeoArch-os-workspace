import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: layoutsLabPage
    categoryId: "layouts"

    // 🌟 1. Responsive Grid & Breakpoint Classes (自适应断点与网格分配)
    ShowcaseSection {
        title: "Responsive Grid & Breakpoint Classes"
        subtitle: "MD3 adaptive layout grid system showing how column counts and margins adapt fluidly using MeoWindowMetrics size classes."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Dynamic breakpoint visualizer card
            Rectangle {
                Layout.fillWidth: true
                height: 100 * MeoTheme.globalScale
                color: MeoTheme.surfaceContainer
                radius: MeoTheme.shapeMedium
                border.color: MeoTheme.primary
                border.width: MeoTheme.strokeWidthMedium

                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: MeoTheme.space4

                    MeoText {
                        text: "Active Window Size Class: LARGE (Default Simulation)"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                        color: MeoTheme.primary
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MeoText {
                        text: "Recommended Margins: 32dp | Column Count: 12 Columns | Pane Mode: Two-Pane Supported"
                        typeRole: "body"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurfaceVariant
                        horizontalAlignment: Text.AlignHCenter
                    }
                }
            }

            // Simulated Columns
            RowLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                Repeater {
                    model: 4
                    delegate: Rectangle {
                        Layout.fillWidth: true
                        height: 60 * MeoTheme.globalScale
                        color: MeoTheme.primaryContainer
                        radius: MeoTheme.shapeSmall

                        MeoText {
                            anchors.centerIn: parent
                            text: "Pane " + (index + 1)
                            typeRole: "label"
                            typeSize: "medium"
                            color: MeoTheme.contentOnPrimaryContainer
                            emphasized: true
                        }
                    }
                }
            }
        }
    }

    // 🌟 2. Aspect Ratio & Grid Proportions (容器比例布局)
    ShowcaseSection {
        title: "Layout Aspect Ratios & Proportions"
        subtitle: "Demonstrates container proportions for horizontal/vertical split layouts and standard image grids."
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // 16:9 Aspect Ratio Card
            MeoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 180 * MeoTheme.globalScale
                type: "outlined"

                Column {
                    anchors.fill: parent
                    anchors.margins: MeoTheme.space16
                    spacing: MeoTheme.space8

                    MeoText {
                        text: "16:9 Proportions"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                    }

                    Rectangle {
                        width: parent.width
                        height: width * (9/16)
                        color: MeoTheme.surfaceContainerHighest
                        radius: MeoTheme.shapeSmall

                        MeoText {
                            anchors.centerIn: parent
                            text: "Cinematic Aspect Ratio"
                            typeRole: "body"
                            typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                    }
                }
            }

            // 4:3 Aspect Ratio Card
            MeoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 180 * MeoTheme.globalScale
                type: "outlined"

                Column {
                    anchors.fill: parent
                    anchors.margins: MeoTheme.space16
                    spacing: MeoTheme.space8

                    MeoText {
                        text: "4:3 Proportions"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                    }

                    Rectangle {
                        width: parent.width
                        height: width * (3/4)
                        color: MeoTheme.surfaceContainerHighest
                        radius: MeoTheme.shapeSmall

                        MeoText {
                            anchors.centerIn: parent
                            text: "Standard Aspect Ratio"
                            typeRole: "body"
                            typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                    }
                }
            }

            // 1:1 Aspect Ratio Card
            MeoCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 180 * MeoTheme.globalScale
                type: "outlined"

                Column {
                    anchors.fill: parent
                    anchors.margins: MeoTheme.space16
                    spacing: MeoTheme.space8

                    MeoText {
                        text: "1:1 Proportions"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                    }

                    Rectangle {
                        width: parent.width
                        height: width
                        color: MeoTheme.surfaceContainerHighest
                        radius: MeoTheme.shapeSmall

                        MeoText {
                            anchors.centerIn: parent
                            text: "Square Aspect Ratio"
                            typeRole: "body"
                            typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                    }
                }
            }
        }
    }

    // 🌟 3. Connected Corner Rounding Strategies (段组流与自适应圆角)
    ShowcaseSection {
        title: "Segmented Rounding Strategies (段组流与自适应圆角)"
        subtitle: "Using connected corner patterns (top, middle, bottom, all, none) to join list items into unified, clean layouts."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoText {
                text: "Interconnected List Group"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Column {
                width: parent.width
                spacing: 0

                MeoListItem {
                    width: parent.width
                    text: "Top Item (Top Corner Rounding)"
                    supportingText: "roundingStrategy: 'top' | Connects to the next item."
                    leadingIcon: "wifi"
                    isSegmented: true
                    roundingStrategy: "top"
                }

                MeoListItem {
                    width: parent.width
                    text: "Middle Item (No Rounding)"
                    supportingText: "roundingStrategy: 'middle' | Straight vertical edges."
                    leadingIcon: "bluetooth"
                    isSegmented: true
                    roundingStrategy: "middle"
                }

                MeoListItem {
                    width: parent.width
                    text: "Bottom Item (Bottom Corner Rounding)"
                    supportingText: "roundingStrategy: 'bottom' | Graceful bottom edges."
                    leadingIcon: "vpn_key"
                    isSegmented: true
                    roundingStrategy: "bottom"
                }
            }
        }
    }
}
