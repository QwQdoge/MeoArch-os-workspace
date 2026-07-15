pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import MeoUI 1.0 as Meo
import ".."
import "../components"

PageFrame {
    id: page
    showBackButton: false
    showPrimaryButton: controller && controller.installationState === "complete"
    primaryLabel: "Continue"
    readonly property var stages: ["Validating configuration", "Preparing disk and filesystems", "Installing and configuring MeoArch", "Final checks"]
    Column {
        anchors.fill: parent; spacing: page.dp(18)
        PageHeading { width: parent.width; title: "Installing"; subtitle: "Keep this device powered on while MeoArch is installed." }
        Row {
            width: parent.width; spacing: page.dp(16)
            Text { text: page.controller ? page.controller.installationProgress + "%" : "0%"; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(40); color: MeoTheme.primary }
            Text { anchors.baseline: parent.children[0].baseline; text: page.controller && page.controller.installationState === "complete" ? "Installation complete" : "Working…"; font.family: page.roboto; font.pixelSize: page.dp(16); color: MeoTheme.onSurfaceVariant }
        }
        Meo.MeoProgressBar { width: parent.width; height: page.dp(8); value: page.controller ? page.controller.installationProgress / 100 : 0; isThick: true; vibrant: true }
        Rectangle {
            width: parent.width; height: page.dp(240); radius: page.dp(16); color: MeoTheme.surfaceContainerLow
            Column {
                anchors.fill: parent; anchors.leftMargin: page.dp(20); anchors.rightMargin: page.dp(20)
                Repeater {
                    model: page.stages
                    delegate: Rectangle {
                        id: stageRow
                        required property string modelData
                        required property int index
                        width: parent.width; height: page.dp(56); color: "transparent"
                        readonly property int threshold: index * 25
                        MeoBusyIndicator { id: stageSpinner; anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; width: page.dp(22); height: page.dp(22); running: visible; visible: page.controller && page.controller.installationProgress >= parent.threshold && page.controller.installationProgress < parent.threshold + 25 }
                        Text { anchors.left: parent.left; anchors.verticalCenter: parent.verticalCenter; visible: !stageSpinner.visible; text: page.controller && page.controller.installationProgress >= parent.threshold + 25 ? "✓" : "○"; color: page.controller && page.controller.installationProgress >= parent.threshold ? MeoTheme.primary : MeoTheme.outline; font.pixelSize: page.dp(20) }
                        Text { anchors.left: parent.left; anchors.leftMargin: page.dp(36); anchors.verticalCenter: parent.verticalCenter; text: stageRow.modelData; font.family: page.roboto; font.pixelSize: page.dp(15); font.weight: page.controller && page.controller.installationProgress >= parent.threshold && page.controller.installationProgress < parent.threshold + 25 ? Font.Bold : Font.Normal; color: MeoTheme.onSurface }
                    }
                }
            }
        }
        MeoButton { text: "Show Details"; kind: "text"; onClicked: logPopup.open() }
    }
    MotionPopup {
        id: logPopup; anchors.centerIn: Overlay.overlay; width: Math.min(page.dp(720), Overlay.overlay ? Overlay.overlay.width - page.dp(64) : page.dp(720)); height: page.dp(420); modal: true; padding: page.dp(24); closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        surfaceColor: "#252329"
        contentItem: Column { spacing: page.dp(12); Text { text: "Installation details"; color: "white"; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(24) } Text { width: parent.width; text: "[preview] configuration validated\n[preview] disk plan prepared\n[preview] MeoArch packages configured\nSecrets are never written to this log."; color: "#E9E4EC"; font.family: page.roboto; font.pixelSize: page.dp(13); lineHeight: 1.5 } }
    }
}
