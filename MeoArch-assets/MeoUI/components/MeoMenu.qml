import QtQuick
import QtQuick.Controls
import Qt5Compat.GraphicalEffects

Popup {
    id: control

    // 🌟 核心属性
    property var model: [] // [{ label: "", icon: "", action: function }]

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    padding: 0 // MD3: Menu content starts immediately

    background: Rectangle {
        id: bgRect
        color: control.themeSurfaceContainer
        radius: 4 * control.themeGlobalScale

        // MD3 Elevation Level 2
        layer.enabled: true
        layer.effect: DropShadow {

            radius: 0.2
            verticalOffset: 2 * control.themeGlobalScale
            color: Qt.rgba(0,0,0,0.2)
        }
    }

    contentItem: Column {
        id: contentColumn
        spacing: 0
        topPadding: 8 * control.themeGlobalScale
        bottomPadding: 8 * control.themeGlobalScale

        Repeater {
            model: control.model
            delegate: MeoListItem {
                width: Math.max(112 * control.themeGlobalScale, Math.min(280 * control.themeGlobalScale, contentColumn.width))
                implicitWidth: width
                headline: modelData.label
                leadingIcon: modelData.icon || ""
                padding: 12 * control.themeGlobalScale
                implicitHeight: 48 * control.themeGlobalScale
                onClicked: {
                    if (modelData.action) modelData.action()
                    control.close()
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
        NumberAnimation { property: "scale"; from: 0.9; to: 1.0; duration: 150; easing.type: Easing.OutQuad }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 100 }
    }
}
