import QtQuick
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    // selection() is an invokable, so its result is not itself a reactive QML
    // property. Depend on the controller's revision to make a clicked profile
    // and component checkbox update immediately rather than only after this
    // page is reloaded.
    readonly property var selectionRevision: controller && controller.selectionRevision !== undefined
                                           ? controller.selectionRevision : 0
    readonly property string profile: {
        const revision = selectionRevision
        return revision >= 0 && controller ? controller.selection("software", "profile", "recommended") : "recommended"
    }
    readonly property var selectedComponents: {
        const revision = selectionRevision
        return revision >= 0 && controller ? controller.selection("software", "components", []) : []
    }
    readonly property var selectedApplications: {
        const revision = selectionRevision
        return revision >= 0 && controller ? controller.selection("software", "applications", []) : []
    }
    readonly property var softwareCatalog: controller ? controller.softwareCatalog : []
    function selectProfile(value) {
        controller.setSelection("software", "profile", value)
        controller.setSelection("software", "components", value === "custom" ? ["meo-desktop"] : [])
    }
    function setComponent(name, enabled) {
        let next = Array.from(page.selectedComponents)
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
               || page.selectedApplications.indexOf(application.id) >= 0
    }
    function setApplication(application, enabled) {
        if (page.applicationIsDefault(application))
            return
        let next = Array.from(page.selectedApplications)
        const index = next.indexOf(application.id)
        if (enabled && index < 0)
            next.push(application.id)
        if (!enabled && index >= 0)
            next.splice(index, 1)
        controller.setSelection("software", "applications", next)
    }
    function applicationDetail(application) {
        return application.summary + "\n" + qsTr("Arch official · package: %1").arg(application.package)
    }
    Column {
        width: parent.width
        spacing: page.dp(16)
        PageHeading {
            width: parent.width
            title: qsTr("Choose what to install")
            subtitle: qsTr("All selections resolve through the signed MeoArch package repository.")
        }
        // Keep the three product profiles as direct children of the page
        // layout.  In a real compact Live session, the dynamic delegate
        // version could be omitted from the positioner's measured height,
        // leaving people in the application list with no way to choose a
        // profile.  These are a fixed product contract, not catalog data.
        SelectionCard {
            width: parent.width
            title: qsTr("Recommended")
            value: qsTr("Meo Desktop, MeoUI, icons, Settings, OmniStore, and required integration.")
            wrapValue: true
            selected: page.profile === "recommended"
            selectionIndicator: true
            onClicked: page.selectProfile("recommended")
        }
        SelectionCard {
            width: parent.width
            title: qsTr("Minimal")
            value: qsTr("Meo Desktop core, MeoUI, icons, and required system integration.")
            wrapValue: true
            selected: page.profile === "minimal"
            selectionIndicator: true
            onClicked: page.selectProfile("minimal")
        }
        SelectionCard {
            width: parent.width
            title: qsTr("Custom")
            value: qsTr("Choose the official components to install. Required desktop components stay enabled.")
            wrapValue: true
            selected: page.profile === "custom"
            selectionIndicator: true
            onClicked: page.selectProfile("custom")
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
                MeoText { width: parent.width; text: qsTr("Included with every MeoArch installation: Meo Desktop, MeoUI runtime, and Meo Icons."); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
                MeoText { text: qsTr("Applications"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoCheckbox {
                    text: qsTr("Meo Settings")
                    controlled: true
                    checked: page.selectedComponents.indexOf("meo-settings") >= 0
                    onToggled: checked => page.setComponent("meo-settings", checked)
                }
                MeoCheckbox {
                    text: qsTr("OmniStore")
                    controlled: true
                    checked: page.selectedComponents.indexOf("omnistore-bin") >= 0
                    onToggled: checked => page.setComponent("omnistore-bin", checked)
                }
                MeoText { text: qsTr("System"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoText { width: parent.width; text: qsTr("Included with every MeoArch installation: signed Meo repository integration and release compatibility metadata."); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
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
                            controlled: true
                            checked: page.applicationIsSelected(modelData)
                            enabled: !page.applicationIsDefault(modelData)
                            onToggled: checked => page.setApplication(modelData, checked)
                        }
                        MeoText { width: parent.width; text: page.applicationDetail(modelData); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
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
                        MeoCheckbox { text: modelData.name; controlled: true; checked: page.applicationIsSelected(modelData); onToggled: checked => page.setApplication(modelData, checked) }
                        MeoText { width: parent.width; text: page.applicationDetail(modelData); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
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
                MeoText { text: qsTr("More official applications"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                InfoBanner { width: parent.width; title: qsTr("Always opt-in"); message: qsTr("These applications are never selected automatically. During installation they come from the signed Arch official repositories; Flatpak and AUR are not installer sources.") }
                Repeater {
                    model: page.applicationsForTier("third-party")
                    delegate: Column {
                        required property var modelData
                        width: parent.width
                        spacing: 0
                        MeoCheckbox { text: modelData.name; controlled: true; checked: page.applicationIsSelected(modelData); onToggled: checked => page.setApplication(modelData, checked) }
                        MeoText { width: parent.width; text: page.applicationDetail(modelData); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
                    }
                }
            }
        }
    }
}
