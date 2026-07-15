import QtQuick
import ".."

PageFrame {
    id: page
    primaryLabel: "Get Started"
    showBackButton: false
    Column {
        anchors.centerIn: parent; anchors.verticalCenterOffset: -page.dp(10)
        width: Math.min(parent.width, page.dp(680)); spacing: page.dp(24)
        Image { anchors.horizontalCenter: parent.horizontalCenter; width: page.dp(232); height: page.dp(104); source: page.asset("icons/Logo.png"); fillMode: Image.PreserveAspectFit }
        Text { width: parent.width; text: "Welcome to MeoArch OS"; horizontalAlignment: Text.AlignHCenter; color: MeoTheme.onSurface; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(40); wrapMode: Text.WordWrap }
        Text { width: parent.width; text: "A guided installation that keeps powerful Arch options close at hand."; horizontalAlignment: Text.AlignHCenter; color: MeoTheme.onSurfaceVariant; font.family: page.roboto; font.pixelSize: page.dp(18); wrapMode: Text.WordWrap }
    }
}
