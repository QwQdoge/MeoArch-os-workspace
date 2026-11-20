pragma ComponentBehavior: Bound
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
        return revision >= 0 && controller ? controller.selection("software", "profile", "minimal") : "minimal"
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
        return application.summary
    }
    readonly property bool storeIncluded: page.profile === "recommended"
                                          || page.selectedComponents.indexOf("omnistore-bin") >= 0
    // Optional apps are not installed here any more; OmniStore installs and
    // updates them after the first sign-in. List what it features.
    readonly property string storeHighlights: Array.from(page.softwareCatalog)
        .filter(application => application.tier === "recommended" || application.tier === "third-party")
        .filter(application => application.package !== "firefox")
        .map(application => application.name).join(" · ")

    component IncludedItem: Row {
        id: included
        property string icon: ""
        property string text: ""
        spacing: page.dp(10)
        MeoIcon { anchors.verticalCenter: parent.verticalCenter; icon: included.icon; size: page.dp(20); color: MeoTheme.primary }
        MeoText { anchors.verticalCenter: parent.verticalCenter; text: included.text; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface }
    }

    Column {
        width: parent.width
        spacing: page.dp(16)
        PageHeading {
            width: parent.width
            title: qsTr("Choose what to install")
            subtitle: qsTr("Pick a starting point. Everything comes from signed MeoArch and Arch repositories, and more apps can be added later.")
        }
        // Keep the three product profiles as direct children of the page
        // layout.  In a real compact Live session, the dynamic delegate
        // version could be omitted from the positioner's measured height,
        // leaving people in the application list with no way to choose a
        // profile.  These are a fixed product contract, not catalog data.
        SelectionCard {
            width: parent.width
            iconText: "verified"
            title: qsTr("Recommended")
            value: qsTr("The full Meo experience: desktop, Meo Settings, OmniStore, Meo AI and everyday apps.")
            wrapValue: true
            selected: page.profile === "recommended"
            selectionIndicator: true
            onClicked: page.selectProfile("recommended")
        }
        SelectionCard {
            width: parent.width
            iconText: "eco"
            title: qsTr("Minimal")
            value: qsTr("Just the Meo desktop and the essentials below. No app store; good for a lean system.")
            wrapValue: true
            selected: page.profile === "minimal"
            selectionIndicator: true
            onClicked: page.selectProfile("minimal")
        }
        SelectionCard {
            width: parent.width
            iconText: "tune"
            title: qsTr("Custom")
            value: qsTr("Start from Minimal and choose which Meo apps to add.")
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
                MeoText { text: qsTr("Meo apps"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
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
                MeoText { width: parent.width; text: qsTr("Included with every MeoArch installation: Meo Desktop, MeoUI runtime, Meo Icons, signed Meo repository integration and release compatibility metadata."); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
            }
        }

        // Essentials are part of every installation; shown so people know
        // they do not need to look for them.
        MeoCard {
            width: parent.width
            implicitHeight: essentialsColumn.implicitHeight + page.dp(28)
            type: "filled"
            padding: page.dp(14)
            Column {
                id: essentialsColumn
                width: parent.width
                spacing: page.dp(10)
                MeoText { text: qsTr("Always included"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                Flow {
                    width: parent.width
                    spacing: page.dp(18)
                    IncludedItem { icon: "public"; text: qsTr("Firefox browser") }
                    IncludedItem { icon: "folder"; text: qsTr("Files and terminal") }
                    IncludedItem { icon: "translate"; text: qsTr("Chinese, Japanese, Korean and emoji fonts") }
                    IncludedItem { icon: "keyboard"; text: qsTr("Input methods for your language") }
                    IncludedItem { icon: "usb"; text: qsTr("Windows, USB and SD card drives") }
                    IncludedItem { icon: "image"; text: qsTr("File previews") }
                    IncludedItem { icon: "speed"; text: qsTr("Performance tuning and gaming mode") }
                }
            }
        }

        MeoCard {
            width: parent.width
            implicitHeight: systemAppsColumn.implicitHeight + page.dp(24)
            type: "outlined"
            padding: page.dp(12)
            Column {
                id: systemAppsColumn
                width: parent.width
                spacing: page.dp(8)
                MeoText { text: qsTr("Everyday tools"); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoText {
                    width: parent.width
                    text: page.profile === "recommended"
                          ? qsTr("Included with Recommended.")
                          : qsTr("Not included with %1. Tick the ones you want.").arg(page.profile === "custom" ? qsTr("Custom") : qsTr("Minimal"))
                    typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap
                }
                Repeater {
                    model: page.applicationsForTier("system")
                    delegate: Column {
                        id: systemApplication
                        required property var modelData
                        width: parent.width
                        spacing: 0
                        MeoCheckbox {
                            text: systemApplication.modelData.name + (page.applicationIsDefault(systemApplication.modelData) ? qsTr(" · Included") : "")
                            controlled: true
                            checked: page.applicationIsSelected(systemApplication.modelData)
                            enabled: !page.applicationIsDefault(systemApplication.modelData)
                            onToggled: checked => page.setApplication(systemApplication.modelData, checked)
                        }
                        MeoText { leftPadding: page.dp(36); width: parent.width; text: page.applicationDetail(systemApplication.modelData); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
                    }
                }
            }
        }

        InfoBanner {
            width: parent.width
            tone: page.storeIncluded ? "info" : "warning"
            title: page.storeIncluded ? qsTr("More apps after installation") : qsTr("No app store selected")
            message: page.storeIncluded
                     ? qsTr("Install office, media and creative apps from OmniStore after you sign in, so they arrive up to date and keep updating. Featured: %1.").arg(page.storeHighlights)
                     : qsTr("Without OmniStore you add apps later with pacman. Choose Recommended, or add OmniStore under Custom, for one-click installs.")
        }
    }
}
