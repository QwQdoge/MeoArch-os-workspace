import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property string label: ""
    property string icon: ""
    property string badgeText: ""
    property bool badgeDot: false
    property bool selected: false
    property string mode: "drawer" // "drawer" | "group"
    property bool roundedTop: true
    property bool roundedBottom: true
    property bool showDivider: false
    property string supportingText: ""

    signal clicked()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeSurfaceContainerLowest: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLowest !== 'undefined') ? MeoTheme.surfaceContainerLowest : "#FFFFFF"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property color themeOnSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSecondaryContainer !== 'undefined') ? MeoTheme.contentOnSecondaryContainer : "#1D192B"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }
    readonly property var fontBodyLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyLarge !== 'undefined') ? MeoTheme.bodyLarge : { "size": 16, "weight": Font.Normal, "lineHeight": 24, "letterSpacing": 0.5 }
    readonly property var fontBodyMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyMedium !== 'undefined') ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal, "lineHeight": 20, "letterSpacing": 0.25 }
    readonly property int animationDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationMedium2 !== 'undefined') ? MeoTheme.motionDurationMedium2 : 300
    readonly property var emphasizedCurve: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionEasingEmphasized !== 'undefined') ? MeoTheme.motionEasingEmphasized : [0.05, 0.7, 0.1, 1]

    implicitWidth: 336 * themeGlobalScale
    implicitHeight: (mode === "group" && supportingText !== "" ? 72 : 56) * themeGlobalScale

    background: Item {
        Rectangle {
            id: groupSurface
            anchors.fill: parent
            visible: control.mode === "group"
            color: control.themeSurfaceContainerLowest
            radius: 24 * control.themeGlobalScale

            Rectangle { visible: !control.roundedTop; anchors.top: parent.top; anchors.left: parent.left; anchors.right: parent.right; height: parent.radius; color: parent.color }
            Rectangle { visible: !control.roundedBottom; anchors.bottom: parent.bottom; anchors.left: parent.left; anchors.right: parent.right; height: parent.radius; color: parent.color }
        }

        Rectangle {
            id: selectedLayer
            anchors.verticalCenter: parent.verticalCenter
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: control.mode === "group" ? 8 * control.themeGlobalScale : 0
            anchors.rightMargin: control.mode === "group" ? 8 * control.themeGlobalScale : 0
            height: control.mode === "group" ? 48 * control.themeGlobalScale : 56 * control.themeGlobalScale
            radius: height / 2
            color: control.selected ? control.themeSecondaryContainer : "transparent"
            clip: true

            MeoStateLayer {
                radius: selectedLayer.radius
                shape: "pill"
                pressed: mouseArea.pressed
                hovered: mouseArea.containsMouse
                pressX: mouseArea.mouseX - selectedLayer.x
                pressY: mouseArea.mouseY - selectedLayer.y
                color: control.selected ? control.themeOnSecondaryContainer : control.themeOnSurface
            }

            Behavior on color { ColorAnimation { duration: control.animationDuration; easing.bezierCurve: control.emphasizedCurve } }
            Behavior on height { NumberAnimation { duration: control.animationDuration; easing.bezierCurve: control.emphasizedCurve } }
            Behavior on anchors.leftMargin { NumberAnimation { duration: control.animationDuration; easing.bezierCurve: control.emphasizedCurve } }
            Behavior on anchors.rightMargin { NumberAnimation { duration: control.animationDuration; easing.bezierCurve: control.emphasizedCurve } }
        }

        Rectangle {
            visible: control.mode === "group" && control.showDivider
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.leftMargin: 72 * control.themeGlobalScale
            height: Math.max(1, 1 * control.themeGlobalScale)
            color: control.themeOutlineVariant
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
        anchors.leftMargin: control.mode === "group" ? 32 * control.themeGlobalScale : 24 * control.themeGlobalScale
        anchors.rightMargin: control.mode === "group" ? 24 * control.themeGlobalScale : 24 * control.themeGlobalScale
        spacing: 16 * control.themeGlobalScale

        MeoIcon {
            icon: control.icon
            fill: control.selected
            size: 24
            color: control.selected ? control.themeOnSecondaryContainer : control.themeOnSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }

        Column {
            width: parent.width - (control.icon !== "" ? 40 * control.themeGlobalScale : 0) - (control.badgeText !== "" ? badge.implicitWidth + 16 * control.themeGlobalScale : 0)
            spacing: 0
            anchors.verticalCenter: parent.verticalCenter

            Text {
                text: control.label
                width: parent.width
                font.family: (typeof MeoTheme !== 'undefined' && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: (control.mode === "group" ? fontBodyLarge.size : fontLabelLarge.size) * control.themeGlobalScale
                font.weight: control.mode === "group" ? fontBodyLarge.weight : (control.selected ? Font.DemiBold : fontLabelLarge.weight)
                lineHeightMode: Text.FixedHeight
                lineHeight: (control.mode === "group" ? fontBodyLarge.lineHeight : 20) * control.themeGlobalScale
                font.letterSpacing: ((control.mode === "group" ? fontBodyLarge.letterSpacing : fontLabelLarge.letterSpacing) || 0) * control.themeGlobalScale
                color: control.selected ? control.themeOnSecondaryContainer : (control.mode === "group" ? control.themeOnSurface : control.themeOnSurfaceVariant)
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                Behavior on color {
                    ColorAnimation {
                        duration: MeoTheme.motionDurationState
                        easing.bezierCurve: control.selected ? MeoTheme.motionEasingEnter : MeoTheme.motionEasingExit
                    }
                }
            }

            Text {
                text: control.supportingText
                width: parent.width
                visible: text !== ""
                font.family: (typeof MeoTheme !== 'undefined' && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                font.pixelSize: fontBodyMedium.size * control.themeGlobalScale
                font.weight: fontBodyMedium.weight
                lineHeightMode: Text.FixedHeight
                lineHeight: fontBodyMedium.lineHeight * control.themeGlobalScale
                verticalAlignment: Text.AlignVCenter
                font.letterSpacing: (fontBodyMedium.letterSpacing || 0) * control.themeGlobalScale
                color: control.themeOnSurfaceVariant
                elide: Text.ElideRight
            }
        }

        MeoBadge {
            id: badge
            text: control.badgeText
            isDot: control.badgeDot
            visible: text !== "" || isDot
            anchors.verticalCenter: parent.verticalCenter
        }
    }
}
