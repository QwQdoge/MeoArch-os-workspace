import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property var actions: [] // List of Components for the actions
    property bool isVibrant: false // Use primary color scheme for higher emphasis

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    width: parent ? parent.width : 360 * themeGlobalScale
    height: 56 * themeGlobalScale // MD3 Expressive Docked Toolbar is shorter than Bottom App Bar (80dp)

    color: isVibrant ? themePrimary : themeSurfaceContainer

    // MD3 Docked Toolbar should have square corners (straight corners)
    radius: 0

    Row {
        id: actionsRow
        anchors.fill: parent
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.rightMargin: 16 * control.themeGlobalScale
        spacing: 12 * control.themeGlobalScale

        Repeater {
            model: control.actions
            delegate: Loader {
                anchors.verticalCenter: parent.verticalCenter
                sourceComponent: modelData
            }
        }
    }
}
