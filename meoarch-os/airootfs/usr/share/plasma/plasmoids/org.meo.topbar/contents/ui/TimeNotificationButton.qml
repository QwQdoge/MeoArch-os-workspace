import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import MeoUI 1.0
import MeoKDE 1.0

QQC2.AbstractButton {
    id: root

    property date currentDateTime: new Date()
    property int unreadCount: 0
    property real textScale: 1.0
    property bool showDate: true
    property bool showNotifications: true
    property bool use24HourClock: true

    signal statusCenterRequested()

    function displayedTime() {
        return Qt.formatTime(currentDateTime, use24HourClock ? "hh:mm" : "h:mm AP")
    }

    function displayedDate() {
        return Qt.formatDate(currentDateTime, Qt.DefaultLocaleShortDate)
    }

    function notificationStatus() {
        return unreadCount > 0
            ? i18n("%1 unread notifications").arg(unreadCount)
            : i18n("No unread notifications")
    }

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: 32 * MeoTheme.globalScale
    leftPadding: MeoTheme.space8
    rightPadding: MeoTheme.space8
    Accessible.name: i18n("Time, calendar, and notifications")
    Accessible.description: showDate
                            ? i18n("%1 · %2 · %3", displayedTime(), displayedDate(), notificationStatus())
                            : i18n("%1 · %2", displayedTime(), notificationStatus())
    onClicked: statusCenterRequested()

    background: MeoShape {
        id: statusSurface
        type: "pill"
        radius: height / 2
        color: root.hovered || root.down ? MeoTheme.surfaceContainerHighest : Qt.rgba(0, 0, 0, 0)

        MeoStateLayer {
            anchors.fill: parent
            radius: statusSurface.radius
            hovered: root.hovered
            pressed: root.down
            focused: root.visualFocus
            color: MeoTheme.onSurface
        }
    }

    contentItem: RowLayout {
        spacing: MeoTheme.space8

        ColumnLayout {
            spacing: 0

            MeoText {
                text: root.displayedTime()
                typeRole: "label"
                typeSize: "medium"
                emphasized: true
                fontScaleOverride: root.textScale
                color: MeoTheme.onSurface
            }

            MeoText {
                visible: root.showDate
                text: root.displayedDate()
                typeRole: "label"
                typeSize: "small"
                fontScaleOverride: root.textScale
                color: MeoTheme.onSurfaceVariant
            }
        }

        Item {
            visible: root.showNotifications
            implicitWidth: 24 * MeoTheme.globalScale
            implicitHeight: width

            MeoIcon {
                anchors.centerIn: parent
                icon: root.unreadCount > 0 ? "notifications" : "notifications_none"
                size: 20
                color: MeoTheme.onSurface
            }

            MeoBadge {
                visible: root.unreadCount > 0
                text: root.unreadCount
                target: parent
            }
        }
    }
}
