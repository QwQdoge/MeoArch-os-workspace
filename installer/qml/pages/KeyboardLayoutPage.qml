pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page

    readonly property var quick: [
        { id: "us", name: "US" }, { id: "gb", name: "United Kingdom" },
        { id: "jp", name: "Japanese" }, { id: "de", name: "German" },
        { id: "fr", name: "French" }, { id: "es", name: "Spanish" }
    ]

    Column {
        width: parent.width
        spacing: page.compactHeight ? page.dp(12) : page.dp(16)

        PageHeading {
            width: parent.width
            title: "Keyboard Layout"
            subtitle: "Select a keyboard layout and test it before continuing."
        }
        GridLayout {
            width: parent.width
            columns: width < page.dp(600) ? 1 : 2
            rowSpacing: page.compactHeight ? page.dp(8) : page.dp(12)
            columnSpacing: page.dp(12)

            Repeater {
                model: page.quick
                SelectionCard {
                    required property var modelData
                    Layout.fillWidth: true
                    Layout.preferredHeight: page.dp(64)
                    iconText: "keyboard"
                    title: modelData.name
                    value: modelData.id
                    selected: page.controller && page.controller.keyboardLayout === modelData.id
                    onClicked: page.controller.setKeyboardLayout(modelData.id)
                }
            }
        }
        RowLayout {
            width: parent.width
            spacing: page.dp(8)

            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "l"
                placeholder: "Type here to test your keyboard"
                text: InstallerSession.keyboardTest
                onTextChanged: InstallerSession.keyboardTest = text
            }
            MeoButton {
                text: "All layouts"
                type: "tonal"
                onClicked: allDialog.openFrom(this)
            }
            MeoButton {
                text: "Advanced"
                type: "text"
                onClicked: advanced.openFrom(this)
            }
        }
    }

    SelectorDialog {
        id: allDialog
        title: "All keyboard layouts"
        sourceModel: page.controller ? page.controller.keyboardLayouts : []
        primaryKey: "id"
        labelKey: "name"
        secondaryKey: "id"
        selectedId: page.controller ? page.controller.keyboardLayout : ""
        onApplied: id => page.controller.setKeyboardLayout(id)
    }

    MeoMotionPopup {
        id: advanced
        presentation: MeoMotionPopup.SideSheet
        parent: Overlay.overlay
        x: parent ? parent.width - width : 0
        y: 0
        width: Math.min(page.dp(520), parent ? parent.width : page.dp(520))
        height: parent ? parent.height : page.height
        padding: page.dp(32)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem: Column {
            spacing: page.dp(20)

            MeoText {
                width: parent.width
                text: "Advanced keyboard settings"
                typeRole: "title"
                typeSize: "medium"
                emphasized: true
                color: MeoTheme.contentOnSurface
            }
            MeoTextField { width: parent.width; type: "outlined"; size: "l"; label: "Variant"; placeholder: "Default"; onTextChanged: page.controller.setSelection("locale", "keyboardVariant", text) }
            MeoTextField { width: parent.width; type: "outlined"; size: "l"; label: "Model"; placeholder: "Generic 105-key PC"; onTextChanged: page.controller.setSelection("locale", "keyboardModel", text) }
            MeoTextField { width: parent.width; type: "outlined"; size: "l"; label: "Compose Key"; placeholder: "Disabled"; onTextChanged: page.controller.setSelection("locale", "composeKey", text) }
            MeoButton { anchors.right: parent.right; text: "Done"; type: "filled"; onClicked: advanced.close() }
        }
    }
}
