import QtQuick
import QtQuick.Controls
import QtQuick.Effects

Frame {
    id: control

    // 🌟 核心属性
    // type: "elevated" | "filled" | "outlined"
    property string type: "elevated"
    property int level: type === "elevated" ? 1 : 0
    property real radius: 12 * themeGlobalScale
    property string shape: "rect" // 🌟 MD3 Expressive: "rect" | "squircle" | "hexagon" | "diamond" | ...
    property bool interactive: false // 🌟 MD3: Supports click interaction

    signal clicked()

    // MD3 Elevation (Shadow)
    readonly property real elevation: {
        if (type !== "elevated") return 0;
        return level;
    }

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceVariant !== 'undefined') ? MeoTheme.surfaceVariant : "#E7E0EC"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    padding: 16 * themeGlobalScale

    background: Item {
        MeoShape {
            id: shapeBg
            anchors.fill: parent
            type: control.shape
            radius: control.radius
            color: {
                if (type === "filled") return control.themeSurfaceVariant
                return control.themeSurface // elevated and outlined
            }
            strokeColor: control.type === "outlined" ? control.themeOutlineVariant : "transparent"
            strokeWidth: control.type === "outlined" ? 1 * control.themeGlobalScale : 0

            // Surface Tint for Elevation
            Rectangle {
                anchors.fill: parent
                color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceTint !== 'undefined') ? MeoTheme.surfaceTint(control.level) : "transparent"
                visible: type !== "filled"
                Behavior on color { ColorAnimation { duration: 150 } }

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: shapeBg.width
                        height: shapeBg.height
                        MeoShape {
                            anchors.fill: parent
                            type: control.shape
                            radius: control.radius
                        }
                    }
                }
            }

            // MD3 Elevation for 'elevated' type
            layer.enabled: control.elevation > 0
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowBlur: 0.2
                shadowVerticalOffset: control.elevation * control.themeGlobalScale
                shadowColor: Qt.rgba(0,0,0,0.2)
            }

            MeoStateLayer {
                anchors.fill: parent
                visible: control.interactive
                pressed: mouseArea.pressed
                hovered: mouseArea.containsMouse
                color: control.isDarkMode ? "#FFFFFF" : "#000000"

                layer.enabled: true
                layer.effect: MultiEffect {
                    maskEnabled: true
                    maskSource: Item {
                        width: shapeBg.width
                        height: shapeBg.height
                        MeoShape {
                            anchors.fill: parent
                            type: control.shape
                            radius: control.radius
                        }
                    }
                }
            }

            MouseArea {
                id: mouseArea
                anchors.fill: parent
                enabled: control.interactive
                onClicked: control.clicked()
            }

            Behavior on color { ColorAnimation { duration: 150 } }
        }

    }
}
