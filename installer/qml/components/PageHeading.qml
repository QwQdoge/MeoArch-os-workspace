import QtQuick
import ".."
Column {
    property string title: ""
    property string subtitle: ""
    spacing: 8
    Text { width: parent.width; text: parent.title; color: MeoTheme.onSurface; font.family: "Comfortaa"; font.bold: true; font.pixelSize: 40; lineHeight: 48; lineHeightMode: Text.FixedHeight; elide: Text.ElideRight }
    Text { width: parent.width; text: parent.subtitle; color: MeoTheme.onSurfaceVariant; font.family: "Roboto"; font.pixelSize: 16; lineHeight: 24; lineHeightMode: Text.FixedHeight; wrapMode: Text.WordWrap }
}
