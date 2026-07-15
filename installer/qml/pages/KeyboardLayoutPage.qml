pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
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
        anchors.fill: parent; spacing: page.dp(16)
        PageHeading { width: parent.width; title: "Keyboard Layout"; subtitle: "Select a keyboard layout and test it before continuing." }
        Grid {
            width: parent.width; columns: 2; rowSpacing: page.dp(12); columnSpacing: page.dp(12)
            Repeater {
                model: page.quick
                SelectionCard {
                    required property var modelData
                    width: (parent.width - page.dp(12)) / 2; height: page.dp(64); iconFont: page.roboto; iconText: "K"; title: modelData.name; value: modelData.id
                    selected: page.controller && page.controller.keyboardLayout === modelData.id
                    onClicked: page.controller.setKeyboardLayout(modelData.id)
                }
            }
        }
        Row {
            width: parent.width; spacing: page.dp(8)
            MeoTextField { width: parent.width - allButton.width - advancedButton.width - page.dp(16); placeholder: "Type here to test your keyboard"; text: InstallerSession.keyboardTest; onTextChanged: InstallerSession.keyboardTest = text }
            MeoButton { id: allButton; text: "All layouts"; kind: "tonal"; anchors.verticalCenter: parent.verticalCenter; onClicked: allDialog.open() }
            MeoButton { id: advancedButton; text: "Advanced"; kind: "text"; anchors.verticalCenter: parent.verticalCenter; onClicked: advanced.open() }
        }
    }
    SelectorDialog { id: allDialog; title: "All keyboard layouts"; sourceModel: page.controller ? page.controller.keyboardLayouts : []; primaryKey: "id"; labelKey: "name"; secondaryKey: "id"; selectedId: page.controller ? page.controller.keyboardLayout : ""; onApplied: id => page.controller.setKeyboardLayout(id) }
    MotionPopup {
        id: advanced
        presentation: "sheet"
        parent: Overlay.overlay; x: parent ? parent.width - width : 0; y: 0
        width: Math.min(page.dp(520), parent ? parent.width : page.dp(520)); height: parent ? parent.height : page.height
        modal: true; padding: page.dp(32); closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Column {
            spacing: page.dp(20)
            Text { text: "Advanced keyboard settings"; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(28); color: MeoTheme.onSurface }
            MeoTextField { width: parent.width; label: "Variant"; placeholder: "Default"; onTextChanged: page.controller.setSelection("locale", "keyboardVariant", text) }
            MeoTextField { width: parent.width; label: "Model"; placeholder: "Generic 105-key PC"; onTextChanged: page.controller.setSelection("locale", "keyboardModel", text) }
            MeoTextField { width: parent.width; label: "Compose Key"; placeholder: "Disabled"; onTextChanged: page.controller.setSelection("locale", "composeKey", text) }
            MeoButton { anchors.right: parent.right; text: "Done"; onClicked: advanced.close() }
        }
    }
}
