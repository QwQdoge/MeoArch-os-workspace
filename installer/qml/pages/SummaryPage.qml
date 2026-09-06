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
    primaryAccessibleDescription: controller && controller.preflightState === "ready"
                                  ? qsTr("Opens a final confirmation before installation can begin")
                                  : qsTr("Validates the installation plan without writing the selected disk")
    property bool riskAccepted: false
    readonly property var resolvedRepository: controller && controller.installPlan.repository
                                              ? controller.installPlan.repository : ({})
    readonly property var resolvedPackage: controller && controller.installPlan.package
                                           ? controller.installPlan.package : ({})
    readonly property var resolvedApplications: controller && controller.installPlan.applications
                                                ? controller.installPlan.applications : ({})
    function profileLabel(profile) {
        if (profile === "minimal") return qsTr("Minimal")
        if (profile === "custom") return qsTr("Custom")
        return qsTr("Recommended")
    }
    function channelLabel(channel) {
        return channel === "beta" ? qsTr("Beta") : qsTr("Stable")
    }
    function joined(values, separator, fallback) {
        return values && values.length ? Array.from(values).join(separator) : fallback
    }
    readonly property var summaryRows: [
        { pageIndex: 1, title: qsTr("Language & Region"), value: controller ? controller.systemLocale + " · " + controller.formatCountry + " · " + controller.timeZone : "" },
        { pageIndex: 2, title: qsTr("Keyboard"), value: controller ? controller.keyboardLayout : "" },
        { pageIndex: 3, title: qsTr("Network"), value: controller ? controller.networkDetail : "" },
        { pageIndex: 4, title: qsTr("Privacy & Security"), value: controller && controller.selection("privacy", "firewall", true) ? qsTr("Firewall enabled") : qsTr("Firewall not selected") },
        { pageIndex: 5, title: qsTr("Disk"), value: controller ? controller.selectedDisk : "" },
        { pageIndex: 6, title: qsTr("User Account"), value: InstallerSession.username + " · " + InstallerSession.hostname },
        { pageIndex: 7, title: qsTr("Software"), value: controller ? page.profileLabel(controller.selection("software", "profile", "recommended")) : "" },
        { pageIndex: 8, title: qsTr("Meo channel"), value: controller ? page.channelLabel(controller.selection("software", "channel", "stable")) : "" },
        { pageIndex: -1, title: qsTr("Graphics Drivers"), value: controller ? controller.hardwareSummary : qsTr("Automatic PCI detection") }
    ]

    onPrimaryRequested: {
        if (controller && controller.preflightState === "ready") confirmDialog.open()
        else if (controller) controller.prepareInstallation()
    }

    Column {
        width: parent.width
        spacing: page.compactHeight ? page.dp(8) : page.dp(12)

        Item {
            width: parent.width
            implicitHeight: Math.max(summaryHeading.implicitHeight, detailsButton.implicitHeight)

            PageHeading {
                id: summaryHeading
                anchors.left: parent.left
                anchors.right: detailsButton.left
                anchors.rightMargin: page.dp(8)
                title: qsTr("Summary")
                subtitle: qsTr("Prepare a validated Archinstall plan before any destructive action is enabled.")
            }
            MeoButton {
                id: detailsButton
                anchors.top: parent.top
                anchors.right: parent.right
                text: qsTr("Details")
                type: "text"
                size: "s"
                Accessible.description: qsTr("Show installation details without secrets")
                onClicked: detailsSheet.openFrom(this)
            }
        }
        InfoBanner {
            visible: page.controller
            width: parent.width
            title: page.controller.preflightState === "ready" ? qsTr("Installation plan ready")
                   : page.controller.preflightState === "failed" ? qsTr("Installation plan blocked")
                   : qsTr("Installation plan not prepared")
            message: page.controller.preflightState === "ready"
                     ? qsTr("Review the selected disk and settings. Install now opens one final erase confirmation.")
                     : page.controller.preflightMessage.length ? page.controller.preflightMessage
                                                               : qsTr("Select a valid disk and account, then prepare the plan.")
            tone: page.controller.preflightState === "ready" ? "success"
                  : page.controller.preflightState === "failed" ? "error" : "info"
        }
        MeoCard {
            visible: page.resolvedPackage.packages && page.resolvedPackage.packages.length > 0
            width: parent.width
            type: "outlined"
            padding: page.dp(16)
            implicitHeight: resolvedPlanColumn.implicitHeight + page.dp(32)

            Column {
                id: resolvedPlanColumn
                width: parent.width
                spacing: page.dp(8)
                MeoText {
                    width: parent.width
                    text: qsTr("Validated Meo package plan")
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                    color: MeoTheme.contentOnSurface
                }
                MeoText {
                    width: parent.width
                    text: qsTr("Repositories: %1").arg(page.joined(page.resolvedRepository.repositories, " → ", qsTr("Not prepared")))
                    typeRole: "body"
                    typeSize: "medium"
                    color: MeoTheme.contentOnSurfaceVariant
                    wrapMode: Text.WordWrap
                }
                MeoText {
                    width: parent.width
                    text: qsTr("System application packages: %1").arg(page.joined(page.resolvedApplications.nativePackages, ", ", qsTr("None")))
                    typeRole: "body"
                    typeSize: "medium"
                    color: MeoTheme.contentOnSurfaceVariant
                    wrapMode: Text.WordWrap
                }
                MeoText {
                    width: parent.width
                    text: qsTr("Meo packages: %1").arg(page.joined(page.resolvedPackage.packages, ", ", qsTr("Not prepared")))
                    typeRole: "body"
                    typeSize: "medium"
                    color: MeoTheme.contentOnSurfaceVariant
                    wrapMode: Text.WordWrap
                }
            }
        }
        MeoCard {
            width: parent.width
            implicitHeight: summaryColumn.implicitHeight + (page.compactHeight ? page.dp(16) : page.dp(24))
            type: "filled"
            padding: page.compactHeight ? page.dp(8) : page.dp(12)

            Column {
                id: summaryColumn
                width: parent.width
                Repeater {
                    model: page.summaryRows
                    delegate: Column {
                        required property var modelData
                        required property int index
                        width: parent.width
                        spacing: 0

                        MeoListItem {
                            width: parent.width
                            implicitHeight: page.compactHeight ? page.dp(48) : page.dp(52)
                            headline: modelData.title
                            supportingText: modelData.value
                            interactive: modelData.pageIndex >= 0
                            isSegmented: true
                            roundingStrategy: index === 0 ? "top"
                                              : index === page.summaryRows.length - 1 ? "bottom" : "middle"
                            Accessible.description: modelData.pageIndex >= 0
                                                    ? qsTr("Select to edit this choice") : ""
                            trailingComponent: Component {
                                MeoIcon {
                                    visible: modelData.pageIndex >= 0
                                    icon: "edit"
                                    size: 20
                                    color: MeoTheme.primary
                                }
                            }
                            onClicked: {
                                if (modelData.pageIndex >= 0)
                                    page.navigateRequested(modelData.pageIndex)
                            }
                        }
                        MeoDivider {
                            width: parent.width - page.dp(32)
                            height: Math.max(1, MeoTheme.strokeWidthThin)
                            anchors.horizontalCenter: parent.horizontalCenter
                            visible: index < page.summaryRows.length - 1
                            opacity: 0.72
                        }
                    }
                }
            }
        }
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
            MeoText { text: qsTr("Installation details"); typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
            InfoBanner { width: parent.width; title: qsTr("Secrets excluded"); message: qsTr("Passwords, Wi-Fi secrets, and disk passphrases are excluded from this view.") }
            MeoText {
                width: parent.width
                text: qsTr("Bootloader\nGRUB\n\nKernel\nlinux\n\nDesktop\nMeoArch KDE Plasma + SDDM\n\nAudio and network\nPipeWire · NetworkManager\n\nGraphics drivers\n") + (page.controller ? page.controller.hardwareSummary : qsTr("Detecting hardware…"))
                      + "\n\n" + qsTr("Disk plan\n") + (page.controller ? page.controller.selectedDisk : qsTr("Not selected"))
                      + "\n\n" + qsTr("Meo repositories\n") + page.joined(page.resolvedRepository.repositories, " → ", qsTr("Prepare the installation plan to resolve repositories."))
                      + "\n\n" + qsTr("Meo packages\n") + page.joined(page.resolvedPackage.packages, "\n", qsTr("Prepare the installation plan to resolve packages."))
                      + "\n\n" + qsTr("System application packages\n") + page.joined(page.resolvedApplications.nativePackages, "\n", qsTr("None"))
                typeRole: "body"
                typeSize: "medium"
                lineHeight: 1.35
                color: MeoTheme.contentOnSurface
            }
            MeoButton { anchors.right: parent.right; text: qsTr("Done"); type: "filled"; onClicked: detailsSheet.close() }
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
                    text: qsTr("Erase disk and install")
                    type: "filled"
                    enabled: accept.checked
                    Accessible.description: qsTr("Starts the confirmed destructive installation")
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
