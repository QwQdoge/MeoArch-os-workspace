import QtQuick
import QtQuick.Layouts
import MeoUI

ColumnLayout {
    id: control

    property string title: "Variants"
    default property alias content: body.data

    width: parent ? parent.width : implicitWidth
    spacing: MeoTheme.space8

    MeoText {
        id: titleText
        Layout.fillWidth: true
        text: control.title
        typeRole: "label"
        typeSize: "big"
        color: MeoTheme.contentOnSurface
    }

    Flow {
        id: body
        Layout.fillWidth: true
        Layout.preferredHeight: childrenRect.height
        spacing: MeoTheme.space12
    }
}
