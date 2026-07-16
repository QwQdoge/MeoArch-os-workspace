import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property Component fab: null
    property var navigationIcons: []

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    width: parent ? parent.width : 360 * themeGlobalScale
    height: 80 * themeGlobalScale
    color: themeSurfaceContainer
    radius: 20 * themeGlobalScale
    clip: true

    Item {
        anchors.fill: parent
        anchors.margins: 16 * control.themeGlobalScale

        Rectangle {
            id: actionsGroupSurface
            width: navigationRow.implicitWidth + 8 * control.themeGlobalScale
            height: 48 * control.themeGlobalScale
            anchors.left: parent.left
            anchors.verticalCenter: parent.verticalCenter
            radius: height / 2
            color: Qt.rgba(control.themeOnSurfaceVariant.r, control.themeOnSurfaceVariant.g, control.themeOnSurfaceVariant.b, 0.08)

            Row {
                id: navigationRow
                anchors.centerIn: parent
            spacing: 12 * control.themeGlobalScale

                Repeater {
                    model: control.navigationIcons
                    delegate: Item {
                        width: 48 * control.themeGlobalScale
                        height: 48 * control.themeGlobalScale

                        Loader {
                            anchors.centerIn: parent
                            sourceComponent: typeof modelData === "string" ? null : modelData
                        }

                        MeoIconButton {
                            anchors.centerIn: parent
                            visible: typeof modelData === "string"
                            icon.name: visible ? modelData : ""
                            type: "standard"
                        }
                    }
                }
            }
        }

        Item {
            id: fabSlot
            width: Math.max(56 * control.themeGlobalScale, fabLoader.implicitWidth)
            height: Math.max(56 * control.themeGlobalScale, fabLoader.implicitHeight)
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            Loader {
                id: fabLoader
                anchors.centerIn: parent
                sourceComponent: control.fab
                asynchronous: false
            }
        }
    }
}
