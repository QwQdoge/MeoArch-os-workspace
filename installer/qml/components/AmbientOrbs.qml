import QtQuick
import MeoUI 1.0

// Purely decorative: a few large, faint colour orbs that drift slowly behind
// the pages. They carry no information and never take input. Motion stops with
// "reduce motion" and is skipped entirely on software rendering (VMs, Cage
// fallback), where continuously repainting a full-window layer would slow the
// installer down for no benefit.
Item {
    id: orbs
    enabled: false

    readonly property bool animated: !MeoTheme.reduceMotion
                                     && GraphicsInfo.api !== GraphicsInfo.Software
                                     && visible

    component Orb: MeoShape {
        id: orb
        property real baseX: 0
        property real baseY: 0
        property real driftX: 0.04
        property real driftY: 0.03
        property int period: 14000
        property real phase: 0

        type: "rect"
        radius: width / 2
        width: Math.min(orbs.width, orbs.height) * size
        height: width
        x: orbs.width * baseX + orbs.width * driftX * phase - width / 2
        y: orbs.height * baseY + orbs.height * driftY * phase - height / 2
        property real size: 0.6

        SequentialAnimation on phase {
            running: orbs.animated
            loops: Animation.Infinite
            NumberAnimation { to: 1; duration: orb.period; easing.type: Easing.InOutSine }
            NumberAnimation { to: 0; duration: orb.period; easing.type: Easing.InOutSine }
        }
    }

    Orb {
        baseX: 0.12; baseY: 0.18; size: 0.62; period: 16000
        driftX: 0.06; driftY: 0.05
        color: MeoTheme.primaryContainer
        opacity: 0.18
    }
    Orb {
        baseX: 0.88; baseY: 0.82; size: 0.7; period: 19000
        driftX: -0.05; driftY: -0.06
        color: MeoTheme.tertiaryContainer
        opacity: 0.16
    }
    Orb {
        baseX: 0.72; baseY: 0.12; size: 0.4; period: 13000
        driftX: -0.07; driftY: 0.08
        color: MeoTheme.secondaryContainer
        opacity: 0.14
    }
}
