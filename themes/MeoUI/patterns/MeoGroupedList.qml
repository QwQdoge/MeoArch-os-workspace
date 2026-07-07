import QtQuick
import QtQuick.Controls
import MeoUI

Column {
    id: control

    property string title: ""
    property string subtitle: ""
    property var model: []
    property int selectedIndex: -1
    property bool showDividers: true
    property bool showChevron: true
    property real dividerInset: 72 * themeGlobalScale
    property real containerRadius: 24 * themeGlobalScale

    signal clicked(int index)

    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property color themeOnSurface: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== "undefined" && typeof MeoTheme.outlineVariant !== "undefined") ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property var fontTitleMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.titleMedium !== "undefined") ? MeoTheme.titleMedium : { "size": 16, "weight": Font.Medium, "lineHeight": 24, "letterSpacing": 0.15 }
    readonly property var fontBodyMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodyMedium !== "undefined") ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal, "lineHeight": 20, "letterSpacing": 0.25 }

    width: parent ? parent.width : 680 * themeGlobalScale
    spacing: 12 * themeGlobalScale

    Column {
        width: parent.width
        spacing: 2 * control.themeGlobalScale
        visible: control.title !== "" || control.subtitle !== ""

        MeoText {
            width: parent.width
            text: control.title
            typeRole: "title"
            typeSize: "small"
            emphasized: true
            visible: text !== ""
        }

        MeoText {
            width: parent.width
            text: control.subtitle
            typeRole: "body"
            typeSize: "medium"
            color: control.themeOnSurfaceVariant
            visible: text !== ""
        }
    }

    Column {
        width: parent.width
        spacing: 0

        Repeater {
            model: control.model

            delegate: MeoListItem {
                width: control.width
                headline: modelData.label || modelData.title || ""
                supportingText: modelData.supportingText || modelData.subtitle || ""
                leadingIcon: modelData.icon || ""
                badgeText: modelData.badgeText || ""
                trailingComponent: control.showChevron ? chevronComp : null

                isSegmented: true
                selected: control.selectedIndex === index
                roundingStrategy: {
                    if (control.model.length === 1) return "all";
                    if (index === 0) return "top";
                    if (index === control.model.length - 1) return "bottom";
                    return "middle";
                }

                onClicked: {
                    control.selectedIndex = index
                    control.clicked(index)
                }
            }
        }
    }

    Component {
        id: chevronComp
        MeoIcon {
            icon: "chevron_right"
            size: 24
            color: control.themeOnSurfaceVariant
        }
    }
}
