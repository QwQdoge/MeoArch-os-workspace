import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property var currentAccount: ({ name: "Meo User", email: "hello@meo.dev", avatar: "" })
    property var otherAccounts: [] // List of { name, email, avatar }
    property var actions: [] // List of { label, icon, action }

    signal accountSelected(var account)
    signal actionClicked(var action)

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"

    implicitWidth: 280 * themeGlobalScale
    implicitHeight: mainLayout.implicitHeight + padding * 2

    padding: 16 * themeGlobalScale

    background: Rectangle {
        radius: 28 * control.themeGlobalScale
        color: control.themeSurface
        border.color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
        border.width: 1 * control.themeGlobalScale
    }

    contentItem: ColumnLayout {
        id: mainLayout
        spacing: 16 * control.themeGlobalScale

        // 1. Current Account Identity
        RowLayout {
            Layout.fillWidth: true
            spacing: 16 * control.themeGlobalScale

            MeoAvatar {
                size: 48 * control.themeGlobalScale
                source: control.currentAccount.avatar || ""
                initials: control.currentAccount.name ? control.currentAccount.name.charAt(0) : "U"
                variant: "squircle"
            }

            Column {
                Layout.fillWidth: true
                spacing: 2 * control.themeGlobalScale

                MeoText {
                    width: parent.width
                    text: control.currentAccount.name
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                    elide: Text.ElideRight
                }

                MeoText {
                    width: parent.width
                    text: control.currentAccount.email
                    typeRole: "body"
                    typeSize: "small"
                    color: control.themeOnSurfaceVariant
                    elide: Text.ElideRight
                }
            }
        }

        // 2. Quick Switch Avatars
        Row {
            Layout.fillWidth: true
            spacing: 8 * control.themeGlobalScale
            visible: control.otherAccounts.length > 0

            Repeater {
                model: control.otherAccounts
                delegate: MeoIconButton {
                    width: 40 * control.themeGlobalScale
                    height: 40 * control.themeGlobalScale
                    icon.name: modelData.avatar ? "" : "person"
                    onClicked: control.accountSelected(modelData)

                    // Avatar overlay
                    MeoAvatar {
                        anchors.fill: parent
                        size: 40 * control.themeGlobalScale
                        source: modelData.avatar || ""
                        initials: modelData.name ? modelData.name.charAt(0) : "U"
                        variant: "circle"
                        visible: modelData.avatar !== "" || !modelData.icon
                    }
                }
            }

            MeoIconButton {
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale
                icon.name: "person_add"
                type: "outlined"
                onClicked: control.actionClicked({ label: "Add account", icon: "person_add" })
            }
        }

        MeoDivider { Layout.fillWidth: true }

        // 3. Actions / Management
        Column {
            Layout.fillWidth: true
            spacing: 4 * control.themeGlobalScale

            Repeater {
                model: control.actions
                delegate: MeoListItem {
                    width: parent.width
                    headline: modelData.label
                    leadingIcon: modelData.icon
                    isDense: true
                    interactive: true
                    onClicked: {
                        if (modelData.action) modelData.action()
                        control.actionClicked(modelData)
                    }
                }
            }

            MeoListItem {
                width: parent.width
                headline: "Manage accounts"
                leadingIcon: "manage_accounts"
                isDense: true
                interactive: true
                onClicked: control.actionClicked({ label: "Manage accounts", icon: "manage_accounts" })
            }

            MeoListItem {
                width: parent.width
                headline: "Sign out"
                leadingIcon: "logout"
                isDense: true
                interactive: true
                onClicked: control.actionClicked({ label: "Sign out", icon: "logout" })
            }
        }
    }
}
