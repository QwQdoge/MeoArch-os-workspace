import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Item {
    id: control
    anchors.fill: parent

    // 🌟 Configuration
    property var navigationModel: []
    property list<Component> pages
    property int currentIndex: 0

    // 🌟 Safe Area Insets (Edge-to-Edge support)
    property real safeAreaTop: 0
    property real safeAreaBottom: 0
    property real safeAreaLeft: 0
    property real safeAreaRight: 0

    // 🌟 Branding & Actions
    property Component accountHeader: null
    property Component fab: null

    // 🌟 MD3 Adaptive Breakpoints
    readonly property bool isCompact: width < 600 * themeGlobalScale
    readonly property bool isMedium: width >= 600 * themeGlobalScale && width < 840 * themeGlobalScale
    readonly property bool isExpanded: width >= 840 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // Main Layout
    Row {
        anchors.fill: parent

        // 1. Navigation Rail (Medium)
        MeoNavigationRail {
            id: navRail
            height: parent.height
            model: control.navigationModel
            currentIndex: control.currentIndex
            visible: control.isMedium
            header: control.accountHeader ? accountHeaderWrapper : null
            onClicked: (index) => { control.currentIndex = index }

            Component {
                id: accountHeaderWrapper
                Loader { sourceComponent: control.accountHeader }
            }
        }

        // 2. Navigation Drawer (Expanded)
        MeoNavigationDrawer {
            id: navDrawer
            height: parent.height
            model: control.navigationModel
            currentIndex: control.currentIndex
            visible: control.isExpanded
            header: control.accountHeader
            onClicked: (index) => { control.currentIndex = index }
        }

        // 3. Main Content Area
        Column {
            width: parent.width - (navRail.visible ? navRail.width : 0) - (navDrawer.visible ? navDrawer.width : 0)
            height: parent.height

            // Top App Bar (Compact only, with Hamburger)
            MeoTopAppBar {
                id: topAppBar
                width: parent.width
                title: control.navigationModel[control.currentIndex] ? control.navigationModel[control.currentIndex].label : "App"
                type: "small"
                visible: control.isCompact

                // Add top padding for notch
                Item { height: control.safeAreaTop; width: parent.width }

                // Add a leading icon for the hamburger menu
                leadingIcon: MeoIconButton {
                    icon.name: "menu"
                    onClicked: modalDrawer.open()
                }
            }

            // Page Content (StackLayout for Keep-Alive)
            Item {
                width: parent.width
                height: parent.height - (topAppBar.visible ? topAppBar.height : 0) - (bottomNavBar.visible ? bottomNavBar.height + control.safeAreaBottom : 0)

                StackLayout {
                    id: stackLayout
                    anchors.fill: parent
                    anchors.leftMargin: control.safeAreaLeft
                    anchors.rightMargin: control.safeAreaRight
                    currentIndex: control.currentIndex

                    Repeater {
                        model: control.pages
                        delegate: Loader {
                            Layout.fillWidth: true
                            Layout.fillHeight: true
                            sourceComponent: modelData
                            // Keep alive is achieved because StackLayout keeps all its children instantiated,
                            // only changing their visibility based on currentIndex.
                        }
                    }
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
                model: control.navigationModel
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
}
