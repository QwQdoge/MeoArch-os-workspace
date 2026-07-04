import QtQuick
import QtQuick.Layouts
import MeoUI

Flow {
    id: control

    property var labels: ["Normal", "Disabled", "Selected", "Error", "Loading", "Focused"]

    width: parent ? parent.width : implicitWidth
    spacing: MeoTheme.space8

    Repeater {
        model: control.labels
        delegate: Rectangle {
            required property string modelData

            implicitWidth: stateLabel.implicitWidth + MeoTheme.space24
            implicitHeight: MeoTheme.buttonHeightXS
            radius: implicitHeight / 2
            color: MeoTheme.surfaceContainer
            border.color: MeoTheme.outlineVariant

            MeoText {
                id: stateLabel
                anchors.centerIn: parent
                text: modelData
                typeRole: "label"
                typeSize: "small"
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
    }
}
