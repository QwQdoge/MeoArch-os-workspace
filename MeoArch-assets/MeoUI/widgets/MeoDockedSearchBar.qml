import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心对外属性
    property string text: ""
    property string placeholder: "Search..."
    property Component menuContent: null
    property bool isExpanded: false

    signal clicked()

    readonly property color themeSurfaceContainerHighest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerHighest !== 'undefined') ? MeoTheme.surfaceContainerHighest : "#E6E1E5"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: isExpanded ? 400 * themeGlobalScale : 56 * themeGlobalScale
    radius: 28 * themeGlobalScale
    color: themeSurfaceContainerHighest

    Behavior on implicitHeight { NumberAnimation { duration: 250; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }

    Column {
        anchors.fill: parent

        // Search Bar Area
        Row {
            width: parent.width
            height: 56 * control.themeGlobalScale
            spacing: 12 * control.themeGlobalScale
            leftPadding: 16 * control.themeGlobalScale
            rightPadding: 16 * control.themeGlobalScale

            MeoIcon {
                icon: "search"
                anchors.verticalCenter: parent.verticalCenter
                color: control.themeOnSurfaceVariant
            }

            TextField {
                id: textField
                width: parent.width - 100 * control.themeGlobalScale
                height: parent.height
                background: null
                placeholderText: control.placeholder
                text: control.text
                font.pixelSize: 16 * control.themeGlobalScale
                color: control.themeOnSurface
                anchors.verticalCenter: parent.verticalCenter

                onTextChanged: control.text = text
                onActiveFocusChanged: if (activeFocus) control.isExpanded = true
            }

            MeoIconButton {
                icon.name: "more_vert"
                type: "standard"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: control.clicked()
            }
        }

        // Expanded Content
        Loader {
            id: contentLoader
            width: parent.width
            height: parent.height - 56 * control.themeGlobalScale
            visible: control.isExpanded
            sourceComponent: control.menuContent
            clip: true
        }
    }
}
