import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    // 🌟 核心对外属性
    property string title: ""
    property string text: ""
    property var actions: [] // Array of { text: "", action: function }

    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    padding: 0
    width: Math.min(320 * themeGlobalScale, (parent ? parent.width - 48 * themeGlobalScale : 320 * themeGlobalScale))

    background: Rectangle {
        color: control.themeSurfaceContainer
        radius: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeMedium !== 'undefined') ? MeoTheme.shapeMedium : 12 * control.themeGlobalScale
        // MD3 Elevation 2
        border.color: Qt.rgba(0,0,0,0.1)
        border.width: 0.5 * themeGlobalScale
    }

    contentItem: Column {
        padding: 16 * control.themeGlobalScale
        spacing: 12 * control.themeGlobalScale

        Text {
            text: control.title
            visible: text !== ""
            width: parent.width - 32 * control.themeGlobalScale
            font.pixelSize: 16 * control.themeGlobalScale
            font.weight: Font.Medium
            color: control.themeOnSurface
            wrapMode: Text.WordWrap
        }

        Text {
            text: control.text
            width: parent.width - 32 * control.themeGlobalScale
            font.pixelSize: 14 * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
            wrapMode: Text.WordWrap
        }

        Row {
            visible: control.actions.length > 0
            width: parent.width - 32 * control.themeGlobalScale
            layoutDirection: Qt.RightToLeft
            spacing: 8 * control.themeGlobalScale

            Repeater {
                model: control.actions
                MeoButton {
                    text: modelData.text
                    type: "text"
                    onClicked: {
                        if (modelData.action) modelData.action()
                        control.close()
                    }
                }
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
    }
}
