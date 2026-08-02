import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: patternsPage
    categoryId: "chips"

    // 🌟 Chip Sizing Scale Section (大小与尺寸配置)
    ShowcaseSection {
        title: "Chip Sizing Scale (大小与尺寸配置)"
        subtitle: "MD3 Chip components utilizing a 5-step size variant scale (XS to XL) mapped to heights from 24dp to 48dp, with adaptive font scaling and internal padding rules."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                // XS Chip
                Column {
                    spacing: MeoTheme.space4
                    MeoChip { size: "xs"; label: "XS Size"; icon: "tag" }
                    MeoText { text: "Height: 24dp"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }

                // S Chip
                Column {
                    spacing: MeoTheme.space4
                    MeoChip { size: "s"; label: "S Size"; icon: "tag"; selected: true }
                    MeoText { text: "Height: 28dp"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }

                // M Chip (Standard)
                Column {
                    spacing: MeoTheme.space4
                    MeoChip { size: "m"; label: "M Size (Std)"; icon: "tag" }
                    MeoText { text: "Height: 32dp"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }

                // L Chip
                Column {
                    spacing: MeoTheme.space4
                    MeoChip { size: "l"; label: "L Size"; icon: "tag"; selected: true }
                    MeoText { text: "Height: 40dp"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }

                // XL Chip
                Column {
                    spacing: MeoTheme.space4
                    MeoChip { size: "xl"; label: "XL Size"; icon: "tag" }
                    MeoText { text: "Height: 48dp"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }
        }
    }

    // 🌟 Chip States Matrix Section (交互状态矩阵)
    ShowcaseSection {
        title: "Chip Interactive States Matrix (交互状态矩阵)"
        subtitle: "A comprehensive states matrix showcasing Assist, Filter, Input, and Suggestion chips under Normal, Checked/Selected, Closable/Removable, and Disabled states."
        width: parent.width

        GridLayout {
            columns: 5
            rowSpacing: MeoTheme.space16
            columnSpacing: MeoTheme.space16
            width: parent.width

            // Header labels
            Item { Layout.preferredWidth: 100 * MeoTheme.globalScale }
            MeoText { text: "Normal State"; typeRole: "label"; typeSize: "medium"; emphasized: true; Layout.alignment: Qt.AlignHCenter }
            MeoText { text: "Selected/Checked"; typeRole: "label"; typeSize: "medium"; emphasized: true; Layout.alignment: Qt.AlignHCenter }
            MeoText { text: "Closable/Remove"; typeRole: "label"; typeSize: "medium"; emphasized: true; Layout.alignment: Qt.AlignHCenter }
            MeoText { text: "Disabled State"; typeRole: "label"; typeSize: "medium"; emphasized: true; Layout.alignment: Qt.AlignHCenter }

            // Assist Chips Row
            MeoText { text: "Assist Chip"; typeRole: "label"; typeSize: "medium"; emphasized: true; Layout.preferredWidth: 100 * MeoTheme.globalScale }
            MeoChip { type: "assist"; label: "Directions"; icon: "directions"; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "assist"; label: "Selected"; icon: "directions"; selected: true; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "assist"; label: "Closable"; icon: "directions"; closable: true; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "assist"; label: "Disabled"; icon: "directions"; enabled: false; Layout.alignment: Qt.AlignHCenter }

            // Filter Chips Row
            MeoText { text: "Filter Chip"; typeRole: "label"; typeSize: "medium"; emphasized: true; Layout.preferredWidth: 100 * MeoTheme.globalScale }
            MeoChip { type: "filter"; label: "Photos"; icon: "photo"; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "filter"; label: "Selected"; icon: "photo"; selected: true; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "filter"; label: "Closable"; icon: "photo"; closable: true; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "filter"; label: "Disabled"; icon: "photo"; enabled: false; Layout.alignment: Qt.AlignHCenter }

            // Input Chips Row
            MeoText { text: "Input Chip"; typeRole: "label"; typeSize: "medium"; emphasized: true; Layout.preferredWidth: 100 * MeoTheme.globalScale }
            MeoChip { type: "input"; label: "Avery"; icon: "person"; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "input"; label: "Selected"; icon: "person"; selected: true; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "input"; label: "Closable"; icon: "person"; closable: true; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "input"; label: "Disabled"; icon: "person"; enabled: false; Layout.alignment: Qt.AlignHCenter }

            // Suggestion Chips Row
            MeoText { text: "Suggestion Chip"; typeRole: "label"; typeSize: "medium"; emphasized: true; Layout.preferredWidth: 100 * MeoTheme.globalScale }
            MeoChip { type: "suggestion"; label: "Performance"; icon: "speed"; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "suggestion"; label: "Selected"; icon: "speed"; selected: true; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "suggestion"; label: "Closable"; icon: "speed"; closable: true; Layout.alignment: Qt.AlignHCenter }
            MeoChip { type: "suggestion"; label: "Disabled"; icon: "speed"; enabled: false; Layout.alignment: Qt.AlignHCenter }
        }
    }

    // 🌟 Chip Border Thickness Section (粗细与轮廓变体)
    ShowcaseSection {
        title: "Chip Outline Thickness (粗细与轮廓变体)"
        subtitle: "Showcasing border styling customized via MeoTheme semantic outline thickness tokens (`strokeWidthThin`, `strokeWidthMedium`, `strokeWidthThick`)."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            // Thin border (default)
            Column {
                spacing: MeoTheme.space4
                MeoChip {
                    label: "strokeWidthThin"
                    icon: "border_all"
                    outlineColor: MeoTheme.outline
                }
                MeoText { text: "1dp Thin Outline"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
            }

            // Medium border
            Column {
                spacing: MeoTheme.space4
                MeoChip {
                    id: mediumBorderChip
                    label: "strokeWidthMedium"
                    icon: "border_style"
                    background: Rectangle {
                        radius: 8 * MeoTheme.globalScale
                        color: "transparent"
                        border.color: MeoTheme.primary
                        border.width: MeoTheme.strokeWidthMedium
                    }
                }
                MeoText { text: "2dp Medium Outline"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
            }

            // Thick border
            Column {
                spacing: MeoTheme.space4
                MeoChip {
                    id: thickBorderChip
                    label: "strokeWidthThick"
                    icon: "border_outer"
                    background: Rectangle {
                        radius: 8 * MeoTheme.globalScale
                        color: "transparent"
                        border.color: MeoTheme.primary
                        border.width: MeoTheme.strokeWidthThick
                    }
                }
                MeoText { text: "3dp Thick Outline"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
            }
        }
    }
}
