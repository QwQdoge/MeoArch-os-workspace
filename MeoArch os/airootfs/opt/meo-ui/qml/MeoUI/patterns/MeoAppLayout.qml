pragma ComponentBehavior: Bound
import QtQuick
import MeoUI

Item {
    id: control
    anchors.fill: parent

    // 🌟 Configuration
    property var navigationModel: []
    property list<Component> pages
    property int currentIndex: 0
    property int compactNavigationLimit: 5

    // 🌟 Safe Area Insets (Edge-to-Edge support)
    property real safeAreaTop: 0
    property real safeAreaBottom: 0
    property real safeAreaLeft: 0
    property real safeAreaRight: 0

    // 🌟 Branding & Actions
    property Component accountHeader: null
    property Component fab: null

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property bool isCompact: windowMetrics.isSmall
    readonly property bool isMedium: windowMetrics.isMedium
    readonly property bool isExpanded: windowMetrics.isLarge
    readonly property string windowSizeClass: windowMetrics.sizeClass
    readonly property real expandedDrawerWidth: 280 * themeGlobalScale
    readonly property var compactNavigationModel: navigationModel.slice(0, Math.min(compactNavigationLimit, navigationModel.length))

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.width
        availableHeight: control.height
    }

    onCurrentIndexChanged: pageEntrance.restart()

    // Main Layout
    Row {
        anchors.fill: parent

        // 1. Navigation Rail (Medium)
        MeoNavigationRail {
            id: navRail
            width: control.isMedium ? 80 * control.themeGlobalScale : 0
            height: parent.height
            model: control.navigationModel
            currentIndex: control.currentIndex
            visible: width > 0
            enabled: control.isMedium
            opacity: control.isMedium ? 1 : 0
            header: control.accountHeader ? accountHeaderWrapper : null
            onClicked: (index) => { control.currentIndex = index }

            Behavior on width { NumberAnimation { duration: MeoTheme.motionDurationControlNormal; easing.bezierCurve: MeoTheme.motionEasingEnter } }
            Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationControlFast } }

            Component {
                id: accountHeaderWrapper
                Loader { sourceComponent: control.accountHeader }
            }
        }

        // 2. Navigation Drawer (Expanded)
        MeoNavigationDrawer {
            id: navDrawer
            width: control.isExpanded ? control.expandedDrawerWidth : 0
            height: parent.height
            model: control.navigationModel
            currentIndex: control.currentIndex
            visible: width > 0
            enabled: control.isExpanded
            opacity: control.isExpanded ? 1 : 0
            header: control.accountHeader
            onClicked: (index) => { control.currentIndex = index }

            Behavior on width { NumberAnimation { duration: MeoTheme.motionDurationControlNormal; easing.bezierCurve: MeoTheme.motionEasingEnter } }
            Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationControlFast } }
        }

        // 3. Main Content Area
        Column {
            width: parent.width - (navRail.visible ? navRail.width : 0) - (navDrawer.visible ? navDrawer.width : 0)
            height: parent.height

            Behavior on width { NumberAnimation { duration: MeoTheme.motionDurationControlNormal; easing.bezierCurve: MeoTheme.motionEasingEnter } }

            // Top App Bar (Compact only, with Hamburger)
            MeoTopAppBar {
                id: topAppBar
                width: parent.width
                title: control.navigationModel[control.currentIndex] ? control.navigationModel[control.currentIndex].label : "App"
                type: "small"
                visible: control.isCompact

                // Add top padding for notch
                Item { height: control.safeAreaTop; width: parent.width }

                // Add a navigation icon for the hamburger menu
                navigationIcon: MeoIconButton {
                    icon.name: "menu"
                    onClicked: modalDrawer.open()
                }
            }

            // Page Content (StackLayout for Keep-Alive)
            Item {
                width: parent.width
                height: parent.height - (topAppBar.visible ? topAppBar.height : 0) - (bottomNavBar.visible ? bottomNavBar.height + control.safeAreaBottom : 0)

                Loader {
                    id: pageLoader
                    anchors.fill: parent
                    anchors.leftMargin: control.safeAreaLeft
                    anchors.rightMargin: control.safeAreaRight
                    sourceComponent: control.currentIndex >= 0 && control.currentIndex < control.pages.length
                                     ? control.pages[control.currentIndex] : null
                }

                // FAB Layer
                Loader {
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 16 * control.themeGlobalScale
                    anchors.bottomMargin: 16 * control.themeGlobalScale + control.safeAreaBottom
                    anchors.rightMargin: 16 * control.themeGlobalScale + control.safeAreaRight
                    sourceComponent: control.fab
                    visible: control.fab !== null
                }
            }

            // Bottom Navigation Bar (Compact only)
            MeoNavigationBar {
                id: bottomNavBar
                width: parent.width
                model: control.compactNavigationModel
                currentIndex: control.currentIndex
                visible: control.isCompact
                onClicked: (index) => { control.currentIndex = index }
            }

            // Safe Area Bottom Spacer for BottomNav
            Item {
                width: parent.width
                height: control.safeAreaBottom
                visible: control.isCompact
            }
        }
    }

    // Modal Navigation Drawer (Compact only, triggered by hamburger)
    MeoNavigationDrawerModal {
        id: modalDrawer
        model: control.navigationModel
        currentIndex: control.currentIndex
        header: control.accountHeader
        onClicked: (index) => {
            control.currentIndex = index
            modalDrawer.close()
        }
    }

    ParallelAnimation {
        id: pageEntrance
        NumberAnimation { target: pageLoader; property: "opacity"; from: 0.72; to: 1; duration: MeoTheme.motionDurationControlNormal; easing.bezierCurve: MeoTheme.motionEasingEnter }
        NumberAnimation { target: pageLoader; property: "scale"; from: 0.992; to: 1; duration: MeoTheme.motionDurationControlNormal; easing.bezierCurve: MeoTheme.motionEasingEnter }
    }
}
