import QtQuick
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    readonly property string channel: controller ? controller.selection("software", "channel", "stable") : "stable"
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
            value: qsTr("Recommended for most users. Receives fully tested MeoArch release trains. Repository: meo")
            selected: page.channel === "stable"
            onClicked: controller.setSelection("software", "channel", "stable")
        }
        SelectionCard {
            width: parent.width
            title: qsTr("Beta")
            value: qsTr("Receives newer Meo components before Stable and may be less tested. Repositories: meo-beta, then meo fallback.")
            selected: page.channel === "beta"
            onClicked: controller.setSelection("software", "channel", "beta")
        }
        InfoBanner {
            width: parent.width
            title: qsTr("Official mirror")
            message: qsTr("Automatic uses packages.meoarch.org. Mirrors change download location, not update channel.")
        }
    }
}
