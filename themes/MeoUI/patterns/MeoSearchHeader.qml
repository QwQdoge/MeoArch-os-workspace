import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    property string title: ""
    property string placeholder: "Search"
    property string text: ""
    property string leadingIcon: "search"
    property string trailingIcon: ""
    property list<Component> actions
    property real maxSearchWidth: 720 * themeGlobalScale

    signal accepted(string text)

    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property color themeSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.surface !== "undefined") ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property var fontTitleLarge: (typeof MeoTheme !== "undefined" && typeof MeoTheme.titleLarge !== "undefined") ? MeoTheme.titleLarge : { "size": 22, "weight": Font.Normal, "lineHeight": 28, "letterSpacing": 0 }

    width: parent ? parent.width : 840 * themeGlobalScale
    implicitHeight: 64 * themeGlobalScale
    color: themeSurface

    Row {
        anchors.fill: parent
        anchors.leftMargin: 24 * control.themeGlobalScale
        anchors.rightMargin: 24 * control.themeGlobalScale
        spacing: 16 * control.themeGlobalScale

        Text {
            width: control.title === "" ? 0 : Math.min(220 * control.themeGlobalScale, implicitWidth)
            text: control.title
            visible: text !== ""
            anchors.verticalCenter: parent.verticalCenter
            font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
            font.pixelSize: control.fontTitleLarge.size * control.themeGlobalScale
            font.weight: control.fontTitleLarge.weight
            font.letterSpacing: (control.fontTitleLarge.letterSpacing || 0) * control.themeGlobalScale
            lineHeight: control.fontTitleLarge.lineHeight / control.fontTitleLarge.size
            color: control.themeOnSurface
            elide: Text.ElideRight
        }

        MeoSearchBar {
            id: searchBar
            width: Math.max(160 * control.themeGlobalScale,
                            Math.min(control.maxSearchWidth,
                                     parent.width - (control.title === "" ? 0 : 236 * control.themeGlobalScale)
                                     - actionRow.width - 16 * control.themeGlobalScale))
            anchors.verticalCenter: parent.verticalCenter
            placeholder: control.placeholder
            text: control.text
            leadingIcon: control.leadingIcon
            trailingIcon: control.trailingIcon
            onTextChanged: control.text = text
            onAccepted: (value) => control.accepted(value)
        }

        Row {
            id: actionRow
            anchors.verticalCenter: parent.verticalCenter
            spacing: 4 * control.themeGlobalScale
            visible: control.actions.length > 0

            Repeater {
                model: control.actions
                delegate: Loader { sourceComponent: modelData }
            }
        }
    }
}
