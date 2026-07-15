import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control
    property string presentation: "dialog" // dialog, sheet, menu
    property real surfaceRadius: presentation === "menu" ? MeoTheme.shapeLargeIncreased : MeoTheme.shapeExtraLarge
    property color surfaceColor: presentation === "menu" ? MeoTheme.surfaceContainer : MeoTheme.surfaceContainerHigh
    property real scrimOpacity: 0.32

    modal: presentation !== "menu"
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    transformOrigin: presentation === "sheet" ? Item.Right : presentation === "menu" ? Item.TopRight : Item.Center

    Overlay.modal: Rectangle {
        color: Qt.rgba(MeoTheme.scrim.r, MeoTheme.scrim.g, MeoTheme.scrim.b, control.scrimOpacity)
        Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationShort4 } }
    }
    background: Item {
        Rectangle {
            x: control.presentation === "sheet" ? -4 : 0
            y: control.presentation === "menu" ? 3 : 6
            width: parent.width
            height: parent.height
            radius: control.surfaceRadius
            color: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b,
                           control.presentation === "menu" ? 0.10 : 0.08)
        }
        Rectangle {
            x: control.presentation === "sheet" ? -2 : 0
            y: control.presentation === "menu" ? 1 : 2
            width: parent.width
            height: parent.height
            radius: control.surfaceRadius
            color: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b,
                           control.presentation === "menu" ? 0.08 : 0.06)
        }
        Rectangle {
            anchors.fill: parent
            radius: control.surfaceRadius
            color: control.surfaceColor
            border.width: 1
            border.color: Qt.rgba(MeoTheme.outline.r, MeoTheme.outline.g, MeoTheme.outline.b, 0.22)
            Behavior on radius { NumberAnimation { duration: MeoTheme.motionDurationMedium1; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
        }
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0; to: 1; duration: MeoTheme.motionDurationMedium2; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
            NumberAnimation { property: "scale"; from: control.presentation === "dialog" ? 0.94 : 0.985; to: 1; duration: MeoTheme.motionDurationMedium2; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
            NumberAnimation { property: "x"; from: control.presentation === "sheet" && control.parent ? control.parent.width : control.x; to: control.presentation === "sheet" && control.parent ? control.parent.width - control.width : control.x; duration: MeoTheme.motionDurationMedium3; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate }
        }
    }
    exit: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 1; to: 0; duration: MeoTheme.motionDurationShort4; easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate }
            NumberAnimation { property: "scale"; from: 1; to: control.presentation === "dialog" ? 0.98 : 0.995; duration: MeoTheme.motionDurationShort4; easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate }
            NumberAnimation { property: "x"; from: control.x; to: control.presentation === "sheet" && control.parent ? control.parent.width : control.x; duration: MeoTheme.motionDurationShort4; easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate }
        }
    }
}
