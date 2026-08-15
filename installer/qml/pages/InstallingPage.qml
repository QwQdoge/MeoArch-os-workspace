import QtQuick
import QtQuick.Controls
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    showBackButton: false
    showPrimaryButton: controller && controller.installationState === "complete"
    primaryLabel: qsTr("Continue")
    Column {
        width: parent.width
        spacing: page.dp(18)
        PageHeading { width: parent.width; title: qsTr("Installing"); subtitle: qsTr("Keep this device powered on while MeoArch is installed.") }
        Row {
            width: parent.width; spacing: page.dp(16)
            MeoText { text: page.controller ? page.controller.installationProgress + "%" : "0%"; typeRole: "title"; typeSize: "big"; emphasized: true; color: MeoTheme.primary }
            MeoText {
                anchors.baseline: parent.children[0].baseline
                text: page.controller && page.controller.installationState === "complete" ? qsTr("Installation complete")
                      : page.controller && page.controller.installationState === "failed" ? qsTr("Installation stopped")
                      : page.controller && page.controller.installationMessage.length ? page.controller.installationMessage : qsTr("Waiting to start…")
                typeRole: "body"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant
            }
        }
        MeoProgressBar { width: parent.width; height: page.dp(8); value: page.controller ? page.controller.installationProgress / 100 : 0; isThick: true; vibrant: true }
        MeoCard {
            width: parent.width
            implicitHeight: page.dp(158)
            type: "filled"
            padding: page.dp(20)
            Column {
                width: parent.width; spacing: page.dp(12)
                Row {
                    spacing: page.dp(12)
                    MeoLoadingIndicator { visible: page.controller && page.controller.installationState === "running"; indeterminate: true; width: page.dp(22); height: width }
                    MeoIcon { visible: !page.controller || page.controller.installationState !== "running"; icon: page.controller && page.controller.installationState === "complete" ? "check_circle" : "info"; size: page.dp(22); color: MeoTheme.primary }
                    MeoText { text: page.controller && page.controller.installationStage.length ? page.controller.installationStage : qsTr("Preflight"); typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                }
                MeoText { width: parent.width; text: page.controller && page.controller.installationMessage.length ? page.controller.installationMessage : qsTr("Structured installation events will appear here."); wrapMode: Text.WordWrap; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                MeoText { width: parent.width; text: qsTr("Live diagnostic log: /tmp/meoarch-installer/logs/install.log"); typeRole: "body"; typeSize: "small"; color: MeoTheme.outline }
            }
        }
        InfoBanner {
            visible: page.controller && page.controller.installationState === "failed"
            width: parent.width; tone: "error"; title: qsTr("Installation failed")
            message: page.controller.errorMessage.length ? page.controller.errorMessage : qsTr("See the diagnostic log for the failing stage. Disk operations are not automatically retried.")
        }
    }
}
