import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心属性
    property var model: [] // [{ label: "", icon: "", action: function }]
    property int orientation: Qt.Horizontal // Qt.Horizontal | Qt.Vertical
    property string type: "outlined" // "outlined" | "tonal" | "filled" | "elevated"

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"

    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    contentItem: ListView {
        id: layout
        orientation: control.orientation === Qt.Horizontal ? ListView.Horizontal : ListView.Vertical
        model: control.model
        interactive: false
        spacing: 0

        implicitWidth: control.orientation === Qt.Horizontal ? (contentItem.children.length * 80 * themeGlobalScale) : 120 * themeGlobalScale
        implicitHeight: control.orientation === Qt.Vertical ? (contentItem.children.length * 40 * themeGlobalScale) : 40 * themeGlobalScale

        delegate: MeoButton {
            id: btn
            text: modelData.label
            icon.name: modelData.icon || ""
            type: control.type
            width: control.orientation === Qt.Horizontal ? undefined : layout.width

            // 📐 MD3 Expressive: Custom radii for grouped buttons
            background: Rectangle {
                radius: 20 * themeGlobalScale
                color: btn.bgColor
                border.color: (control.type === "outlined") ? themeOutline : "transparent"
                border.width: (control.type === "outlined") ? 1 : 0

                // Overlays to square off internal corners
                Rectangle {
                    anchors.fill: parent
                    radius: 0
                    color: parent.color
                    visible: false // Logic below
                }

                // Top-left/Bottom-left for first item, etc.
                // In QML, Rectangle doesn't support individual corner radius easily.
                // We use the same technique as DateRangePicker: overlaying square rectangles.

                // Square off Right side if NOT the last item (Horizontal)
                Rectangle {
                    visible: control.orientation === Qt.Horizontal && index < control.model.length - 1
                    width: parent.radius
                    height: parent.height
                    anchors.right: parent.right
                    color: parent.color
                }

                // Square off Left side if NOT the first item (Horizontal)
                Rectangle {
                    visible: control.orientation === Qt.Horizontal && index > 0
                    width: parent.radius
                    height: parent.height
                    anchors.left: parent.left
                    color: parent.color
                }

                // Square off Bottom side if NOT the last item (Vertical)
                Rectangle {
                    visible: control.orientation === Qt.Vertical && index < control.model.length - 1
                    width: parent.width
                    height: parent.radius
                    anchors.bottom: parent.bottom
                    color: parent.color
                }

                // Square off Top side if NOT the first item (Vertical)
                Rectangle {
                    visible: control.orientation === Qt.Vertical && index > 0
                    width: parent.width
                    height: parent.radius
                    anchors.top: parent.top
                    color: parent.color
                }

                // Internal Dividers
                Rectangle {
                    visible: index < control.model.length - 1
                    width: control.orientation === Qt.Horizontal ? 1 : parent.width
                    height: control.orientation === Qt.Vertical ? 1 : parent.height
                    anchors.right: control.orientation === Qt.Horizontal ? parent.right : undefined
                    anchors.bottom: control.orientation === Qt.Vertical ? parent.bottom : undefined
                    color: Qt.rgba(btn.textColor.r, btn.textColor.g, btn.textColor.b, 0.12)
                }

                MeoStateLayer {
                    radius: parent.radius
                    pressed: btn.pressed
                    hovered: btn.hovered
                    color: btn.textColor
                }
            }

            onClicked: {
                if (modelData.action) modelData.action()
            }
        }
    }
}
