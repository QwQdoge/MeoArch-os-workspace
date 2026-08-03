pragma ComponentBehavior: Bound
import QtQuick
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page

    property var selectedProfiles: page.controller
                                   ? page.controller.selection("software", "profiles", [])
                                   : []

    function isSelected(profileId) {
        return selectedProfiles.indexOf(profileId) >= 0
    }

    function setProfile(profileId, enabled) {
        let next = selectedProfiles.slice()
        const index = next.indexOf(profileId)
        if (enabled && index < 0)
            next.push(profileId)
        else if (!enabled && index >= 0)
            next.splice(index, 1)
        selectedProfiles = next
        page.controller.setSelection("software", "profiles", next)
    }

    Column {
        width: parent.width
        spacing: page.dp(16)

        PageHeading {
            width: parent.width
            title: "Apps for your workflow"
            subtitle: "Choose optional app groups. OmniStore will review the exact packages with you after first login."
        }

        InfoBanner {
            width: parent.width
            height: page.dp(64)
            title: "Nothing optional is installed without confirmation"
            tone: "info"
        }

        MeoCard {
            width: parent.width
            implicitHeight: page.dp(238)
            type: "filled"
            padding: page.dp(12)

            Column {
                width: parent.width
                Repeater {
                    model: [
                        { id: "productivity", title: "Productivity", detail: "Office, documents, communication" },
                        { id: "creative", title: "Creative", detail: "Graphics, audio, and media tools" },
                        { id: "developer", title: "Developer", detail: "Editors, Git, containers, and SDK discovery" },
                        { id: "gaming", title: "Gaming", detail: "Game launchers and compatibility tools" }
                    ]

                    delegate: ToggleRow {
                        required property var modelData
                        width: parent.width
                        title: modelData.title
                        subtitle: modelData.detail
                        checked: page.isSelected(modelData.id)
                        onToggled: checked => page.setProfile(modelData.id, checked)
                    }
                }
            }
        }
    }
}
