import QtQuick
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    Column {
        width: parent.width
        spacing: page.dp(16)
        PageHeading {
            width: parent.width
            title: qsTr("Privacy & Security")
            subtitle: qsTr("Only settings that are applied to the installed system are shown here.")
        }
        MeoCard {
            width: parent.width
            implicitHeight: securityColumn.implicitHeight + page.dp(32)
            type: "filled"
            padding: page.dp(16)
            Column {
                id: securityColumn
                width: parent.width
                spacing: page.dp(6)
                MeoText {
                    width: parent.width
                    text: qsTr("System protection")
                    typeRole: "label"
                    typeSize: "medium"
                    emphasized: true
                    color: MeoTheme.contentOnSurfaceVariant
                }
                ToggleRow {
                    width: parent.width
                    title: qsTr("Enable firewalld")
                    subtitle: qsTr("Installs firewalld and enables its service on the installed system.")
                    checked: page.controller ? page.controller.selection("privacy", "firewall", true) : true
                    onToggled: checked => page.controller.setSelection("privacy", "firewall", checked)
                }
            }
        }
        InfoBanner {
            width: parent.width
            title: qsTr("Disk encryption")
            message: qsTr("Disk encryption is not available in this installer yet. It is intentionally hidden until its secret, recovery, and rollback flow is tested.")
            tone: "info"
        }
        InfoBanner {
            width: parent.width
            title: qsTr("No telemetry or unattended updates")
            message: qsTr("MeoArch does not show settings without a real backend. Updates and diagnostics stay under your control.")
            tone: "info"
        }
    }
}
