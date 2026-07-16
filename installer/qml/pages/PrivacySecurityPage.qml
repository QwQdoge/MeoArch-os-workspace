pragma ComponentBehavior: Bound
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
            title: "Privacy & Security"
            subtitle: "Review recommended privacy defaults and security protections."
        }
        InfoBanner {
            width: parent.width
            height: page.dp(64)
            title: "Recommended protections are enabled"
            tone: "info"
        }
        MeoCard {
            width: parent.width
            implicitHeight: page.dp(294)
            type: "filled"
            padding: page.dp(20)

            Column {
                width: parent.width
                Repeater {
                    model: [
                        { key: "diagnostics", title: "Share anonymous diagnostics", value: false },
                        { key: "firewall", title: "Firewall", value: true },
                        { key: "securityUpdates", title: "Automatic security updates", value: true },
                        { key: "diskEncryption", title: "Encrypt installation disk", value: false },
                        { key: "restrictAppPermissions", title: "Restrict app permissions by default", value: true }
                    ]
                    delegate: ToggleRow {
                        required property var modelData
                        width: parent.width
                        checked: page.controller ? page.controller.selection("privacy", modelData.key, modelData.value) : modelData.value
                        title: modelData.title
                        onToggled: checked => page.controller.setSelection("privacy", modelData.key, checked)
                    }
                }
            }
        }
    }
}
