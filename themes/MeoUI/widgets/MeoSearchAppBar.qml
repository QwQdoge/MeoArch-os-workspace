import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property string text: ""
    property string placeholder: "Search..."
    property bool active: false
    property string leadingIcon: "search"
    property string trailingIcon: "person"
    property Component menuIcon: null
    property var actions: []

    // 🌟 样式与主题
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    width: parent ? parent.width : 360 * themeGlobalScale
    height: 64 * themeGlobalScale
    color: themeSurface

    // MD3 Search App Bar Anatomy:
    // When inactive, it looks like a standard Search Bar but placed in the App Bar position.
    // When active, it morphs into a full Search View.

    MeoSearchBar {
        id: searchBar
        anchors.centerIn: parent
        width: control.active ? parent.width : parent.width - 32 * control.themeGlobalScale
        height: control.active ? parent.height : 56 * control.themeGlobalScale
        active: control.active
        placeholder: control.placeholder
        text: control.text
        leadingIcon: control.leadingIcon
        trailingIcon: control.trailingIcon

        onActiveChanged: control.active = active
        onTextChanged: control.text = text

        // Expansion is handled by MeoSearchBar's internal logic,
        // but we can override or extend here if needed.
    }

    // Optional Top App Bar level actions when inactive
    Row {
        anchors.right: parent.right
        anchors.rightMargin: 16 * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter
        spacing: 12 * control.themeGlobalScale
        visible: !control.active && control.actions.length > 0

        Repeater {
            model: control.actions
            delegate: Loader { sourceComponent: modelData }
        }
    }
}
