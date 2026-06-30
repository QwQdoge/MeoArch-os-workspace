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

    signal activated()
    signal accepted(string text)

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 56 * themeGlobalScale

    // 📐 Expressive Expansion Logic
    readonly property bool isWide: parent && parent.width > 600 * themeGlobalScale

    function activateSearch() {
        if (!active) {
            active = true
            activated()
        }
        textField.forceActiveFocus()
    }

    function forceSearchFocus() {
        textField.forceActiveFocus()
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
                if (control.active) {
                    control.active = false
                    textField.focus = false
                } else {
                    control.activateSearch()
                }
            }
        }

        TextField {
            id: textField
            width: parent.width - 48 * control.themeGlobalScale - (trailingButton.visible ? 48 * control.themeGlobalScale : 0) - parent.spacing * 2
            height: parent.height
            background: null
            placeholderText: control.placeholder
            text: control.text
            font.pixelSize: 16 * control.themeGlobalScale
            color: control.themeOnSurface
            placeholderTextColor: control.themeOnSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
            selectByMouse: true

            onTextChanged: control.text = text
            onActiveFocusChanged: if (activeFocus) control.activateSearch()
            onAccepted: control.accepted(text)
        }

        MeoIconButton {
            id: trailingButton
            icon.name: control.active && control.text !== "" ? "close" : control.trailingIcon
            type: "standard"
            anchors.verticalCenter: parent.verticalCenter
            visible: icon.name !== ""
            onClicked: {
                if (control.active && control.text !== "") {
                    control.text = ""
                    textField.text = ""
                    textField.forceActiveFocus()
                }
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: control.activateSearch()
    }
}
