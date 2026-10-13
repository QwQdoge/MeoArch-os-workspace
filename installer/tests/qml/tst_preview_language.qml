import QtQuick
import QtTest
import "../../qml" as Installer

TestCase {
    name: "PreviewLanguageBridge"
    visible: true
    when: windowShown

    QtObject {
        id: nativeController
        property string requested: ""
        function setUiLanguage(id) { requested = id }
    }

    Installer.Main {
        installerController: nativeController
        visualPreview: true
        visible: true
    }

    function test_languageChoiceReachesNativeTranslator() {
        Installer.PreviewController.setUiLanguage("zh_CN")
        compare(nativeController.requested, "zh_CN")
    }
}
