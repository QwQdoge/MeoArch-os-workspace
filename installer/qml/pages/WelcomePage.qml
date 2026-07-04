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
            width: page.dp(232)
            height: page.dp(104)
            source: page.asset("icons/Logo.png")
            fillMode: Image.PreserveAspectFit
            smooth: true
            opacity: 0.68
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: "Welcome to MeoArch OS"
            color: MeoTheme.contentOnSurface
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            fontSizeMode: Text.Fit
            minimumPixelSize: page.dp(28)
            font.family: page.typeface
            font.weight: Font.Medium
            font.pixelSize: Math.min(page.displayLarge, page.dp(42))
        }
    }
}
