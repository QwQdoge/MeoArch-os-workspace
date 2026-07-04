import QtQuick
import QtQuick.Layouts
import MeoUI

ColumnLayout {
    id: control

    property string api: ""
    property string states: ""
    property string variants: ""

    width: parent ? parent.width : implicitWidth
    spacing: MeoTheme.space8

    RowLayout {
        Layout.fillWidth: true
        spacing: MeoTheme.space8
        ApiPill { label: "Variants"; value: control.variants }
        ApiPill { label: "States"; value: control.states }
    }

    ApiPill {
        Layout.fillWidth: true
        label: "API"
        value: control.api
    }

    component ApiPill: Rectangle {
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
                text: parent.parent.label
                typeRole: "label"
                typeSize: "small"
                color: MeoTheme.primary
            }

            MeoText {
                width: parent.width
                text: parent.parent.value
                typeRole: "body"
                typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
                wrapMode: Text.WordWrap
            }
        }
    }
}
