import QtQuick
import "."

PageFrame {
    id: page

    property string title: ""
    property string subtitle: "This step is ready for its real controls."

    primaryLabel: pageIndex === pageCount - 1 ? "Finish" : "Continue"

    Column {
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.76, page.dp(680))
        spacing: page.dp(16)

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: page.title
            color: MeoTheme.contentOnSurface
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            font.family: page.comfortaa
            font.weight: MeoTheme.displaySmallEmphasized.weight
            font.pixelSize: page.dp(40)
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            width: parent.width
            text: page.subtitle
            color: MeoTheme.contentOnSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            lineHeight: 1.22
            font.family: page.roboto
            font.weight: MeoTheme.bodyLarge.weight
            font.pixelSize: page.dp(18)
        }
    }
}
