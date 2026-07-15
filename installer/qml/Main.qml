import QtQuick
import QtQuick.Window
import "." as Installer

Window {
    id: root
    width: 1440
    height: 900
    minimumWidth: 960
    minimumHeight: 600
    visible: true
    color: MeoTheme.windowBg
    title: "MeoArch Installer"

    property int currentPage: 0
    property int navigationDirection: 1
    property string screenshotPath: ""
    readonly property var controller: typeof installerController !== "undefined" ? installerController : Installer.PreviewController
    readonly property var pages: [
        "pages/WelcomePage.qml", "pages/LanguageRegionPage.qml", "pages/KeyboardLayoutPage.qml",
        "pages/NetworkPage.qml", "pages/PrivacySecurityPage.qml", "pages/DiskSelectionPage.qml",
        "pages/UserAccountPage.qml", "pages/SummaryPage.qml", "pages/InstallingPage.qml", "pages/FinishPage.qml"
    ]

    Component.onCompleted: {
        for (let i = 0; i < Qt.application.arguments.length; ++i) {
            const argument = Qt.application.arguments[i]
            if (argument.indexOf("--page=") === 0)
                currentPage = Math.max(0, Math.min(pages.length - 1, Number(argument.substring(7))))
            if (argument.indexOf("--screenshot=") === 0)
                screenshotPath = argument.substring(13)
        }
        if (screenshotPath.length)
            failSafeTimer.start()
        if (screenshotPath.length)
            captureTimer.start()
    }

    Timer {
        id: captureTimer
        interval: 1000
        repeat: false
        onTriggered: root.contentItem.grabToImage(function(result) {
            result.saveToFile(root.screenshotPath)
            Qt.quit()
        }, Qt.size(root.width, root.height))
    }
    Timer { id: failSafeTimer; interval: 3500; repeat: false; onTriggered: Qt.quit() }

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: root.pages[root.currentPage]
        onLoaded: {
            item.pageIndex = root.currentPage
            item.pageCount = root.pages.length
            item.controller = root.controller
            const entrance = item["playEntrance"]
            if (typeof entrance === "function")
                entrance.call(item, root.navigationDirection)
        }
    }

    Connections {
        target: pageLoader.item
        ignoreUnknownSignals: true
        function onNextRequested() {
            if (root.currentPage < root.pages.length - 1) {
                root.navigationDirection = 1
                root.currentPage++
            }
        }
        function onPreviousRequested() {
            if (root.currentPage > 0) {
                root.navigationDirection = -1
                root.currentPage--
            }
        }
        function onExitRequested() { Qt.quit() }
    }
}
