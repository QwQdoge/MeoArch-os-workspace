import QtQuick
import QtQuick.Controls
import QtQuick.Window
import QtTest
import "../../qml/components" as InstallerComponents

TestCase {
    name: "SelectorDialogBounds"
    visible: true
    when: windowShown

    Window {
        id: host
        width: 960
        height: 600
        visible: true
        InstallerComponents.SelectorDialog {
            id: dialog
            title: "Countries and regions"
            sourceModel: [
                {alpha2: "US", name: "United States"},
                {alpha2: "DE", name: "Germany"},
                {alpha2: "JP", name: "Japan"},
                {alpha2: "SG", name: "Singapore"}
            ]
            primaryKey: "alpha2"
            labelKey: "name"
            secondaryKey: "alpha2"
            selectedId: "US"
        }
    }

    function verifyBounds() {
        dialog.open()
        tryVerify(function() { return dialog.opened })
        const actions = findChild(dialog.contentItem, "selectorActions")
        const options = findChild(dialog.contentItem, "selectorOptions")
        verify(actions !== null)
        verify(options !== null)
        verify(actions.y >= 0)
        verify(actions.y + actions.height <= dialog.contentItem.height + 1)
        verify(options.y >= 0)
        verify(options.y + options.height <= actions.y + 1)
        dialog.close()
    }

    function test_compactWindow() { verifyBounds() }
    function test_largeWindow() {
        host.width = 1228
        host.height = 803
        verifyBounds()
    }
}
