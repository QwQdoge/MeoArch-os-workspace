import QtQuick
import MeoUI

Item {
    id: control
    default property alias content: contentLayer.data
    property color color: MeoTheme.surfaceContainerLowest
    property real radius: MeoTheme.shapeExtraLarge
    property int elevation: 2
    property real entranceDistance: 40 * MeoTheme.globalScale
    property bool animateOnCompleted: false
    property int entranceDirection: 1
    property real motionOffset: 0

    function reveal(direction) {
        entranceDirection = direction === 0 ? 1 : direction
        entrance.stop()
        opacity = 0
        scale = 0.985
        motionOffset = entranceDistance * entranceDirection
        entrance.start()
    }

    transform: Translate { x: control.motionOffset }
    Rectangle {
        x: 0; y: control.elevation * 4
        width: parent.width; height: parent.height
        radius: control.radius
        color: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b, control.elevation > 0 ? 0.055 : 0)
        opacity: control.elevation > 0 ? 1 : 0
    }
    Rectangle {
        x: 0; y: control.elevation * 2
        width: parent.width; height: parent.height
        radius: control.radius
        color: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b, control.elevation > 0 ? 0.065 : 0)
        opacity: control.elevation > 0 ? 1 : 0
    }
    Rectangle {
        anchors.fill: parent
        radius: control.radius
        color: control.color
        border.width: 1
        border.color: Qt.rgba(MeoTheme.outline.r, MeoTheme.outline.g, MeoTheme.outline.b, 0.16)
        Behavior on radius { NumberAnimation { duration: MeoTheme.motionDurationMedium1; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
    }
    Item { id: contentLayer; anchors.fill: parent }

    Component.onCompleted: if (animateOnCompleted) reveal(entranceDirection)
    ParallelAnimation {
        id: entrance
        NumberAnimation { target: control; property: "opacity"; to: 1; duration: MeoTheme.motionDurationMedium2; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
        NumberAnimation { target: control; property: "scale"; to: 1; duration: MeoTheme.motionDurationMedium3; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
        NumberAnimation { target: control; property: "motionOffset"; to: 0; duration: MeoTheme.motionDurationMedium3; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
    }
}
