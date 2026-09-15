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
    title: qsTr("MeoArch Installer")

    readonly property url assetsRoot: String(Qt.resolvedUrl(".")).indexOf("/opt/meoarch-installer/") >= 0
                                      ? Qt.resolvedUrl("../assets/") : Qt.resolvedUrl("../../assets/")
    property int currentPage: root.initialPage
    property int navigationDirection: 1
    property int startupAttempt: 0
    property bool startupTimedOut: false
    property string screenshotPath: ""
    readonly property bool startupPending: pageHost.readyPageKey.length === 0
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
        sourceProperties: ({
            pageIndex: root.currentPage,
            pageCount: root.pages.length,
            controller: root.controller
        })
        pageKey: String(root.currentPage) + "-" + String(root.startupAttempt)
        direction: root.navigationDirection
        loadingAccessibleName: qsTr("Loading installation step")
        opacity: root.startupPending ? 0 : 1

        Behavior on opacity {
            NumberAnimation {
                duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationMedium2
                easing.type: Easing.BezierSpline
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
    }

    Timer {
        id: startupTimeout
        interval: 8000
        repeat: false
        running: root.startupPending && !root.startupTimedOut
        onTriggered: root.startupTimedOut = true
    }

    MeoMotionSurface {
        id: startupSurface
        z: 200
        anchors.centerIn: parent
        width: Math.min(root.width - 64 * MeoTheme.globalScale, 360 * MeoTheme.globalScale)
        height: startupColumn.implicitHeight + 56 * MeoTheme.globalScale
        visible: opacity > 0.001
        opacity: root.startupPending ? 1 : 0
        radius: MeoTheme.shapeExtraLargeIncreased
        color: MeoTheme.surfaceContainerHigh
        elevation: 3

        Behavior on opacity {
            NumberAnimation {
                duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationMedium2
                easing.type: Easing.BezierSpline
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate
            }
        }

        Column {
            id: startupColumn
            anchors.centerIn: parent
            width: parent.width - 56 * MeoTheme.globalScale
            spacing: 14 * MeoTheme.globalScale

            Image {
                anchors.horizontalCenter: parent.horizontalCenter
                width: 148 * MeoTheme.globalScale
                height: 64 * MeoTheme.globalScale
                source: root.assetsRoot + "icons/Logo.png"
                fillMode: Image.PreserveAspectFit
                Accessible.name: qsTr("MeoArch OS")
            }
            MeoLoadingIndicator {
                visible: !root.startupTimedOut
                running: visible
                anchors.horizontalCenter: parent.horizontalCenter
                width: 40 * MeoTheme.globalScale
                height: width
                variant: "contained"
            }
            MeoIcon {
                visible: root.startupTimedOut
                anchors.horizontalCenter: parent.horizontalCenter
                icon: "error"
                size: 32 * MeoTheme.globalScale
                color: MeoTheme.error
            }
            MeoText {
                width: parent.width
                text: root.startupTimedOut ? qsTr("Installer could not open")
                                           : qsTr("Preparing installer")
                horizontalAlignment: Text.AlignHCenter
                typeRole: "title"
                typeSize: "small"
                emphasized: true
                color: MeoTheme.contentOnSurface
                wrapMode: Text.WordWrap
            }
            MeoText {
                visible: root.startupTimedOut
                width: parent.width
                text: qsTr("The interface did not finish loading. Retry, or open the debug terminal from the boot status screen.")
                horizontalAlignment: Text.AlignHCenter
                typeRole: "body"
                typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
                wrapMode: Text.WordWrap
            }
            MeoButton {
                visible: root.startupTimedOut
                anchors.horizontalCenter: parent.horizontalCenter
                text: qsTr("Retry")
                icon.name: "refresh"
                type: "tonal"
                onClicked: {
                    root.startupTimedOut = false
                    root.startupAttempt++
                }
            }
        }
    }

    Connections {
        target: pageHost
        function onReadyPageKeyChanged() {
            if (pageHost.readyPageKey.length > 0)
                root.startupTimedOut = false
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
