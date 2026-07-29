import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: selectionPage
    categoryId: "selection"

    // 🌟 Sizing scale variants (XS to XL) for Checkboxes, Radio Buttons, and Switches
    ShowcaseSection {
        title: "Selection Component XS-XL Sizing Scale"
        subtitle: "Demonstrates 5-step sizing scales mapped from compact to expansive layouts, utilizing variable labels."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Checkboxes Size Scale
            MeoText {
                text: "MeoCheckbox Sizes"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }
            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16
                MeoCheckbox { label: "XS Checkbox"; size: "xs"; checked: true }
                MeoCheckbox { label: "S Checkbox"; size: "s"; checked: true }
                MeoCheckbox { label: "M Checkbox"; size: "m"; checked: true }
                MeoCheckbox { label: "L Checkbox"; size: "l"; checked: true }
                MeoCheckbox { label: "XL Checkbox"; size: "xl"; checked: true }
            }

            // Radio Buttons Size Scale
            MeoText {
                text: "MeoRadioButton Sizes"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }
            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16
                MeoRadioButton { label: "XS Radio"; size: "xs"; checked: true }
                MeoRadioButton { label: "S Radio"; size: "s"; checked: true }
                MeoRadioButton { label: "M Radio"; size: "m"; checked: true }
                MeoRadioButton { label: "L Radio"; size: "l"; checked: true }
                MeoRadioButton { label: "XL Radio"; size: "xl"; checked: true }
            }

            // Switches Size Scale
            MeoText {
                text: "MeoSwitch Sizes"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }
            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16
                MeoSwitch { label: "XS Switch"; size: "xs"; checked: true }
                MeoSwitch { label: "S Switch"; size: "s"; checked: true }
                MeoSwitch { label: "M Switch"; size: "m"; checked: true }
                MeoSwitch { label: "L Switch"; size: "l"; checked: true }
                MeoSwitch { label: "XL Switch"; size: "xl"; checked: true }
            }
        }
    }

    // 🌟 Thickness Variants (Thin, Medium, Thick)
    ShowcaseSection {
        title: "Thickness and Outline Variants"
        subtitle: "Visualizes the semantic outline thickness tokens from MeoTheme applied directly to Selection controls."
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
                    spacing: MeoTheme.space8

                    MeoText {
                        text: "Thin (strokeWidthThin: 1dp)"
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: true
                    }
                    MeoCheckbox { label: "Thin Outline"; thickness: "thin"; checked: false }
                    MeoRadioButton { label: "Thin Outline"; thickness: "thin"; checked: false }
                    MeoSwitch { label: "Thin Track"; thickness: "thin"; checked: false }
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
                    spacing: MeoTheme.space8

                    MeoText {
                        text: "Medium (strokeWidthMedium: 2dp)"
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: true
                    }
                    MeoCheckbox { label: "Medium Outline"; thickness: "medium"; checked: false }
                    MeoRadioButton { label: "Medium Outline"; thickness: "medium"; checked: false }
                    MeoSwitch { label: "Medium Track"; thickness: "medium"; checked: false }
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
                    spacing: MeoTheme.space8

                    MeoText {
                        text: "Thick (strokeWidthThick: 3dp)"
                        typeRole: "label"
                        typeSize: "medium"
                        emphasized: true
                    }
                    MeoCheckbox { label: "Thick Outline"; thickness: "thick"; checked: false }
                    MeoRadioButton { label: "Thick Outline"; thickness: "thick"; checked: false }
                    MeoSwitch { label: "Thick Track"; thickness: "thick"; checked: false }
                }
            }
        }
    }

    // 🌟 Interaction States (Normal, Checked, Indeterminate, Error, Disabled, Focused)
    ShowcaseSection {
        title: "Interactive States and Feedback"
        subtitle: "A detailed matrix highlighting complete state coverage for MD3 compliance."
        width: parent.width

        GridLayout {
            width: parent.width
            columns: 3
            columnSpacing: MeoTheme.space24
            rowSpacing: MeoTheme.space24

            // Checkbox States Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText { text: "MeoCheckbox States"; typeRole: "title"; typeSize: "small"; emphasized: true }
                MeoCheckbox { label: "Normal (Unchecked)"; checked: false }
                MeoCheckbox { label: "Normal (Checked)"; checked: true }
                MeoCheckbox { label: "Indeterminate"; indeterminate: true }
                MeoCheckbox { label: "Error State"; isError: true; errorText: "Invalid choice!" }
                MeoCheckbox { label: "With Helper Text"; helperText: "This is optional." }
                MeoCheckbox { label: "Disabled State"; enabled: false; checked: true }
            }

            // Radio Button States Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText { text: "MeoRadioButton States"; typeRole: "title"; typeSize: "small"; emphasized: true }
                MeoRadioButton { label: "Normal (Unchecked)"; checked: false }
                MeoRadioButton { label: "Normal (Checked)"; checked: true }
                MeoRadioButton { label: "Error State"; isError: true; errorText: "Please select one!" }
                MeoRadioButton { label: "With Helper Text"; helperText: "Choose wisely." }
                MeoRadioButton { label: "Disabled (Unchecked)"; enabled: false; checked: false }
                MeoRadioButton { label: "Disabled (Checked)"; enabled: false; checked: true }
            }

            // Switch States Column
            ColumnLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoText { text: "MeoSwitch States"; typeRole: "title"; typeSize: "small"; emphasized: true }
                MeoSwitch { label: "Normal (Unchecked)"; checked: false }
                MeoSwitch { label: "Normal (Checked)"; checked: true }
                MeoSwitch { label: "Without Thumb Icon"; checked: true; showIcon: false }
                MeoSwitch { label: "Error State"; isError: true; errorText: "Turn off immediately!" }
                MeoSwitch { label: "With Helper Text"; helperText: "Controls system power." }
                MeoSwitch { label: "Disabled State"; enabled: false; checked: true }
            }
        }
    }
}
