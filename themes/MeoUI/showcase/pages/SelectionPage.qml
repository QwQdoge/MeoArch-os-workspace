import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    contentHeight: selectionColumn.implicitHeight + 64 * MeoTheme.globalScale
    clip: true
    Column {
        id: selectionColumn
        padding: 24 * MeoTheme.globalScale
        spacing: 32 * MeoTheme.globalScale
        width: parent.width

        // Checkboxes
        Column {
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Checkboxes"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
            Row {
                spacing: 12 * MeoTheme.globalScale
                MeoCheckbox { checked: true; label: "Checked" }
                MeoCheckbox { checked: false; label: "Unchecked" }
                MeoCheckbox { indeterminate: true; label: "Indeterminate" }
            }
        }

        // Switches
        Column {
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Switches"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
            Row {
                spacing: 12 * MeoTheme.globalScale
                MeoSwitch { checked: true; label: "On" }
                MeoSwitch { checked: false; label: "Off" }
                MeoSwitch { checked: true; icon: "check"; label: "With Icon" }
            }
        }

        // Radio Buttons
        Column {
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Radio Buttons"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
            Row {
                spacing: 12 * MeoTheme.globalScale
                MeoRadioButton { checked: true; label: "Option A" }
                MeoRadioButton { checked: false; label: "Option B" }
            }
        }

        // Sliders
        Column {
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Sliders"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
            Column {
                spacing: 24 * MeoTheme.globalScale
                MeoSlider {
                    width: 300 * MeoTheme.globalScale
                    value: 40
                    from: 0
                    to: 100
                    discrete: true
                    stepSize: 10
                }
                MeoRangeSlider {
                    width: 300 * MeoTheme.globalScale
                    firstValue: 20
                    secondValue: 80
                    from: 0
                    to: 100
                }
            }
        }

        // Selection Groups
        Column {
            spacing: 16 * MeoTheme.globalScale
            Text { text: "Selection Groups (Lists)"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }

            MeoSelectionGroup {
                width: 360 * MeoTheme.globalScale
                type: "checkbox"
                showSelectAll: true
                model: [
                    { label: "Option 1", checked: true },
                    { label: "Option 2", checked: false },
                    { label: "Option 3", checked: false }
                ]
            }
        }

        // List with Multiple Actions (New)
        Column {
            spacing: 16 * MeoTheme.globalScale
            Text { text: "List Item with Multiple Actions"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }

            MeoListItem {
                width: 400 * MeoTheme.globalScale
                headline: "Multi-action item"
                supportingText: "This item has multiple trailing actions"
                leadingIcon: "folder"
                actions: [
                    Component { MeoIconButton { icon.name: "edit"; type: "standard" } },
                    Component { MeoIconButton { icon.name: "delete"; type: "standard" } }
                ]
            }

            MeoListItem {
                width: 400 * MeoTheme.globalScale
                headline: "Segmented Style"
                isSegmented: true
                selected: true
                leadingImage: "https://picsum.photos/100"
                leadingImageVariant: "circle"
                trailingComponent: MeoIcon { icon: "check_circle"; color: MeoTheme.primary }
            }
        }
    }
}
