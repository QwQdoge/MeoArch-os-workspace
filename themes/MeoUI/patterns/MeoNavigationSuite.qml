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
    readonly property bool isCompact: availableWidth < 600 * themeGlobalScale
    readonly property bool isMedium: availableWidth >= 600 * themeGlobalScale && availableWidth < 840 * themeGlobalScale
    readonly property bool isExpanded: availableWidth >= 840 * themeGlobalScale
    readonly property real expandedDrawerWidth: Math.max(240 * themeGlobalScale, Math.min(320 * themeGlobalScale, 280 * themeGlobalScale))

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
