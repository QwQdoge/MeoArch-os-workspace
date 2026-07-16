import QtQuick
import MeoUI 1.0

PageFrame {
    id: page

    property string title: ""
    property string subtitle: "This step is ready for its real controls."

    primaryLabel: pageIndex === pageCount - 1 ? "Finish" : "Continue"

    Column {
        id: content
        anchors.centerIn: parent
        width: Math.min(page.width * 0.76, page.dp(680))
        spacing: page.dp(16)

        MeoText {
            anchors.horizontalCenter: content.horizontalCenter
            width: content.width
            text: page.title
            color: MeoTheme.contentOnSurface
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            typeRole: "display"
            typeSize: "small"
            emphasized: true
        }

        MeoText {
            anchors.horizontalCenter: content.horizontalCenter
            width: content.width
            text: page.subtitle
            color: MeoTheme.contentOnSurfaceVariant
            horizontalAlignment: Text.AlignHCenter
            wrapMode: Text.WordWrap
            lineHeight: 1.22
            typeRole: "body"
            typeSize: "large"
        }
    }
}
