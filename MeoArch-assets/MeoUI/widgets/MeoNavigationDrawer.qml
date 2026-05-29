import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property var model: []
    property int currentIndex: 0
    property bool isModal: false
    property string title: ""

    signal clicked(int index)

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    width: 360 * themeGlobalScale
    height: parent ? parent.height : 600 * themeGlobalScale
    color: themeSurfaceContainerLow

    // Drawer Header
    Column {
        id: mainColumn
        anchors.fill: parent
        anchors.topMargin: 24 * control.themeGlobalScale
        spacing: 4 * control.themeGlobalScale

        Text {
            text: control.title
            visible: text !== ""
            padding: 16 * control.themeGlobalScale
            font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
            font.weight: fontLabelLarge.weight
            color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
        }

        Repeater {
            model: control.model
            delegate: MeoNavigationDrawerItem {
                width: parent.width - 24 * control.themeGlobalScale
                anchors.horizontalCenter: parent.horizontalCenter
                label: modelData.label
                icon: modelData.icon
                badgeText: modelData.badgeText || ""
                selected: control.currentIndex === index
                onClicked: {
                    control.currentIndex = index
                    control.clicked(index)
                }
            }
        }
    }
}
