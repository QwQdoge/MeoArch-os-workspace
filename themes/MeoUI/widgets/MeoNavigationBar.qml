import QtQuick
import MeoUI

Rectangle {
    id: control

    property var model: []
    property int currentIndex: 0
    property string labelType: "always" // "always" | "selected" | "none"
    property string shape: "pill" // 🌟 MD3 Expressive Shape
    signal clicked(int index)

    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelMedium !== 'undefined') ? MeoTheme.labelMedium : { "size": 12, "weight": Font.Medium }

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: 80 * themeGlobalScale
    color: themeSurfaceContainer

    Row {
        anchors.fill: parent

        Repeater {
            model: control.model
            delegate: Item {
                id: destination
                width: control.width / control.model.length
                height: control.height
                activeFocusOnTab: true
                Accessible.role: Accessible.PageTab
                Accessible.name: modelData.label
                Accessible.selected: isSelected
                Accessible.focusable: true
                Accessible.onPressAction: activate()

                readonly property bool isSelected: control.currentIndex === index

                function activate() {
                    control.currentIndex = index
                    control.clicked(index)
                }

                Column {
                    anchors.centerIn: parent
                    spacing: 4 * control.themeGlobalScale

                    Item {
                        width: 64 * control.themeGlobalScale
                        height: 32 * control.themeGlobalScale
                        anchors.horizontalCenter: parent.horizontalCenter

                        MeoShape {
                            id: selectionIndicator
                            width: isSelected ? 64 * control.themeGlobalScale : 0
                            height: 32 * control.themeGlobalScale
                            radius: 16 * control.themeGlobalScale
                            anchors.centerIn: parent
                            type: control.shape
                            color: isSelected ? control.themeSecondaryContainer : "transparent"
                            opacity: isSelected ? 1.0 : 0.0

                            Behavior on width {
                                NumberAnimation {
                                    duration: MeoTheme.motionDurationSelection
                                    easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate
                                }
                            }
                            Behavior on opacity {
                                NumberAnimation {
                                    duration: MeoTheme.motionDurationState
                                    easing.bezierCurve: isSelected ? MeoTheme.motionEasingEnter : MeoTheme.motionEasingExit
                                }
                            }
                        }

                        MeoIcon {
                            anchors.centerIn: parent
                            icon: modelData.icon
                            fill: isSelected
                            size: 24
                            color: isSelected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
                        }

                        // 🏷️ Badge (Notification)
                        MeoBadge {
                            text: modelData.badgeText || (modelData.badgeCount !== undefined ? modelData.badgeCount.toString() : "")
                            isDot: modelData.badgeDot || false
                            visible: text !== "" || isDot
                            anchors.top: parent.top
                            anchors.right: parent.right
                            anchors.topMargin: -4 * control.themeGlobalScale
                            anchors.rightMargin: -4 * control.themeGlobalScale
                        }
                    }

                    Text {
                        text: modelData.label
                        anchors.horizontalCenter: parent.horizontalCenter
                        font.pixelSize: fontLabelMedium.size * control.themeGlobalScale
                        font.weight: isSelected ? Font.Bold : fontLabelMedium.weight
                        verticalAlignment: Text.AlignVCenter
                        color: isSelected ? control.themeOnSurface : control.themeOnSurfaceVariant
                        visible: {
                            if (control.labelType === "always") return true
                            if (control.labelType === "selected") return isSelected
                            return false
                        }
                    }
                }

                MeoStateLayer {
                    id: stateLayer
                    anchors.fill: parent
                    anchors.margins: 4 * control.themeGlobalScale
                    radius: 16 * control.themeGlobalScale
                    hovered: hitArea.containsMouse
                    pressed: hitArea.pressed
                    focused: destination.activeFocus
                    pressX: hitArea.mouseX
                    pressY: hitArea.mouseY
                    color: isSelected ? control.themeOnSecondaryContainer : control.themeOnSurface
                }

                MouseArea {
                    id: hitArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        destination.forceActiveFocus(Qt.MouseFocusReason)
                        destination.activate()
                    }
                }
                Keys.onReturnPressed: activate()
                Keys.onEnterPressed: activate()
                Keys.onSpacePressed: activate()
            }
        }
    }
}
