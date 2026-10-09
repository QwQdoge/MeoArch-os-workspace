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
                    title: qsTr("Enable firewall")
                    subtitle: qsTr("Installs and enables the firewall on the installed system.")
                    checked: page.controller ? page.controller.selection("privacy", "firewall", true) : true
                    onToggled: checked => page.controller.setSelection("privacy", "firewall", checked)
                }
            }
        }
        InfoBanner {
            width: parent.width
            title: qsTr("Disk encryption")
            message: qsTr("Disk encryption is not available during installation. Data on the installed disk will not be encrypted.")
            tone: "info"
        }
        InfoBanner {
            width: parent.width
            title: qsTr("No telemetry or unattended updates")
            message: qsTr("MeoArch does not send usage data or install updates without your action.")
            tone: "info"
        }
    }
}
