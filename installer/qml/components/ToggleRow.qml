import QtQuick
import MeoUI 1.0

Item {
    id: row
    property string title: ""
    property string subtitle: ""
    property alias checked: toggle.checked
    property real cornerRadius: MeoTheme.shapeMedium
    signal toggled(bool checked)
    implicitHeight: Math.max(64 * MeoTheme.globalScale,
                             copy.implicitHeight + 24 * MeoTheme.globalScale)
    activeFocusOnTab: true
    Accessible.name: title
    Accessible.role: Accessible.CheckBox
    Accessible.checked: checked

    MeoStateLayer {
        anchors.fill: parent
        radius: row.cornerRadius
        hovered: hover.hovered
        pressed: tap.pressed
        focused: row.activeFocus
        color: MeoTheme.contentOnSurface
    }
    Column {
        id: copy
        anchors.left: parent.left; anchors.leftMargin: 16 * MeoTheme.globalScale
        anchors.right: toggle.left; anchors.rightMargin: 16 * MeoTheme.globalScale
        anchors.verticalCenter: parent.verticalCenter; spacing: 2 * MeoTheme.globalScale
        MeoText { width: parent.width; text: row.title; typeRole: "body"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface; elide: Text.ElideRight }
        MeoText { visible: row.subtitle.length > 0; width: parent.width; text: row.subtitle; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; elide: Text.ElideRight }
    }
    MeoSwitch {
        id: toggle
        width: 52 * MeoTheme.globalScale
        height: 32 * MeoTheme.globalScale
        anchors.right: parent.right
        anchors.rightMargin: 12 * MeoTheme.globalScale
        anchors.verticalCenter: parent.verticalCenter
        showIcon: false
        onToggled: row.toggled(checked)
    }
    HoverHandler { id: hover }
    TapHandler { id: tap; onTapped: { row.forceActiveFocus(); toggle.checked = !toggle.checked; row.toggled(toggle.checked) } }
    Keys.onSpacePressed: { toggle.checked = !toggle.checked; row.toggled(toggle.checked) }
}
