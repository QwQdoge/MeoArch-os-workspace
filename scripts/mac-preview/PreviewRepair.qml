import QtQuick
import "file://@REPAIR_QML@" as R
R.Main {
    id: win
    repairController: RepairControllerStub {}
    uiLanguageController: QtObject { function select(l) {} }
    visualPreview: true
    advancedMode: @ADV@
    previewWizardStage: "@STAGE@"
    initialCategory: "@CATEGORY@"
    Timer {
        interval: 2500; running: "@SHOT@".length > 0
        onTriggered: win.contentItem.grabToImage(function(r) { r.saveToFile("@SHOT@"); Qt.quit() })
    }
}
