import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心对外属性
    // model can be ["Tab 1", "Tab 2"] or [{ label: "Home", icon: "home", badgeText: "3" }, ...]
    property var model: []
    property int currentIndex: 0
    property string type: "primary" // "primary" | "secondary"
    property bool isScrollable: false

    signal clicked(int index)

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontTitleSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleSmall !== 'undefined') ? MeoTheme.titleSmall : { "size": 14, "weight": Font.Medium }

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: {
        if (type === "primary") {
            // Check if any item in model has an icon
            let hasIcon = false;
            for (let i = 0; i < model.length; i++) {
                if (typeof model[i] === 'object' && model[i].icon) {
                    hasIcon = true;
                    break;
                }
            }
            return (hasIcon ? 64 : 48) * themeGlobalScale;
        }
        return 48 * themeGlobalScale;
    }

    background: Rectangle {
        color: "transparent"
        // Secondary tabs have a full-width divider at the bottom
        Rectangle {
            anchors.bottom: parent.bottom
            width: parent.width
            height: 1 * control.themeGlobalScale
            color: control.themeOutlineVariant
            visible: control.type === "secondary"
        }
    }

    contentItem: ScrollView {
        id: scrollView
        width: control.availableWidth
        height: control.availableHeight
        contentWidth: layoutRow.implicitWidth
        ScrollBar.horizontal.policy: control.isScrollable ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
        ScrollBar.vertical.policy: ScrollBar.AlwaysOff

        Item {
            id: contentWrapper
            height: control.availableHeight
            width: layoutRow.width

            Row {
                id: layoutRow
                height: control.availableHeight
                width: control.isScrollable ? implicitWidth : control.availableWidth

                Repeater {
                    id: tabRepeater
                    model: control.model
                    delegate: Item {
                        id: tabItem
                        width: control.isScrollable ? Math.max(90 * control.themeGlobalScale, contentCol.implicitWidth + 32 * control.themeGlobalScale) : (layoutRow.width / Math.max(1, control.model.length))
                        height: layoutRow.height

                        readonly property real contentWidth: contentCol.implicitWidth
                        readonly property var itemData: modelData
                        readonly property string label: typeof itemData === 'string' ? itemData : (itemData.label || "")
                        readonly property string icon: typeof itemData === 'object' ? (itemData.icon || "") : ""
                        readonly property string badgeText: typeof itemData === 'object' ? (itemData.badgeText || "") : ""
                        readonly property bool badgeDot: typeof itemData === 'object' ? (itemData.badgeDot || false) : false
                        readonly property bool isSelected: control.currentIndex === index

                        Column {
                            id: contentCol
                            anchors.centerIn: parent
                            spacing: 4 * control.themeGlobalScale

                            Item {
                                width: 24 * control.themeGlobalScale
                                height: 24 * control.themeGlobalScale
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: icon !== ""

                                MeoIcon {
                                    anchors.centerIn: parent
                                    icon: tabItem.icon
                                    size: 24 // MeoIcon handles themeGlobalScale internally
                                    color: tabItem.isSelected ? control.themePrimary : control.themeOnSurfaceVariant
                                }

                                MeoBadge {
                                    text: tabItem.badgeText
                                    isDot: tabItem.badgeDot
                                    visible: text !== "" || isDot
                                    anchors.top: parent.top
                                    anchors.right: parent.right
                                    anchors.topMargin: -4 * control.themeGlobalScale
                                    anchors.rightMargin: -4 * control.themeGlobalScale
                                }
                            }

                            Item {
                                width: labelText.implicitWidth + (tabItem.icon === "" ? badgeStandalone.implicitWidth + 4 * control.themeGlobalScale : 0)
                                height: labelText.implicitHeight
                                anchors.horizontalCenter: parent.horizontalCenter

                                Text {
                                    id: labelText
                                    anchors.centerIn: parent
                                    text: tabItem.label
                                    font.pixelSize: control.fontTitleSmall.size * control.themeGlobalScale
                                    font.weight: tabItem.isSelected ? Font.Bold : control.fontTitleSmall.weight
                                    color: tabItem.isSelected ? control.themePrimary : control.themeOnSurfaceVariant
                                    Behavior on color { ColorAnimation { duration: 150 } }
                                }

                                MeoBadge {
                                    id: badgeStandalone
                                    text: tabItem.badgeText
                                    isDot: tabItem.badgeDot
                                    visible: (text !== "" || isDot) && tabItem.icon === ""
                                    anchors.left: labelText.right
                                    anchors.leftMargin: 4 * control.themeGlobalScale
                                    anchors.verticalCenter: labelText.top
                                    anchors.verticalCenterOffset: 4 * control.themeGlobalScale
                                }
                            }
                        }

                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            onClicked: {
                                control.currentIndex = index
                                control.clicked(index)
                            }
                        }

                        MeoStateLayer {
                            anchors.fill: parent
                            radius: 8 * control.themeGlobalScale
                            pressed: mouseArea.pressed
                            hovered: mouseArea.containsMouse
                            pressX: mouseArea.mouseX
                            pressY: mouseArea.mouseY
                            color: tabItem.isSelected ? control.themePrimary : control.themeOnSurfaceVariant
                        }
                    }
                }
            }

            // 🌟 Sliding Selection Indicator (MD3 Expressive Pattern)
            Rectangle {
                id: slidingIndicator
                anchors.bottom: parent.bottom
                height: 3 * control.themeGlobalScale
                radius: 3 * control.themeGlobalScale
                color: control.themePrimary

                readonly property Item currentItem: tabRepeater.itemAt(control.currentIndex)

                x: currentItem ? currentItem.x + (currentItem.width - width) / 2 : 0
                width: {
                    if (!currentItem) return 0;
                    if (control.type === "secondary") return currentItem.width;
                    // For primary, it wraps the content
                    return Math.max(32 * control.themeGlobalScale, currentItem.contentWidth);
                }

                Behavior on x {
                    NumberAnimation {
                        duration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationMedium1 !== "undefined") ? MeoTheme.motionDurationMedium1 : 250
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.05, 0.7, 0.1, 1.0]
                    }
                }
                Behavior on width {
                    NumberAnimation {
                        duration: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationMedium1 !== "undefined") ? MeoTheme.motionDurationMedium1 : 250
                        easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.05, 0.7, 0.1, 1.0]
                    }
                }
            }
        }
    }
}
