import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Popup {
    id: control

    // 🌟 核心属性
    property var model: [] // [{ label: "", icon: "", action: function, isVibrant: bool }]
    property bool vibrant: false // Global vibrant style for the entire menu
    property real itemSpacing: 0 // MD3 Expressive: Support for item gaps

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    padding: 0 // MD3: Menu content starts immediately

    background: Rectangle {
        id: bgRect
        color: control.vibrant ? control.themePrimaryContainer : control.themeSurfaceContainer
        radius: (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeMedium : 12 * control.themeGlobalScale)

        // MD3 Elevation Level 2
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.2
            shadowVerticalOffset: 2 * control.themeGlobalScale
            shadowColor: Qt.rgba(0,0,0,0.2)
        }
    }

    contentItem: Column {
        id: contentColumn
        spacing: control.itemSpacing
        topPadding: 8 * control.themeGlobalScale
        bottomPadding: 8 * control.themeGlobalScale

        Repeater {
            model: control.model
            delegate: MeoListItem {
                width: Math.max(112 * control.themeGlobalScale, Math.min(280 * control.themeGlobalScale, contentColumn.width))
                implicitWidth: width
                headline: modelData.label
                leadingIcon: modelData.icon || ""
                padding: 12 * control.themeGlobalScale
                implicitHeight: 48 * control.themeGlobalScale

                // MD3 Expressive Vibrant Item
                selected: control.vibrant || modelData.isVibrant || false
                isSegmented: control.itemSpacing > 0

                onClicked: {
                    if (modelData.action) modelData.action()
                    control.close()
                }
            }
        }
    }

    enter: Transition {
        ParallelAnimation {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 250; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]) }
            NumberAnimation { property: "scale"; from: 0.8; to: 1.0; duration: 300; easing.bezierCurve: [0.34, 1.56, 0.64, 1] } // Bouncy entrance
        }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100 }
    }
}
