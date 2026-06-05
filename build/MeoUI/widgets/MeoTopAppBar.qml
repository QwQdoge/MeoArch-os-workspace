import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    property string type: "small"
    property string title: ""
    property Component navigationIcon: null
    property var actions: []

    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontTitleLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleLarge !== 'undefined') ? MeoTheme.titleLarge : { "size": 22, "weight": Font.Normal }
    readonly property var fontHeadlineMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.headlineMedium !== 'undefined') ? MeoTheme.headlineMedium : { "size": 28, "weight": Font.Normal }
    readonly property var fontHeadlineLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.headlineLarge !== 'undefined') ? MeoTheme.headlineLarge : { "size": 32, "weight": Font.Normal }

    width: parent ? parent.width : 360 * themeGlobalScale
    height: {
        if (type === "medium") return 112 * themeGlobalScale
        if (type === "large") return 152 * themeGlobalScale
        return 64 * themeGlobalScale
    }
    color: themeSurface

    Item {
        anchors.fill: parent
        anchors.margins: 16 * control.themeGlobalScale

        Loader {
            id: navIconLoader
            anchors.left: parent.left
            anchors.verticalCenter: control.type === "small" || control.type === "center" ? parent.verticalCenter : undefined
            anchors.top: control.type === "medium" || control.type === "large" ? parent.top : undefined
            sourceComponent: control.navigationIcon
            width: 24 * control.themeGlobalScale
            height: 24 * control.themeGlobalScale
        }

        Text {
            text: control.title
            font.pixelSize: (control.type === "large" ? fontHeadlineLarge.size : (control.type === "medium" ? fontHeadlineMedium.size : fontTitleLarge.size)) * control.themeGlobalScale
            font.weight: (control.type === "large" ? fontHeadlineLarge.weight : (control.type === "medium" ? fontHeadlineMedium.weight : fontTitleLarge.weight))
            color: control.themeOnSurface
            anchors.horizontalCenter: control.type === "center" ? parent.horizontalCenter : undefined
            anchors.left: control.type === "center" ? undefined : navIconLoader.right
            anchors.leftMargin: control.type === "center" ? 0 : 16 * control.themeGlobalScale
            anchors.verticalCenter: control.type === "small" || control.type === "center" ? parent.verticalCenter : undefined
            anchors.bottom: control.type === "medium" || control.type === "large" ? parent.bottom : undefined
        }

        Row {
            anchors.right: parent.right
            anchors.verticalCenter: control.type === "small" || control.type === "center" ? parent.verticalCenter : undefined
            anchors.top: control.type === "medium" || control.type === "large" ? parent.top : undefined
            spacing: 12 * control.themeGlobalScale

            Repeater {
                model: control.actions
                delegate: Loader { sourceComponent: modelData }
            }
        }
    }
}
