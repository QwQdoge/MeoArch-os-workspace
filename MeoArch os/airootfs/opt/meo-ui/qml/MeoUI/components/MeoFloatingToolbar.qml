import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property list<Component> actions
    property bool isVibrant: false // Use primary color scheme for higher emphasis
    property string orientation: "horizontal" // "horizontal" | "vertical"

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHigh !== 'undefined') ? MeoTheme.surfaceContainerHigh : "#F3EDF7"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: orientation === "horizontal" ? Math.max(64 * themeGlobalScale, horizontalLayout.implicitWidth + 28 * themeGlobalScale) : 64 * themeGlobalScale
    implicitHeight: orientation === "vertical" ? Math.max(64 * themeGlobalScale, verticalLayout.implicitHeight + 28 * themeGlobalScale) : 64 * themeGlobalScale

    color: isVibrant ? themeSecondaryContainer : themeSurfaceContainer
    radius: height / 2

    // MD3 Elevation Level 2
    layer.enabled: control.visible
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowBlur: 0.2
        shadowVerticalOffset: 2 * control.themeGlobalScale
        shadowColor: Qt.rgba(0,0,0,0.2)
    }

    Row {
        id: horizontalLayout
        visible: control.orientation === "horizontal"
        anchors.centerIn: parent
        spacing: 10 * control.themeGlobalScale

        Repeater {
            model: control.orientation === "horizontal" ? control.actions : []
            delegate: Loader {
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: modelData
            }
        }
    }

    Column {
        id: verticalLayout
        visible: control.orientation === "vertical"
        anchors.centerIn: parent
        spacing: 10 * control.themeGlobalScale

        Repeater {
            model: control.orientation === "vertical" ? control.actions : []
            delegate: Loader {
                anchors.horizontalCenter: parent.horizontalCenter
                sourceComponent: modelData
            }
        }
    }
}
