import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property var currentAccount: ({ "name": "Meo User", "email": "meo@example.com", "avatar": "" })
    property var otherAccounts: [] // List of { name, email, avatar }
    property var actions: [] // List of { label, icon, action (optional) }

    signal accountSwitched(int index, var account)
    signal actionClicked(int index, var action)

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 320 * themeGlobalScale
    padding: 16 * themeGlobalScale

    background: Rectangle {
        radius: (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeLarge : 16 * themeGlobalScale)
        color: control.themeSurfaceContainerLow
    }

    contentItem: ColumnLayout {
        spacing: 12 * control.themeGlobalScale

        // 👤 Active Account Identity
        RowLayout {
            Layout.fillWidth: true
            spacing: 16 * control.themeGlobalScale

            MeoAvatar {
                size: 56
                source: control.currentAccount.avatar || ""
                initials: control.currentAccount.name ? control.currentAccount.name.substring(0, 1) : ""
                variant: "squircle"
            }

            ColumnLayout {
                spacing: 0
                Layout.fillWidth: true

                MeoText {
                    text: control.currentAccount.name || ""
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                    color: control.themeOnSurface
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }

                MeoText {
                    text: control.currentAccount.email || ""
                    typeRole: "body"
                    typeSize: "small"
                    color: control.themeOnSurfaceVariant
                    Layout.fillWidth: true
                    elide: Text.ElideRight
                }
            }

            MeoIconButton {
                icon.name: "expand_more"
                type: "standard"
            }
        }

        // 🚀 Quick-switch Avatar Row
        Row {
            Layout.fillWidth: true
            spacing: 12 * control.themeGlobalScale
            visible: control.otherAccounts.length > 0

            Repeater {
                model: control.otherAccounts
                delegate: Item {
                    width: 40 * control.themeGlobalScale
                    height: 40 * control.themeGlobalScale

                    MeoAvatar {
                        anchors.fill: parent
                        size: 40
                        source: modelData.avatar || ""
                        initials: modelData.name ? modelData.name.substring(0, 1) : ""
                        variant: "circle"
                    }

                    MouseArea {
                        id: avatarMouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: control.accountSwitched(index, modelData)
                    }

                    // Hover state for avatar
                    MeoStateLayer {
                        anchors.fill: parent
                        radius: width / 2
                        color: control.themeOnSurface
                        hovered: avatarMouseArea.containsMouse
                        pressed: avatarMouseArea.pressed
                    }
                }
            }

            // Add Account Button
            Item {
                width: 40 * control.themeGlobalScale
                height: 40 * control.themeGlobalScale

                Rectangle {
                    anchors.fill: parent
                    radius: width / 2
                    color: "transparent"
                    border.color: control.themeOutlineVariant
                    border.width: 1 * control.themeGlobalScale

                    MeoIcon {
                        anchors.centerIn: parent
                        icon: "add"
                        size: 24
                        color: control.themeOnSurfaceVariant
                    }
                }

                MouseArea {
                    id: addAccountMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: control.actionClicked(-1, { "label": "Add Account", "icon": "add" })
                }

                MeoStateLayer {
                    anchors.fill: parent
                    radius: width / 2
                    color: control.themeOnSurface
                    hovered: addAccountMouseArea.containsMouse
                    pressed: addAccountMouseArea.pressed
                }
            }
        }

        // 🛠️ Management / Action Menu
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2 * control.themeGlobalScale
            visible: control.actions.length > 0

            Rectangle {
                Layout.fillWidth: true
                height: 1 * control.themeGlobalScale
                color: control.themeOutlineVariant
                Layout.topMargin: 4 * control.themeGlobalScale
                Layout.bottomMargin: 4 * control.themeGlobalScale
            }

            Repeater {
                model: control.actions
                delegate: MeoListItem {
                    headline: modelData.label
                    leadingIcon: modelData.icon || ""
                    Layout.fillWidth: true
                    isDense: true
                    interactive: true
                    onClicked: {
                        if (modelData.action && typeof modelData.action === 'function') {
                            modelData.action()
                        }
                        control.actionClicked(index, modelData)
                    }
                }
            }
        }
    }
}
