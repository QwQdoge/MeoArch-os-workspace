import QtQuick
import QtQuick.Window
import MeoUI 1.0
import "." as Installer

Window {
    id: root
    required property var installerController
    property bool visualPreview: false
    property int initialPage: 0
    width: 1440
    height: 900
    minimumWidth: 960
    minimumHeight: 600
    visible: true
    color: MeoTheme.windowBg
    title: "MeoArch Installer"

    readonly property url assetsRoot: String(Qt.resolvedUrl(".")).indexOf("/opt/meoarch-installer/") >= 0
                                      ? Qt.resolvedUrl("../assets/") : Qt.resolvedUrl("../../assets/")
    property int currentPage: root.initialPage
    property int navigationDirection: 1
    property string screenshotPath: ""
    readonly property var controller: root.visualPreview ? Installer.PreviewController : root.installerController
    readonly property var pages: [
        Qt.resolvedUrl("pages/WelcomePage.qml"), Qt.resolvedUrl("pages/LanguageRegionPage.qml"),
        Qt.resolvedUrl("pages/KeyboardLayoutPage.qml"), Qt.resolvedUrl("pages/NetworkPage.qml"),
        Qt.resolvedUrl("pages/PrivacySecurityPage.qml"), Qt.resolvedUrl("pages/DiskSelectionPage.qml"),
        Qt.resolvedUrl("pages/UserAccountPage.qml"), Qt.resolvedUrl("pages/SoftwarePage.qml"),
        Qt.resolvedUrl("pages/UpdateChannelPage.qml"), Qt.resolvedUrl("pages/SummaryPage.qml"), Qt.resolvedUrl("pages/InstallingPage.qml"),
        Qt.resolvedUrl("pages/FinishPage.qml")
    ]

    Component.onCompleted: {
        for (let i = 0; i < Qt.application.arguments.length; ++i) {
            const argument = Qt.application.arguments[i]
            if (argument.indexOf("--screenshot=") === 0)
                screenshotPath = argument.substring(13)
            if (argument.indexOf("--size=") === 0) {
                const parts = argument.substring(7).toLowerCase().split("x")
                if (parts.length === 2) {
                    root.width = Math.max(root.minimumWidth, Number(parts[0]))
                    root.height = Math.max(root.minimumHeight, Number(parts[1]))
                }
            }
        }
        if (screenshotPath.length) {
            MeoTheme.reduceMotion = true
        }
    }

    // The wallpaper belongs to the window rather than an individual page so
    // it remains stable while pages transition and is decoded only once.
    Image {
        anchors.fill: parent
        source: root.assetsRoot + "wallpapers/installer_background.png"
        fillMode: Image.PreserveAspectCrop
        asynchronous: false
        cache: true
    }

    MeoShape {
        anchors.fill: parent
        type: "rect"
        radius: 0
        color: MeoTheme.surface
        opacity: 0.14
    }

    MeoPageHost {
        id: pageHost
        anchors.fill: parent
        source: root.pages[root.currentPage]
        direction: root.navigationDirection
        onPageLoaded: item => {
            item.pageIndex = root.currentPage
            item.pageCount = root.pages.length
            item.controller = root.controller
        }
    }

    Connections {
        target: pageHost.currentItem
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
        function onNavigateRequested(index) {
            if (index >= 0 && index < root.pages.length) {
                root.navigationDirection = index < root.currentPage ? -1 : 1
                root.currentPage = index
            }
        }
    }
}
