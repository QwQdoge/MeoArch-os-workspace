import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    property string headline: ""
    property string supportingText: ""
    property int supportingTextLines: 1 // 1 or 2
    property string leadingIcon: ""
    property Component leadingComponent: null
    property Component trailingComponent: null
    property bool interactive: true

    signal clicked()

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontBodyLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyLarge !== 'undefined') ? MeoTheme.bodyLarge : { "size": 16, "weight": Font.Normal }
    readonly property var fontBodyMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyMedium !== 'undefined') ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal }

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: Math.max(56 * themeGlobalScale, contentRow.implicitHeight + padding * 2)

    padding: 16 * themeGlobalScale

    background: Rectangle {
        color: "transparent"

        Rectangle {
            anchors.fill: parent
            visible: control.interactive
            color: {
                if (mouseArea.pressed) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.12)
                if (mouseArea.containsMouse) return Qt.rgba(control.themeOnSurface.r, control.themeOnSurface.g, control.themeOnSurface.b, 0.08)
                return "transparent"
            }
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        enabled: control.interactive
        onClicked: control.clicked()
    }

    contentItem: Row {
        id: contentRow
        spacing: 16 * control.themeGlobalScale
        width: parent.width

        Item {
            width: 24 * control.themeGlobalScale
            height: 24 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            visible: control.leadingIcon !== "" || control.leadingComponent !== null

            Loader {
                anchors.centerIn: parent
                sourceComponent: control.leadingComponent
                visible: control.leadingComponent !== null
            }

            MeoIcon {
                anchors.centerIn: parent
                icon: control.leadingIcon
                size: 24
                color: control.themeOnSurfaceVariant
                visible: control.leadingIcon !== "" && control.leadingComponent === null
            }
        }

        Column {
            width: parent.width - (control.leadingIcon !== "" || control.leadingComponent !== null ? 40 * control.themeGlobalScale : 0) - (control.trailingComponent !== null ? 40 * control.themeGlobalScale : 0)
            anchors.verticalCenter: parent.verticalCenter
            spacing: 0

            Text {
                text: control.headline
                width: parent.width
                font.pixelSize: fontBodyLarge.size * control.themeGlobalScale
                font.weight: fontBodyLarge.weight
                color: control.themeOnSurface
                elide: Text.ElideRight
            }

            Text {
                text: control.supportingText
                width: parent.width
                font.pixelSize: fontBodyMedium.size * control.themeGlobalScale
                font.weight: fontBodyMedium.weight
                color: control.themeOnSurfaceVariant
                visible: text !== ""
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: control.supportingTextLines
            }
        }

        Loader {
            width: 24 * control.themeGlobalScale
            height: 24 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: control.trailingComponent
            visible: control.trailingComponent !== null
        }
    }
}
