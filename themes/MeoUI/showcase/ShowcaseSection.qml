import QtQuick
import QtQuick.Layouts
import MeoUI

Rectangle {
    id: control

    property var componentData: ({})
    property string title: ""
    property string subtitle: ""
    property string source: ""
    readonly property var headerData: {
        if (componentData && componentData.name) return componentData;
        return {
            "name": title,
            "summary": subtitle,
            "source": source
        };
    }
    default property alias content: contentColumn.data

    width: parent ? parent.width : implicitWidth
    readonly property bool compact: width < MeoTheme.windowBreakpointMedium * MeoTheme.globalScale
    readonly property real contentMargin: compact ? MeoTheme.space12 : MeoTheme.space24
    implicitHeight: contentColumn.implicitHeight + contentMargin * 2
    radius: compact ? MeoTheme.shapeSmall : MeoTheme.shapeMedium
    color: MeoTheme.surface
    border.color: Qt.rgba(MeoTheme.outlineVariant.r, MeoTheme.outlineVariant.g, MeoTheme.outlineVariant.b, 0.72)

    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: control.contentMargin
        spacing: control.compact ? MeoTheme.space16 : MeoTheme.space24

        ShowcaseComponentHeader {
            Layout.fillWidth: true
            componentData: control.headerData
        }
    }
}
