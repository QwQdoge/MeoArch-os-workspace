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
            implicitHeight: securityColumn.implicitHeight + page.dp(24)
            type: "filled"
            padding: page.dp(12)
            Column {
                id: securityColumn
                width: parent.width
                spacing: page.dp(8)
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
            message: qsTr("Encryption configuration belongs in Disk Selection. It is unavailable until its tested Archinstall secret flow is enabled.")
            tone: "info"
        }
        InfoBanner {
            width: parent.width
            title: qsTr("No telemetry or unattended updates")
            message: qsTr("MeoArch does not present diagnostics, automatic security updates, or global permission restrictions as switches without a real backend.")
            tone: "info"
        }
    }
}
