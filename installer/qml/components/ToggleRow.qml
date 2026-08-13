import QtQuick
import MeoUI 1.0

Rectangle {
    id: row
    property string title: ""
    property string subtitle: ""
    property alias checked: toggle.checked
    signal toggled(bool checked)
    color: "transparent"
    radius: MeoTheme.shapeMedium
    implicitHeight: 58
    activeFocusOnTab: true
    Accessible.name: title
    Accessible.role: Accessible.CheckBox
    Accessible.checked: checked

    MeoStateLayer {
        anchors.fill: parent
        radius: row.radius
        hovered: hover.hovered
        pressed: tap.pressed
        focused: row.activeFocus
        color: MeoTheme.contentOnSurface
    }
    Column {
        anchors.left: parent.left; anchors.leftMargin: 12; anchors.right: toggle.left; anchors.rightMargin: 16
        anchors.verticalCenter: parent.verticalCenter; spacing: 1
        MeoText { width: parent.width; text: row.title; typeRole: "body"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface; elide: Text.ElideRight }
        MeoText { visible: row.subtitle.length > 0; width: parent.width; text: row.subtitle; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; elide: Text.ElideRight }
    }
    MeoSwitch { id: toggle; width: 52; height: 32; anchors.right: parent.right; anchors.rightMargin: 8; anchors.verticalCenter: parent.verticalCenter; showIcon: false; onToggled: row.toggled(checked) }
    HoverHandler { id: hover }
    TapHandler { id: tap; onTapped: { row.forceActiveFocus(); toggle.checked = !toggle.checked; row.toggled(toggle.checked) } }
    Keys.onSpacePressed: { toggle.checked = !toggle.checked; row.toggled(toggle.checked) }
}
