import QtQuick
import MeoUI 1.0

MeoCard {
    id: card
    property string iconText: "•"
    property string iconFont: "Roboto"
    property string title: ""
    property string value: ""
    type: "outlined"
    interactive: true
    padding: 0
    implicitHeight: 84 * MeoTheme.globalScale
    radius: MeoTheme.shapeLarge
    activeFocusOnTab: true
    Accessible.name: title + (value.length ? ", " + value : "")
    Accessible.role: Accessible.Button

    // MeoCard's visual background owns its hover state, but controls place
    // background items behind their content item. A root-level handler keeps
    // the complete card reliably actionable in the installer.
    TapHandler {
        enabled: card.enabled
        onTapped: {
            card.forceActiveFocus(Qt.MouseFocusReason)
            card.clicked()
        }
    }

    MeoIcon {
        id: leadingIcon
        anchors.left: parent.left
        anchors.leftMargin: 20 * MeoTheme.globalScale
        anchors.verticalCenter: parent.verticalCenter
        icon: card.iconText
        size: 24
        color: MeoTheme.primary
    }
    Column {
        anchors.left: leadingIcon.right
        anchors.leftMargin: 16 * MeoTheme.globalScale
        anchors.right: chevron.left
        anchors.rightMargin: 12 * MeoTheme.globalScale
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2 * MeoTheme.globalScale
        MeoText { width: parent.width; text: card.title; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface; elide: Text.ElideRight }
        MeoText { width: parent.width; text: card.value; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; elide: Text.ElideRight }
    }
    MeoIcon {
        id: chevron
        anchors.right: parent.right
        anchors.rightMargin: 20 * MeoTheme.globalScale
        anchors.verticalCenter: parent.verticalCenter
        icon: "chevron_right"
        size: 24
        color: card.selected ? MeoTheme.primary : MeoTheme.contentOnSurfaceVariant
    }
}
