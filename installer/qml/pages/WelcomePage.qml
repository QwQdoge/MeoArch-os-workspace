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
                    size: 22
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
