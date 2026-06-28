import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property var actions: [] // List of Components for the actions
    property bool isVibrant: false // Use primary color scheme for higher emphasis
    property string orientation: "horizontal" // "horizontal" | "vertical"

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: orientation === "horizontal" ? Math.max(48 * themeGlobalScale, layout.implicitWidth + 24 * themeGlobalScale) : 48 * themeGlobalScale
    implicitHeight: orientation === "vertical" ? Math.max(48 * themeGlobalScale, layout.implicitHeight + 24 * themeGlobalScale) : 48 * themeGlobalScale

    color: isVibrant ? themePrimary : themeSurfaceContainer
    radius: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeFull !== 'undefined') ? MeoTheme.shapeFull : 24 * themeGlobalScale

    // MD3 Elevation Level 2
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.2
        shadowVerticalOffset: 2 * control.themeGlobalScale
        shadowColor: Qt.rgba(0,0,0,0.2)
    }

    Control {
        id: innerContent
        anchors.fill: parent
        padding: 12 * control.themeGlobalScale

        contentItem: Column {
            id: layout
            spacing: 8 * control.themeGlobalScale
            anchors.centerIn: parent

            // Re-using Row if horizontal
            data: control.orientation === "horizontal" ? null : []

            Repeater {
                model: control.actions
                delegate: Loader {
                    anchors.centerIn: undefined // Reset for vertical
                    sourceComponent: modelData
                }
            }
        }

        // Use Row for horizontal orientation
        Row {
            id: horizontalLayout
            visible: control.orientation === "horizontal"
            anchors.centerIn: parent
            spacing: 8 * control.themeGlobalScale

            Repeater {
                model: control.orientation === "horizontal" ? control.actions : []
                delegate: Loader {
                    anchors.verticalCenter: parent.verticalCenter
                    sourceComponent: modelData
                }
            }
        }
    }
}
