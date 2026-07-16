import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

Popup {
    id: control

    // 🌟 核心对外属性
    property string title: ""
    property string text: ""
    property string icon: "" // 🌟 New: Illustrative Icon
    property string image: "" // 🌟 New: Illustrative Image
    property string shape: "rect" // 🌟 MD3 Expressive Shape
    property var actions: [] // Array of { text: "", action: function }

    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    padding: 0
    width: Math.min(320 * themeGlobalScale, (parent ? parent.width - 48 * themeGlobalScale : 320 * themeGlobalScale))

    background: MeoShape {
        id: shapeBg
        type: control.shape
        color: control.themeSurfaceContainer
        radius: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeMedium !== 'undefined') ? MeoTheme.shapeMedium : 12 * control.themeGlobalScale
        // MD3 Elevation 2

        layer.enabled: control.visible
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.2
            shadowVerticalOffset: 2 * control.themeGlobalScale
            shadowColor: Qt.rgba(0,0,0,0.2)
        }
    }

    contentItem: Column {
        padding: 0
        spacing: 0

        // Illustrative Image/Icon
        Rectangle {
            width: parent.width
            height: 120 * control.themeGlobalScale
            visible: control.image !== "" || control.icon !== ""
            color: control.themeSurfaceContainer
            radius: shapeBg.radius
            clip: true

            Image {
                anchors.fill: parent
                source: control.image
                fillMode: Image.PreserveAspectCrop
                visible: control.image !== ""
            }

            MeoIcon {
                anchors.centerIn: parent
                icon: control.icon
                size: 48
                color: control.themeOnSurfaceVariant
                visible: control.icon !== "" && control.image === ""
            }

            layer.enabled: control.visible
            layer.effect: MultiEffect {
                maskEnabled: true
                maskSource: Item {
                    width: shapeBg.width
                    height: shapeBg.height
                    MeoShape {
                        anchors.fill: parent
                        type: control.shape
                        radius: shapeBg.radius
                    }
                }
            }
        }

        Column {
            width: parent.width
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
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 150 }
    }
}
