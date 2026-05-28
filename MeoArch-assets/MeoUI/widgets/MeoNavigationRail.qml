import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property var model: [] // [{ icon: "", label: "" }]
    property int currentIndex: 0
    signal clicked(int index)

    // 🌟 作用域与主题安全防御
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    width: 80 * themeGlobalScale
    height: parent ? parent.height : 600 * themeGlobalScale
    color: themeSurface

    Column {
        anchors.top: parent.top
        anchors.topMargin: 24 * control.themeGlobalScale
        anchors.horizontalCenter: parent.horizontalCenter
        spacing: 12 * control.themeGlobalScale

        Repeater {
            model: control.model
            delegate: Item {
                width: 80 * control.themeGlobalScale
                height: 56 * control.themeGlobalScale

                readonly property bool isSelected: control.currentIndex === index

                Column {
                    anchors.centerIn: parent
                    spacing: 4 * control.themeGlobalScale

                    Rectangle {
                        id: selectionIndicator
                        width: 56 * control.themeGlobalScale
                        height: 32 * control.themeGlobalScale
                        radius: 16 * control.themeGlobalScale
                        color: isSelected ? control.themeSecondaryContainer : "transparent"
                        anchors.horizontalCenter: parent.horizontalCenter
                        scale: isSelected ? 1.0 : 0.0
                        opacity: isSelected ? 1.0 : 0.0

                        MeoIcon {
                            anchors.centerIn: parent
                            icon: modelData.icon
                            size: 24
                            color: isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                        }

                        Behavior on scale { NumberAnimation { duration: 200; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
                        Behavior on opacity { NumberAnimation { duration: 150 } }
                    }

                    MeoIcon {
                        visible: !isSelected
                        anchors.centerIn: selectionIndicator
                        icon: modelData.icon
                        size: 24
                        color: control.themeOnSurfaceVariant
                    }

                    Text {
                        text: modelData.label
                        font.pixelSize: 12 * control.themeGlobalScale
                        font.weight: isSelected ? Font.Bold : Font.Normal
                        color: isSelected ? control.themePrimary : control.themeOnSurfaceVariant
                        anchors.horizontalCenter: parent.horizontalCenter
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        control.currentIndex = index
                        control.clicked(index)
                    }
                }
            }
        }
    }
}
