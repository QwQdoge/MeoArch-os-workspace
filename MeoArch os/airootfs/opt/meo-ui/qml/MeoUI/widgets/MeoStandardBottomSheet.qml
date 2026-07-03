import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Item {
    id: control

    // 🌟 核心对外属性
    property Component content: null
    property bool isOpen: false
    property real peekHeight: 80 * themeGlobalScale
    property real expandedHeight: 400 * themeGlobalScale

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: parent ? parent.width : 360 * themeGlobalScale
    implicitHeight: isOpen ? expandedHeight : peekHeight

    z: 10 // Ensure it's above other content if needed

    readonly property real targetY: control.isOpen ? (parent.height - expandedHeight) : (parent.height - peekHeight)

    Rectangle {
        id: sheetBackground
        width: parent.width
        height: control.expandedHeight + 100 // Extra height for over-scroll/safety
        y: targetY

        color: control.themeSurfaceContainerLow
        radius: 28 * control.themeGlobalScale

        // Ensure bottom corners are not rounded for persistent sheet
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 28 * control.themeGlobalScale
            color: parent.color
        }

        // MD3 Elevation Shadow
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.2
            shadowVerticalOffset: -2 * control.themeGlobalScale
            shadowColor: Qt.rgba(0,0,0,0.1)
        }

        Behavior on y {
            id: yBehavior
            NumberAnimation {
                duration: 300
                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1.0]
            }
        }

        // 🌟 Drag Handle & Interaction Area
        Item {
            id: handleArea
            width: parent.width
            height: 32 * control.themeGlobalScale
            anchors.top: parent.top

            Rectangle {
                anchors.centerIn: parent
                width: 32 * control.themeGlobalScale
                height: 4 * control.themeGlobalScale
                radius: 2 * control.themeGlobalScale
                color: control.themeOutlineVariant
            }

            MouseArea {
                anchors.fill: parent
                drag.target: null // We'll handle drag manually for threshold logic

                property real startY: 0
                onPressed: (mouse) => startY = mouse.y
                onReleased: {
                    yBehavior.enabled = true
                    let threshold = (parent.height - control.expandedHeight + parent.height - control.peekHeight) / 2
                    control.isOpen = sheetBackground.y < threshold
                    sheetBackground.y = control.targetY // Re-bind to target
                }
                onPositionChanged: (mouse) => {
                    if (pressed) {
                        yBehavior.enabled = false
                        let delta = mouse.y - startY
                        sheetBackground.y = Math.max(parent.height - control.expandedHeight, Math.min(parent.height - control.peekHeight + 50, sheetBackground.y + delta))
                    }
                }
                onClicked: control.isOpen = !control.isOpen
            }
        }

        // 🌟 Content Loader
        Loader {
            id: contentLoader
            anchors.top: handleArea.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.bottomMargin: 100 // Match the safety extra height
            sourceComponent: control.content
            clip: true
            opacity: (parent.height - sheetBackground.y - control.peekHeight) / (control.expandedHeight - control.peekHeight)
        }
    }
}
