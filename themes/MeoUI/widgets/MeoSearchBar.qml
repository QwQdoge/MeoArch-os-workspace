import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property string text: ""
    property string placeholder: "Search..."
    property string leadingIcon: "search"
    property string trailingIcon: "person"
    property bool active: false // 🌟 MD3 Expressive: Active state for transition

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 56 * themeGlobalScale

    // 📐 Expressive Expansion Logic
    readonly property bool isWide: parent && parent.width > 600 * themeGlobalScale

    // Use Layout.preferredWidth if inside a layout, otherwise set width
    width: {
        if (typeof Layout !== 'undefined' && typeof Layout.fillWidth !== 'undefined') return implicitWidth;
        return active ? (parent ? parent.width : implicitWidth) : implicitWidth
    }

    // Handle Layout.fillWidth safely
    Component.onCompleted: {
        if (typeof Layout !== 'undefined' && typeof Layout.fillWidth !== 'undefined') {
            // If in a layout, we might need a different strategy, but for standard usage:
        }
    }

    radius: active ? (isWide ? 16 * themeGlobalScale : 0) : 28 * themeGlobalScale
    color: active ? themeSurface : themeSurfaceContainerHighest

    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"

    Behavior on width { NumberAnimation { duration: 300; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
    Behavior on color { ColorAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
    Behavior on radius { NumberAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.rightMargin: 16 * control.themeGlobalScale
        spacing: 12 * control.themeGlobalScale

        MeoIconButton {
            icon.name: control.active ? "arrow_back" : control.leadingIcon
            type: "standard"
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                if (control.active) control.active = false
            }
        }

        TextField {
            id: textField
            width: parent.width - (control.leadingIcon !== "" ? 24 : 0) - (control.trailingIcon !== "" ? 24 : 0) - (parent.spacing * 2)
            height: parent.height
            background: null
            placeholderText: control.placeholder
            text: control.text
            font.pixelSize: 16 * control.themeGlobalScale
            color: control.themeOnSurface
            anchors.verticalCenter: parent.verticalCenter

            onTextChanged: control.text = text
        }

        MeoIcon {
            icon: control.trailingIcon
            size: 24
            anchors.verticalCenter: parent.verticalCenter
            color: control.themeOnSurfaceVariant
            visible: control.trailingIcon !== ""
        }
    }
}
