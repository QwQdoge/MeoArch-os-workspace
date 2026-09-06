import QtQuick
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    readonly property string profile: controller ? controller.selection("software", "profile", "recommended") : "recommended"
    readonly property var softwareCatalog: controller ? controller.softwareCatalog : []
    function selectProfile(value) {
        controller.setSelection("software", "profile", value)
        controller.setSelection("software", "components", value === "custom" ? ["meo-desktop"] : [])
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
    function applicationsForTier(tier) {
        return Array.from(page.softwareCatalog).filter(application => application.tier === tier)
    }
    function applicationIsDefault(application) {
        return Array.from(application.profiles || []).indexOf(page.profile) >= 0
    }
    function applicationIsSelected(application) {
        return page.applicationIsDefault(application)
               || (controller && controller.selection("software", "applications", []).indexOf(application.id) >= 0)
    }
    function setApplication(application, enabled) {
        if (page.applicationIsDefault(application))
            return
        let next = controller.selection("software", "applications", []).slice()
        const index = next.indexOf(application.id)
        if (enabled && index < 0)
            next.push(application.id)
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
                selectionIndicator: true
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
                MeoText { text: qsTr("Core"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoCheckbox { text: qsTr("Meo Desktop (Required)"); checked: true; enabled: false }
                MeoCheckbox { text: qsTr("MeoUI runtime (Required)"); checked: true; enabled: false }
                MeoCheckbox { text: qsTr("Meo Icons (Required)"); checked: true; enabled: false }
                MeoText { text: qsTr("Applications"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
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
                MeoText { text: qsTr("System"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoCheckbox { text: qsTr("Signed Meo repository integration (Required)"); checked: true; enabled: false }
                MeoCheckbox { text: qsTr("Meo release compatibility metadata (Required)"); checked: true; enabled: false }
            }
        }
        MeoCard {
            width: parent.width
            implicitHeight: systemAppsColumn.implicitHeight + page.dp(24)
            type: "filled"
            padding: page.dp(12)
            Column {
                id: systemAppsColumn
                width: parent.width
                spacing: page.dp(8)
                MeoText { text: qsTr("Preinstalled system applications"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoText { width: parent.width; text: qsTr("The Recommended profile includes these desktop essentials. Minimal and Custom can add them individually."); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
                Repeater {
                    model: page.applicationsForTier("system")
                    delegate: Column {
                        required property var modelData
                        width: parent.width
                        spacing: 0
                        MeoCheckbox {
                            text: modelData.name + (page.applicationIsDefault(modelData) ? qsTr(" · Included") : "")
                            checked: page.applicationIsSelected(modelData)
                            enabled: !page.applicationIsDefault(modelData)
                            onToggled: checked => page.setApplication(modelData, checked)
                        }
                        MeoText { width: parent.width; text: modelData.summary; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
                    }
                }
            }
        }
        MeoCard {
            width: parent.width
            implicitHeight: recommendedAppsColumn.implicitHeight + page.dp(24)
            type: "outlined"
            padding: page.dp(12)
            Column {
                id: recommendedAppsColumn
                width: parent.width
                spacing: page.dp(8)
                MeoText { text: qsTr("Recommended applications"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                Repeater {
                    model: page.applicationsForTier("recommended")
                    delegate: Column {
                        required property var modelData
                        width: parent.width
                        spacing: 0
                        MeoCheckbox { text: modelData.name; checked: page.applicationIsSelected(modelData); onToggled: checked => page.setApplication(modelData, checked) }
                        MeoText { width: parent.width; text: modelData.summary; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
                    }
                }
            }
        }
        MeoCard {
            width: parent.width
            implicitHeight: thirdPartyAppsColumn.implicitHeight + page.dp(24)
            type: "outlined"
            padding: page.dp(12)
            Column {
                id: thirdPartyAppsColumn
                width: parent.width
                spacing: page.dp(8)
                MeoText { text: qsTr("Third-party recommendations"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                InfoBanner { width: parent.width; title: qsTr("Always opt-in"); message: qsTr("These applications are never selected automatically. During installation they come from the signed Arch official repositories.") }
                Repeater {
                    model: page.applicationsForTier("third-party")
                    delegate: Column {
                        required property var modelData
                        width: parent.width
                        spacing: 0
                        MeoCheckbox { text: modelData.name; checked: page.applicationIsSelected(modelData); onToggled: checked => page.setApplication(modelData, checked) }
                        MeoText { width: parent.width; text: modelData.summary; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
                    }
                }
            }
        }
    }
}
