import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    property bool isOpen: false
    property var model: []
    property int currentIndex: 0

    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    property bool isModal: false

    width: 360 * themeGlobalScale
    height: parent ? parent.height : 600 * themeGlobalScale
    x: isModal ? (isOpen ? 0 : -width) : 0
    visible: isModal ? true : isOpen
    color: themeSurfaceContainerLow

    Behavior on x { enabled: control.isModal; NumberAnimation { duration: 250; easing.type: Easing.OutCubic } }

    Column {
        anchors.fill: parent
        anchors.margins: 12 * control.themeGlobalScale
        spacing: 4 * control.themeGlobalScale

        Text {
            text: "MeoArch OS"
            font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
            font.weight: Font.Medium
            color: control.themeOnSurface
            height: 56 * control.themeGlobalScale
            verticalAlignment: Text.AlignVCenter
            anchors.left: parent.left
            anchors.leftMargin: 16 * control.themeGlobalScale
        }

        Repeater {
            model: control.model
            delegate: Item {
                width: parent.width
                height: 56 * control.themeGlobalScale

                readonly property bool isSelected: control.currentIndex === index

                Rectangle {
                    anchors.fill: parent
                    radius: 28 * control.themeGlobalScale
                    color: isSelected ? control.themeSecondaryContainer : "transparent"

                    Row {
                        anchors.fill: parent
                        anchors.leftMargin: 16 * control.themeGlobalScale
                        spacing: 12 * control.themeGlobalScale

                        MeoIcon {
                            icon: modelData.icon
                            size: 24
                            color: isSelected ? control.themePrimary : control.themeOnSurface
                            anchors.verticalCenter: parent.verticalCenter
                        }

                        Text {
                            text: modelData.label
                            font.pixelSize: fontLabelLarge.size * control.themeGlobalScale
                            font.weight: isSelected ? Font.Bold : fontLabelLarge.weight
                            color: isSelected ? control.themePrimary : control.themeOnSurface
                            anchors.verticalCenter: parent.verticalCenter
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    onClicked: {
                        control.currentIndex = index
                        control.isOpen = false
                    }
                }
            }
        }
    }
}
