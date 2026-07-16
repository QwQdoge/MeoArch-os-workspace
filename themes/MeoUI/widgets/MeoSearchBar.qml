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
    readonly property color themeSurfaceContainerHigh: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHigh !== 'undefined') ? MeoTheme.surfaceContainerHigh : "#ECE6F0"
    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property var fontBodyLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyLarge !== 'undefined') ? MeoTheme.bodyLarge : { "size": 16, "weight": Font.Normal, "lineHeight": 24, "letterSpacing": 0.5 }

    implicitWidth: Math.min(720 * themeGlobalScale, parent ? parent.width : 720 * themeGlobalScale)
    implicitHeight: 56 * themeGlobalScale

    // 📐 Expressive Expansion Logic
    readonly property bool isWide: parent && parent.width >= MeoTheme.windowBreakpointMedium

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
    color: active ? themeSurface : themeSurfaceContainerHigh

    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"

    Behavior on width { NumberAnimation { duration: MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
    Behavior on color { ColorAnimation { duration: MeoTheme.motionDurationState; easing.bezierCurve: MeoTheme.motionEasingStandard } }
    Behavior on radius { NumberAnimation { duration: MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }

    Row {
        anchors.fill: parent
        anchors.leftMargin: 4 * control.themeGlobalScale
        anchors.rightMargin: 4 * control.themeGlobalScale
        spacing: 4 * control.themeGlobalScale

        MeoIconButton {
            id: leadingButton
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

            // 🌟 MD3 Expressive: Fluid icon rotation/swap
            contentItem: MeoIcon {
                icon: leadingButton.icon.name
                size: 24
                color: leadingButton.icon.color
                rotation: control.active ? 0 : -90
                Behavior on rotation { NumberAnimation { duration: MeoTheme.motionDurationSelection; easing.bezierCurve: MeoTheme.motionEasingEmphasized } }
                Behavior on icon {
                    SequentialAnimation {
                        NumberAnimation { target: parent; property: "opacity"; to: 0; duration: MeoTheme.motionDurationShort2 }
                        PropertyAction { property: "icon" }
                        NumberAnimation { target: parent; property: "opacity"; to: 1; duration: MeoTheme.motionDurationShort2 }
                    }
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
            font.pixelSize: fontBodyLarge.size * control.themeGlobalScale
            font.weight: fontBodyLarge.weight
            font.letterSpacing: (fontBodyLarge.letterSpacing || 0) * control.themeGlobalScale
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
            opacity: visible ? 1.0 : 0.0
            Behavior on opacity { NumberAnimation { duration: MeoTheme.motionDurationState } }

            onClicked: {
                if (control.active && control.text !== "") {
                    control.text = ""
                    textField.text = ""
                    textField.forceActiveFocus()
                }
            }

            contentItem: MeoIcon {
                icon: trailingButton.icon.name
                size: 24
                color: trailingButton.icon.color
                Behavior on icon {
                    SequentialAnimation {
                        NumberAnimation { target: parent; property: "scale"; to: 0.5; duration: MeoTheme.motionDurationShort2 }
                        PropertyAction { property: "icon" }
                        NumberAnimation { target: parent; property: "scale"; to: 1.0; duration: MeoTheme.motionDurationShort2 }
                    }
                }
            }
        }
    }

    TapHandler {
        acceptedButtons: Qt.LeftButton
        onTapped: control.activateSearch()
    }
}
