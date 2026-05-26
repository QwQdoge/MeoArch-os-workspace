import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property bool isOpen: false
    property Component content: null

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    width: 360 * themeGlobalScale
    height: parent ? parent.height : 600 * themeGlobalScale
    x: parent ? (isOpen ? parent.width - width : parent.width) : 0
    color: themeSurfaceContainerLow

    Behavior on x { NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    Loader {
        anchors.fill: parent
        sourceComponent: control.content
    }
}
