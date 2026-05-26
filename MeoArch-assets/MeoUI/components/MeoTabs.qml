import QtQuick
import QtQuick.Controls

Control {
    id: control

    // 🌟 核心属性
    property var model: [] // ["Tab 1", "Tab 2", ...]
    property int currentIndex: 0
    property string type: "primary" // "primary" | "secondary"

    signal clicked(int index)

    // 🌟 作用域与主题安全防御
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 48 * themeGlobalScale

    background: Rectangle {
        color: "transparent"

        // Bottom border for secondary tabs
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1 * control.themeGlobalScale
            color: control.type === "secondary" ? Qt.rgba(0,0,0,0.1) : "transparent"
        }
    }

    contentItem: Row {
        anchors.fill: parent

        Repeater {
            model: control.model
            delegate: Item {
                width: control.width / control.model.length
                height: control.height

                readonly property bool isSelected: control.currentIndex === index

                Text {
                    anchors.centerIn: parent
                    text: modelData
                    font.pixelSize: 14 * control.themeGlobalScale
                    font.weight: isSelected ? Font.Bold : Font.Normal
                    color: isSelected ? control.themePrimary : control.themeOnSurfaceVariant

                    Behavior on color { ColorAnimation { duration: 150 } }
                }

                // Selection Indicator (Primary: fixed width, Secondary: full width)
                Rectangle {
                    anchors.bottom: parent.bottom
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: control.type === "primary" ? 40 * control.themeGlobalScale : parent.width
                    height: 3 * control.themeGlobalScale
                    radius: 3 * control.themeGlobalScale
                    color: control.themePrimary
                    visible: isSelected

                    Behavior on width { NumberAnimation { duration: 200; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
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
