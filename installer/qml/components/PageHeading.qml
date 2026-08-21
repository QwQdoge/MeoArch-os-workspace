import QtQuick
import MeoUI 1.0
Column {
    property string title: ""
    property string subtitle: ""
    spacing: MeoTheme.space8
    MeoText {
        width: parent.width
        text: parent.title
        color: MeoTheme.contentOnSurface
        typeRole: "title"
        typeSize: "medium"
        emphasized: true
        elide: Text.ElideRight
    }
    MeoText {
        width: parent.width
        text: parent.subtitle
        color: MeoTheme.contentOnSurfaceVariant
        typeRole: "body"
        typeSize: "medium"
        wrapMode: Text.WordWrap
    }
}
