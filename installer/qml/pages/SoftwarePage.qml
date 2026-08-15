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
            title: qsTr("Apps for your workflow")
            subtitle: qsTr("Optional app profiles remain user-confirmed after installation.")
        }
        InfoBanner {
            width: parent.width
            tone: "error"
            title: qsTr("OmniStore provisioning unavailable")
            message: qsTr("This ISO does not yet include a verified OmniStore runtime and first-login consumer for provisioning.json. No optional app profile can be selected until that integration is packaged and tested.")
        }
        MeoCard {
            width: parent.width
            implicitHeight: page.dp(120)
            type: "filled"
            padding: page.dp(20)
            MeoText {
                anchors.fill: parent
                text: qsTr("The base MeoArch system is installed without optional workflow bundles. This avoids recording an intent that no installed application can consume.")
                wrapMode: Text.WordWrap
                typeRole: "body"
                typeSize: "medium"
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
    }
}
