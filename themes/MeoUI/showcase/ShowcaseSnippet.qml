import QtQuick
import MeoUI

Rectangle {
    id: control

    property string code: ""

    width: parent ? parent.width : implicitWidth
    implicitHeight: snippetText.implicitHeight + MeoTheme.space24
    radius: MeoTheme.shapeMedium
    color: MeoTheme.surfaceContainerHighest

    MeoText {
        id: snippetText
        anchors.fill: parent
        anchors.margins: MeoTheme.space12
        text: control.code
        typeRole: "body"
        typeSize: "small"
        color: MeoTheme.contentOnSurfaceVariant
        wrapMode: Text.Wrap
    }
}
