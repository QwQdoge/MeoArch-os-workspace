import QtQuick
import MeoUI 1.0 as Meo
import ".."

Meo.MeoCard {
    id: card
    property string iconText: "•"
    property string iconFont: "Roboto"
    property string title: ""
    property string value: ""
    type: "outlined"
    interactive: true
    padding: 0
    implicitHeight: 84
    radius: 16
    activeFocusOnTab: true
    Accessible.name: title + (value.length ? ", " + value : "")
    Accessible.role: Accessible.Button

    Text {
        anchors.left: parent.left; anchors.leftMargin: 20; anchors.verticalCenter: parent.verticalCenter
        text: card.iconText; font.family: card.iconFont; font.pixelSize: 24; color: MeoTheme.primary
    }
    Column {
        anchors.left: parent.left; anchors.leftMargin: 60; anchors.right: chevron.left; anchors.rightMargin: 12
        anchors.verticalCenter: parent.verticalCenter; spacing: 2
        Text { width: parent.width; text: card.title; font.family: "Roboto"; font.weight: Font.Bold; font.pixelSize: 16; color: MeoTheme.onSurface; elide: Text.ElideRight }
        Text { width: parent.width; text: card.value; font.family: "Roboto"; font.pixelSize: 14; color: MeoTheme.onSurfaceVariant; elide: Text.ElideRight }
    }
    Text {
        id: chevron
        anchors.right: parent.right; anchors.rightMargin: 20; anchors.verticalCenter: parent.verticalCenter
        text: "›"; font.pixelSize: 28; color: card.selected ? MeoTheme.primary : MeoTheme.onSurfaceVariant
    }
}
