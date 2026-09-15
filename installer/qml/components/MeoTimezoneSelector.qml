import QtQuick
import MeoUI 1.0

/*
 * The Live ISO intentionally has no Plasma Workspace or KWin dependency.
 * Time-zone selection remains fully usable through the searchable list above;
 * this reserved area explains why an interactive map is not included in the
 * Cage-only installer image.
 */
Item {
    id: root

    property string selectedTimeZone: ""
    readonly property bool mapAvailable: false

    function dp(value) { return Math.round(value * MeoTheme.globalScale) }

    MeoCard {
        anchors.fill: parent
        type: "filled"
        padding: root.dp(20)
        Column {
            anchors.centerIn: parent
            width: parent.width - root.dp(40)
            spacing: root.dp(10)
            MeoIcon { anchors.horizontalCenter: parent.horizontalCenter; icon: "map"; size: root.dp(36); color: MeoTheme.primary }
            MeoText { width: parent.width; text: qsTr("Choose a time zone from the searchable list"); horizontalAlignment: Text.AlignHCenter; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
            MeoText { width: parent.width; text: qsTr("The Live installer keeps its Cage-only security boundary and does not load a Plasma Workspace map. Your selected time zone is applied normally."); horizontalAlignment: Text.AlignHCenter; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
        }
    }
}
