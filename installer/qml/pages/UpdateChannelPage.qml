import QtQuick
import ".."
import "../components"

PageFrame {
    id: page
    // See SoftwarePage: selection() is an invokable. Include the observable
    // revision so the selected channel changes on the same interaction.
    readonly property var selectionRevision: controller && controller.selectionRevision !== undefined
                                           ? controller.selectionRevision : 0
    readonly property string channel: {
        const revision = selectionRevision
        return revision >= 0 && controller ? controller.selection("software", "channel", "stable") : "stable"
    }
    Column {
        width: parent.width
        spacing: page.dp(16)
        PageHeading {
            width: parent.width
            title: qsTr("Update channel")
            subtitle: qsTr("Choose how cautiously MeoArch updates after installation. Stable is the safe default for most people.")
        }
        SelectionCard {
            width: parent.width
            title: qsTr("Stable")
            value: qsTr("Recommended for most people. Receives tested MeoArch updates.")
            wrapValue: true
            selected: page.channel === "stable"
            selectionIndicator: true
            onClicked: page.controller.setSelection("software", "channel", "stable")
        }
        SelectionCard {
            width: parent.width
            title: qsTr("Beta")
            value: qsTr("Receives new features sooner. Updates may be less tested.")
            wrapValue: true
            selected: page.channel === "beta"
            selectionIndicator: true
            onClicked: page.controller.setSelection("software", "channel", "beta")
        }
        InfoBanner {
            visible: page.channel === "beta"
            width: parent.width
            title: qsTr("Beta is opt-in")
            message: qsTr("Choose Stable if you depend on this computer for important work.")
            tone: "warning"
        }
        InfoBanner {
            width: parent.width
            title: qsTr("Official mirror")
            message: qsTr("Downloads use the official MeoArch package mirror by default.")
        }
    }
}
