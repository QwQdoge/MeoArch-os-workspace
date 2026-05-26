import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property Component fab: null
    property var navigationIcons: []

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    width: parent ? parent.width : 360 * themeGlobalScale
    height: 80 * themeGlobalScale
    color: themeSurfaceContainer

    Item {
        anchors.fill: parent
        anchors.margins: 16 * control.themeGlobalScale

        Row {
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            spacing: 12 * control.themeGlobalScale

            Repeater {
                model: control.navigationIcons
                delegate: Loader { sourceComponent: modelData }
            }
        }

        Loader {
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: control.fab
        }
    }
}
