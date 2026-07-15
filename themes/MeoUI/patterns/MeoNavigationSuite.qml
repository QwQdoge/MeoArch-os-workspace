import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    property var model: []
    property int currentIndex: 0
    property bool expandedRail: false
    property Component header: null
    property Component footer: null
    property string labelType: "always"
    property real availableWidth: parent ? parent.width : width

    signal clicked(int index)

    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property bool isCompact: windowMetrics.isSmall
    readonly property bool isMedium: windowMetrics.isMedium
    readonly property bool isExpanded: windowMetrics.isLarge
    readonly property string windowSizeClass: windowMetrics.sizeClass
    readonly property real expandedDrawerWidth: 280 * themeGlobalScale

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.availableWidth
        availableHeight: control.height
    }

    implicitWidth: isCompact ? 360 * themeGlobalScale : (isMedium ? (expandedRail ? 256 : 80) * themeGlobalScale : expandedDrawerWidth)
    implicitHeight: isCompact ? 80 * themeGlobalScale : 600 * themeGlobalScale
    width: implicitWidth

    MeoNavigationBar {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: control.isCompact
        model: control.model
        currentIndex: control.currentIndex
        labelType: control.labelType
        onClicked: (index) => {
            control.currentIndex = index
            control.clicked(index)
        }
    }

    MeoNavigationRail {
        anchors.fill: parent
        visible: control.isMedium
        model: control.model
        currentIndex: control.currentIndex
        isExpanded: control.expandedRail
        header: control.header
        footer: control.footer
        labelType: control.labelType
        onClicked: (index) => {
            control.currentIndex = index
            control.clicked(index)
        }
    }

    MeoNavigationDrawer {
        anchors.fill: parent
        visible: control.isExpanded
        model: control.model
        currentIndex: control.currentIndex
        header: control.header
        footer: control.footer
        onClicked: (index) => {
            control.currentIndex = index
            control.clicked(index)
        }
    }
}
