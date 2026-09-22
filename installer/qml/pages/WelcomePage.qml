import QtQuick
import QtQuick.Layouts
import MeoUI 1.0
import Meo.System 1.0 as MeoSystem
import ".."

PageFrame {
    id: page
    primaryLabel: qsTr("Get Started")
    showBackButton: false

    Column {
        id: welcomeContent
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -page.dp(8)
        width: Math.min(parent.width, page.dp(600))
        spacing: page.compactHeight ? page.dp(12) : page.dp(18)

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: page.dp(168)
            height: page.dp(76)
            source: page.asset("icons/Logo.png")
            fillMode: Image.PreserveAspectFit
            Accessible.name: qsTr("MeoArch OS")
        }
        MeoText {
            width: parent.width
            text: qsTr("Welcome to MeoArch OS")
            horizontalAlignment: Text.AlignHCenter
            color: MeoTheme.contentOnSurface
            typeRole: "title"
            typeSize: "big"
            emphasized: true
            wrapMode: Text.WordWrap
        }
        MeoText {
            width: parent.width
            text: qsTr("Install MeoArch in a few clear, guided steps.")
            horizontalAlignment: Text.AlignHCenter
            color: MeoTheme.contentOnSurfaceVariant
            typeRole: "body"
            typeSize: "big"
            wrapMode: Text.WordWrap
        }

        MeoCard {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width, page.dp(520))
            type: "outlined"
            Accessible.name: qsTr("Live environment check")

            ColumnLayout {
                anchors.fill: parent
                spacing: page.dp(10)

                RowLayout {
                    Layout.fillWidth: true
                    MeoIcon { icon: "fact_check"; size: page.dp(22); color: MeoTheme.primary }
                    MeoText {
                        Layout.fillWidth: true
                        text: qsTr("Live environment check")
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                    }
                    MeoBadge { text: qsTr("LIVE") }
                }

                Repeater {
                    model: [
                        {
                            "icon": "computer",
                            "title": qsTr("Environment"),
                            "value": page.controller && page.controller.runtimeEnvironment === "live"
                                     ? qsTr("Live ISO")
                                     : qsTr("Unknown")
                        },
                        {
                            "icon": "wifi",
                            "title": qsTr("Network"),
                            "value": MeoSystem.SystemState.networkConnected
                                     ? (MeoSystem.SystemState.networkName.length
                                        ? MeoSystem.SystemState.networkName
                                        : qsTr("Connected"))
                                     : qsTr("Not connected")
                        },
                        {
                            "icon": "memory",
                            "title": qsTr("Hardware"),
                            "value": page.controller && page.controller.hardwareDetecting
                                     ? qsTr("Checking…")
                                     : qsTr("Detected")
                        },
                        {
                            "icon": "account_circle",
                            "title": qsTr("Meo Account"),
                            "value": qsTr("After installation")
                        }
                    ]

                    delegate: RowLayout {
                        id: liveCheckRow
                        required property var modelData
                        Layout.fillWidth: true
                        spacing: page.dp(10)
                        MeoIcon { icon: liveCheckRow.modelData.icon; size: page.dp(18); color: MeoTheme.contentOnSurfaceVariant }
                        MeoText { Layout.fillWidth: true; text: liveCheckRow.modelData.title; typeRole: "body"; typeSize: "small" }
                        MeoText {
                            text: liveCheckRow.modelData.value
                            typeRole: "label"
                            typeSize: "small"
                            emphasized: true
                            color: MeoTheme.contentOnSurfaceVariant
                        }
                    }
                }

                MeoText {
                    Layout.fillWidth: true
                    text: qsTr("Live checks are temporary. Meo Account and installed-system health checks run only after installation.")
                    typeRole: "label"
                    typeSize: "small"
                    color: MeoTheme.contentOnSurfaceVariant
                    wrapMode: Text.WordWrap
                }
            }
        }

        MeoMotionSurface {
            anchors.horizontalCenter: parent.horizontalCenter
            width: Math.min(parent.width, page.dp(430))
            height: page.dp(52)
            radius: height / 2
            color: MeoTheme.secondaryContainer
            elevation: 0

            Row {
                anchors.centerIn: parent
                spacing: page.dp(10)
                MeoIcon {
                    anchors.verticalCenter: parent.verticalCenter
                    icon: "verified_user"
                    size: page.dp(22)
                    color: MeoTheme.contentOnSecondaryContainer
                }
                MeoText {
                    anchors.verticalCenter: parent.verticalCenter
                    text: qsTr("Review first. Nothing changes until you confirm.")
                    typeRole: "label"
                    typeSize: "medium"
                    emphasized: true
                    color: MeoTheme.contentOnSecondaryContainer
                }
            }
        }
    }
}
