import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property string type: "small" // "small" | "center" | "medium" | "large"
    property string title: ""
    property Component navigationIcon: null
    property var actions: []

    // 🌟 MD3 Contextual Mode (Selection state)
    property bool isContextual: false
    property int selectionCount: 0

    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimaryContainer !== 'undefined') ? MeoTheme.onPrimaryContainer : "#21005D"
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

    // Background color transition for Contextual Mode
    color: isContextual ? themePrimaryContainer : themeSurface
    Behavior on color { ColorAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }

    Rectangle {
        id: stateLayer
        anchors.fill: parent
        color: isContextual ? themeOnPrimaryContainer : "transparent"
        opacity: 0.08
        visible: isContextual
    }

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
            text: isContextual ? (selectionCount > 0 ? selectionCount.toString() : "") : control.title
            font.pixelSize: (control.type === "large" ? fontHeadlineLarge.size : (control.type === "medium" ? fontHeadlineMedium.size : fontTitleLarge.size)) * control.themeGlobalScale
            font.weight: (control.type === "large" ? fontHeadlineLarge.weight : (control.type === "medium" ? fontHeadlineMedium.weight : fontTitleLarge.weight))
            color: isContextual ? control.themeOnPrimaryContainer : control.themeOnSurface
            anchors.horizontalCenter: (control.type === "center" && !isContextual) ? parent.horizontalCenter : undefined
            anchors.left: (control.type === "center" && !isContextual) ? undefined : navIconLoader.right
            anchors.leftMargin: (control.type === "center" && !isContextual) ? 0 : 16 * control.themeGlobalScale
            anchors.verticalCenter: control.type === "small" || control.type === "center" ? parent.verticalCenter : undefined
            anchors.bottom: control.type === "medium" || control.type === "large" ? parent.bottom : undefined

            Behavior on color { ColorAnimation { duration: 150 } }
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
