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
        spacing: page.compactHeight ? page.dp(12) : page.dp(20)

        MeoShape {
            anchors.horizontalCenter: parent.horizontalCenter
            width: page.compactHeight ? page.dp(72) : page.dp(96)
            height: width
            radius: width / 2
            color: MeoTheme.primaryContainer
            MeoIcon { anchors.centerIn: parent; icon: page.completed ? "check" : "info"; size: page.dp(48); color: MeoTheme.contentOnPrimaryContainer }
        }
        MeoText {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: page.completed ? qsTr("Installation complete") : qsTr("Installation has not completed")
            typeRole: "title"
            typeSize: page.compactHeight ? "large" : "big"
            emphasized: true
            color: MeoTheme.contentOnSurface
        }
        Row {
            visible: page.completed
            width: parent.width
            spacing: page.dp(12)
            SelectionCard { width: (parent.width - page.dp(12)) / 2; iconText: "eject"; title: qsTr("Remove installation media"); value: qsTr("Before restarting"); wrapValue: true; actionable: false; trailingIcon: "" }
            SelectionCard { width: (parent.width - page.dp(12)) / 2; iconText: "description"; title: qsTr("Live diagnostic log"); value: qsTr("Available until restart: /tmp/meoarch-installer/logs/install.log"); wrapValue: true; actionable: false; trailingIcon: "" }
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
            MeoButton { text: qsTr("Restart Now"); type: "filled"; implicitWidth: page.dp(150); onClicked: page.controller.requestRestart() }
            MeoButton { text: qsTr("Shut Down"); type: "outlined"; implicitWidth: page.dp(140); onClicked: page.controller.requestShutdown() }
        }
    }
}
