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

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 56 * themeGlobalScale
    radius: 28 * themeGlobalScale
    color: themeSurfaceContainerHighest

    Behavior on color { ColorAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.rightMargin: 16 * control.themeGlobalScale
        spacing: 12 * control.themeGlobalScale

        MeoIcon {
            icon: control.leadingIcon
            size: 24
            anchors.verticalCenter: parent.verticalCenter
            color: control.themeOnSurfaceVariant
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
