import QtQuick
import QtQuick.Controls

Control {
    id: control

    // 🌟 核心属性
    // type: "assist" | "filter" | "input" | "suggestion"
    property string type: "assist"
    property string label: ""
    property string icon: ""
    property bool selected: false
    property bool closable: false
    property bool isEmphasized: false // MD3 Expressive: Use bold typography

    signal clicked()
    signal closed()

    // 🌟 作用域与主题安全防御
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitHeight: 32 * themeGlobalScale
    implicitWidth: contentRow.implicitWidth + padding * 2

    padding: 8 * themeGlobalScale

    background: Rectangle {
        radius: 8 * themeGlobalScale
        color: control.selected ? control.themeSecondaryContainer : "transparent"
        border.color: {
            if (control.selected) return "transparent"
            if (!control.enabled) return Qt.rgba(control.themeOutline.r, control.themeOutline.g, control.themeOutline.b, 0.12)
            if (control.activeFocus) return control.themePrimary
            return control.themeOutline
        }
        border.width: (control.activeFocus && !control.selected) ? 2 * themeGlobalScale : 1 * themeGlobalScale

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: control.clicked()
        }

        // 🌟 状态层
        Rectangle {
            anchors.fill: parent
            radius: parent.radius
            color: {
                let overlay = control.themeOnSurface
                if (mouseArea.pressed) return Qt.rgba(overlay.r, overlay.g, overlay.b, 0.12)
                if (mouseArea.containsMouse) return Qt.rgba(overlay.r, overlay.g, overlay.b, 0.08)
                return "transparent"
            }
            Behavior on color { ColorAnimation { duration: 150 } }
        }

        Behavior on color { ColorAnimation { duration: 150 } }
    }

    contentItem: Row {
        id: contentRow
        spacing: 8 * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter

        MeoIcon {
            icon: control.icon
            visible: icon !== ""
            size: 18
            color: control.selected ? control.themePrimary : control.themeOnSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: control.label
            font.pixelSize: 14 * control.themeGlobalScale
            font.weight: {
                if (control.selected) return Font.Medium;
                if (control.isEmphasized) return Font.DemiBold;
                return Font.Normal;
            }
            color: control.selected ? control.themePrimary : control.themeOnSurfaceVariant
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: "×"
            visible: control.closable
            font.pixelSize: 18 * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
            verticalAlignment: Text.AlignVCenter

            MouseArea {
                anchors.fill: parent
                onClicked: control.closed()
            }
        }
    }
}
