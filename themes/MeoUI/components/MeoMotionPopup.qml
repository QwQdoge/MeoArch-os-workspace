import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    enum Presentation {
        Dialog,
        Menu,
        BottomSheet,
        SideSheet,
        FullScreen
    }

    property int presentation: MeoMotionPopup.Dialog
    property real surfaceRadius: isMenu ? MeoTheme.shapeLargeIncreased
                                        : isFullScreen ? MeoTheme.shapeNone
                                                       : MeoTheme.shapeExtraLarge
    property color surfaceColor: isMenu ? MeoTheme.surfaceContainer
                                        : isFullScreen ? MeoTheme.surface
                                                       : MeoTheme.surfaceContainerHigh
    property real scrimOpacity: 0.32
    property real viewportMargin: 24 * MeoTheme.globalScale
    property Item initialFocusItem: null
    property Item focusReturnItem: null

    readonly property bool isMenu: presentation === MeoMotionPopup.Menu
    readonly property bool isBottomSheet: presentation === MeoMotionPopup.BottomSheet
    readonly property bool isSideSheet: presentation === MeoMotionPopup.SideSheet
    readonly property bool isFullScreen: presentation === MeoMotionPopup.FullScreen
    readonly property int enterDuration: isMenu ? MeoTheme.motionDurationMenuEnter
                                                 : isBottomSheet || isSideSheet ? MeoTheme.motionDurationSheetEnter
                                                                               : MeoTheme.motionDurationDialogEnter
    readonly property int exitDuration: isMenu ? MeoTheme.motionDurationMenuExit
                                                : isBottomSheet || isSideSheet ? MeoTheme.motionDurationSheetExit
                                                                              : MeoTheme.motionDurationDialogExit

    function openFrom(item) {
        focusReturnItem = item || null
        open()
    }

    function clampToViewport() {
        if (!parent || isFullScreen || isBottomSheet || isSideSheet)
            return
        const maximumX = Math.max(viewportMargin, parent.width - width - viewportMargin)
        const maximumY = Math.max(viewportMargin, parent.height - height - viewportMargin)
        x = Math.max(viewportMargin, Math.min(x, maximumX))
        y = Math.max(viewportMargin, Math.min(y, maximumY))
    }

    modal: !isMenu
    focus: true
    closePolicy: isFullScreen ? Popup.CloseOnEscape
                              : Popup.CloseOnEscape | Popup.CloseOnPressOutside
    transformOrigin: isSideSheet ? Item.Right
                                 : isBottomSheet ? Item.Bottom
                                                 : isMenu ? Item.TopRight : Item.Center

    onAboutToShow: clampToViewport()
    onOpened: Qt.callLater(function() {
        if (initialFocusItem && initialFocusItem.visible && initialFocusItem.enabled)
            initialFocusItem.forceActiveFocus(Qt.PopupFocusReason)
        else if (contentItem)
            contentItem.forceActiveFocus(Qt.PopupFocusReason)
    })
    onClosed: {
        if (focusReturnItem && focusReturnItem.visible && focusReturnItem.enabled)
            focusReturnItem.forceActiveFocus(Qt.PopupFocusReason)
    }

    Overlay.modal: Rectangle {
        color: Qt.rgba(MeoTheme.scrim.r, MeoTheme.scrim.g, MeoTheme.scrim.b, control.scrimOpacity)
        Behavior on opacity {
            NumberAnimation {
                duration: control.presentation === MeoMotionPopup.SideSheet
                          || control.presentation === MeoMotionPopup.BottomSheet
                          ? MeoTheme.motionDurationSheetExit : MeoTheme.motionDurationDialogExit
            }
        }
    }

    background: Item {
        clip: false

        Rectangle {
            visible: !control.isFullScreen
            x: control.isSideSheet ? -4 * MeoTheme.globalScale : 0
            y: control.isMenu ? 3 * MeoTheme.globalScale : 6 * MeoTheme.globalScale
            width: parent.width
            height: parent.height
            radius: control.surfaceRadius
            color: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b,
                           control.isMenu ? 0.10 : 0.08)
        }

        Rectangle {
            visible: !control.isFullScreen
            x: control.isSideSheet ? -2 * MeoTheme.globalScale : 0
            y: control.isMenu ? 1 * MeoTheme.globalScale : 2 * MeoTheme.globalScale
            width: parent.width
            height: parent.height
            radius: control.surfaceRadius
            color: Qt.rgba(MeoTheme.shadow.r, MeoTheme.shadow.g, MeoTheme.shadow.b,
                           control.isMenu ? 0.08 : 0.06)
        }

        Rectangle {
            anchors.fill: parent
            radius: control.surfaceRadius
            color: control.surfaceColor
            border.width: control.isFullScreen ? 0 : 1
            border.color: Qt.rgba(MeoTheme.outline.r, MeoTheme.outline.g, MeoTheme.outline.b, 0.22)

            Behavior on radius {
                NumberAnimation {
                    duration: MeoTheme.motionDurationSelection
                    easing.bezierCurve: MeoTheme.motionEasingEmphasized
                }
            }
        }
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 0
                to: 1
                duration: control.enterDuration
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
            NumberAnimation {
                property: "scale"
                from: MeoTheme.reduceMotion ? 1 : control.isMenu ? 0.92 : control.presentation === MeoMotionPopup.Dialog ? 0.90 : 1
                to: 1
                duration: control.enterDuration
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
            NumberAnimation {
                property: "x"
                from: control.isSideSheet && control.parent && !MeoTheme.reduceMotion ? control.parent.width : control.x
                to: control.isSideSheet && control.parent ? control.parent.width - control.width : control.x
                duration: control.enterDuration
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
            NumberAnimation {
                property: "y"
                from: control.isBottomSheet && control.parent && !MeoTheme.reduceMotion ? control.parent.height : control.y
                to: control.isBottomSheet && control.parent ? control.parent.height - control.height : control.y
                duration: control.enterDuration
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
            }
        }
    }

    exit: Transition {
        ParallelAnimation {
            NumberAnimation {
                property: "opacity"
                from: 1
                to: 0
                duration: control.exitDuration
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate
            }
            NumberAnimation {
                property: "scale"
                from: 1
                to: MeoTheme.reduceMotion ? 1 : control.isMenu ? 0.98 : control.presentation === MeoMotionPopup.Dialog ? 0.96 : 1
                duration: control.exitDuration
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate
            }
            NumberAnimation {
                property: "x"
                from: control.x
                to: control.isSideSheet && control.parent && !MeoTheme.reduceMotion ? control.parent.width : control.x
                duration: control.exitDuration
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate
            }
            NumberAnimation {
                property: "y"
                from: control.y
                to: control.isBottomSheet && control.parent && !MeoTheme.reduceMotion ? control.parent.height : control.y
                duration: control.exitDuration
                easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate
            }
        }
    }
}
