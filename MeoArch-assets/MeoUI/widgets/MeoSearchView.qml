import QtQuick
import QtQuick.Controls
import MeoUI

Popup {
    id: control

    // 🌟 核心属性
    property string text: ""

    // 🌟 作用域与主题安全防御
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    width: parent ? parent.width : 360 * themeGlobalScale
    height: parent ? parent.height : 600 * themeGlobalScale
    padding: 0

    background: Rectangle {
        color: "transparent"
    }

    contentItem: Column {
        MeoSearchBar {
            id: searchBar
            width: parent.width
            text: control.text
            active: control.opened
            onTextChanged: control.text = text
        }

        // Results would go here
        Item {
            width: parent.width
            height: parent.height - 56 * control.themeGlobalScale

            Text {
                anchors.centerIn: parent
                text: "No recent searches"
                color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
            }
        }
    }

    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: 250; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] }
    }

    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: 200 }
    }
}
