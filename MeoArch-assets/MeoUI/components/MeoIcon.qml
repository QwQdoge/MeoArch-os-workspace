import QtQuick

Text {
    id: control
    property string icon: ""
    property real size: 24

    // MD3 Material Symbols Properties
    property bool fill: false
    property int weight: 400 // 100-700
    property int grade: 0 // -25, 0, 200
    property int opticalSize: 24 // 20, 24, 40, 48

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    text: icon
    font.family: "Material Symbols Rounded"
    font.pixelSize: size * themeGlobalScale

    font.weight: weight

    // Using font.styleName or specific font features if supported by the environment's QML version
    // For simplicity in standard QML, we'll map weight. Grade and Optical Size often require
    // raw font feature settings which might not be universally exposed in all Qt versions' Font type.
}
