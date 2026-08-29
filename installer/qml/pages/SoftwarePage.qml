import QtQuick
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    readonly property string profile: controller ? controller.selection("software", "profile", "recommended") : "recommended"
    function selectProfile(value) {
        controller.setSelection("software", "profile", value)
        if (value !== "custom")
            controller.setSelection("software", "components", [])
    }
    function setComponent(name, enabled) {
        let next = controller.selection("software", "components", []).slice()
        const index = next.indexOf(name)
        if (enabled && index < 0)
            next.push(name)
        if (!enabled && index >= 0)
            next.splice(index, 1)
        controller.setSelection("software", "components", next)
    }
    function setApplication(name, enabled) {
        let next = controller.selection("software", "applications", []).slice()
        const index = next.indexOf(name)
        if (enabled && index < 0)
            next.push(name)
        if (!enabled && index >= 0)
            next.splice(index, 1)
        controller.setSelection("software", "applications", next)
    }
    Column {
        width: parent.width
        spacing: page.dp(16)
        PageHeading {
            width: parent.width
            title: qsTr("Choose what to install")
            subtitle: qsTr("All selections resolve through the signed MeoArch package repository.")
        }
        Repeater {
            model: [
                { id: "recommended", title: qsTr("Recommended"), detail: qsTr("Meo Desktop, MeoUI, icons, Settings, OmniStore, and required integration.") },
                { id: "minimal", title: qsTr("Minimal"), detail: qsTr("Meo Desktop core, MeoUI, icons, and required system integration.") },
                { id: "custom", title: qsTr("Custom"), detail: qsTr("Choose optional official components. Required desktop dependencies stay enabled.") }
            ]
            delegate: SelectionCard {
                required property var modelData
                width: parent.width
                title: modelData.title
                value: modelData.detail
                selected: page.profile === modelData.id
                onClicked: page.selectProfile(modelData.id)
            }
        }
        MeoCard {
            visible: page.profile === "custom"
            width: parent.width
            implicitHeight: customColumn.implicitHeight + page.dp(24)
            type: "filled"
            padding: page.dp(12)
            Column {
                id: customColumn
                width: parent.width
                spacing: page.dp(8)
                MeoCheckbox { text: qsTr("Meo Desktop (Required)"); checked: true; enabled: false }
                MeoCheckbox {
                    text: qsTr("Meo Settings")
                    checked: controller && controller.selection("software", "components", []).indexOf("meo-settings") >= 0
                    onToggled: checked => page.setComponent("meo-settings", checked)
                }
                MeoCheckbox {
                    text: qsTr("OmniStore")
                    checked: controller && controller.selection("software", "components", []).indexOf("omnistore-bin") >= 0
                    onToggled: checked => page.setComponent("omnistore-bin", checked)
                }
            }
        }
        MeoCard {
            visible: page.profile === "recommended"
            width: parent.width
            implicitHeight: recommendedApps.implicitHeight + page.dp(24)
            type: "filled"
            padding: page.dp(12)
            Column {
                id: recommendedApps
                width: parent.width
                spacing: page.dp(4)
                MeoText { text: qsTr("Included applications"); typeRole: "title"; typeSize: "small"; emphasized: true }
                MeoText {
                    width: parent.width
                    text: qsTr("Ark, Kate, Okular, and Spectacle are installed from signed Arch official repositories.")
                    typeRole: "body"
                    typeSize: "small"
                    wrapMode: Text.Wrap
                }
            }
        }
        MeoCard {
            visible: page.profile === "recommended" || page.profile === "custom"
            width: parent.width
            implicitHeight: optionalApps.implicitHeight + page.dp(24)
            type: "filled"
            padding: page.dp(12)
            Column {
                id: optionalApps
                width: parent.width
                spacing: page.dp(8)
                MeoText { text: qsTr("Optional official applications"); typeRole: "title"; typeSize: "small"; emphasized: true }
                MeoText {
                    width: parent.width
                    text: qsTr("These applications are installed only when selected.")
                    typeRole: "body"
                    typeSize: "small"
                    wrapMode: Text.Wrap
                }
                MeoCheckbox { text: qsTr("Firefox"); checked: controller && controller.selection("software", "applications", []).indexOf("firefox") >= 0; onToggled: checked => page.setApplication("firefox", checked) }
                MeoCheckbox { text: qsTr("LibreOffice"); checked: controller && controller.selection("software", "applications", []).indexOf("libreoffice-fresh") >= 0; onToggled: checked => page.setApplication("libreoffice-fresh", checked) }
                MeoCheckbox { text: qsTr("VLC"); checked: controller && controller.selection("software", "applications", []).indexOf("vlc") >= 0; onToggled: checked => page.setApplication("vlc", checked) }
                MeoCheckbox { text: qsTr("GIMP"); checked: controller && controller.selection("software", "applications", []).indexOf("gimp") >= 0; onToggled: checked => page.setApplication("gimp", checked) }
                MeoCheckbox { text: qsTr("Inkscape"); checked: controller && controller.selection("software", "applications", []).indexOf("inkscape") >= 0; onToggled: checked => page.setApplication("inkscape", checked) }
                MeoCheckbox { text: qsTr("Kdenlive"); checked: controller && controller.selection("software", "applications", []).indexOf("kdenlive") >= 0; onToggled: checked => page.setApplication("kdenlive", checked) }
            }
        }
    }
}
