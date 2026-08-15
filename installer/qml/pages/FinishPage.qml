import QtQuick
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    showBackButton: false
    showPrimaryButton: false

    readonly property bool completed: page.controller && page.controller.installationState === "complete"

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
            MeoIcon { anchors.centerIn: parent; icon: page.completed ? "check" : "info"; size: 48; color: MeoTheme.contentOnPrimaryContainer }
        }
        MeoText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: page.completed ? qsTr("Installation complete") : qsTr("Installation has not completed")
            typeRole: "title"
            typeSize: "big"
            emphasized: true
            color: MeoTheme.contentOnSurface
        }
        Row {
            visible: page.completed
            width: parent.width
            spacing: page.dp(12)
            SelectionCard { width: (parent.width - page.dp(12)) / 2; height: page.dp(80); iconText: "eject"; title: "Remove installation media"; value: "Before restarting" }
            SelectionCard { width: (parent.width - page.dp(12)) / 2; height: page.dp(80); iconText: "description"; title: "Session log saved"; value: "Secrets excluded" }
        }
        InfoBanner {
            visible: !page.completed || (page.controller && !page.controller.systemActionsEnabled)
            width: parent.width
            title: page.completed ? qsTr("Preview mode") : qsTr("No completed installation")
            message: page.completed ? qsTr("Restart and Shut Down are safe no-op actions until system actions are enabled.")
                                    : qsTr("The finish screen is only available after target validation succeeds.")
        }
        Row {
            visible: page.completed
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: page.dp(12)
            MeoButton { text: "Restart Now"; type: "filled"; implicitWidth: page.dp(150); onClicked: page.controller.requestRestart() }
            MeoButton { text: "Shut Down"; type: "outlined"; implicitWidth: page.dp(140); onClicked: page.controller.requestShutdown() }
        }
    }
}
