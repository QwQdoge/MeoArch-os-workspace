import QtQuick
import QtQuick.Layouts
import MeoUI

Item {
    id: control

    property var componentData: ({})

    width: parent ? parent.width : implicitWidth
    implicitWidth: headerColumn.implicitWidth
    implicitHeight: headerColumn.implicitHeight

    ColumnLayout {
        id: headerColumn
        anchors.left: parent.left
        anchors.right: parent.right
        spacing: MeoTheme.space12

        GridLayout {
            Layout.fillWidth: true
            columns: control.width < MeoTheme.windowBreakpointMedium * MeoTheme.globalScale ? 1 : 2
            rowSpacing: MeoTheme.space8
            columnSpacing: MeoTheme.space12

            MeoText {
                text: control.componentData.name || ""
                typeRole: "title"
                typeSize: "medium"
                emphasized: true
                color: MeoTheme.contentOnSurface
            }

            MeoText {
                Layout.fillWidth: true
                text: control.componentData.source || ""
                typeRole: "label"
                typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
                elide: Text.ElideLeft
                horizontalAlignment: parent.columns === 1 ? Text.AlignLeft : Text.AlignRight
            }
        }

        MeoText {
            Layout.fillWidth: true
            text: control.componentData.summary || ""
            typeRole: "body"
            typeSize: "medium"
            color: MeoTheme.contentOnSurfaceVariant
            wrapMode: Text.WordWrap
        }
    }
}
