import QtQuick
import QtQuick.Layouts
import MeoUI

ColumnLayout {
    id: control

    property string api: ""
    property string stateSummary: ""
    property string variants: ""

    width: parent ? parent.width : implicitWidth
    spacing: MeoTheme.space8

    GridLayout {
        Layout.fillWidth: true
        columns: control.width < 520 * MeoTheme.globalScale ? 1 : 2
        rowSpacing: MeoTheme.space8
        columnSpacing: MeoTheme.space8
        ApiPill { label: "Variants"; value: control.variants }
        ApiPill { label: "States"; value: control.stateSummary }
    }

    ApiPill {
        Layout.fillWidth: true
        label: "API"
        value: control.api
    }

    component ApiPill: Rectangle {
        id: pill
        property string label: ""
        property string value: ""

        Layout.fillWidth: true
        implicitHeight: content.implicitHeight + MeoTheme.space16
        radius: MeoTheme.shapeSmall
        color: MeoTheme.surfaceContainerLow
        border.color: MeoTheme.outlineVariant

        Column {
            id: content
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.margins: MeoTheme.space8
            spacing: MeoTheme.space2

            MeoText {
                text: pill.label
                typeRole: "label"
                typeSize: "small"
                color: MeoTheme.primary
            }

            MeoText {
                width: parent.width
                text: pill.value
                typeRole: "body"
                typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
                wrapMode: Text.WordWrap
            }
        }
    }
}
