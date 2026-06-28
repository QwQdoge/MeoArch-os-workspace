import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    id: control
    contentWidth: width
    contentHeight: contentColumn.implicitHeight + padding * 2

    property string title: "Settings"
    property alias model: repeater.model
    property real padding: 16 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property var fontTitleLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleLarge !== 'undefined') ? MeoTheme.titleLarge : { "size": 22, "weight": Font.Normal }

    Column {
        id: contentColumn
        width: parent.width - control.padding * 2
        x: control.padding
        y: control.padding
        spacing: 0

        Text {
            text: control.title
            font.pixelSize: fontTitleLarge.size * control.themeGlobalScale
            font.weight: fontTitleLarge.weight
            color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
            bottomPadding: 16 * control.themeGlobalScale
        }

        Repeater {
            id: repeater
            delegate: Column {
                width: parent.width

                MeoListHeader {
                    text: modelData.sectionTitle
                    visible: text !== ""
                    type: "emphasized"
                    topPadding: 16 * control.themeGlobalScale
                    bottomPadding: 8 * control.themeGlobalScale
                }

                Repeater {
                    model: modelData.items
                    delegate: MeoListItem {
                        width: parent.width
                        headline: modelData.title
                        supportingText: modelData.subtitle || ""
                        leadingIcon: modelData.icon || ""
                        trailingComponent: modelData.type === "switch" ? switchComp : (modelData.type === "chevron" ? chevronComp : null)

                        Component { id: switchComp; MeoSwitch { checked: modelData.checked; onToggled: modelData.checked = checked } }
                        Component { id: chevronComp; MeoIcon { icon: "chevron_right"; size: 24; color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F" } }

                        onClicked: if (modelData.action) modelData.action()
                    }
                }

                MeoDivider {
                    visible: index < repeater.count - 1
                    topPadding: 8 * control.themeGlobalScale
                    bottomPadding: 8 * control.themeGlobalScale
                }
            }
        }
    }
}
