import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string label: ""
    property string icon: ""
    property string badgeText: ""
    property bool selected: false

    signal clicked()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? MeoTheme.onSecondaryContainer : "#1D192B"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    implicitWidth: 336 * themeGlobalScale
    implicitHeight: 56 * themeGlobalScale

    background: Item {
        // 🌟 Pill-shaped Active Indicator
        Rectangle {
            id: indicator
            anchors.centerIn: parent
            width: parent.width - 24 * control.themeGlobalScale
            height: parent.height - 8 * control.themeGlobalScale
            radius: height / 2
            color: control.selected ? control.themeSecondaryContainer : "transparent"

            MeoStateLayer {
                radius: parent.radius
                pressed: mouseArea.pressed
                hovered: mouseArea.containsMouse
                color: control.selected ? control.themeOnSecondaryContainer : control.themeOnSurface
            }

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: control.clicked()
    }

    contentItem: Row {
        id: contentRow
        anchors.fill: parent
        anchors.leftMargin: 28 * control.themeGlobalScale
        anchors.rightMargin: 28 * control.themeGlobalScale
        spacing: 12 * control.themeGlobalScale

        MeoIcon {
            icon: control.icon
            size: 24
            color: control.selected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: control.label
            font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
            font.weight: fontLabelLarge.weight
            color: control.selected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
            verticalAlignment: Text.AlignVCenter
            anchors.verticalCenter: parent.verticalCenter

            // Expand to fill available space
            width: parent.width - (control.icon !== "" ? 36 * control.themeGlobalScale : 0) - (control.badgeText !== "" ? badge.implicitWidth + 12 * control.themeGlobalScale : 0)
            elide: Text.ElideRight
        }

        MeoBadge {
            id: badge
            text: control.badgeText
            visible: text !== ""
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
