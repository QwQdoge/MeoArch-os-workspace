import QtQuick
import QtQuick.Layouts
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    primaryLabel: qsTr("Continue installation")
    showBackButton: false
    property bool showTryHint: false

    Column {
        width: parent.width
        y: Math.max(0, (parent.height - implicitHeight) / 2)
        spacing: page.dp(20)

        GridLayout {
            width: parent.width
            columns: width < page.dp(760) ? 1 : 2
            columnSpacing: page.dp(44)
            rowSpacing: page.dp(24)

            Column {
                Layout.fillWidth: true
                Layout.preferredWidth: page.dp(420)
                spacing: page.dp(18)

                Image {
                    width: page.dp(100)
                    height: page.dp(64)
                    source: page.asset("icons/Logo.png")
                    fillMode: Image.PreserveAspectFit
                    Accessible.name: qsTr("MeoArch OS")
                }
                MeoText {
                    width: parent.width
                    text: qsTr("Start using MeoArch OS")
                    typeRole: "title"
                    typeSize: "big"
                    emphasized: true
                    color: MeoTheme.contentOnSurface
                    wrapMode: Text.WordWrap
                }
                MeoText {
                    width: parent.width
                    text: qsTr("Install it on this computer, or explore the Live desktop first. You can return to installation when you are ready.")
                    typeRole: "body"
                    typeSize: "big"
                    color: MeoTheme.contentOnSurfaceVariant
                    wrapMode: Text.WordWrap
                }
                InfoBanner {
                    width: parent.width
                    title: qsTr("Your disk is safe until confirmation")
                    message: qsTr("Review the storage choice and installation plan before any changes are made.")
                    tone: "info"
                }
            }

            Column {
                Layout.fillWidth: true
                Layout.preferredWidth: page.dp(500)
                spacing: page.dp(14)

                SelectionCard {
                    width: parent.width
                    iconText: "download"
                    title: qsTr("Install MeoArch OS")
                    value: qsTr("Set up this computer with MeoArch OS.")
                    selectionIndicator: true
                    selected: true
                    onClicked: page.nextRequested()
                }
                SelectionCard {
                    width: parent.width
                    iconText: "explore"
                    title: qsTr("Try the Live desktop first")
                    value: page.desktopLive
                           ? qsTr("Close the installer and explore without changing your disk.")
                           : qsTr("Restart and choose the graphical setup entry to reach the Live desktop.")
                    wrapValue: true
                    trailingIcon: "chevron_right"
                    onClicked: page.desktopLive ? page.exitRequested() : page.showTryHint = true
                }
                InfoBanner {
                    visible: page.showTryHint
                    width: parent.width
                    title: qsTr("Open the Live desktop")
                    message: qsTr("Restart, then choose “Install MeoArch OS — graphical setup” in the boot menu. The installer opens on the Live desktop and can be closed while you explore.")
                    tone: "info"
                }
                MeoCard {
                    width: parent.width
                    type: "outlined"
                    Accessible.name: qsTr("Live environment check")
                    ColumnLayout {
                        anchors.fill: parent
                        spacing: page.dp(8)
                        RowLayout {
                            Layout.fillWidth: true
                            MeoIcon { icon: "fact_check"; size: page.dp(20); color: MeoTheme.primary }
                            MeoText {
                                Layout.fillWidth: true
                                text: qsTr("Live environment check")
                                typeRole: "title"
                                typeSize: "small"
                                emphasized: true
                            }
                            MeoBadge { text: qsTr("LIVE") }
                        }
                        MeoText {
                            Layout.fillWidth: true
                            text: qsTr("Firmware: %1 · Network: %2 · Hardware: %3")
                                  .arg(page.controller && page.controller.firmwareMode === "bios" ? qsTr("Legacy BIOS") : qsTr("UEFI"))
                                  .arg(page.controller && (page.controller.networkState === "online" || page.controller.networkState === "repository") ? qsTr("Connected") : qsTr("Check connection"))
                                  .arg(page.controller && page.controller.hardwareDetecting ? qsTr("Checking")
                                       : page.controller && page.controller.hardwareDetected ? qsTr("Detected")
                                       : qsTr("Compatibility mode"))
                            typeRole: "body"
                            typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        InfoBanner {
            visible: page.controller && page.controller.hardwareWarning.length > 0
            width: parent.width
            tone: "warning"
            title: qsTr("Graphics compatibility mode")
            message: page.controller ? page.controller.hardwareWarning : ""
        }
        InfoBanner {
            visible: page.controller && page.controller.firmwareMode === "bios"
            width: parent.width
            tone: "warning"
            title: qsTr("UEFI boot required")
            message: qsTr("This installer supports UEFI target installations. Restart with UEFI firmware enabled before installing. No disk changes have been made.")
        }
    }
}
