import QtQuick
import MeoUI 1.0

// Soft fade-and-settle for one item, started with play(). Uses opacity and
// scale only, so it never fights a Column/Layout that owns the item's position.
// With reduced motion the item simply appears.
SequentialAnimation {
    id: entrance

    property Item item: null
    property int delay: 0
    property real fromScale: 0.96

    function play() {
        if (!item)
            return
        if (MeoTheme.reduceMotion) {
            item.opacity = 1
            item.scale = 1
            return
        }
        item.opacity = 0
        item.scale = fromScale
        start()
    }

    // Never leave a page half-faded if the animation is interrupted.
    onStopped: if (item) { item.opacity = 1; item.scale = 1 }

    PauseAnimation { duration: entrance.delay }
    ParallelAnimation {
        NumberAnimation {
            target: entrance.item; property: "opacity"; to: 1
            duration: MeoTheme.motionDurationMedium2
            easing.type: Easing.OutCubic
        }
        NumberAnimation {
            target: entrance.item; property: "scale"; to: 1
            duration: MeoTheme.motionDurationLong1
            easing.type: Easing.OutBack
            easing.overshoot: 1.1
        }
    }
}
