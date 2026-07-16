import QtQuick
import QtQuick.Controls
import MeoUI

Rectangle {
    id: control

    // 🌟 核心属性
    property bool isOpen: false
    property string title: ""
    property Component content: null
    property bool showCloseButton: true

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainerLow: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainerLow !== 'undefined') ? MeoTheme.surfaceContainerLow : "#F7F2FA"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontTitleLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleLarge !== 'undefined') ? MeoTheme.titleLarge : { "size": 22, "weight": Font.Normal }

    width: 360 * themeGlobalScale
    height: parent ? parent.height : 600 * themeGlobalScale
    x: parent ? (isOpen ? parent.width - width : parent.width) : 0
    color: themeSurfaceContainerLow

    // MD3 Standard Side Sheet: 0dp radius or slightly rounded?
    // Usually Standard Side Sheets are not rounded on the edge they attach to.

    border.width: 1
    border.color: Qt.rgba(MeoTheme.outline.r, MeoTheme.outline.g, MeoTheme.outline.b, 0.22)

    Behavior on x { NumberAnimation { duration: control.isOpen ? MeoTheme.motionDurationSheetEnter : MeoTheme.motionDurationSheetExit; easing.bezierCurve: control.isOpen ? MeoTheme.motionEasingEmphasizedDecelerate : MeoTheme.motionEasingEmphasizedAccelerate } }

    Column {
        anchors.fill: parent

        // Header
        Item {
            width: parent.width
            height: 64 * control.themeGlobalScale
            visible: control.title !== "" || control.showCloseButton

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16 * control.themeGlobalScale
                anchors.rightMargin: 16 * control.themeGlobalScale
                spacing: 12 * control.themeGlobalScale

                Text {
                    text: control.title
                    visible: text !== ""
                    font.pixelSize: fontTitleLarge.size * control.themeGlobalScale
                    font.weight: fontTitleLarge.weight
                    color: control.themeOnSurface
                    verticalAlignment: Text.AlignVCenter
                    anchors.verticalCenter: parent.verticalCenter
                    width: parent.width - (control.showCloseButton ? 48 * control.themeGlobalScale : 0)
                    elide: Text.ElideRight
                }

                MeoIconButton {
                    icon.name: "close"
                    visible: control.showCloseButton
                    anchors.verticalCenter: parent.verticalCenter
                    onClicked: control.isOpen = false
                }
            }
        }

        Loader {
            id: contentLoader
            width: parent.width
            height: parent.height - (control.title !== "" || control.showCloseButton ? 64 * control.themeGlobalScale : 0)
            sourceComponent: control.content
        }
    }
}
