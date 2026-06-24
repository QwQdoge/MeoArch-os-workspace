import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property var model: []
    property Component delegate: null
    property string type: "standard" // "standard" | "uncontained" | "hero"

    // MD3 Multi-browse: Next items should be partially visible
    // "standard": contained, usually fixed sizes
    // "uncontained": partially visible next item (80-90% width)
    // "hero": large focused item

    property real itemWidth: {
        if (type === "hero") return (width - 32 * themeGlobalScale);
        if (type === "uncontained") return (width * 0.85); // 🌟 MD3: Partially visible next item
        return 200 * themeGlobalScale;
    }
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
        spacing: control.spacing
        model: control.model

        // 🌟 MD3: Container padding
        leftMargin: (type === "hero" || type === "uncontained") ? 16 * control.themeGlobalScale : 0
        rightMargin: (type === "hero" || type === "uncontained") ? 16 * control.themeGlobalScale : 0

        delegate: Item {
            width: control.itemWidth
            height: control.itemHeight

            // 🌟 MD3 Hero Scale Transition
            scale: control.type === "hero" ? (listView.currentIndex === index ? 1.0 : 0.9) : 1.0
            opacity: control.type === "hero" ? (listView.currentIndex === index ? 1.0 : 0.6) : 1.0

            Behavior on scale { NumberAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
            Behavior on opacity { NumberAnimation { duration: 250 } }

            // 🌟 MD3: 28dp (shapeExtraLarge) corner radius for carousel items
            Rectangle {
                id: maskRect
                anchors.fill: parent
                radius: 28 * control.themeGlobalScale
                clip: true
                color: "transparent"

                Loader {
                    anchors.fill: parent
                    sourceComponent: control.delegate
                    property var modelData: model.modelData
                }
            }
        }

        snapMode: (control.type === "uncontained" || control.type === "hero") ? ListView.SnapToItem : ListView.NoSnap
        highlightMoveDuration: 300
        preferredHighlightBegin: (type === "hero" || type === "uncontained") ? 16 * control.themeGlobalScale : 0
        preferredHighlightEnd: (type === "hero" || type === "uncontained") ? width - 16 * control.themeGlobalScale : width
        highlightRangeMode: (control.type === "hero" || control.type === "uncontained") ? ListView.ApplyRange : ListView.NoHighlightRange
    }

    MeoPageIndicator {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        count: listView.count
        currentIndex: listView.currentIndex
        visible: control.showPageIndicator && listView.count > 1
    }
}
