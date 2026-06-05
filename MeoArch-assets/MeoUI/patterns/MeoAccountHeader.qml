import QtQuick
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string name: "User Name"
    property string email: "user@example.com"
    property string avatarSource: ""
    property bool showDropdown: true

    signal clicked()

    // 🌟 作用域与主题安全防御
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontTitleSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleSmall !== 'undefined') ? MeoTheme.titleSmall : { "size": 14, "weight": Font.Medium }
    readonly property var fontBodySmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodySmall !== 'undefined') ? MeoTheme.bodySmall : { "size": 12, "weight": Font.Normal }

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 148 * themeGlobalScale

    Column {
        anchors.fill: parent
        anchors.margins: 16 * control.themeGlobalScale
        spacing: 12 * control.themeGlobalScale

        // Avatar
        Rectangle {
            width: 64 * control.themeGlobalScale
            height: 64 * control.themeGlobalScale
            radius: 32 * control.themeGlobalScale
            color: control.themeSecondaryContainer
            clip: true

            Image {
                anchors.fill: parent
                source: control.avatarSource
                visible: control.avatarSource !== ""
                fillMode: Image.PreserveAspectCrop
            }

            MeoIcon {
                anchors.centerIn: parent
                icon: "person"
                visible: control.avatarSource === ""
                size: 32
                color: control.themeOnSurfaceVariant
            }
        }

        // Info and Dropdown
        Row {
            width: parent.width
            spacing: 8 * control.themeGlobalScale

            Column {
                width: parent.width - (control.showDropdown ? 40 * control.themeGlobalScale : 0)
                spacing: 0

                Text {
                    width: parent.width
                    text: control.name
                    font.pixelSize: fontTitleSmall.size * control.themeGlobalScale
                    font.weight: fontTitleSmall.weight
                    color: control.themeOnSurface
                    elide: Text.ElideRight
                }

                Text {
                    width: parent.width
                    text: control.email
                    font.pixelSize: fontBodySmall.size * control.themeGlobalScale
                    color: control.themeOnSurfaceVariant
                    elide: Text.ElideRight
                }
            }

            MeoIconButton {
                icon: "arrow_drop_down"
                visible: control.showDropdown
                type: "standard"
                anchors.verticalCenter: parent.verticalCenter
                onClicked: control.clicked()
            }
        }
    }

    // Interaction Layer
    MouseArea {
        anchors.fill: parent
        onClicked: control.clicked()
        enabled: !control.showDropdown // If dropdown exists, let the button handle it. Or both.
    }
}
