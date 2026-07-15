import QtQuick
import QtQuick.Controls

Popup {
    id: control

    // 🌟 核心属性
    property string message: ""
    property string actionText: ""
    signal actionClicked()

    // 🌟 作用域与主题安全防御
    readonly property color themeInverseSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined' && MeoTheme.isDarkMode) ? "#E6E1E5" : "#313033"
    readonly property color themeInverseOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined' && MeoTheme.isDarkMode) ? "#313033" : "#F4F0F4"
    readonly property color themeInversePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? (MeoTheme.isDarkMode ? MeoTheme.primary : "#D0BCFF") : "#D0BCFF"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int motionEnter: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationMedium1 !== 'undefined') ? MeoTheme.motionDurationMedium1 : 250
    readonly property int motionExit: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationShort4 !== 'undefined') ? MeoTheme.motionDurationShort4 : 200
    readonly property int autoDismissDuration: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationExtraLong4 !== 'undefined') ? MeoTheme.motionDurationExtraLong4 * 4 : 4000
    readonly property var fontBodyMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyMedium !== 'undefined') ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal }
    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }

    x: (parent.width - width) / 2
    y: parent.height - height - 24 * themeGlobalScale
    width: Math.min(parent.width - 48 * themeGlobalScale, 400 * themeGlobalScale)

    closePolicy: Popup.NoAutoClose

    background: Rectangle {
        color: control.themeInverseSurface
        radius: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.shapeExtraSmall !== 'undefined') ? MeoTheme.shapeExtraSmall : 4 * control.themeGlobalScale
    }

    contentItem: Row {
        padding: 12 * control.themeGlobalScale
        spacing: 16 * control.themeGlobalScale

        Text {
            text: control.message
            width: parent.width - (control.actionText !== "" ? 80 * control.themeGlobalScale : 0) - 24 * control.themeGlobalScale
            font.pixelSize: control.fontBodyMedium.size * control.themeGlobalScale
            font.weight: control.fontBodyMedium.weight
            color: control.themeInverseOnSurface
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
        }

        MeoButton {
            text: control.actionText
            type: "text"
            visible: text !== ""
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                control.actionClicked()
                control.close()
            }
            // Overriding button color to MD3 Inverse Primary
            contentItem: Text {
                text: parent.text
                color: control.themeInversePrimary
                font.pixelSize: control.fontLabelLarge.size * control.themeGlobalScale
                font.weight: control.fontLabelLarge.weight
            }
        }
    }

    Timer {
        id: autoCloseTimer
        interval: control.autoDismissDuration
        onTriggered: control.close()
    }

    onOpened: autoCloseTimer.start()

    enter: Transition {
        NumberAnimation { property: "y"; from: parent.height; to: control.y; duration: control.motionEnter; easing.type: Easing.OutCubic }
        NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: control.motionEnter }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: control.motionExit }
    }
}
