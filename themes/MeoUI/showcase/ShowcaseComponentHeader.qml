import QtQuick
import QtQuick.Layouts
import MeoUI

ColumnLayout {
    id: control

    property var componentData: ({})

    width: parent ? parent.width : implicitWidth
    spacing: MeoTheme.space8

    RowLayout {
        Layout.fillWidth: true
        spacing: MeoTheme.space12

        MeoText {
            text: componentData.name || ""
            typeRole: "title"
            typeSize: "medium"
            emphasized: true
            color: MeoTheme.contentOnSurface
        }

        MeoText {
            Layout.fillWidth: true
            text: componentData.source || ""
            typeRole: "label"
            typeSize: "small"
            color: MeoTheme.contentOnSurfaceVariant
            elide: Text.ElideLeft
            horizontalAlignment: Text.AlignRight
        }
    }

    MeoText {
        Layout.fillWidth: true
        text: componentData.summary || ""
        typeRole: "body"
        typeSize: "medium"
        color: MeoTheme.contentOnSurfaceVariant
        wrapMode: Text.WordWrap
    }
}
