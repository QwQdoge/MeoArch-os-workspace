import QtQuick
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    readonly property string channel: controller ? controller.selection("software", "channel", "beta") : "beta"
    Column {
        width: parent.width
        spacing: page.dp(16)
        PageHeading {
            width: parent.width
            title: qsTr("Update channel")
            subtitle: qsTr("The selected pacman configuration is the single source of truth after installation.")
        }
        SelectionCard {
            width: parent.width
            title: qsTr("Stable")
            value: qsTr("No Stable core train is published for this beta trial. You can inspect this option, but the signed preflight will stop before any disk is written. Repository: meo")
            selected: page.channel === "stable"
            onClicked: controller.setSelection("software", "channel", "stable")
        }
        SelectionCard {
            width: parent.width
            title: qsTr("Beta")
            value: qsTr("Available for this ISO. Receives the signed beta trial components. Repositories: meo-beta, then meo fallback.")
            selected: page.channel === "beta"
            onClicked: controller.setSelection("software", "channel", "beta")
        }
        InfoBanner {
            width: parent.width
            title: qsTr("Official mirror")
            message: qsTr("Automatic uses packages.meoarch.org. This ISO is online-only; mirrors change download location, not update channel.")
        }
    }
}
