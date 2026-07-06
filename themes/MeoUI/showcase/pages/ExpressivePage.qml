import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    categoryId: "expressive"

    ColumnLayout {
        width: parent.width
        spacing: 32 * MeoTheme.globalScale

        ShowcaseSection {
            title: "Account Switcher"
            subtitle: "MD3 Expressive account selection and management widget."
            Layout.fillWidth: true

            MeoAccountSwitcher {
                currentAccount: ({ "name": "Jules Engineer", "email": "jules@meoarch.os", "avatar": "" })
                otherAccounts: [
                    { "name": "Meo Design", "email": "design@meoarch.os", "avatar": "" },
                    { "name": "Guest User", "email": "guest@meoarch.os", "avatar": "" }
                ]
                actions: [
                    { "label": "Manage Account", "icon": "manage_accounts" },
                    { "label": "Settings", "icon": "settings" },
                    { "label": "Sign Out", "icon": "logout" }
                ]
            }
        }

        ShowcaseSection {
            title: "Segmented Lists"
            subtitle: "Grouped list items with cohesive container shapes."
            Layout.fillWidth: true

            MeoSegmentedList {
                title: "CONNECTED DEVICES"
                model: [
                    { "label": "Bluetooth", "icon": "bluetooth", "subtitle": "On" },
                    { "label": "Wi-Fi", "icon": "wifi", "subtitle": "MeoGuest_5G" },
                    { "label": "NFC", "icon": "nfc", "subtitle": "Off" }
                ]
                delegate: MeoListItem {
                    headline: modelData.label
                    leadingIcon: modelData.icon
                    supportingText: modelData.subtitle
                    interactive: true
                    onClicked: selected = !selected
                }
            }
        }

        ShowcaseSection {
            title: "Vibrant Selection & Rounding"
            subtitle: "High-emphasis states in segmented groups."
            Layout.fillWidth: true

            MeoSegmentedList {
                title: "SYSTEM ACTIONS"
                model: [
                    { "label": "Check for updates", "icon": "system_update", "vibrant": true },
                    { "label": "Factory reset", "icon": "restart_alt", "vibrant": false }
                ]
                delegate: MeoListItem {
                    headline: modelData.label
                    leadingIcon: modelData.icon
                    vibrant: modelData.vibrant
                    interactive: true
                    onClicked: selected = !selected
                }
            }
        }
    }
}
