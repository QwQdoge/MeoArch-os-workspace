import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    anchors.fill: parent
    MeoEmptyState {
        anchors.centerIn: parent
        icon: "inbox"
        title: "No Data"
        description: "There is nothing to show here."
    }
}
