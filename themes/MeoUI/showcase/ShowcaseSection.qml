import QtQuick
import QtQuick.Layouts
import MeoUI

Rectangle {
    id: control

    property var componentData: ({})
    default property alias content: contentColumn.data

    width: parent ? parent.width : implicitWidth
    implicitHeight: contentColumn.implicitHeight + MeoTheme.space32
    radius: MeoTheme.shapeLarge
    color: MeoTheme.surfaceContainerLowest
    border.color: MeoTheme.outlineVariant

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: MeoTheme.space16
        spacing: MeoTheme.space16

        ShowcaseComponentHeader {
            Layout.fillWidth: true
            componentData: control.componentData
        }
    }
}
