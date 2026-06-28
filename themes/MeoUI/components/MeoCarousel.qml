import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property var model: []
    property Component delegate: null
    property string type: "multi-browse" // "multi-browse" | "uncontained" | "hero" | "full-screen"
    property real itemWidth: type === "hero" ? (width - 32 * themeGlobalScale) : 200 * themeGlobalScale
    property real itemHeight: 300 * themeGlobalScale
    spacing: (type === "multi-browse" || type === "uncontained") ? 8 * themeGlobalScale : 16 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property real themeShapeExtraLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeExtraLarge !== 'undefined') ? MeoTheme.shapeExtraLarge : 28 * themeGlobalScale

    implicitWidth: parent ? parent.width : 400 * themeGlobalScale
    implicitHeight: itemHeight + (showPageIndicator ? 32 * themeGlobalScale : 0)

    property bool showPageIndicator: true

    ListView {
        id: listView
        anchors.fill: parent
        orientation: ListView.Horizontal
        spacing: control.spacing
        model: control.model
        leftMargin: (control.type === "multi-browse" || control.type === "hero") ? 16 * control.themeGlobalScale : 0
        rightMargin: (control.type === "multi-browse" || control.type === "hero") ? 16 * control.themeGlobalScale : 0

        delegate: Item {
            width: {
                if (control.type === "multi-browse") {
                    // MD3 Multi-browse strategy: Large, Medium, Small
                    // Simplified logic for QML ListView:
                    // We'll give most items 'Large' width, and some 'Small' at the end of viewport
                    let largeWidth = (listView.width - 64 * control.themeGlobalScale) / 1.5;
                    if (index % 4 === 0) return largeWidth; // Large
                    if (index % 4 === 1) return largeWidth * 0.6; // Medium
                    if (index % 4 === 2) return 56 * control.themeGlobalScale; // Small
                    return largeWidth;
                }
                if (control.type === "uncontained") return (listView.width * 0.8);
                if (control.type === "full-screen") return listView.width;
                return control.itemWidth;
            }
            height: control.itemHeight

            // 🌟 MD3 Hero Scale Transition
            scale: control.type === "hero" ? (listView.currentIndex === index ? 1.0 : 0.9) : 1.0
            opacity: control.type === "hero" ? (listView.currentIndex === index ? 1.0 : 0.6) : 1.0

            Behavior on scale { NumberAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
            Behavior on opacity { NumberAnimation { duration: 250 } }

            Loader {
                id: delegateLoader
                anchors.fill: parent
                sourceComponent: control.delegate
                property var modelData: model.modelData

                // 🌟 MD3 Corner Radius for Carousel Items
                Rectangle {
                    anchors.fill: parent
                    z: -1
                    radius: control.themeShapeExtraLarge
                    color: "transparent"
                    border.color: "transparent"
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskThresholdMin: 0.5
                        maskSource: Rectangle {
                            width: delegateLoader.width
                            height: delegateLoader.height
                            radius: control.themeShapeExtraLarge
                        }
                    }
                }
            }
        }
        snapMode: (control.type === "uncontained" || control.type === "full-screen") ? ListView.NoSnap : ListView.SnapToItem
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
