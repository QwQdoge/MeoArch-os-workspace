import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    // model: [{ name: "User Name", email: "user@example.com", avatar: "path/to/img", active: true }]
    property var model: []
    property int currentIndex: 0

    signal accountSelected(int index, var data)
    signal addAccountRequested()
    signal manageAccountsRequested()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 280 * themeGlobalScale
    implicitHeight: mainLayout.implicitHeight + padding * 2
    padding: 16 * themeGlobalScale

    background: Rectangle {
        radius: 28 * themeGlobalScale
        color: control.themeSurfaceContainerLow
        border.color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
        border.width: 1 * themeGlobalScale
    }

    contentItem: ColumnLayout {
        id: mainLayout
        spacing: 12 * control.themeGlobalScale

        // Active Account Info
        RowLayout {
            Layout.fillWidth: true
            spacing: 16 * control.themeGlobalScale

            MeoAvatar {
                size: 48
                source: (control.model.length > control.currentIndex) ? (control.model[control.currentIndex].avatar || "") : ""
                initials: (control.model.length > control.currentIndex) ? (control.model[control.currentIndex].name || "U") : "U"
            }

            Column {
                Layout.fillWidth: true
                spacing: 0
                MeoText {
                    width: parent.width
                    text: (control.model.length > control.currentIndex) ? (control.model[control.currentIndex].name || "Account") : "Account"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                    elide: Text.ElideRight
                }
                MeoText {
                    width: parent.width
                    text: (control.model.length > control.currentIndex) ? (control.model[control.currentIndex].email || "") : ""
                    typeRole: "body"
                    typeSize: "small"
                    color: control.themeOnSurfaceVariant
                    elide: Text.ElideRight
                }
            }

            MeoIconButton {
                icon.name: "expand_more"
                type: "standard"
                onClicked: accountMenu.open()
            }
        }

        // Quick Switcher Avatars (Other accounts)
        Row {
            Layout.fillWidth: true
            spacing: 12 * control.themeGlobalScale
            visible: control.model.length > 1

            Repeater {
                model: control.model
                delegate: MeoAvatar {
                    visible: index !== control.currentIndex
                    size: 32
                    source: modelData.avatar || ""
                    initials: modelData.name || "U"

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            control.currentIndex = index
                            control.accountSelected(index, modelData)
                        }
                    }
                }
            }

            // Add Account Button
            Rectangle {
                width: 32 * control.themeGlobalScale
                height: 32 * control.themeGlobalScale
                radius: width / 2
                color: "transparent"
                border.color: control.themeOnSurfaceVariant
                border.width: 1 * control.themeGlobalScale

                MeoIcon {
                    anchors.centerIn: parent
                    icon: "add"
                    size: 18
                    color: control.themeOnSurfaceVariant
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: control.addAccountRequested()
                }
            }
        }
    }

    MeoMenu {
        id: accountMenu
        width: parent.width
        model: [
            { label: "Manage Accounts", icon: "manage_accounts", action: () => control.manageAccountsRequested() },
            { label: "Sign Out", icon: "logout", action: () => console.log("Sign out requested") }
        ]
    }
}
