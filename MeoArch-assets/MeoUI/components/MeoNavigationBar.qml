import QtQuick
import QtQuick.Controls

Rectangle {
    id: control

    // 🌟 核心属性
    property var model: [] // { icon: "", label: "" }
    property int currentIndex: 0
    signal clicked(int index)

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 80 * themeGlobalScale
    color: themeSurface

    Row {
        anchors.fill: parent

        Repeater {
            model: control.model

            delegate: Item {
                width: control.width / control.model.length
                height: control.height

                readonly property bool isSelected: control.currentIndex === index

                Column {
                    anchors.centerIn: parent
                    spacing: 4 * control.themeGlobalScale

                    // 🎨 选中背景圆点
                    Rectangle {
                        id: selectionIndicator
                        width: isSelected ? 64 * control.themeGlobalScale : 32 * control.themeGlobalScale
                        height: 32 * control.themeGlobalScale
                        radius: 16 * control.themeGlobalScale
                        anchors.horizontalCenter: parent.horizontalCenter
                        color: isSelected ? control.themeSecondaryContainer : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: modelData.icon
                            font.pixelSize: 24 * control.themeGlobalScale
                            color: isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                        }

                        Behavior on width { NumberAnimation { duration: 200; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
                        Behavior on color { ColorAnimation { duration: 200 } }
                    }

                    Text {
                        text: modelData.label
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: 12 * control.themeGlobalScale
                        font.weight: isSelected ? Font.Bold : Font.Normal
                        color: isSelected ? control.themeOnSurface : control.themeOnSurfaceVariant
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

    // Top border/shadow
    Rectangle {
        width: parent.width
        height: 1
        color: Qt.rgba(0,0,0,0.05)
        anchors.top: parent.top
    }
}
