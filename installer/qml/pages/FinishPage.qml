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

        Item {
            anchors.horizontalCenter: parent.horizontalCenter
            width: page.compactHeight ? page.dp(72) : page.dp(96)
            height: width

            // Decorative celebration ring; only while the install succeeded.
            MeoShape {
                id: ring
                anchors.fill: parent
                radius: width / 2
                color: MeoTheme.primaryContainer
                opacity: 0
                visible: page.completed && !MeoTheme.reduceMotion
                ParallelAnimation {
                    running: ring.visible
                    loops: Animation.Infinite
                    NumberAnimation { target: ring; property: "scale"; from: 1; to: 1.9; duration: 2400; easing.type: Easing.OutCubic }
                    SequentialAnimation {
                        NumberAnimation { target: ring; property: "opacity"; from: 0.55; to: 0; duration: 2400; easing.type: Easing.OutQuad }
                    }
                }
            }
            MeoShape {
                id: badge
                anchors.fill: parent
                radius: width / 2
                color: MeoTheme.primaryContainer
                MeoIcon { anchors.centerIn: parent; icon: page.completed ? "check" : "info"; size: page.dp(48); color: MeoTheme.contentOnPrimaryContainer }
            }
            EntranceAnimation { id: badgePop; item: badge; fromScale: 0.4 }
            Component.onCompleted: badgePop.play()
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
            message: page.completed ? qsTr("Restart and Shut Down are disabled in preview mode.")
                                    : qsTr("The finish screen is only available after target validation succeeds.")
        }
        Row {
            visible: page.completed
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: page.dp(12)
            MeoButton {
                text: qsTr("Restart Now")
                type: "filled"
                implicitWidth: page.dp(150)
                enabled: page.controller && page.controller.systemActionsEnabled
                onClicked: page.controller.requestRestart()
            }
            MeoButton {
                text: qsTr("Shut Down")
                type: "outlined"
                implicitWidth: page.dp(140)
                enabled: page.controller && page.controller.systemActionsEnabled
                onClicked: page.controller.requestShutdown()
            }
        }
    }
}
