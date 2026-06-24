import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property var model: [] // [{ icon: "", label: "" }]
    property int currentIndex: 0
    property Component header: null
    property Component footer: null
    property string labelType: "always" // "always" | "selected" | "none"

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

    // Top Section
    Column {
        id: topSection
        anchors.top: parent.top
        anchors.topMargin: 24 * control.themeGlobalScale
        anchors.horizontalCenter: parent.horizontalCenter
        width: parent.width
        spacing: 12 * control.themeGlobalScale

        Loader {
            sourceComponent: control.header
            anchors.horizontalCenter: parent.horizontalCenter
            visible: control.header !== null
        }

        Item {
            width: 1
            height: 8 * control.themeGlobalScale
            visible: control.header !== null
        }

        Repeater {
            model: control.model
            delegate: Item {
                width: 80 * control.themeGlobalScale
                height: 56 * control.themeGlobalScale

                readonly property bool isSelected: control.currentIndex === index

                Column {
                    anchors.centerIn: parent
                    spacing: 4 * control.themeGlobalScale

                    // 使用 anchors.horizontalCenter 来代替 anchors.centerIn，防止在 Column 内抛出警告并破坏布局
                    Rectangle {
                        id: selectionIndicator
                        width: isSelected ? 56 * control.themeGlobalScale : 28 * control.themeGlobalScale
                        height: 32 * control.themeGlobalScale
                        radius: 16 * control.themeGlobalScale
                        // 背景色在未选中时透明，选中时显示主题色容器
                        color: isSelected ? control.themeSecondaryContainer : "transparent"
                        anchors.horizontalCenter: parent.horizontalCenter

                        MeoIcon {
                            anchors.centerIn: parent
                            icon: modelData.icon
                            size: 24
                            color: isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                        }

                        Behavior on width { NumberAnimation { duration: 200; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingStandard !== "undefined") ? MeoTheme.motionEasingStandard : [0.2, 0, 0, 1] } }
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }


                    // 移除这里的独立 MeoIcon，因为它在 Column 里尝试 anchors.centerIn: selectionIndicator 会触发非法定位


                    // 🏷️ Badge (Notification)
                    MeoBadge {
                        text: modelData.badgeText || (modelData.badgeCount !== undefined ? modelData.badgeCount.toString() : "")
                        isDot: modelData.badgeDot || false
                        visible: text !== "" || isDot
                        anchors.horizontalCenter: selectionIndicator.right
                        anchors.verticalCenter: selectionIndicator.top
                        anchors.horizontalCenterOffset: -4 * control.themeGlobalScale
                        anchors.verticalCenterOffset: 4 * control.themeGlobalScale
                    }

                    Text {
                        text: modelData.label
                        font.pixelSize: 12 * control.themeGlobalScale
                        font.weight: isSelected ? Font.Bold : Font.Normal
                        color: isSelected ? control.themePrimary : control.themeOnSurfaceVariant
                        anchors.horizontalCenter: parent.horizontalCenter
                        visible: {
                            if (control.labelType === "always") return true
                            if (control.labelType === "selected") return isSelected
                            return false
                        }
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

    // Bottom Section
    Loader {
        id: footerLoader
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 24 * control.themeGlobalScale
        anchors.horizontalCenter: parent.horizontalCenter
        sourceComponent: control.footer
        visible: control.footer !== null
    }
}
