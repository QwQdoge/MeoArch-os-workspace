import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property string type: "small" // "small" | "center" | "medium" | "large"
    property bool flexible: false
    property real scrollProgress: 0.0 // 0.0 (collapsed) to 1.0 (expanded)
    property string title: ""
    property Component navigationIcon: null
    property list<Component> actions

    // 🌟 MD3 Contextual Mode (Selection state)
    property bool isContextual: false
    property int selectionCount: 0

    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ? MeoTheme.contentOnPrimaryContainer : "#21005D"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontTitleLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleLarge !== 'undefined') ? MeoTheme.titleLarge : { "size": 22, "weight": Font.Normal }
    readonly property var fontHeadlineMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.headlineMedium !== 'undefined') ? MeoTheme.headlineMedium : { "size": 28, "weight": Font.Normal }
    readonly property var fontHeadlineLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.headlineLarge !== 'undefined') ? MeoTheme.headlineLarge : { "size": 32, "weight": Font.Normal }

    width: parent ? parent.width : 360 * themeGlobalScale
    height: {
        let baseHeight = 64;
        if (type === "medium") baseHeight = 112;
        if (type === "large") baseHeight = 152;

        if (flexible && (type === "medium" || type === "large")) {
            return (64 + (baseHeight - 64) * scrollProgress) * themeGlobalScale;
        }
        return baseHeight * themeGlobalScale;
    }

    // Background color transition for Contextual Mode
    color: isContextual ? themePrimaryContainer : themeSurface
    Behavior on color { ColorAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }

    Behavior on height { NumberAnimation { duration: 300; easing.bezierCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingSoul !== 'undefined') ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }

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

            readonly property real targetFontSize: {
                if (control.type === "large") return fontHeadlineLarge.size;
                if (control.type === "medium") return fontHeadlineMedium.size;
                return fontTitleLarge.size;
            }

            font.pixelSize: {
                if (control.flexible && (control.type === "medium" || control.type === "large")) {
                    return (fontTitleLarge.size + (targetFontSize - fontTitleLarge.size) * control.scrollProgress) * control.themeGlobalScale;
                }
                return targetFontSize * control.themeGlobalScale;
            }

            font.weight: (control.type === "large" ? fontHeadlineLarge.weight : (control.type === "medium" ? fontHeadlineMedium.weight : fontTitleLarge.weight))
            color: isContextual ? control.themeOnPrimaryContainer : control.themeOnSurface
            anchors.horizontalCenter: (control.type === "center" && !isContextual) ? parent.horizontalCenter : undefined
            anchors.left: (control.type === "center" && !isContextual) ? undefined : navIconLoader.right
            anchors.leftMargin: (control.type === "center" && !isContextual) ? 0 : 16 * control.themeGlobalScale

            anchors.verticalCenter: {
                if (control.flexible && (control.type === "medium" || control.type === "large")) return undefined;
                return control.type === "small" || control.type === "center" ? parent.verticalCenter : undefined
            }

            anchors.bottom: {
                if (control.flexible && (control.type === "medium" || control.type === "large")) return parent.bottom;
                return control.type === "medium" || control.type === "large" ? parent.bottom : undefined
            }

            anchors.bottomMargin: {
                if (control.flexible && (control.type === "medium" || control.type === "large")) {
                    return (parent.height - fontTitleLarge.size * control.themeGlobalScale) / 2 * (1.0 - control.scrollProgress);
                }
                return 0;
            }

            Behavior on font.pixelSize {
                enabled: !control.flexible
                NumberAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== 'undefined' ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]) }
            }
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
