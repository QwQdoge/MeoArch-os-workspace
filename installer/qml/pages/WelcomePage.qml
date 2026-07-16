import QtQuick
import MeoUI 1.0
import ".."

PageFrame {
    id: page
    primaryLabel: "Get Started"
    showBackButton: false

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -page.dp(10)
        width: Math.min(parent.width, page.dp(680))
        spacing: page.dp(24)

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: page.dp(232)
            height: page.dp(104)
            source: page.asset("icons/Logo.png")
            fillMode: Image.PreserveAspectFit
            Accessible.name: "MeoArch OS"
        }
        MeoText {
            width: parent.width
            text: "Welcome to MeoArch OS"
            horizontalAlignment: Text.AlignHCenter
            color: MeoTheme.contentOnSurface
            typeRole: "title"
            typeSize: "big"
            emphasized: true
            wrapMode: Text.WordWrap
        }
        MeoText {
            width: parent.width
            text: "A guided installation that keeps powerful Arch options close at hand."
            horizontalAlignment: Text.AlignHCenter
            color: MeoTheme.contentOnSurfaceVariant
            typeRole: "body"
            typeSize: "big"
            wrapMode: Text.WordWrap
        }
    }
}
