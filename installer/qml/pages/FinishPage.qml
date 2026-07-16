import QtQuick
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    showBackButton: false
    showPrimaryButton: false

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -page.dp(12)
        width: Math.min(parent.width, page.dp(680))
        spacing: page.dp(20)

        MeoShape {
            anchors.horizontalCenter: parent.horizontalCenter
            width: page.dp(96)
            height: page.dp(96)
            radius: width / 2
            color: MeoTheme.primaryContainer
            MeoIcon { anchors.centerIn: parent; icon: "check"; size: 48; color: MeoTheme.contentOnPrimaryContainer }
        }
        MeoText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: "Installation complete"
            typeRole: "title"
            typeSize: "big"
            emphasized: true
            color: MeoTheme.contentOnSurface
        }
        Row {
            width: parent.width
            spacing: page.dp(12)
            SelectionCard { width: (parent.width - page.dp(12)) / 2; height: page.dp(80); iconText: "eject"; title: "Remove installation media"; value: "Before restarting" }
            SelectionCard { width: (parent.width - page.dp(12)) / 2; height: page.dp(80); iconText: "description"; title: "Session log saved"; value: "Secrets excluded" }
        }
        InfoBanner {
            visible: page.controller && !page.controller.systemActionsEnabled
            width: parent.width
            title: "Preview mode"
            message: "Restart and Shut Down are safe no-op actions until system actions are enabled."
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: page.dp(12)
            MeoButton { text: "Restart Now"; type: "filled"; implicitWidth: page.dp(150); onClicked: page.controller.requestRestart() }
            MeoButton { text: "Shut Down"; type: "outlined"; implicitWidth: page.dp(140); onClicked: page.controller.requestShutdown() }
        }
    }
}
