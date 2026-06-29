pragma ComponentBehavior: Bound

import QtQuick
import "../"
import ".."

PageFrame {
    id: page

    primaryLabel: "Get Started"

    Column {
        anchors.centerIn: parent
        anchors.verticalCenterOffset: -page.dp(28)
        width: Math.min(parent.width * 0.82, page.dp(760))
        spacing: page.dp(32)

        Image {
            anchors.horizontalCenter: parent.horizontalCenter
            width: page.dp(260)
            height: page.dp(116)
            source: page.asset("icons/Logo.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: 0.68
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Welcome to MeoArch OS"
            color: MeoTheme.onSurface
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.family: page.typeface
            font.weight: MeoTheme.displayLargeEmphasized.weight
            font.pixelSize: page.displayLarge
        }
    }
}
