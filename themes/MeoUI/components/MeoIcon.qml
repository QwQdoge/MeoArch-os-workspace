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
    // Material Symbols exposes FILL as a variable-font axis (0–100).  Keeping
    // it numeric lets selected icons morph instead of popping between glyphs.
    property real fillLevel: fill ? 100 : 0

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    FontLoader {
        id: materialSymbols
        source: Qt.resolvedUrl("../assets/fonts/MaterialSymbolsRounded.ttf")
    }

    text: icon
    font.family: materialSymbols.status === FontLoader.Ready ? materialSymbols.name : "Material Symbols Rounded"
    font.pixelSize: size * themeGlobalScale

    font.weight: weight
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
    renderType: Text.NativeRendering
    font.letterSpacing: 0

    // 🔤 Qt 6 variable-font axes used by Material Symbols.
    font.variableAxes: ({
        "FILL": control.fillLevel,
        "wght": control.weight,
        "GRAD": control.grade,
        "opsz": control.opticalSize
    })

    Behavior on fillLevel {
        NumberAnimation {
            duration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationSelection !== "undefined") ? MeoTheme.motionDurationSelection : 220
            easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1]
        }
    }
}
