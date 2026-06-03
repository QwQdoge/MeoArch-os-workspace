import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property var model: []
    property Component delegate: null
    property real itemWidth: 200 * themeGlobalScale
    property real itemHeight: 300 * themeGlobalScale
    property real spacing: 16 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: parent ? parent.width : 400 * themeGlobalScale
    implicitHeight: itemHeight + (showPageIndicator ? 32 * themeGlobalScale : 0)

    property bool showPageIndicator: true

    ListView {
        id: listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: control.spacing
        model: control.model
        delegate: Item {
            width: control.itemWidth
            height: control.itemHeight
            Loader {
                anchors.fill: parent
                sourceComponent: control.delegate
                property var modelData: model.modelData
            }
        }
        snapMode: ListView.SnapToItem
        highlightMoveDuration: 300
    }

    MeoPageIndicator {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        count: listView.count
        currentIndex: listView.currentIndex
        visible: control.showPageIndicator && listView.count > 1
    }
}
