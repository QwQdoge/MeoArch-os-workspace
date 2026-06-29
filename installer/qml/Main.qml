import QtQuick
import QtQuick.Window
import "."

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
    readonly property var pages: [
        { title: "WelcomePage", source: "pages/WelcomePage.qml" },
        { title: "Language & Region", source: "pages/LanguageRegionPage.qml" },
        { title: "Keyboard Layout", source: "pages/KeyboardLayoutPage.qml" },
        { title: "Network", source: "pages/NetworkPage.qml" },
        { title: "Privacy & Security", source: "pages/PrivacySecurityPage.qml" },
        { title: "Disk Selection", source: "pages/DiskSelectionPage.qml" },
        { title: "User Account", source: "pages/UserAccountPage.qml" },
        { title: "Summary", source: "pages/SummaryPage.qml" },
        { title: "Installing", source: "pages/InstallingPage.qml" },
        { title: "Finish", source: "pages/FinishPage.qml" }
    ]

    Loader {
        id: pageLoader
        anchors.fill: parent
        source: root.pages[root.currentPage].source

        onLoaded: {
            item.pageTitle = root.pages[root.currentPage].title
            item.pageIndex = root.currentPage
            item.pageCount = root.pages.length
        }
    }

    Connections {
        target: pageLoader.item
        ignoreUnknownSignals: true

        function onNextRequested() {
            root.nextPage()
        }

        function onPreviousRequested() {
            root.previousPage()
        }

        function onExitRequested() {
            Qt.quit()
        }
    }

    function nextPage() {
        if (currentPage < pages.length - 1)
            currentPage += 1
    }

    function previousPage() {
        if (currentPage > 0)
            currentPage -= 1
    }
}
