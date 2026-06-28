import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control
    anchors.fill: parent

    // 🌟 核心对外接口 (Slots)
    property Component topBar: null
    property Component bottomBar: null
    property Component navigationBar: null
    property Component navigationRail: null
    property Component navigationDrawer: null
    property Component sideSheet: null
    property bool sideSheetOpen: false
    property Component fab: null
    property Component content: null
    property Component snackbar: null

    // 🌟 响应式断点逻辑 (与 MeoListDetailLayout 保持一致)
    readonly property bool isCompact: width < 600 * themeGlobalScale
    readonly property bool isMedium: width >= 600 * themeGlobalScale && width < 840 * themeGlobalScale
    readonly property bool isExpanded: width >= 840 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // Layout Logic
    Row {
        anchors.fill: parent

        // 1. Navigation Rail (Visible in Medium and Expanded by default)
        Loader {
            id: railLoader
            height: parent.height
            sourceComponent: control.navigationRail
            visible: (control.isMedium || control.isExpanded) && control.navigationRail !== null
        }

        // 2. Navigation Drawer (Visible in Expanded by default if provided)
        Loader {
            id: drawerLoader
            height: parent.height
            sourceComponent: control.navigationDrawer
            visible: control.isExpanded && control.navigationDrawer !== null
        }

        // 3. Main Body Column
        Column {
            width: parent.width - (railLoader.visible ? railLoader.width : 0) - (drawerLoader.visible ? drawerLoader.width : 0)
            height: parent.height

            // Top Bar Slot
            Loader {
                id: topBarLoader
                width: parent.width
                sourceComponent: control.topBar
                visible: control.topBar !== null
            }

            // Content Area
            Item {
                width: parent.width
                height: parent.height - (topBarLoader.visible ? topBarLoader.height : 0) - (bottomBarLoader.visible ? bottomBarLoader.height : 0) - (navBarLoader.visible ? navBarLoader.height : 0)

                Row {
                    anchors.fill: parent

                    Loader {
                        id: contentLoader
                        width: parent.width - (sideSheetLoader.visible ? sideSheetLoader.width : 0)
                        height: parent.height
                        sourceComponent: control.content
                    }

                    Loader {
                        id: sideSheetLoader
                        height: parent.height
                        sourceComponent: control.sideSheet
                        visible: control.sideSheetOpen && control.sideSheet !== null
                    }
                }

                // FAB Slot (MD3: Floating above content, usually bottom-right)
                Loader {
                    id: fabLoader
                    anchors.right: parent.right
                    anchors.bottom: parent.bottom
                    anchors.margins: 16 * control.themeGlobalScale
                    sourceComponent: control.fab
                    visible: control.fab !== null
                }
            }

            // Bottom Bar Slot (MD3: Bottom App Bar)
            Loader {
                id: bottomBarLoader
                width: parent.width
                sourceComponent: control.bottomBar
                visible: control.isCompact && control.bottomBar !== null
            }

            // Navigation Bar Slot (MD3: Mobile bottom nav)
            Loader {
                id: navBarLoader
                width: parent.width
                sourceComponent: control.navigationBar
                visible: control.isCompact && control.navigationBar !== null
            }
        }
    }

    // 4. Snackbar Layer (MD3: Floating above everything, usually bottom-center)
    Loader {
        id: snackbarLoader
        anchors.bottom: parent.bottom
        anchors.bottomMargin: (navBarLoader.visible ? navBarLoader.height : (bottomBarLoader.visible ? bottomBarLoader.height : 0)) + 16 * control.themeGlobalScale
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: control.snackbar
        visible: control.snackbar !== null
    }

    // 5. Modal Navigation Drawer (Handled by the component itself if it's a Popup, but we can provide a trigger helper)
}
