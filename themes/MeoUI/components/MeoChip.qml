import QtQuick
import QtQuick.Controls

Control {
    id: control

    // 🌟 核心属性
    // type: "assist" | "filter" | "input" | "suggestion"
    property string type: "assist"
    property string label: ""
    property string icon: ""
    property string size: "m" // 🌟 MD3 Expressive: "xs" | "s" | "m" | "l" | "xl"
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
    readonly property var fontToken: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        let token;
        if (size === "xs") token = MeoTheme.labelSmall;
        else if (size === "s") token = MeoTheme.labelMedium;
        else if (size === "l") token = MeoTheme.titleSmall;
        else if (size === "xl") token = MeoTheme.titleMedium;
        else token = MeoTheme.labelLarge;

        if (isEmphasized) {
            if (size === "xs") return MeoTheme.labelSmallEmphasized || token;
            if (size === "s") return MeoTheme.labelMediumEmphasized || token;
            if (size === "l") return MeoTheme.titleSmallEmphasized || token;
            if (size === "xl") return MeoTheme.titleMediumEmphasized || token;
            return MeoTheme.labelLargeEmphasized || token;
        }
        return token;
    }

    implicitHeight: {
        if (size === "xs") return 24 * themeGlobalScale;
        if (size === "s") return 28 * themeGlobalScale;
        if (size === "m") return 32 * themeGlobalScale;
        if (size === "l") return 40 * themeGlobalScale;
        if (size === "xl") return 48 * themeGlobalScale;
        return 32 * themeGlobalScale;
    }
    implicitWidth: contentRow.implicitWidth + leftPadding + rightPadding

    padding: 0
    leftPadding: (icon !== "" ? 8 : (size === "xl" ? 24 : 16)) * themeGlobalScale
    rightPadding: (closable ? 8 : (size === "xl" ? 24 : 16)) * themeGlobalScale

    background: Rectangle {
        radius: (size === "xl" ? 16 : 8) * themeGlobalScale
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
        spacing: (size === "xs" ? 4 : 8) * control.themeGlobalScale
        anchors.verticalCenter: parent.verticalCenter

        MeoIcon {
            icon: control.icon
            visible: icon !== ""
            size: {
                if (size === "xs" || size === "s") return 18;
                if (size === "xl") return 32;
                return 24;
            }
            color: control.selected ? control.themePrimary : control.themeOnSurfaceVariant
            anchors.verticalCenter: parent.verticalCenter
        }

        Text {
            text: control.label
            font.pixelSize: fontToken.size * control.themeGlobalScale
            font.weight: fontToken.weight
            font.letterSpacing: (fontToken.letterSpacing || 0) * control.themeGlobalScale
            color: control.selected ? control.themePrimary : control.themeOnSurfaceVariant
            verticalAlignment: Text.AlignVCenter
        }

        Text {
            text: "×"
            visible: control.closable
            font.pixelSize: (size === "xl" ? 24 : 18) * control.themeGlobalScale
            color: control.themeOnSurfaceVariant
            verticalAlignment: Text.AlignVCenter

            MouseArea {
                anchors.fill: parent
                onClicked: control.closed()
            }
        }
    }
}
