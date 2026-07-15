pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import MeoUI 1.0 as Meo
import "."
import "components"

Item {
    id: frame
    property var controller
    property int pageIndex: 0
    property int pageCount: 10
    property string pageTitle: ""
    property string pageSubtitle: ""
    property string primaryLabel: pageIndex === 0 ? "Get Started" : "Continue"
    property bool showBackButton: pageIndex > 0 && pageIndex < 8
    property bool showPrimaryButton: true
    property bool primaryEnabled: true
    property bool primaryAdvances: true
    property bool languageMenuOpen: false
    property bool powerMenuOpen: false
    property string statusMessage: ""
    default property alias content: body.data
    readonly property real scaleFactor: Math.max(0.72, Math.min(1.28, Math.min(width / 1440, height / 900)))
    readonly property bool compact: width < 1060 || height < 700
    readonly property real pageMargin: dp(compact ? 20 : 32)
    readonly property real cardInset: dp(compact ? 24 : 40)
    readonly property real mainCardWidth: Math.min(width - pageMargin * 2, dp(compact ? 1040 : 860))
    readonly property real mainCardHeight: Math.min(height - pageMargin * 3.2, dp(compact ? 690 : 612))
    readonly property string roboto: robotoLoader.name.length ? robotoLoader.name : "Roboto"
    readonly property string comfortaa: comfortaaLoader.name.length ? comfortaaLoader.name : "Comfortaa"
    readonly property string symbols: symbolsLoader.name.length ? symbolsLoader.name : "Material Symbols Rounded"
    property url assetsRoot: Qt.resolvedUrl("../assets/")
    readonly property url fallbackAssetsRoot: Qt.resolvedUrl("../../assets/")

    signal nextRequested()
    signal previousRequested()
    signal exitRequested()
    signal primaryRequested()

    function dp(value) { return Math.round(value * scaleFactor) }
    function asset(path) { return String(assetsRoot) + path }
    function useFallbackAssets() { if (String(assetsRoot) !== String(fallbackAssetsRoot)) assetsRoot = fallbackAssetsRoot }
    function firePrimary() { primaryAdvances ? nextRequested() : primaryRequested() }
    function playEntrance(direction) { card.reveal(direction) }
    onStatusMessageChanged: if (statusMessage.length) snackbar.open()

    FontLoader { id: robotoLoader; source: frame.asset("fonts/Roboto/Roboto-VariableFont_wdth,wght.ttf"); onStatusChanged: if (status === FontLoader.Error) frame.useFallbackAssets() }
    FontLoader { id: comfortaaLoader; source: frame.asset("fonts/Comfortaa/Comfortaa-VariableFont_wght.ttf"); onStatusChanged: if (status === FontLoader.Error) frame.useFallbackAssets() }
    FontLoader { id: symbolsLoader; source: frame.asset("fonts/Material_Symbols_Outlined,Material_Symbols_Rounded,Material_Symbols_Sharp/Material_Symbols_Rounded/static/MaterialSymbolsRounded-Regular.ttf"); onStatusChanged: if (status === FontLoader.Error) frame.useFallbackAssets() }

    Image {
        anchors.fill: parent
        source: frame.asset("wallpapers/installer_background.png")
        fillMode: Image.PreserveAspectCrop
        onStatusChanged: if (status === Image.Error) frame.useFallbackAssets()
    }

    Rectangle {
        x: frame.pageMargin; y: frame.pageMargin
        width: frame.dp(278); height: frame.dp(48); radius: frame.dp(18)
        color: Qt.rgba(1, 1, 1, 0.80)
        Row {
            anchors.fill: parent; anchors.leftMargin: frame.dp(18); spacing: frame.dp(12)
            Image { width: frame.dp(68); height: frame.dp(32); anchors.verticalCenter: parent.verticalCenter; source: frame.asset("icons/Logo.png"); fillMode: Image.PreserveAspectFit }
            Text { anchors.verticalCenter: parent.verticalCenter; text: "MeoArch Installer"; color: MeoTheme.onSurface; font.family: frame.comfortaa; font.bold: true; font.pixelSize: frame.dp(18) }
        }
    }

    Row {
        id: actions
        anchors.top: parent.top; anchors.right: parent.right
        anchors.topMargin: frame.pageMargin; anchors.rightMargin: frame.pageMargin; spacing: frame.dp(10)
        MeoIconButton { iconText: "?"; iconFont: frame.roboto; accessibleName: "Help"; onClicked: frame.statusMessage = "Documentation is available in the installer guide." }
        MeoIconButton { iconText: "L"; iconFont: frame.roboto; accessibleName: "Installer language"; onClicked: { frame.languageMenuOpen = !frame.languageMenuOpen; frame.powerMenuOpen = false } }
        MeoIconButton { iconText: "P"; iconFont: frame.roboto; accessibleName: "Power"; onClicked: { frame.powerMenuOpen = !frame.powerMenuOpen; frame.languageMenuOpen = false } }
    }

    MotionPopup {
        id: languagePopup
        presentation: "menu"
        visible: frame.languageMenuOpen
        x: frame.width - frame.pageMargin - width
        y: frame.pageMargin + frame.dp(58)
        width: frame.dp(300); height: Math.min(frame.dp(544), frame.height - y - frame.pageMargin)
        padding: frame.dp(8); modal: false; closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        onClosed: frame.languageMenuOpen = false
        contentItem: ListView {
            clip: true; model: frame.controller ? frame.controller.uiLanguages : []
            delegate: Rectangle {
                id: languageOption
                required property var modelData
                width: ListView.view.width; height: frame.dp(48); radius: frame.dp(12)
                color: frame.controller && frame.controller.uiLanguage === languageOption.modelData.id ? MeoTheme.primaryContainer : "transparent"
                Meo.MeoStateLayer { anchors.fill: parent; radius: parent.radius; hovered: languageHover.hovered; pressed: languageTap.pressed; color: MeoTheme.onSurface }
                Text { anchors.left: parent.left; anchors.leftMargin: frame.dp(16); anchors.verticalCenter: parent.verticalCenter; text: languageOption.modelData.nativeName; font.family: frame.roboto; font.pixelSize: frame.dp(15); color: MeoTheme.onSurface }
                Text { anchors.right: parent.right; anchors.rightMargin: frame.dp(16); anchors.verticalCenter: parent.verticalCenter; text: frame.controller && frame.controller.uiLanguage === languageOption.modelData.id ? "✓" : ""; font.pixelSize: frame.dp(18); color: MeoTheme.primary }
                HoverHandler { id: languageHover }
                TapHandler { id: languageTap; onTapped: { frame.controller.setUiLanguage(languageOption.modelData.id); frame.languageMenuOpen = false } }
            }
        }
    }

    MotionPopup {
        presentation: "menu"
        visible: frame.powerMenuOpen
        x: frame.width - frame.pageMargin - width; y: frame.pageMargin + frame.dp(58)
        width: frame.dp(220); height: frame.dp(124); padding: frame.dp(8)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        onClosed: frame.powerMenuOpen = false
        contentItem: Column {
            Repeater {
                model: [{ label: "Restart", action: "restart" }, { label: "Shut down", action: "shutdown" }]
                delegate: MeoButton {
                    required property var modelData
                    width: parent.width; text: modelData.label; kind: "text"
                    onClicked: { modelData.action === "restart" ? frame.controller.requestRestart() : frame.controller.requestShutdown(); frame.powerMenuOpen = false }
                }
            }
        }
    }

    Meo.MeoMotionSurface {
        id: card
        anchors.centerIn: parent; width: frame.mainCardWidth; height: frame.mainCardHeight
        radius: frame.dp(30); color: Qt.rgba(1, 1, 1, 0.94); elevation: 3
        Item {
            id: body
            anchors.left: parent.left; anchors.right: parent.right; anchors.top: parent.top; anchors.bottom: footer.top
            anchors.margins: frame.cardInset; anchors.bottomMargin: frame.dp(16)
        }
        Rectangle {
            id: footer
            anchors.left: parent.left; anchors.right: parent.right; anchors.bottom: parent.bottom
            height: frame.dp(80); color: "transparent"
            MeoButton { visible: frame.showBackButton; anchors.left: parent.left; anchors.leftMargin: frame.dp(24); anchors.verticalCenter: parent.verticalCenter; text: "Back"; kind: "text"; onClicked: frame.previousRequested() }
            Meo.MeoPageIndicator {
                anchors.centerIn: parent
                count: frame.pageCount
                currentIndex: frame.pageIndex
                dotSize: frame.dp(6)
                activeDotWidth: frame.dp(18)
                spacing: frame.dp(6)
            }
            MeoButton { visible: frame.showPrimaryButton; enabled: frame.primaryEnabled; anchors.right: parent.right; anchors.rightMargin: frame.dp(24); anchors.verticalCenter: parent.verticalCenter; text: frame.primaryLabel; minWidth: frame.dp(136); onClicked: frame.firePrimary() }
        }
    }

    Meo.MeoSnackbar { id: snackbar; message: frame.controller && frame.controller.errorMessage.length ? frame.controller.errorMessage : frame.statusMessage }
    Connections { target: frame.controller; ignoreUnknownSignals: true; function onErrorMessageChanged() { if (frame.controller.errorMessage.length) snackbar.open() } }
}
