import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property var model: [] // [{ label: "Step 1" }, ...]
    property int currentIndex: 0
    property string orientation: "horizontal" // "horizontal" | "vertical"

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? MeoTheme.contentOnPrimary : "#FFFFFF"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"

    implicitWidth: orientation === "horizontal" ? 400 * themeGlobalScale : 240 * themeGlobalScale
    implicitHeight: orientation === "horizontal" ? 72 * themeGlobalScale : 320 * themeGlobalScale

    contentItem: Item {
        id: container

        // 📐 Horizontal Layout
        Row {
            visible: control.orientation === "horizontal"
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: control.model
                delegate: Item {
                    width: control.model.length > 0 ? container.width / control.model.length : 0
                    height: parent.height

                    readonly property bool isCompleted: index < control.currentIndex
                    readonly property bool isActive: index === control.currentIndex

                    // MD3 Connector Line
                    Rectangle {
                        visible: index < control.model.length - 1
                        x: parent.width / 2 + 16 * control.themeGlobalScale
                        y: 12 * control.themeGlobalScale + 12 * control.themeGlobalScale // Center of 24dp circle
                        width: parent.width - 32 * control.themeGlobalScale
                        height: 1 * control.themeGlobalScale
                        color: isCompleted ? control.themePrimary : control.themeOutline
                    }

                    Column {
                        anchors.centerIn: parent
                        spacing: 8 * control.themeGlobalScale

                        Rectangle {
                            id: indicatorCircle
                            width: 24 * control.themeGlobalScale
                            height: 24 * control.themeGlobalScale
                            radius: width / 2
                            color: isCompleted || isActive ? control.themePrimary : "transparent"
                            border.color: isCompleted || isActive ? control.themePrimary : control.themeOutline
                            border.width: 1 * control.themeGlobalScale
                            anchors.horizontalCenter: parent.horizontalCenter

                            MeoIcon {
                                anchors.centerIn: parent
                                icon: "check"
                                visible: isCompleted
                                size: 16 * control.themeGlobalScale
                                color: control.themeOnPrimary
                            }

                            Text {
                                anchors.centerIn: parent
                                text: String(index + 1)
                                visible: !isCompleted
                                font.pixelSize: 12 * control.themeGlobalScale
                                font.weight: Font.Medium
                                color: isActive ? control.themeOnPrimary : control.themeOnSurfaceVariant
                            }
                        }

                        Text {
                            text: modelData.label || ""
                            font.pixelSize: 12 * control.themeGlobalScale
                            font.weight: isActive ? Font.Bold : Font.Normal
                            color: isActive ? control.themeOnSurface : control.themeOnSurfaceVariant
                            anchors.horizontalCenter: parent.horizontalCenter
                            horizontalAlignment: Text.AlignHCenter
                            width: parent.width - 8 * control.themeGlobalScale
                            elide: Text.ElideRight
                        }
                    }
                }
            }
        }

        // 📐 Vertical Layout
        Column {
            visible: control.orientation === "vertical"
            anchors.fill: parent
            spacing: 0

            Repeater {
                model: control.model
                delegate: Item {
                    width: parent.width
                    height: control.model.length > 0 ? container.height / control.model.length : 0

                    readonly property bool isCompleted: index < control.currentIndex
                    readonly property bool isActive: index === control.currentIndex

                    // MD3 Connector Line
                    Rectangle {
                        visible: index < control.model.length - 1
                        x: 28 * control.themeGlobalScale // 16 margin + 12 center
                        y: parent.height / 2 + 16 * control.themeGlobalScale
                        width: 1 * control.themeGlobalScale
                        height: parent.height - 32 * control.themeGlobalScale
                        color: isCompleted ? control.themePrimary : control.themeOutline
                    }

                    Row {
                        anchors.left: parent.left
                        anchors.leftMargin: 16 * control.themeGlobalScale
                        anchors.verticalCenter: parent.verticalCenter
                        spacing: 16 * control.themeGlobalScale

                        Rectangle {
                            width: 24 * control.themeGlobalScale
                            height: 24 * control.themeGlobalScale
                            radius: width / 2
                            color: isCompleted || isActive ? control.themePrimary : "transparent"
                            border.color: isCompleted || isActive ? control.themePrimary : control.themeOutline
                            border.width: 1 * control.themeGlobalScale

                            MeoIcon {
                                anchors.centerIn: parent
                                icon: "check"
                                visible: isCompleted
                                size: 16 * control.themeGlobalScale
                                color: control.themeOnPrimary
                            }

                            Text {
                                anchors.centerIn: parent
                                text: String(index + 1)
                                visible: !isCompleted
                                font.pixelSize: 12 * control.themeGlobalScale
                                font.weight: Font.Medium
                                color: isActive ? control.themeOnPrimary : control.themeOnSurfaceVariant
                            }
                        }

                        Text {
                            text: modelData.label || ""
                            font.pixelSize: 14 * control.themeGlobalScale
                            font.weight: isActive ? Font.Bold : Font.Normal
                            color: isActive ? control.themeOnSurface : control.themeOnSurfaceVariant
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }
            }
        }
    }
}
