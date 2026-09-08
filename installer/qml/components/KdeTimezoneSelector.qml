import QtQuick
import org.kde.plasma.workspace.timezoneselector 254.0 as PlasmaTimezone

Item {
    id: root
    property alias selectedTimeZone: selector.selectedTimeZone

    PlasmaTimezone.TimezoneSelector {
        id: selector
        anchors.fill: parent
    }
}
