pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import MeoUI 1.0
import "."

Item {
    id: frame

    property var controller: PreviewController
    property int pageIndex: 0
    property int pageCount: 11
    property string pageTitle: ""
    property string pageSubtitle: ""
    property string primaryLabel: pageIndex === 0 ? "Get Started" : "Continue"
    property bool showBackButton: pageIndex > 0 && pageIndex < 9
    property bool showPrimaryButton: true
    property bool primaryEnabled: true
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
        width: windowMetrics.isExtraLargeWidth ? frame.dp(328) : frame.dp(278)
        height: windowMetrics.isExtraLargeWidth ? frame.dp(56) : frame.dp(48)
        color: MeoTheme.surfaceContainer
        radius: MeoTheme.shapeLargeIncreased
        elevation: 0

        Row {
            anchors.fill: parent
            anchors.leftMargin: frame.dp(18)
            spacing: frame.dp(12)

            Image {
                width: frame.dp(68)
                height: frame.dp(32)
                anchors.verticalCenter: parent.verticalCenter
                source: frame.asset("icons/Logo.png")
                fillMode: Image.PreserveAspectFit
            }
            MeoText {
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
            icon.name: "help"
            size: "l"
            type: "tonal"
            Accessible.name: qsTr("Help")
            onClicked: frame.statusMessage = qsTr("Documentation is available in the installer guide.")
        }
        MeoIconButton {
            id: languageButton
            icon.name: "language"
            size: "l"
            type: "tonal"
            Accessible.name: qsTr("Installer language")
            onClicked: languagePopup.openFrom(languageButton)
        }
        MeoIconButton {
            id: powerButton
            icon.name: "power_settings_new"
            size: "l"
            type: "tonal"
            Accessible.name: qsTr("Power")
            onClicked: powerPopup.openFrom(powerButton)
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
                        size: 20
                        color: MeoTheme.contentOnSecondaryContainer
                    }
                }
                onClicked: choose()
            }
        }
    }

    MeoMotionPopup {
        id: powerPopup
        presentation: MeoMotionPopup.Menu
        x: frame.width - frame.pageMargin - width
        y: frame.pageMargin + frame.dp(58)
        width: frame.dp(220)
        height: frame.dp(112)
        padding: frame.dp(8)

        contentItem: Column {
            Repeater {
                model: [
                    { label: qsTr("Restart"), icon: "restart_alt", action: "restart" },
                    { label: qsTr("Shut down"), icon: "power_settings_new", action: "shutdown" }
                ]
                delegate: MeoListItem {
                    required property var modelData
                    width: parent.width
                    implicitHeight: frame.dp(48)
                    headline: modelData.label
                    leadingIcon: modelData.icon
                    onClicked: {
                        modelData.action === "restart" ? frame.controller.requestRestart()
                                                         : frame.controller.requestShutdown()
                        powerPopup.close()
                    }
                }
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
                spacing: frame.dp(12)

                MeoText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Step %1 of %2").arg(frame.pageIndex + 1).arg(frame.pageCount)
                    typeRole: "label"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                }
                MeoPageIndicator {
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
