import QtQuick
import ".."
import "../components"

PageFrame {
    id: page
    showBackButton: false
    showPrimaryButton: false
    Column {
        anchors.centerIn: parent; anchors.verticalCenterOffset: -page.dp(12); width: Math.min(parent.width, page.dp(680)); spacing: page.dp(20)
        Rectangle { anchors.horizontalCenter: parent.horizontalCenter; width: page.dp(96); height: page.dp(96); radius: 48; color: MeoTheme.primaryContainer; Text { anchors.centerIn: parent; text: "OK"; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(28); color: MeoTheme.primary } }
        Text { width: parent.width; horizontalAlignment: Text.AlignHCenter; text: "Installation complete"; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(40); color: MeoTheme.onSurface }
        Row { width: parent.width; spacing: page.dp(12); SelectionCard { width: (parent.width-page.dp(12))/2; height: page.dp(76); iconText: "1"; title: "Remove installation media"; value: "Before restarting" } SelectionCard { width: (parent.width-page.dp(12))/2; height: page.dp(76); iconText: "2"; title: "Session log saved"; value: "Secrets excluded" } }
        InfoBanner { visible: page.controller && !page.controller.systemActionsEnabled; width: parent.width; iconText: "i"; title: "Preview mode"; message: "Restart and Shut Down are safe no-op actions until system actions are enabled." }
        Row { anchors.horizontalCenter: parent.horizontalCenter; spacing: page.dp(12); MeoButton { text: "Restart Now"; minWidth: page.dp(150); onClicked: page.controller.requestRestart() } MeoButton { text: "Shut Down"; kind: "outlined"; minWidth: page.dp(140); onClicked: page.controller.requestShutdown() } }
    }
}
