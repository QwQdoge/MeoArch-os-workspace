import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property var model: []
    property Component delegate: null
    property string type: "standard" // "standard" | "uncontained" | "hero"
    property real itemWidth: type === "hero" ? (width - 32 * themeGlobalScale) : 200 * themeGlobalScale
    property real itemHeight: 300 * themeGlobalScale
    spacing: 16 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: parent ? parent.width : 400 * themeGlobalScale
    implicitHeight: itemHeight + (showPageIndicator ? 32 * themeGlobalScale : 0)

    property bool showPageIndicator: true

    ListView {
        id: listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: control.type === "uncontained" ? 8 * control.themeGlobalScale : control.spacing
        model: control.model
        leftMargin: control.type === "hero" ? 16 * control.themeGlobalScale : 0
        rightMargin: control.type === "hero" ? 16 * control.themeGlobalScale : 0

        delegate: Item {
            width: {
                if (control.type === "uncontained") return (listView.width * 0.8);
                return control.itemWidth;
            }
            height: control.itemHeight

            // 🌟 MD3 Hero Scale Transition
            scale: control.type === "hero" ? (listView.currentIndex === index ? 1.0 : 0.9) : 1.0
            opacity: control.type === "hero" ? (listView.currentIndex === index ? 1.0 : 0.6) : 1.0

            Behavior on scale { NumberAnimation { duration: 250; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
            Behavior on opacity { NumberAnimation { duration: 250 } }

            Loader {
                anchors.fill: parent
                sourceComponent: control.delegate
                property var modelData: model.modelData
            }
        }
        snapMode: control.type === "uncontained" ? ListView.NoSnap : ListView.SnapToItem
        highlightMoveDuration: 300
        preferredHighlightBegin: control.type === "hero" ? 16 * control.themeGlobalScale : 0
        preferredHighlightEnd: control.type === "hero" ? width - 16 * control.themeGlobalScale : width
        highlightRangeMode: control.type === "hero" ? ListView.ApplyRange : ListView.NoHighlightRange
    }

    MeoPageIndicator {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        count: listView.count
        currentIndex: listView.currentIndex
        visible: control.showPageIndicator && listView.count > 1
    }
}
