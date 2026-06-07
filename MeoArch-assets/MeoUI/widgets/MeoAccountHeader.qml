import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    // 🌟 核心属性
    property string name: "User Name"
    property string email: "user@example.com"
    property string avatarSource: ""
    property bool showDropdown: true

    signal clicked()
    signal dropdownClicked()

    // 🌟 作用域与主题安全防御
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontTitleMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleMedium !== 'undefined') ? MeoTheme.titleMedium : { "size": 16, "weight": Font.Medium }
    readonly property var fontBodySmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodySmall !== 'undefined') ? MeoTheme.bodySmall : { "size": 12, "weight": Font.Normal }

    implicitWidth: parent ? parent.width : 360 * themeGlobalScale
    implicitHeight: 72 * themeGlobalScale

    Row {
        anchors.fill: parent
        anchors.leftMargin: 16 * control.themeGlobalScale
        anchors.rightMargin: 16 * control.themeGlobalScale
        spacing: 16 * control.themeGlobalScale

        // 🖼️ Avatar
        Rectangle {
            width: 40 * control.themeGlobalScale
            height: 40 * control.themeGlobalScale
            radius: width / 2
            color: control.themeSecondaryContainer
            clip: true
            anchors.verticalCenter: parent.verticalCenter

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
                size: 24
                color: control.themeOnSurfaceVariant
            }
        }

        // 🔤 Info
        Column {
            anchors.verticalCenter: parent.verticalCenter
            width: parent.width - 40 * control.themeGlobalScale - (control.showDropdown ? 32 * control.themeGlobalScale : 0) - (parent.spacing * 2)

            Text {
                text: control.name
                font.pixelSize: fontTitleMedium.size * control.themeGlobalScale
                font.weight: fontTitleMedium.weight
                color: control.themeOnSurface
                width: parent.width
                elide: Text.ElideRight
            }

            Text {
                text: control.email
                font.pixelSize: fontBodySmall.size * control.themeGlobalScale
                font.weight: fontBodySmall.weight
                color: control.themeOnSurfaceVariant
                width: parent.width
                elide: Text.ElideRight
            }
        }

        // 🔽 Dropdown Icon
        MeoIconButton {
            icon.name: "arrow_drop_down"
            visible: control.showDropdown
            anchors.verticalCenter: parent.verticalCenter
            width: 32 * control.themeGlobalScale
            height: 32 * control.themeGlobalScale
            onClicked: control.dropdownClicked()
        }
    }

    MouseArea {
        anchors.fill: parent
        onClicked: control.clicked()
        z: -1
    }
}
