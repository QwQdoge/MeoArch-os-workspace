pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import ".."
import "../components"

PageFrame {
    id: page
    primaryLabel: "Install Now"
    primaryAdvances: false
    property bool riskAccepted: false
    readonly property var summaryRows: [
        { title: "Language & Region", value: controller ? controller.systemLocale + " · " + controller.formatCountry + " · " + controller.timeZone : "" },
        { title: "Keyboard", value: controller ? controller.keyboardLayout : "" },
        { title: "Network", value: controller ? controller.networkState : "" },
        { title: "Privacy & Security", value: "Recommended protections" },
        { title: "Disk", value: controller ? controller.selectedDisk : "" },
        { title: "User Account", value: InstallerSession.username + " · " + InstallerSession.hostname }
    ]
    onPrimaryRequested: confirmDialog.open()
    Column {
        anchors.fill: parent; spacing: page.dp(12)
        PageHeading { width: parent.width; title: "Summary"; subtitle: "Review every choice before installation begins." }
        Rectangle {
            width: parent.width; height: page.dp(330); radius: page.dp(16); color: MeoTheme.surfaceContainerLow
            Column {
                anchors.fill: parent; anchors.leftMargin: page.dp(20); anchors.rightMargin: page.dp(20)
                Repeater {
                    model: page.summaryRows
                    delegate: Rectangle {
                        id: summaryRow
                        required property var modelData
                        width: parent.width; height: page.dp(54); color: "transparent"
                        Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; text: summaryRow.modelData.title; font.family: page.roboto; font.bold: true; font.pixelSize: page.dp(15); color: MeoTheme.onSurface }
                        Text { anchors.right: edit.left; anchors.rightMargin: page.dp(12); anchors.verticalCenter: parent.verticalCenter; width: parent.width * 0.52; horizontalAlignment: Text.AlignRight; elide: Text.ElideRight; text: summaryRow.modelData.value; font.family: page.roboto; font.pixelSize: page.dp(14); color: MeoTheme.onSurfaceVariant }
                        Text { id: edit; anchors.right: parent.right; anchors.verticalCenter: parent.verticalCenter; text: "›"; font.family: page.roboto; font.pixelSize: page.dp(22); color: MeoTheme.primary }
                    }
                }
            }
        }
        MeoButton { text: "Show Details"; kind: "text"; onClicked: detailsSheet.open() }
    }
    MotionPopup {
        id: detailsSheet
        presentation: "sheet"
        parent: Overlay.overlay; x: parent ? parent.width - width : 0; y: 0
        width: Math.min(page.dp(520), parent ? parent.width : page.dp(520)); height: parent ? parent.height : page.height
        modal: true; padding: page.dp(32); closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Column {
            spacing: page.dp(18)
            Text { text: "Installation details"; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(28); color: MeoTheme.onSurface }
            InfoBanner { width: parent.width; title: "Safe preview"; message: "Passwords, Wi-Fi secrets, and disk passphrases are excluded from this view." }
            Text { width: parent.width; text: "Bootloader\nGRUB\n\nKernel\nlinux\n\nDesktop\nMeoArch KDE Plasma + SDDM\n\nAudio and network\nPipeWire · NetworkManager\n\nDisk plan\n" + (page.controller ? page.controller.selectedDisk : "Not selected"); font.family: page.roboto; font.pixelSize: page.dp(15); lineHeight: 1.35; color: MeoTheme.onSurface }
            MeoButton { anchors.right: parent.right; text: "Done"; onClicked: detailsSheet.close() }
        }
    }
    MotionPopup {
        id: confirmDialog
        anchors.centerIn: Overlay.overlay; width: Math.min(page.dp(520), Overlay.overlay ? Overlay.overlay.width - page.dp(48) : page.dp(520)); height: page.dp(300); modal: true; padding: page.dp(28); closePolicy: Popup.CloseOnEscape
        contentItem: Column {
            spacing: page.dp(18)
            Text { width: parent.width; text: "Begin installation?"; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(28); color: MeoTheme.onSurface }
            InfoBanner { width: parent.width; tone: "error"; iconText: "!"; title: "The selected disk will be erased"; message: "This cannot be undone after disk changes begin." }
            CheckBox { id: accept; text: "I understand that the selected disk will be erased."; font.family: page.roboto; font.pixelSize: page.dp(14); onCheckedChanged: page.riskAccepted = checked }
            Row { anchors.right: parent.right; spacing: page.dp(8); MeoButton { text: "Cancel"; kind: "text"; onClicked: confirmDialog.close() } MeoButton { text: "Install"; enabled: accept.checked; onClicked: { page.controller.generatePreview(); page.controller.confirmSummary(); page.controller.startInstallation(); confirmDialog.close(); page.nextRequested() } } }
        }
    }
}
