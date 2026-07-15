import QtQuick
import MeoUI 1.0 as Meo
import ".."

Rectangle {
    id: row
    property string title: ""
    property string subtitle: ""
    property alias checked: toggle.checked
    signal toggled(bool checked)
    color: "transparent"
    radius: 12
    implicitHeight: 58
    activeFocusOnTab: true
    Accessible.name: title
    Accessible.role: Accessible.CheckBox
    Accessible.checked: checked

    Meo.MeoStateLayer {
        anchors.fill: parent
        radius: row.radius
        hovered: hover.hovered
        pressed: tap.pressed
        focused: row.activeFocus
        color: MeoTheme.onSurface
    }
    Column {
        anchors.left: parent.left; anchors.leftMargin: 12; anchors.right: toggle.left; anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter; spacing: 1
        Text { width: parent.width; text: row.title; font.family: "Roboto"; font.pixelSize: 15; font.weight: Font.Medium; color: MeoTheme.onSurface; elide: Text.ElideRight }
        Text { visible: row.subtitle.length > 0; width: parent.width; text: row.subtitle; font.family: "Roboto"; font.pixelSize: 12; color: MeoTheme.onSurfaceVariant; elide: Text.ElideRight }
    }
    MeoSwitch { id: toggle; anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; onToggled: row.toggled(checked) }
    HoverHandler { id: hover }
    TapHandler { id: tap; onTapped: { row.forceActiveFocus(); toggle.checked = !toggle.checked; row.toggled(toggle.checked) } }
    Keys.onSpacePressed: { toggle.checked = !toggle.checked; row.toggled(toggle.checked) }
}
