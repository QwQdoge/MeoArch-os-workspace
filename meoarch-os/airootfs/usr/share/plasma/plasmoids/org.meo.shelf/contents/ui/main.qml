import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.plasma.plasmoid
import org.kde.plasma.core as PlasmaCore
import org.kde.taskmanager as TaskManager
import MeoUI 1.0
import MeoKDE 1.0

Item {
    id: root

    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground

    implicitHeight: ShellMetrics.shelfPanelHeight
    implicitWidth: Math.max(72 * MeoTheme.globalScale,
                            Math.min(shelfContent.implicitWidth + 20 * MeoTheme.globalScale,
                                     Screen.width * 0.70))

    Component.onCompleted: MeoShellTheme.sync()

    // Shelf Visibility States
    readonly property int stateVisible: 0
    readonly property int stateDodgeHidden: 1
    readonly property int stateFullscreenHidden: 2
    readonly property int stateRevealed: 3

    property int currentShelfState: root.stateVisible
    property bool isEdgeHovered: edgeMouseArea.containsMouse || surfaceContainerMouse.containsMouse

    // Edge Reveal Handle (48x4, radius 2, opacity 0.35 -> hover 64x4, opacity 0.7)
    Rectangle {
        id: edgeHandle
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 2
        anchors.horizontalCenter: parent.horizontalCenter

        width: edgeMouseArea.containsMouse ? ShellMetrics.shelfSurfaceHeight : ShellMetrics.shelfItemSize
        height: MeoTheme.space4
        radius: MeoTheme.shapeFull

        color: MeoTheme.onSurfaceVariant
        opacity: edgeMouseArea.containsMouse ? 0.7 : 0.35
        visible: root.currentShelfState !== root.stateVisible

        Behavior on width { NumberAnimation { duration: MeoMotion.hover; easing.type: Easing.OutCubic } }
        Behavior on opacity { NumberAnimation { duration: MeoMotion.hover; easing.type: Easing.OutCubic } }
    }

    // Touch/Hover Edge Area at bottom of screen
    MouseArea {
        id: edgeMouseArea
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: MeoTheme.space8
        hoverEnabled: true

        onEntered: {
            if (root.currentShelfState === root.stateDodgeHidden || root.currentShelfState === root.stateFullscreenHidden) {
                root.currentShelfState = root.stateRevealed
            }
        }
    }

    // Root Material 3 Content-Sized Surface Pill Container
    Rectangle {
        id: surfaceContainer

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: ShellMetrics.shelfBottomMargin

        width: Math.max(72 * MeoTheme.globalScale,
                        Math.min(shelfContent.implicitWidth + 20 * MeoTheme.globalScale, root.width))
        height: ShellMetrics.shelfSurfaceHeight
        radius: height / 2

        color: MeoTheme.surfaceContainer
        border.color: MeoTheme.outlineVariant
        border.width: ShellMetrics.panelOutlineWidth

        transform: Translate {
            y: (root.currentShelfState === root.stateDodgeHidden || root.currentShelfState === root.stateFullscreenHidden) ? ShellMetrics.shelfPanelHeight : 0
            Behavior on y {
                NumberAnimation {
                    duration: root.currentShelfState === root.stateRevealed ? MeoMotion.shelfReveal : MeoMotion.shelfHide
                    easing.type: Easing.OutCubic
                }
            }
        }

        opacity: (root.currentShelfState === root.stateDodgeHidden || root.currentShelfState === root.stateFullscreenHidden) ? 0 : 1
        Behavior on opacity {
            NumberAnimation { duration: MeoMotion.shelfReveal }
        }

        MouseArea {
            id: surfaceContainerMouse
            anchors.fill: parent
            hoverEnabled: true
        }

        // Inner Content Layout
        RowLayout {
            id: shelfContent
            anchors.centerIn: parent
            spacing: MeoTheme.space2

            // 1. Launcher Button
            ShelfItem {
                id: launcherButton
                isLauncher: true
                title: "Application Launcher"
                isActive: launcherPopup.visible

                onClicked: {
                    launcherPopup.visible = !launcherPopup.visible
                }
            }

            // Divider Line
            Rectangle {
                Layout.preferredWidth: ShellMetrics.panelOutlineWidth
                Layout.preferredHeight: MeoTheme.space24
                Layout.alignment: Qt.AlignVCenter
                color: MeoTheme.outlineVariant
            }

            // 2. Tasks Model Repeater (Pinned + Running Apps merged)
            Repeater {
                id: tasksRepeater
                model: TaskManager.TasksModel {
                    id: tasksModel
                    filterByVirtualDesktop: false
                    filterByActivity: false
                    filterByScreen: false
                    groupMode: TaskManager.TasksModel.GroupApplications
                    sortMode: TaskManager.TasksModel.SortAlpha
                }

                delegate: ShelfItem {
                    required property int index
                    required property string display
                    property var icon: null
                    property var model: null

                    title: display || ""
                    iconName: typeof icon === "string" ? icon : ""
                    iconSource: typeof icon !== "string" ? icon : null
                    isActive: model && typeof model.IsActive !== "undefined" ? model.IsActive : (model && typeof model.isActive !== "undefined" ? model.isActive : false)
                    isRunning: true
                    winCount: model && typeof model.ChildCount !== "undefined" ? Math.max(1, model.ChildCount) : (model && typeof model.winCount !== "undefined" ? model.winCount : 1)
                    isPinned: model && typeof model.IsPinned !== "undefined" ? model.IsPinned : false

                    onClicked: (mouse) => {
                        var modelIndex = tasksModel.index(index, 0)
                        if (winCount > 1 && isActive) {
                            // Multiple windows & currently active -> open window selector popup
                            windowSelectorMenu.targetIndex = index
                            windowSelectorMenu.popup()
                        } else if (isActive) {
                            tasksModel.requestToggleMinimized(modelIndex)
                        } else {
                            tasksModel.requestActivate(modelIndex)
                        }
                    }

                    onRightClicked: (mouse) => {
                        taskContextMenu.targetIndex = index
                        taskContextMenu.popup()
                    }
                }
            }
        }
    }

    // Window Selector Menu for Multi-window grouped tasks
    QQC2.Menu {
        id: windowSelectorMenu
        property int targetIndex: -1

        background: Rectangle {
            color: MeoTheme.surfaceContainerHighest
            radius: MeoTheme.shapeLarge
            border.color: MeoTheme.outlineVariant
            border.width: ShellMetrics.panelOutlineWidth
        }

        Instantiator {
            model: windowSelectorMenu.targetIndex >= 0 ? tasksModel.data(tasksModel.index(windowSelectorMenu.targetIndex, 0), TaskManager.TasksModel.ChildList) || [] : []
            onObjectAdded: (idx, obj) => windowSelectorMenu.insertItem(idx, obj)
            onObjectRemoved: (idx, obj) => windowSelectorMenu.removeItem(obj)

            delegate: QQC2.MenuItem {
                required property var modelData
                text: modelData.display || "Window"
                onTriggered: {
                    var idx = tasksModel.index(windowSelectorMenu.targetIndex, 0)
                    tasksModel.requestActivate(idx)
                }
            }
        }
    }

    // Context Menu for Tasks (M3 Style without Plasma internal jargon)
    QQC2.Menu {
        id: taskContextMenu
        property int targetIndex: -1

        background: Rectangle {
            color: MeoTheme.surfaceContainer
            radius: MeoTheme.shapeLarge
            border.color: MeoTheme.outlineVariant
            border.width: ShellMetrics.panelOutlineWidth
        }

        QQC2.MenuItem {
            text: "Open New Window"
            onTriggered: {
                if (taskContextMenu.targetIndex >= 0) {
                    var idx = tasksModel.index(taskContextMenu.targetIndex, 0)
                    tasksModel.requestNewInstance(idx)
                }
            }
        }

        QQC2.MenuItem {
            property bool isPinned: taskContextMenu.targetIndex >= 0 ? (tasksModel.data(tasksModel.index(taskContextMenu.targetIndex, 0), TaskManager.TasksModel.IsPinned) || false) : false
            text: isPinned ? "Unpin from Shelf" : "Pin to Shelf"
            onTriggered: {
                if (taskContextMenu.targetIndex >= 0) {
                    var idx = tasksModel.index(taskContextMenu.targetIndex, 0)
                    tasksModel.requestToggleIsPinned(idx)
                }
            }
        }

        QQC2.MenuSeparator {}

        QQC2.MenuItem {
            text: "Close Window"
            onTriggered: {
                if (taskContextMenu.targetIndex >= 0) {
                    var idx = tasksModel.index(taskContextMenu.targetIndex, 0)
                    tasksModel.requestClose(idx)
                }
            }
        }
    }

    // Launcher Popup Surface
    LauncherPopup {
        id: launcherPopup
    }
}
