import QtQuick
import QtTest
import MeoUI 1.0
import "../../qml/components" as InstallerComponents

TestCase {
    name: "SelectionCardSingleClick"
    visible: true
    when: windowShown
    width: 600
    height: 300
    property int clickCount: 0

    InstallerComponents.SelectionCard {
        id: card
        x: 20
        y: 20
        width: 500
        title: "Install MeoArch OS"
        selectionIndicator: true
        selected: true
        onClicked: clickCount++
    }

    function test_oneMouseClickEmitsOneAction() {
        clickCount = 0
        mouseClick(card, card.width / 2, card.height / 2)
        compare(clickCount, 1)
    }
}
