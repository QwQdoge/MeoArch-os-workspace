pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    primaryLabel: controller && controller.preflightState === "ready" ? qsTr("Install now")
                  : controller && controller.preflightState === "checking" ? qsTr("Checking installation plan…")
                  : qsTr("Prepare installation plan")
    primaryAdvances: false
    primaryEnabled: !(controller && controller.preflightState === "checking")
    property bool riskAccepted: false
    readonly property var summaryRows: [
        { pageIndex: 1, title: "Language & Region", value: controller ? controller.systemLocale + " · " + controller.formatCountry + " · " + controller.timeZone : "" },
        { pageIndex: 2, title: "Keyboard", value: controller ? controller.keyboardLayout : "" },
        { pageIndex: 3, title: qsTr("Network"), value: controller ? controller.networkDetail : "" },
        { pageIndex: 4, title: qsTr("Privacy & Security"), value: controller && controller.selection("privacy", "firewall", true) ? qsTr("Firewall enabled") : qsTr("Firewall not selected") },
        { pageIndex: 5, title: "Disk", value: controller ? controller.selectedDisk : "" },
        { pageIndex: 6, title: "User Account", value: InstallerSession.username + " · " + InstallerSession.hostname },
        { pageIndex: -1, title: "Graphics Drivers", value: controller ? controller.hardwareSummary : "Automatic PCI detection" }
    ]

    onPrimaryRequested: {
        if (controller && controller.preflightState === "ready") confirmDialog.open()
        else if (controller) controller.prepareInstallation()
    }

    Column {
        width: parent.width
        spacing: page.dp(12)

        PageHeading {
            width: parent.width
            title: qsTr("Summary")
            subtitle: qsTr("Prepare a validated Archinstall plan before any destructive action is enabled.")
        }
        InfoBanner {
            visible: page.controller && page.controller.preflightState !== "ready"
            width: parent.width
            title: page.controller && page.controller.preflightState === "failed" ? qsTr("Installation plan blocked") : qsTr("Installation plan not prepared")
            message: page.controller && page.controller.preflightMessage.length ? page.controller.preflightMessage : qsTr("Select a valid disk and account, then prepare the plan.")
            tone: page.controller && page.controller.preflightState === "failed" ? "error" : "info"
        }
        MeoCard {
            width: parent.width
            implicitHeight: summaryColumn.implicitHeight + page.dp(24)
            type: "filled"
            padding: page.dp(12)

            Column {
                id: summaryColumn
                width: parent.width
                Repeater {
                    model: page.summaryRows
                    delegate: MeoListItem {
                        required property var modelData
                        width: parent.width
                        implicitHeight: page.dp(52)
                        headline: modelData.title
                        supportingText: modelData.value
                        trailingComponent: Component {
                            MeoIcon { icon: "edit"; size: 20; color: MeoTheme.primary }
                        }
                        onClicked: page.navigateRequested(modelData.pageIndex)
                    }
                }
            }
        }
        MeoButton { text: "Show Details"; type: "text"; onClicked: detailsSheet.openFrom(this) }
    }

    MeoMotionPopup {
        id: detailsSheet
        presentation: MeoMotionPopup.SideSheet
        parent: Overlay.overlay
        x: parent ? parent.width - width : 0
        y: 0
        width: Math.min(page.dp(520), parent ? parent.width : page.dp(520))
        height: parent ? parent.height : page.height
        padding: page.dp(32)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside

        contentItem: Column {
            spacing: page.dp(18)
            MeoText { text: "Installation details"; typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
            InfoBanner { width: parent.width; title: qsTr("Secrets excluded"); message: qsTr("Passwords, Wi-Fi secrets, and disk passphrases are excluded from this view.") }
            MeoText {
                width: parent.width
                text: qsTr("Bootloader\nGRUB\n\nKernel\nlinux\n\nDesktop\nMeoArch KDE Plasma + SDDM\n\nAudio and network\nPipeWire · NetworkManager\n\nGraphics drivers\n") + (page.controller ? page.controller.hardwareSummary : qsTr("Detecting hardware…")) + "\n\n" + qsTr("Disk plan\n") + (page.controller ? page.controller.selectedDisk : qsTr("Not selected"))
                typeRole: "body"
                typeSize: "medium"
                lineHeight: 1.35
                color: MeoTheme.contentOnSurface
            }
            MeoButton { anchors.right: parent.right; text: "Done"; type: "filled"; onClicked: detailsSheet.close() }
        }
    }

    MeoMotionPopup {
        id: confirmDialog
        presentation: MeoMotionPopup.Dialog
        anchors.centerIn: Overlay.overlay
        width: Math.min(page.dp(520), Overlay.overlay ? Overlay.overlay.width - page.dp(48) : page.dp(520))
        height: page.dp(320)
        padding: page.dp(28)
        closePolicy: Popup.CloseOnEscape
        initialFocusItem: accept
        onAboutToShow: accept.checked = false

        contentItem: Column {
            spacing: page.dp(18)
            MeoText { width: parent.width; text: qsTr("Begin installation?"); typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
            InfoBanner { width: parent.width; tone: "error"; title: qsTr("The selected disk will be erased"); message: qsTr("This cannot be undone after disk changes begin.") }
            MeoCheckbox {
                id: accept
                text: qsTr("I understand that the selected disk will be erased.")
                onCheckedChanged: page.riskAccepted = checked
            }
            Row {
                anchors.right: parent.right
                spacing: page.dp(8)
                MeoButton { text: qsTr("Cancel"); type: "text"; onClicked: confirmDialog.close() }
                MeoButton {
                    text: qsTr("Install")
                    type: "filled"
                    enabled: accept.checked
                    onClicked: {
                        page.controller.confirmSummary()
                        if (page.controller.readyToInstall) {
                            page.controller.startInstallation()
                            confirmDialog.close()
                            page.nextRequested()
                        }
                    }
                }
            }
        }
    }
}
