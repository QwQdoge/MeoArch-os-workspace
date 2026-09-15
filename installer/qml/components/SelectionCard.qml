import QtQuick
import MeoUI 1.0

MeoCard {
    id: card
    property string iconText: "•"
    property string iconFont: "Roboto"
    property string title: ""
    property string value: ""
    // Most option cards are intentionally compact.  Pages with explanatory
    // copy can opt in to a taller card so translated text is never clipped.
    property bool wrapValue: false
    // A selection card represents one option in a mutually exclusive choice;
    // a navigation card opens another view. Keeping that distinction explicit
    // prevents a right-facing chevron from implying navigation on radio-like
    // installer choices such as disks and software profiles.
    property bool selectionIndicator: false
    property bool actionable: true
    property string trailingIcon: "chevron_right"
    type: "outlined"
    interactive: actionable
    padding: 0
    implicitHeight: Math.max(84 * MeoTheme.globalScale,
                             copy.implicitHeight + 32 * MeoTheme.globalScale)
    radius: MeoTheme.shapeLarge
    activeFocusOnTab: actionable
    Accessible.name: title + (value.length ? ", " + value : "")
    Accessible.role: selectionIndicator ? Accessible.RadioButton
                                         : actionable ? Accessible.Button : Accessible.Pane
    Accessible.checked: selectionIndicator && selected

    // MeoCard's visual background owns its hover state, but controls place
    // background items behind their content item. A root-level handler keeps
    // the complete card reliably actionable in the installer.
    TapHandler {
        enabled: card.enabled && card.actionable
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
        size: 24 * MeoTheme.globalScale
        color: MeoTheme.primary
    }
    Column {
        anchors.left: leadingIcon.right
        anchors.leftMargin: 16 * MeoTheme.globalScale
        anchors.right: trailing.left
        anchors.rightMargin: 12 * MeoTheme.globalScale
        anchors.verticalCenter: parent.verticalCenter
        spacing: 2 * MeoTheme.globalScale
        MeoText { width: parent.width; text: card.title; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface; elide: Text.ElideRight }
        MeoText {
            width: parent.width
            text: card.value
            typeRole: "body"
            typeSize: "medium"
            color: MeoTheme.contentOnSurfaceVariant
            wrapMode: card.wrapValue ? Text.WordWrap : Text.NoWrap
            elide: card.wrapValue ? Text.ElideNone : Text.ElideRight
        }
    }
    MeoIcon {
        id: trailing
        anchors.right: parent.right
        anchors.rightMargin: 20 * MeoTheme.globalScale
        anchors.verticalCenter: parent.verticalCenter
        visible: card.selectionIndicator || card.trailingIcon.length > 0
        icon: card.selectionIndicator ? (card.selected ? "check_circle" : "radio_button_unchecked")
                                      : card.trailingIcon
        size: 24 * MeoTheme.globalScale
        color: card.selected ? MeoTheme.primary : MeoTheme.contentOnSurfaceVariant
    }
}
