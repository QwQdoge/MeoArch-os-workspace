pragma ComponentBehavior: Bound

import QtQuick
import "."

Item {
    id: frame

    readonly property real compactBreakpoint: 980
    readonly property real baseWidth: 1440
    readonly property real baseHeight: 900
    readonly property real scaleFactor: Math.max(0.72, Math.min(1.18, Math.min(width / baseWidth, height / baseHeight)))
    readonly property bool compact: width < frame.compactBreakpoint || height < 700
    readonly property real pageMargin: frame.dp(frame.compact ? 20 : 32)
    readonly property real cardInset: frame.dp(frame.compact ? 22 : 40)
    readonly property real cardBottomControlHeight: frame.dp(72)

    readonly property string typeface: roboto.name.length > 0 ? roboto.name : "Roboto"
    readonly property string iconTypeface: materialSymbols.name.length > 0 ? materialSymbols.name : "Material Symbols Outlined"
    readonly property int displayLarge: Math.round(frame.dp(MeoTheme.displayLargeEmphasized.size))
    readonly property int displaySmall: Math.round(frame.dp(MeoTheme.displaySmallEmphasized.size))
    readonly property int titleMedium: Math.round(frame.dp(MeoTheme.titleMediumEmphasized.size))
    readonly property int labelLarge: Math.round(frame.dp(MeoTheme.labelLargeEmphasized.size))
    readonly property int labelSmall: Math.round(frame.dp(MeoTheme.labelSmall.size))
    readonly property int bodyLarge: Math.round(frame.dp(MeoTheme.bodyLarge.size))
    property bool powerMenuOpen: false

    property string pageTitle: ""
    property int pageIndex: 0
    property int pageCount: 10
    default property alias content: pageContent.data
    property string primaryLabel: pageIndex === pageCount - 1 ? "Finish" : "Get Started"
    property bool showPrimaryButton: true
    property bool showBackButton: pageIndex > 0
    property url assetsRoot: Qt.resolvedUrl("../assets/")
    readonly property url fallbackAssetsRoot: Qt.resolvedUrl("../../assets/")

    signal nextRequested()
    signal previousRequested()
    signal exitRequested()

    function dp(value) {
        return Math.round(value * scaleFactor)
    }

    function asset(relativePath) {
        return String(assetsRoot) + relativePath
    }

    function useFallbackAssets() {
        if (String(assetsRoot) !== String(fallbackAssetsRoot))
            assetsRoot = fallbackAssetsRoot
    }

    FontLoader {
        id: roboto
        source: frame.asset("fonts/Roboto/Roboto-VariableFont_wdth,wght.ttf")
        onStatusChanged: if (status === FontLoader.Error) frame.useFallbackAssets()
    }

    FontLoader {
        id: materialSymbols
        source: frame.asset("fonts/Material_Symbols_Outlined,Material_Symbols_Rounded,Material_Symbols_Sharp/Material_Symbols_Outlined/static/MaterialSymbolsOutlined_28pt-Regular.ttf")
        onStatusChanged: if (status === FontLoader.Error) frame.useFallbackAssets()
    }

    Image {
        anchors.fill: parent
        source: frame.asset("wallpapers/installer_background.png")
        fillMode: Image.PreserveAspectCrop
        smooth: true
        onStatusChanged: if (status === Image.Error) frame.useFallbackAssets()
    }

    Rectangle {
        id: brandPill
        x: frame.pageMargin
        y: frame.pageMargin
        width: Math.min(frame.dp(278), parent.width - frame.pageMargin * 2 - topActions.width - frame.dp(20))
        height: frame.dp(48)
        radius: frame.dp(16)
        color: MeoTheme.surfaceContainerLow
        opacity: 0.94
        border.color: MeoTheme.outlineVariant
        border.width: 1

        Image {
            id: brandLogo
            x: frame.dp(20)
            anchors.verticalCenter: parent.verticalCenter
            width: frame.dp(64)
            height: frame.dp(28)
            source: frame.asset("icons/Logo.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
        }

        Text {
            anchors.left: brandLogo.right
            anchors.leftMargin: frame.dp(14)
            anchors.right: parent.right
            anchors.rightMargin: frame.dp(16)
            anchors.verticalCenter: parent.verticalCenter
            text: "MeoArch Installer"
            color: MeoTheme.onSurfaceVariant
            elide: Text.ElideRight
            font.family: frame.typeface
            font.weight: MeoTheme.titleMediumEmphasized.weight
            font.pixelSize: frame.titleMedium
        }
    }

    Row {
        id: topActions
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.topMargin: frame.pageMargin
        anchors.rightMargin: frame.pageMargin
        spacing: frame.dp(10)

        Repeater {
            model: [
                { icon: "help", label: "Help" },
                { icon: "language", label: "Language" },
                { icon: "power_settings_new", label: "Power" }
            ]

            Rectangle {
                id: topActionButton
                required property var modelData

                width: frame.dp(48)
                height: frame.dp(48)
                radius: frame.dp(16)
                color: MeoTheme.surfaceContainerLow
                opacity: 0.94

                Text {
                    anchors.centerIn: parent
                    text: topActionButton.modelData.icon
                    color: MeoTheme.onSurfaceVariant
                    font.family: frame.iconTypeface
                    font.pixelSize: frame.dp(24)
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        if (topActionButton.modelData.icon === "power_settings_new")
                            frame.powerMenuOpen = !frame.powerMenuOpen
                    }
                }
            }
        }
    }

    Rectangle {
        id: menuShadow
        anchors.top: topActions.bottom
        anchors.right: parent.right
        anchors.topMargin: frame.dp(16)
        anchors.rightMargin: frame.pageMargin - frame.dp(2)
        width: frame.dp(204)
        height: frame.dp(168)
        radius: frame.dp(20)
        visible: frame.powerMenuOpen
        color: MeoTheme.outlineVariant
        opacity: 0.28
    }

    Rectangle {
        id: menuCard
        anchors.top: topActions.bottom
        anchors.right: parent.right
        anchors.topMargin: frame.dp(12)
        anchors.rightMargin: frame.pageMargin
        width: menuShadow.width
        height: menuShadow.height
        radius: menuShadow.radius
        visible: frame.powerMenuOpen
        color: MeoTheme.surfaceContainerLow
        border.color: MeoTheme.outlineVariant
        border.width: 1

        Column {
            anchors.fill: parent
            anchors.margins: frame.dp(8)
            spacing: frame.dp(4)

            Repeater {
                model: [
                    { icon: "power_settings_new", label: "Power off" },
                    { icon: "restart_alt", label: "Restart" },
                    { icon: "bedtime", label: "Sleep" }
                ]

                Row {
                    id: powerMenuItem
                    required property var modelData

                    width: parent.width
                    height: frame.dp(48)
                    spacing: frame.dp(12)

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        text: powerMenuItem.modelData.icon
                        color: MeoTheme.onSurfaceVariant
                        font.family: frame.iconTypeface
                        font.pixelSize: frame.dp(20)
                    }

                    Text {
                        anchors.verticalCenter: parent.verticalCenter
                        width: frame.dp(128)
                        text: powerMenuItem.modelData.label
                        color: MeoTheme.onSurface
                        font.family: frame.typeface
                        font.weight: MeoTheme.labelLarge.weight
                        font.pixelSize: frame.labelLarge
                    }
                }
            }
        }
    }

    Rectangle {
        id: mainCard
        anchors.centerIn: parent
        width: Math.min(parent.width - frame.pageMargin * 2, frame.compact ? parent.width * 0.86 : parent.width * 0.62, frame.dp(1120))
        height: Math.min(parent.height - frame.pageMargin * 6, frame.compact ? parent.height * 0.66 : parent.height * 0.64, frame.dp(700))
        radius: frame.dp(32)
        color: MeoTheme.surface
        opacity: 0.88
        border.color: MeoTheme.primary
        border.width: Math.max(2, frame.dp(3))

        Item {
            id: pageContent
            anchors.fill: parent
            anchors.leftMargin: frame.cardInset
            anchors.rightMargin: frame.cardInset
            anchors.topMargin: frame.cardInset
            anchors.bottomMargin: frame.cardInset + frame.cardBottomControlHeight
        }

        Rectangle {
            visible: frame.showBackButton
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: frame.dp(22)
            anchors.bottomMargin: frame.dp(22)
            width: frame.dp(82)
            height: frame.dp(40)
            radius: frame.dp(20)
            color: MeoTheme.surfaceContainerHigh

            Row {
                anchors.centerIn: parent
                spacing: frame.dp(6)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "arrow_back"
                    color: MeoTheme.onSurfaceVariant
                    font.family: frame.iconTypeface
                    font.pixelSize: frame.dp(18)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Back"
                    color: MeoTheme.onSurfaceVariant
                    font.family: frame.typeface
                    font.weight: MeoTheme.labelSmall.weight
                    font.pixelSize: frame.labelSmall
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: frame.previousRequested()
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.bottom: parent.bottom
            anchors.leftMargin: frame.showBackButton ? frame.dp(114) : frame.dp(22)
            anchors.bottomMargin: frame.dp(22)
            width: frame.dp(74)
            height: frame.dp(40)
            radius: frame.dp(20)
            color: MeoTheme.surfaceContainerHigh

            Row {
                anchors.centerIn: parent
                spacing: frame.dp(6)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "logout"
                    color: MeoTheme.onSurfaceVariant
                    font.family: frame.iconTypeface
                    font.pixelSize: frame.dp(18)
                }

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "Exit"
                    color: MeoTheme.onSurfaceVariant
                    font.family: frame.typeface
                    font.weight: MeoTheme.labelSmall.weight
                    font.pixelSize: frame.labelSmall
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: frame.exitRequested()
            }
        }

        Rectangle {
            visible: frame.showPrimaryButton
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.rightMargin: frame.dp(22)
            anchors.bottomMargin: frame.dp(22)
            width: Math.max(frame.dp(136), primaryText.implicitWidth + frame.dp(56))
            height: frame.dp(40)
            radius: frame.dp(20)
            color: MeoTheme.primary

            Row {
                anchors.centerIn: parent
                spacing: frame.dp(8)

                Text {
                    anchors.verticalCenter: parent.verticalCenter
                    text: "stars"
                    color: MeoTheme.onPrimary
                    font.family: frame.iconTypeface
                    font.pixelSize: frame.dp(18)
                }

                Text {
                    id: primaryText
                    anchors.verticalCenter: parent.verticalCenter
                    text: frame.primaryLabel
                    color: MeoTheme.onPrimary
                    font.family: frame.typeface
                    font.weight: MeoTheme.labelLargeEmphasized.weight
                    font.pixelSize: frame.labelLarge
                }
            }

            MouseArea {
                anchors.fill: parent
                onClicked: frame.nextRequested()
            }
        }
    }

    Rectangle {
        anchors.left: parent.left
        anchors.bottom: parent.bottom
        anchors.leftMargin: frame.pageMargin
        anchors.bottomMargin: frame.dp(16)
        width: Math.min(parent.width - frame.pageMargin * 2, frame.dp(430))
        height: frame.dp(28)
        radius: frame.dp(14)
        color: MeoTheme.surfaceContainerLow
        opacity: 0.9

        Text {
            anchors.centerIn: parent
            text: "No disk changes will be made until the final confirmation step."
            color: MeoTheme.onSurfaceVariant
            font.family: frame.typeface
            font.weight: Font.Normal
            font.pixelSize: frame.labelSmall
        }
    }
}
