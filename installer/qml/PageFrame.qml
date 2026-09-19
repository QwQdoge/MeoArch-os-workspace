pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import MeoUI 1.0
import "."

Item {
    id: frame

    property var controller: PreviewController
    property int pageIndex: 0
    property int pageCount: 12
    property string pageTitle: ""
    property string pageSubtitle: ""
    property string primaryLabel: pageIndex === 0 ? qsTr("Get Started") : qsTr("Continue")
    property bool showBackButton: pageIndex > 0 && pageIndex < 9
    property bool showPrimaryButton: true
    property bool primaryEnabled: true
    property bool primaryLoading: false
    property bool primaryAdvances: true
    property string primaryAccessibleDescription: qsTr("Continue to the next installation step")
    property string statusMessage: ""
    default property alias content: bodyHost.data

    readonly property real pageMargin: windowMetrics.pageMargin
    readonly property real cardInset: compactHeight ? dp(24)
                                                     : windowMetrics.isExtraLargeWidth ? dp(48)
                                                                                       : windowMetrics.isLargeWidth ? dp(40) : dp(32)
    readonly property real mainCardWidth: Math.min(width - pageMargin * 2,
                                                    windowMetrics.isExtraLargeWidth ? dp(1152)
                                                                                   : windowMetrics.isLargeWidth ? dp(860) : dp(760))
    readonly property bool reserveTopBar: height < dp(720)
    readonly property real cardTop: reserveTopBar ? pageMargin + dp(64)
                                                   : (height - mainCardHeight) / 2
    readonly property real mainCardHeight: Math.min(height - pageMargin * 2,
                                                     reserveTopBar ? height - cardTop - pageMargin : Number.MAX_VALUE,
                                                     windowMetrics.isExtraLargeWidth ? dp(736)
                                                                                    : windowMetrics.isLargeWidth
                                                                                      ? (windowMetrics.isExpandedHeight ? dp(680) : dp(612))
                                                                                      : dp(520))
    readonly property real footerHeight: compactHeight ? dp(64)
                                                        : windowMetrics.isExtraLargeWidth ? dp(96)
                                                                                          : windowMetrics.isLargeWidth ? dp(80) : dp(72)
    readonly property bool compactHeight: windowMetrics.isCompactHeight || mainCardHeight < dp(560)
    // A 960 px kiosk can still have a high UI scale.  Collapse decorative
    // chrome before the brand and footer controls compete for the same space.
    readonly property bool compactChrome: windowMetrics.isCompactWidth || width < dp(760)
    // Pixel's top-app-bar actions are visually compact.  MeoIconButton keeps
    // its 48dp accessible target for S even though the rendered container is
    // only 40dp, so this reduces kiosk chrome without reducing hit targets.
    readonly property string topActionSize: "s"
    readonly property string topActionType: "standard"
    readonly property bool showFooterPageIndicator: !compactChrome
    readonly property string roboto: robotoLoader.name.length ? robotoLoader.name : MeoTheme.typefacePlain
    readonly property string comfortaa: comfortaaLoader.name.length ? comfortaaLoader.name : MeoTheme.typefaceBrand
    readonly property string symbols: symbolsLoader.name.length ? symbolsLoader.name : "Material Symbols Rounded"
    property url assetsRoot: String(Qt.resolvedUrl("." )).indexOf("/opt/meoarch-installer/") >= 0
                             ? Qt.resolvedUrl("../assets/") : Qt.resolvedUrl("../../assets/")

    signal nextRequested()
    signal previousRequested()
    signal exitRequested()
    signal primaryRequested()
    signal navigateRequested(int index)

    function dp(value) { return Math.round(value * MeoTheme.globalScale) }
    function asset(path) { return String(assetsRoot) + path }
    function firePrimary() { primaryAdvances ? nextRequested() : primaryRequested() }
    readonly property string currentStepHelp: {
        switch (pageIndex) {
        case 0:
            return qsTr("This installer guides you through language, keyboard, network, privacy, storage, account, software, and a final review. Nothing changes until you confirm the final plan.")
        case 1:
            return qsTr("Choose the language and regional formats used by the installed desktop. You can change them later in Settings.")
        case 2:
            return qsTr("Choose a keyboard layout and make sure typing feels right before continuing.")
        case 3:
            return qsTr("Connect to a network when you need online packages. Continue offline only when this page says that it is available.")
        case 4:
            return qsTr("Review privacy choices. This installer shows only settings that have a real backend.")
        case 5:
            return qsTr("Check the target storage carefully. Erase actions run only after final confirmation and remove data from that device.")
        case 6:
            return qsTr("Create a local account. Keep the password safe: it is not shown again after installation.")
        case 7:
            return qsTr("Choose a software profile. Third-party software is always opt-in and is never added by default.")
        case 8:
            return qsTr("Choose how cautiously MeoArch updates after installation. Stable is the safe choice for most people.")
        case 9:
            return qsTr("Review every selection. Install now still opens one final confirmation before an erase plan can run.")
        case 10:
            return qsTr("Installation is in progress. Do not power off or force a restart; if it fails, note the stage and check the Live diagnostic log.")
        case 11:
            return qsTr("When installation is complete, remove the installation media before restarting into the new system. Keep the diagnostic log if validation reports a problem.")
        default:
            return qsTr("Review this page before continuing. Nothing is written to disk until the final confirmation.")
        }
    }
    function openDocumentation(url, description) {
        statusMessage = Qt.openUrlExternally(url)
                ? description : qsTr("Could not open the documentation browser.")
    }

    onStatusMessageChanged: if (statusMessage.length) snackbar.open()
    Component.onCompleted: MeoTheme.isDarkMode = false

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: frame.width
        availableHeight: frame.height
    }

    FontLoader {
        id: robotoLoader
        source: frame.asset("fonts/Roboto/Roboto-VariableFont_wdth,wght.ttf")
    }
    FontLoader {
        id: comfortaaLoader
        source: frame.asset("fonts/Comfortaa/Comfortaa-VariableFont_wght.ttf")
    }
    FontLoader {
        id: symbolsLoader
        source: frame.asset("fonts/Material_Symbols_Outlined,Material_Symbols_Rounded,Material_Symbols_Sharp/Material_Symbols_Rounded/static/MaterialSymbolsRounded_28pt-Regular.ttf")
    }

    MeoMotionSurface {
        x: frame.pageMargin
        y: frame.pageMargin
        width: frame.compactChrome ? frame.dp(104)
                                   : windowMetrics.isExtraLargeWidth ? frame.dp(328) : frame.dp(278)
        height: windowMetrics.isExtraLargeWidth ? frame.dp(56) : frame.dp(48)
        color: MeoTheme.surfaceContainer
        radius: MeoTheme.shapeLargeIncreased
        elevation: 0

        Row {
            anchors.fill: parent
            anchors.leftMargin: frame.dp(18)
            spacing: frame.compactChrome ? 0 : frame.dp(12)

            Image {
                width: frame.dp(68)
                height: frame.dp(32)
                anchors.verticalCenter: parent.verticalCenter
                source: frame.asset("icons/Logo.png")
                fillMode: Image.PreserveAspectFit
            }
            MeoText {
                visible: !frame.compactChrome
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("MeoArch Installer")
                typeRole: "title"
                typeSize: "small"
                emphasized: true
                color: MeoTheme.contentOnSurface
            }
        }
    }

    Row {
        id: actions
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: frame.pageMargin
        anchors.rightMargin: frame.pageMargin
        spacing: frame.dp(8)

        MeoIconButton {
            id: diagnosticButton
            visible: frame.controller && frame.controller.diagnosticConsoleAvailable
            icon.name: "terminal"
            size: frame.topActionSize
            type: frame.topActionType
            Accessible.name: qsTr("Open diagnostic console")
            Accessible.description: qsTr("Runs diagnostic commands inside the Cage installer as the unprivileged Live user")
            onClicked: diagnosticPopup.openFrom(diagnosticButton)
        }
        MeoIconButton {
            id: helpButton
            icon.name: "help"
            size: frame.topActionSize
            type: frame.topActionType
            Accessible.name: qsTr("Help")
            onClicked: helpPopup.openFrom(helpButton)
        }
        MeoIconButton {
            id: languageButton
            visible: frame.controller && frame.controller.uiLanguages.length > 1
            icon.name: "language"
            size: frame.topActionSize
            type: frame.topActionType
            Accessible.name: qsTr("Installer language")
            onClicked: languagePopup.openFrom(languageButton)
        }
        MeoIconButton {
            id: powerButton
            icon.name: "power_settings_new"
            size: frame.topActionSize
            type: frame.topActionType
            Accessible.name: qsTr("Power")
            onClicked: powerPopup.openFrom(powerButton)
        }
    }

    MeoMotionPopup {
        id: diagnosticPopup
        presentation: MeoMotionPopup.Dialog
        x: (frame.width - width) / 2
        y: (frame.height - height) / 2
        width: Math.min(frame.dp(760), frame.width - frame.pageMargin * 2)
        height: Math.min(frame.dp(620), frame.height - frame.pageMargin * 2)
        padding: frame.dp(20)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem: Column {
            id: diagnosticContent
            width: parent.width
            spacing: frame.dp(12)

            Row {
                width: parent.width
                spacing: frame.dp(12)

                MeoIcon {
                    icon: "terminal"
                    size: frame.dp(28)
                    color: MeoTheme.contentOnSurface
                }
                Column {
                    width: parent.width - frame.dp(40)
                    spacing: frame.dp(2)
                    MeoText {
                        width: parent.width
                        text: qsTr("Live diagnostic console")
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                        color: MeoTheme.contentOnSurface
                    }
                    MeoText {
                        width: parent.width
                        text: qsTr("Commands run inside this Cage session as the unprivileged live user. Use it for network and hardware checks.")
                        typeRole: "body"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurfaceVariant
                        wrapMode: Text.WordWrap
                    }
                }
            }

            MeoMotionSurface {
                width: parent.width
                height: diagnosticPopup.height - frame.dp(210)
                radius: MeoTheme.shapeLarge
                color: MeoTheme.surfaceContainerLowest
                elevation: 0

                TextArea {
                    id: diagnosticOutput
                    anchors.fill: parent
                    anchors.margins: frame.dp(12)
                    readOnly: true
                    selectByMouse: true
                    wrapMode: TextEdit.WrapAnywhere
                    text: frame.controller ? frame.controller.diagnosticConsoleOutput : ""
                    color: MeoTheme.contentOnSurface
                    selectionColor: MeoTheme.primaryContainer
                    selectedTextColor: MeoTheme.contentOnPrimaryContainer
                    font.family: "monospace"
                    font.pixelSize: frame.dp(13)
                    background: null
                    onTextChanged: cursorPosition = length
                }
            }

            Row {
                width: parent.width
                spacing: frame.dp(8)

                MeoTextField {
                    id: diagnosticCommand
                    width: parent.width - runDiagnosticButton.width - frame.dp(8)
                    label: qsTr("Command")
                    placeholderText: qsTr("Example: ip route")
                    enabled: frame.controller && !frame.controller.diagnosticConsoleRunning
                    onAccepted: {
                        if (text.trim().length > 0 && frame.controller) {
                            frame.controller.runDiagnosticCommand(text)
                            text = ""
                        }
                    }
                }
                MeoButton {
                    id: runDiagnosticButton
                    text: frame.controller && frame.controller.diagnosticConsoleRunning
                          ? qsTr("Running…") : qsTr("Run")
                    type: "filled"
                    loading: frame.controller && frame.controller.diagnosticConsoleRunning
                    enabled: frame.controller && !frame.controller.diagnosticConsoleRunning
                             && diagnosticCommand.text.trim().length > 0
                    onClicked: {
                        frame.controller.runDiagnosticCommand(diagnosticCommand.text)
                        diagnosticCommand.text = ""
                    }
                }
            }

            Row {
                anchors.right: parent.right
                spacing: frame.dp(8)
                MeoButton {
                    text: qsTr("Clear")
                    type: "text"
                    enabled: frame.controller && !frame.controller.diagnosticConsoleRunning
                    onClicked: frame.controller.clearDiagnosticConsole()
                }
                MeoButton {
                    text: qsTr("Close")
                    type: "tonal"
                    onClicked: diagnosticPopup.close()
                }
            }
        }
    }

    MeoMotionPopup {
        id: helpPopup
        presentation: MeoMotionPopup.Menu
        x: Math.max(frame.pageMargin, helpButton.x - width + helpButton.width)
        y: frame.pageMargin + frame.dp(58)
        width: frame.dp(360)
        height: Math.min(frame.dp(286), frame.height - frame.pageMargin * 2)
        padding: frame.dp(12)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem: Flickable {
            id: helpFlick
            contentWidth: width
            contentHeight: helpContent.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height
            ScrollBar.vertical: ScrollBar {
                policy: helpFlick.interactive ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }

            Column {
                id: helpContent
                width: parent.width
                spacing: frame.dp(6)
                MeoText {
                    width: parent.width
                    text: qsTr("Current step")
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                    color: MeoTheme.contentOnSurface
                }
                MeoText {
                    width: parent.width
                    text: frame.currentStepHelp
                    typeRole: "body"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                    wrapMode: Text.WordWrap
                }
                MeoDivider { width: parent.width }
                MeoText {
                    width: parent.width
                    text: qsTr("More reference")
                    typeRole: "label"
                    typeSize: "large"
                    emphasized: true
                    color: MeoTheme.contentOnSurface
                }
                MeoListItem {
                    width: parent.width
                    implicitHeight: frame.dp(44)
                    headline: qsTr("ArchWiki: Installation guide")
                    leadingIcon: "open_in_new"
                    interactive: true
                    onClicked: { frame.openDocumentation("https://wiki.archlinux.org/title/Installation_guide", qsTr("Opened the ArchWiki installation guide.")); helpPopup.close() }
                }
                MeoListItem {
                    width: parent.width
                    implicitHeight: frame.dp(44)
                    headline: qsTr("ArchWiki: Network configuration")
                    leadingIcon: "wifi"
                    interactive: true
                    onClicked: { frame.openDocumentation("https://wiki.archlinux.org/title/Network_configuration", qsTr("Opened the ArchWiki network guide.")); helpPopup.close() }
                }
                MeoListItem {
                    width: parent.width
                    implicitHeight: frame.dp(44)
                    headline: qsTr("Cage kiosk environment")
                    leadingIcon: "fullscreen"
                    interactive: false
                    supportingText: qsTr("The Live installer runs directly in Cage, not in a KDE Plasma desktop session.")
                }
            }
        }
    }

    MeoMotionPopup {
        id: languagePopup
        presentation: MeoMotionPopup.Menu
        x: frame.width - frame.pageMargin - width
        y: frame.pageMargin + frame.dp(58)
        width: frame.dp(300)
        height: Math.min(frame.dp(544), frame.height - y - frame.pageMargin)
        padding: frame.dp(8)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem: ListView {
            id: languageList
            clip: true
            model: frame.controller ? frame.controller.uiLanguages : []
            keyNavigationEnabled: true
            boundsBehavior: Flickable.StopAtBounds

            delegate: MeoListItem {
                id: languageOption
                required property var modelData
                width: ListView.view.width
                implicitHeight: frame.dp(48)
                headline: languageOption.modelData.nativeName
                interactive: true
                isDense: true
                isSegmented: true
                roundingStrategy: "all"
                selected: frame.controller && frame.controller.uiLanguage === modelData.id
                Accessible.role: Accessible.MenuItem
                Accessible.name: modelData.nativeName
                Accessible.selected: frame.controller && frame.controller.uiLanguage === modelData.id

                function choose() {
                    frame.controller.setUiLanguage(modelData.id)
                    languagePopup.close()
                }

                trailingComponent: Component {
                    MeoIcon {
                        icon: languageOption.selected ? "check" : ""
                        size: frame.dp(20)
                        color: MeoTheme.contentOnSecondaryContainer
                    }
                }
                onClicked: choose()
            }
        }
    }

    MeoMotionPopup {
        id: powerPopup
        // Caelestia's session surface is the interaction reference: large
        // rounded actions, vertical focus navigation, and state-driven shape.
        // This is an independent MeoUI implementation; no Quickshell service
        // or upstream GPL QML is embedded in the installer.
        presentation: MeoMotionPopup.Dialog
        x: (frame.width - width) / 2
        y: (frame.height - height) / 2
        width: Math.min(frame.dp(420), frame.width - frame.pageMargin * 2)
        height: powerContent.implicitHeight + frame.dp(48)
        padding: frame.dp(24)
        initialFocusItem: restartAction
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem: Column {
            id: powerContent
            width: parent.width
            spacing: frame.dp(14)

            Row {
                width: parent.width
                spacing: frame.dp(12)
                MeoMotionSurface {
                    width: frame.dp(48)
                    height: width
                    radius: width / 2
                    color: MeoTheme.secondaryContainer
                    elevation: 0
                    MeoIcon {
                        anchors.centerIn: parent
                        icon: "power_settings_new"
                        size: frame.dp(24)
                        color: MeoTheme.contentOnSecondaryContainer
                    }
                }
                Column {
                    width: parent.width - frame.dp(60)
                    spacing: frame.dp(2)
                    MeoText {
                        width: parent.width
                        text: qsTr("Power options")
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                        color: MeoTheme.contentOnSurface
                    }
                    MeoText {
                        width: parent.width
                        text: qsTr("Hold an action to avoid ending the live session by accident.")
                        typeRole: "body"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurfaceVariant
                        wrapMode: Text.WordWrap
                    }
                }
            }

            MeoHoldToConfirm {
                id: restartAction
                width: parent.width
                confirmationText: qsTr("Hold to restart")
                holdingText: qsTr("Keep holding to restart…")
                holdDuration: 1200
                iconName: "restart_alt"
                tone: "neutral"
                KeyNavigation.down: shutdownAction
                onConfirmed: {
                    powerPopup.close()
                    frame.controller.requestRestart()
                }
            }
            MeoHoldToConfirm {
                id: shutdownAction
                width: parent.width
                confirmationText: qsTr("Hold to shut down")
                holdingText: qsTr("Keep holding to shut down…")
                holdDuration: 1200
                iconName: "power_settings_new"
                tone: "error"
                KeyNavigation.up: restartAction
                KeyNavigation.down: cancelPowerAction
                onConfirmed: {
                    powerPopup.close()
                    frame.controller.requestShutdown()
                }
            }
            MeoButton {
                id: cancelPowerAction
                anchors.right: parent.right
                text: qsTr("Cancel")
                type: "text"
                KeyNavigation.up: shutdownAction
                onClicked: powerPopup.close()
            }
        }
    }

    MeoMotionSurface {
        id: card
        anchors.horizontalCenter: parent.horizontalCenter
        y: frame.cardTop
        width: frame.mainCardWidth
        height: frame.mainCardHeight
        radius: windowMetrics.isExtraLargeWidth ? MeoTheme.shapeExtraLargeIncreased
                                                : MeoTheme.shapeExtraLarge
        color: MeoTheme.surfaceContainerLowest
        elevation: 3

        Flickable {
            id: contentFlick
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.bottom: footer.top
            anchors.leftMargin: frame.cardInset
            anchors.rightMargin: frame.cardInset
            anchors.topMargin: frame.cardInset
            anchors.bottomMargin: frame.compactHeight ? frame.dp(8) : frame.dp(16)
            contentWidth: width
            contentHeight: bodyHost.height
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height
            // A persistent, narrow affordance is important on the compact
            // installer window: otherwise a clipped review page looks like a
            // broken layout instead of content that can be scrolled.
            ScrollBar.vertical: ScrollBar {
                policy: contentFlick.interactive ? ScrollBar.AlwaysOn : ScrollBar.AlwaysOff
            }

            Item {
                id: bodyHost
                width: contentFlick.width
                height: Math.max(contentFlick.height,
                                 children.length && children[0].implicitHeight !== undefined
                                 ? children[0].implicitHeight : contentFlick.height)
            }
        }

        Item {
            id: footer
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            height: frame.footerHeight

            MeoDivider {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.top: parent.top
                height: Math.max(1, MeoTheme.strokeWidthThin)
                opacity: 0.72
            }

            MeoButton {
                visible: frame.showBackButton
                anchors.left: parent.left
                anchors.leftMargin: frame.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Back")
                type: "text"
                size: "m"
                onClicked: frame.previousRequested()
            }
            Row {
                anchors.centerIn: parent
                spacing: frame.showFooterPageIndicator ? frame.dp(12) : 0

                MeoText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Step %1 of %2").arg(frame.pageIndex + 1).arg(frame.pageCount)
                    typeRole: "label"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                }
                MeoPageIndicator {
                    visible: frame.showFooterPageIndicator
                    anchors.verticalCenter: parent.verticalCenter
                    count: frame.pageCount
                    currentIndex: frame.pageIndex
                    dotSize: frame.dp(6)
                    activeDotWidth: frame.dp(18)
                    spacing: frame.dp(6)
                }
            }
            MeoButton {
                visible: frame.showPrimaryButton
                enabled: frame.primaryEnabled
                anchors.right: parent.right
                anchors.rightMargin: frame.dp(24)
                anchors.verticalCenter: parent.verticalCenter
                implicitWidth: Math.max(frame.dp(136), contentItem.implicitWidth + leftPadding + rightPadding)
                text: frame.primaryLabel
                loading: frame.primaryLoading
                type: "filled"
                size: "m"
                isEmphasized: true
                Accessible.description: frame.primaryAccessibleDescription
                onClicked: frame.firePrimary()
            }
        }
    }

    MeoSnackbar {
        id: snackbar
        message: frame.controller && frame.controller.errorMessage.length
                 ? frame.controller.errorMessage : frame.statusMessage
    }
    Connections {
        target: frame.controller || null
        ignoreUnknownSignals: true
        function onErrorMessageChanged() {
            if (frame.controller.errorMessage.length)
                snackbar.open()
        }
    }
}
