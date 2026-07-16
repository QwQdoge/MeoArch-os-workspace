import QtQuick
import MeoUI 1.0
Column {
    property string title: ""
    property string subtitle: ""
    spacing: 8
    MeoText { width: parent.width; text: parent.title; color: MeoTheme.contentOnSurface; typeRole: "title"; typeSize: "big"; emphasized: true; elide: Text.ElideRight }
    MeoText { width: parent.width; text: parent.subtitle; color: MeoTheme.contentOnSurfaceVariant; typeRole: "body"; typeSize: "big"; wrapMode: Text.WordWrap }
}
