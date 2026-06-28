import QtQuick
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property real radius: 4 * themeGlobalScale
    property bool animate: true

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceVariant !== 'undefined') ? MeoTheme.surfaceVariant : "#E7E0EC"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 100 * themeGlobalScale
    implicitHeight: 20 * themeGlobalScale

    Rectangle {
        id: base
        anchors.fill: parent
        radius: control.radius
        color: control.themeSurfaceVariant
        clip: true

        // Shimmer Effect
        Rectangle {
            id: shimmer
            width: parent.width * 2
            height: parent.height
            anchors.verticalCenter: parent.verticalCenter

            gradient: Gradient {
                orientation: Gradient.Horizontal
                GradientStop { position: 0.0; color: "transparent" }
                GradientStop {
                    position: 0.5;
                    color: Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08)
                }
                GradientStop { position: 1.0; color: "transparent" }
            }

            XAnimator {
                target: shimmer
                from: -control.width * 2
                to: control.width
                duration: 1500
                running: control.animate && control.visible
                loops: Animation.Infinite
            }
        }
    }
}
