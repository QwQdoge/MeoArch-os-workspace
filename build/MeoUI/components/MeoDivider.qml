import QtQuick
import QtQuick.Controls

Rectangle {
    id: control

    // 🌟 作用域与主题安全防御
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: parent ? parent.width : 100 * themeGlobalScale
    implicitHeight: 1 * themeGlobalScale
    color: themeOutlineVariant
}
