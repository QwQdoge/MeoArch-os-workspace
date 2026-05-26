import QtQuick
import QtQuick.Controls

Control {
    id: control

    // 🌟 核心属性
    property string headline: ""
    property string supportingText: ""
    property string leadingIcon: ""
    property Component leadingComponent: null
    property Component trailingComponent: null
    property bool interactive: true

    signal clicked()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: Math.max(56 * themeGlobalScale, contentRow.implicitHeight + padding * 2)

    padding: 16 * themeGlobalScale

    background: Rectangle {
        color: "transparent"

        // 🌟 状态层反馈
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

        // Leading Area
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

            Text {
                anchors.centerIn: parent
                text: control.leadingIcon
                font.pixelSize: 24 * control.themeGlobalScale
                color: control.themeOnSurfaceVariant
                visible: control.leadingIcon !== "" && control.leadingComponent === null
            }
        }

        // Text Area
        Column {
            width: parent.width - (control.leadingIcon !== "" || control.leadingComponent !== null ? 40 * control.themeGlobalScale : 0) - (control.trailingComponent !== null ? 40 * control.themeGlobalScale : 0)
            anchors.verticalCenter: parent.verticalCenter
            spacing: 2 * control.themeGlobalScale

            Text {
                text: control.headline
                width: parent.width
                font.pixelSize: 16 * control.themeGlobalScale
                color: control.themeOnSurface
                elide: Text.ElideRight
            }

            Text {
                text: control.supportingText
                width: parent.width
                font.pixelSize: 14 * control.themeGlobalScale
                color: control.themeOnSurfaceVariant
                visible: text !== ""
                elide: Text.ElideRight
                wrapMode: Text.WordWrap
                maximumLineCount: 2
            }
        }

        // Trailing Area
        Loader {
            width: 24 * control.themeGlobalScale
            height: 24 * control.themeGlobalScale
            anchors.verticalCenter: parent.verticalCenter
            sourceComponent: control.trailingComponent
            visible: control.trailingComponent !== null
        }
    }
}
