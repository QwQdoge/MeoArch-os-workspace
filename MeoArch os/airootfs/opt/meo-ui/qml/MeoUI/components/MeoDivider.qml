import QtQuick
import QtQuick.Controls

Rectangle {
    id: control

    // 🌟 核心属性
    property string orientation: "horizontal" // "horizontal" | "vertical"
    property real inset: 0
    property real leftInset: inset
    property real rightInset: inset
    property real topInset: inset
    property real bottomInset: inset

    // 🌟 作用域与主题安全防御
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: orientation === "horizontal" ? (parent ? parent.width : 100 * themeGlobalScale) : 1 * themeGlobalScale
    implicitHeight: orientation === "vertical" ? (parent ? parent.height : 100 * themeGlobalScale) : 1 * themeGlobalScale

    color: themeOutlineVariant

    // Note: To support insets, use padding or margin in the parent container
    // or manually anchor when using this component.
    // Self-anchoring is removed to ensure compatibility with Layouts.
}
