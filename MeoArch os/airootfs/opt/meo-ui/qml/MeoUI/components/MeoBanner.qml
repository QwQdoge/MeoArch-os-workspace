import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Control {
    id: control
    property string title: ""
    property string text: ""
    property string icon: "info"
    property string tone: "tonal" // tonal, success, error
    property string confirmText: ""
    property string cancelText: ""
    signal confirmed()
    signal cancelled()

    readonly property color containerColor: tone === "error" ? MeoTheme.errorContainer
                                              : tone === "success" ? MeoTheme.successContainer
                                              : MeoTheme.secondaryContainer
    readonly property color contentColor: tone === "error" ? MeoTheme.contentOnErrorContainer
                                            : tone === "success" ? MeoTheme.contentOnSuccessContainer
                                            : MeoTheme.contentOnSecondaryContainer
    readonly property real themeGlobalScale: MeoTheme.globalScale

    implicitWidth: parent ? parent.width : 360 * themeGlobalScale
    implicitHeight: Math.max(64 * themeGlobalScale, contentColumn.implicitHeight + 24 * themeGlobalScale)
    padding: 12 * themeGlobalScale
    scale: visible ? 1 : 0.98
    opacity: visible ? 1 : 0
    Behavior on scale { NumberAnimation { duration: MeoTheme.motionDurationMedium1; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate } }
    Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationShort3 } }

    background: Rectangle {
        radius: MeoTheme.shapeLargeIncreased
        color: control.containerColor
        border.width: 1
        border.color: Qt.rgba(control.contentColor.r, control.contentColor.g, control.contentColor.b, 0.16)
        Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationMedium1 } }
        Behavior on radius { NumberAnimation { duration: MeoTheme.motionDurationMedium1; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
    }

    contentItem: Row {
        id: contentColumn
        spacing: 12 * control.themeGlobalScale
        Rectangle {
            width: 40 * control.themeGlobalScale; height: width
            radius: control.tone === "error" ? MeoTheme.shapeMedium : width / 2
            color: Qt.rgba(control.contentColor.r, control.contentColor.g, control.contentColor.b, 0.10)
            anchors.verticalCenter: parent.verticalCenter
            MeoIcon { anchors.centerIn: parent; icon: control.icon; size: 22; color: control.contentColor }
            Behavior on radius { NumberAnimation { duration: MeoTheme.motionDurationMedium1; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
        }
        Column {
            width: parent.width - 52 * control.themeGlobalScale - actions.implicitWidth
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2 * control.themeGlobalScale
            Text { width: parent.width; visible: control.title.length > 0; text: control.title; font.family: MeoTheme.typefacePlain; font.pixelSize: 16 * control.themeGlobalScale; font.weight: Font.DemiBold; color: control.contentColor; wrapMode: Text.WordWrap }
            Text { width: parent.width; visible: control.text.length > 0; text: control.text; font.family: MeoTheme.typefacePlain; font.pixelSize: 14 * control.themeGlobalScale; color: control.contentColor; opacity: 0.84; wrapMode: Text.WordWrap }
        }
        Row {
            id: actions
            spacing: 4 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            MeoButton { text: control.cancelText; type: "text"; visible: text.length > 0; onClicked: control.cancelled() }
            MeoButton { text: control.confirmText; type: "text"; visible: text.length > 0; onClicked: control.confirmed() }
        }
    }
}
