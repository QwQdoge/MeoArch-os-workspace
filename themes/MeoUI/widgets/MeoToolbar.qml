import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property string title: ""
    property list<Component> actions
    property bool isCompact: false

    // 🌟 样式与主题
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property var fontTitleMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleMedium !== 'undefined') ? MeoTheme.titleMedium : { "size": 16, "weight": Font.Medium }

    width: parent ? parent.width : 360 * themeGlobalScale
    height: (isCompact ? 48 : 56) * themeGlobalScale
    color: themeSurface

    // Implementation using anchors for better reliability without RowLayout
    Row {
        id: actionsRow
        anchors.right: parent.right
        anchors.rightMargin: 16 * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8 * control.themeGlobalScale

        Repeater {
            model: control.actions
            delegate: Loader { sourceComponent: modelData }
        }
    }

    Text {
        id: titleText
        text: control.title
        visible: text !== ""
        anchors.left: parent.left
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: actionsRow.left
        anchors.rightMargin: 16 * control.themeGlobalScale
        font.pixelSize: fontTitleMedium.size * control.themeGlobalScale
        font.weight: fontTitleMedium.weight
        color: control.themeOnSurface
        elide: Text.ElideRight
    }
}
