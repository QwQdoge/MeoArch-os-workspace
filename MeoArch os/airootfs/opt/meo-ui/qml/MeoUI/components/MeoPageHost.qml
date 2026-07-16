import QtQuick
import MeoUI

Item {
    id: control

    property url source
    property int direction: 1
    property real transitionDistance: 32 * MeoTheme.globalScale
    readonly property var currentItem: activeSlot === 0 ? firstLoader.item : secondLoader.item
    readonly property bool transitioning: pageTransition.running

    signal pageLoaded(Item item)

    property int activeSlot: 0
    property int pendingSlot: 0
    property bool initialized: false
    property var incomingLoader: firstLoader
    property var outgoingLoader: secondLoader

    clip: true

    function loaderForSlot(slot) {
        return slot === 0 ? firstLoader : secondLoader
    }

    function finishTransition() {
        if (!pageTransition.running)
            return
        pageTransition.complete()
    }

    function requestPage() {
        if (!source || String(source).length === 0)
            return
        finishTransition()
        pendingSlot = initialized ? 1 - activeSlot : 0
        incomingLoader = loaderForSlot(pendingSlot)
        outgoingLoader = loaderForSlot(activeSlot)
        incomingLoader.source = source
    }

    function beginTransition(loader) {
        pageLoaded(loader.item)
        if (!initialized) {
            activeSlot = pendingSlot
            initialized = true
            loader.opacity = 1
            loader.x = 0
            loader.scale = 1
            return
        }

        if (MeoTheme.reduceMotion) {
            incomingLoader.opacity = 1
            incomingLoader.x = 0
            incomingLoader.scale = 1
            activeSlot = pendingSlot
            if (outgoingLoader !== incomingLoader)
                outgoingLoader.source = ""
            outgoingLoader.opacity = 0
            outgoingLoader.x = 0
            outgoingLoader.scale = 1
            return
        }

        incomingLoader.opacity = 0
        incomingLoader.x = MeoTheme.reduceMotion ? 0 : transitionDistance * (direction < 0 ? -1 : 1)
        incomingLoader.scale = MeoTheme.reduceMotion ? 1 : 0.992
        outgoingLoader.opacity = 1
        outgoingLoader.x = 0
        outgoingLoader.scale = 1
        pageTransition.restart()
    }

    onSourceChanged: requestPage()
    Component.onCompleted: requestPage()

    Loader {
        id: firstLoader
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        onLoaded: if (firstLoader === control.incomingLoader) Qt.callLater(function() { control.beginTransition(firstLoader) })
    }

    Loader {
        id: secondLoader
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        width: parent.width
        opacity: 0
        onLoaded: if (secondLoader === control.incomingLoader) Qt.callLater(function() { control.beginTransition(secondLoader) })
    }

    ParallelAnimation {
        id: pageTransition

        NumberAnimation {
            target: control.incomingLoader
            property: "opacity"
            from: 0
            to: 1
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationPage
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
        NumberAnimation {
            target: control.incomingLoader
            property: "x"
            to: 0
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationPage
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
        NumberAnimation {
            target: control.incomingLoader
            property: "scale"
            to: 1
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationPage
            easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
        }
        NumberAnimation {
            target: control.outgoingLoader
            property: "opacity"
            to: 0
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationMedium2
            easing.bezierCurve: MeoTheme.motionEasingStandardAccelerate
        }
        NumberAnimation {
            target: control.outgoingLoader
            property: "x"
            to: MeoTheme.reduceMotion ? 0 : -control.transitionDistance * 0.35 * (control.direction < 0 ? -1 : 1)
            duration: MeoTheme.reduceMotion ? 0 : MeoTheme.motionDurationMedium2
            easing.bezierCurve: MeoTheme.motionEasingStandardAccelerate
        }

        onFinished: {
            control.activeSlot = control.pendingSlot
            control.outgoingLoader.source = ""
            control.outgoingLoader.opacity = 0
            control.outgoingLoader.x = 0
            control.outgoingLoader.scale = 1
        }
    }
}
