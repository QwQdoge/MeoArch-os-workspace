import QtQuick
import MeoUI 1.0
import ".."

PageFrame {
    id: page
    primaryLabel: qsTr("Get Started")
    showBackButton: false

    Column {
        id: welcomeContent
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -page.dp(8)
        width: Math.min(parent.width, page.dp(680))
        spacing: page.dp(16)

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: page.dp(188)
            height: page.dp(84)
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
            text: qsTr("A guided setup that keeps each important Arch choice clear and reviewable.")
            horizontalAlignment: Text.AlignHCenter
            color: MeoTheme.contentOnSurfaceVariant
            typeRole: "body"
            typeSize: "medium"
            wrapMode: Text.WordWrap
        }

        MeoCard {
            width: parent.width
            type: "filled"
            padding: page.dp(20)
            implicitHeight: featureRow.implicitHeight + page.dp(40)

            Row {
                id: featureRow
                width: parent.width
                spacing: page.dp(16)

                Repeater {
                    model: [
                        { icon: "edit_note", title: qsTr("Guided choices"), text: qsTr("Language, storage, account, and software in a clear order.") },
                        { icon: "memory", title: qsTr("Hardware-aware"), text: qsTr("Graphics planning is prepared from real PCI hardware detection.") },
                        { icon: "fact_check", title: qsTr("Review before install"), text: qsTr("No destructive action is enabled until the installation plan is checked.") }
                    ]

                    delegate: Column {
                        required property var modelData
                        width: (featureRow.width - featureRow.spacing * 2) / 3
                        spacing: page.dp(6)

                        MeoIcon {
                            icon: modelData.icon
                            size: page.dp(24)
                            color: MeoTheme.primary
                        }
                        MeoText {
                            width: parent.width
                            text: modelData.title
                            typeRole: "label"
                            typeSize: "medium"
                            emphasized: true
                            color: MeoTheme.contentOnSurface
                            wrapMode: Text.WordWrap
                        }
                        MeoText {
                            width: parent.width
                            text: modelData.text
                            typeRole: "body"
                            typeSize: "small"
                            color: MeoTheme.contentOnSurfaceVariant
                            wrapMode: Text.WordWrap
                        }
                    }
                }
            }
        }

        MeoText {
            width: parent.width
            text: qsTr("You can review every choice before installation begins.")
            horizontalAlignment: Text.AlignHCenter
            typeRole: "label"
            typeSize: "small"
            color: MeoTheme.contentOnSurfaceVariant
        }
    }
}
