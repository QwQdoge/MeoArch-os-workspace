import QtQuick

Text {
    id: control
    property string icon: ""
    property real size: 24

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    text: icon
    font.family: "Material Symbols Rounded"
    font.pixelSize: size * themeGlobalScale
}
