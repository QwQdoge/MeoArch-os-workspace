import QtQuick
import QtTest

TestCase {
    name: "InstallerPageLoading"
    visible: true
    when: windowShown
    width: 1280
    height: 800

    function test_eachPageLoads_data() {
        return ["Welcome", "LanguageRegion", "KeyboardLayout", "Network",
                "PrivacySecurity", "DiskSelection", "UserAccount", "Software",
                "UpdateChannel", "Summary", "Installing", "Finish"].map(
            function(name) { return { tag: name, page: name } })
    }

    function test_eachPageLoads(data) {
        const component = Qt.createComponent("../../qml/pages/" + data.page + "Page.qml")
        compare(component.status, Component.Ready, component.errorString())
        const page = component.createObject(this, { width: width, height: height })
        verify(page !== null, component.errorString())
        wait(20)
        page.destroy()
    }
}
