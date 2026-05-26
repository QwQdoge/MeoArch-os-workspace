import QtQuick
import QtQuick.Controls

Popup {
    id: control

    // 🌟 核心属性
    property var model: [] // [{ label: "", icon: "", action: function }]

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    padding: 8 * themeGlobalScale

    background: Rectangle {
        color: control.themeSurfaceContainer
        radius: 4 * control.themeGlobalScale
        // Elevation shadow simplified
        border.color: Qt.rgba(0,0,0,0.1)
        border.width: 1
    }

    contentItem: Column {
        spacing: 0

        Repeater {
            model: control.model
            delegate: MeoListItem {
                width: 160 * control.themeGlobalScale
                headline: modelData.label
                leadingIcon: modelData.icon || ""
                padding: 12 * control.themeGlobalScale
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
