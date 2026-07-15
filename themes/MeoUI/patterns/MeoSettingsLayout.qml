import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    id: control
    contentWidth: width
    contentHeight: contentColumn.implicitHeight + padding * 2

    property string title: "Settings"
    property alias model: repeater.model
    property real padding: windowMetrics.pageMargin

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property var fontTitleLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleLarge !== 'undefined') ? MeoTheme.titleLarge : { "size": 22, "weight": Font.Normal }

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.width
        availableHeight: control.height
    }

    Column {
        id: contentColumn
        width: Math.min(parent.width - control.padding * 2, windowMetrics.maximumContentWidth)
        anchors.horizontalCenter: parent.horizontalCenter
        y: control.padding
        spacing: 0

        Text {
            text: control.title
            font.pixelSize: fontTitleLarge.size * control.themeGlobalScale
            font.weight: fontTitleLarge.weight
            color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
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
                        Component { id: chevronComp; MeoIcon { icon: "chevron_right"; size: 24; color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F" } }

                        onClicked: if (modelData.action) modelData.action()
                    }
                }

                Item {
                    width: parent.width
                    height: 17 * control.themeGlobalScale
                    visible: index < repeater.count - 1

                    MeoDivider {
                        width: parent.width
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
            }
        }
    }
}
