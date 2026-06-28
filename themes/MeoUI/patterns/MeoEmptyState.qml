import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string icon: ""
    property string title: ""
    property string description: ""
    property string actionText: ""
    property Component customContent: null

    signal actionClicked()

    // 🌟 作用域与主题安全防御
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontHeadlineSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.headlineSmall !== 'undefined') ? MeoTheme.headlineSmall : { "size": 24, "weight": Font.Normal }
    readonly property var fontBodyMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyMedium !== 'undefined') ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal }

    implicitWidth: 320 * themeGlobalScale
    implicitHeight: mainColumn.implicitHeight

    Column {
        id: mainColumn
        anchors.centerIn: parent
        width: Math.min(parent.width * 0.8, 400 * control.themeGlobalScale)
        spacing: 24 * control.themeGlobalScale

        // Illustration / Icon
        MeoIcon {
            icon: control.icon
            visible: icon !== ""
            size: 64
            color: control.themeOnSurfaceVariant
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Text Group
        Column {
            width: parent.width
            spacing: 8 * control.themeGlobalScale

            Text {
                text: control.title
                visible: text !== ""
                width: parent.width
                font.pixelSize: fontHeadlineSmall.size * control.themeGlobalScale
                font.weight: fontHeadlineSmall.weight
                color: control.themeOnSurface
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }

            Text {
                text: control.description
                visible: text !== ""
                width: parent.width
                font.pixelSize: fontBodyMedium.size * control.themeGlobalScale
                font.weight: fontBodyMedium.weight
                color: control.themeOnSurfaceVariant
                horizontalAlignment: Text.AlignHCenter
                wrapMode: Text.WordWrap
            }
        }

        // Custom Content Slot
        Loader {
            id: customLoader
            sourceComponent: control.customContent
            visible: control.customContent !== null
            anchors.horizontalCenter: parent.horizontalCenter
        }

        // Primary Action
        MeoButton {
            text: control.actionText
            type: "filled"
            visible: text !== ""
            anchors.horizontalCenter: parent.horizontalCenter
            onClicked: control.actionClicked()
        }
    }
}
