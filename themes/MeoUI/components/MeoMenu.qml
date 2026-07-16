import QtQuick
import QtQuick.Controls
import QtQuick.Effects
import MeoUI

MeoMotionPopup {
    id: control
    presentation: MeoMotionPopup.Menu

    // 🌟 核心属性
    property var model: [] // [{ label/text, icon, trailingText, trailingIcon, type, enabled, action, subItems, isVibrant }]
    property bool vibrant: false // Global vibrant style for the entire menu
    property real itemSpacing: 0 // MD3 Expressive: Support for item gaps
    property real menuPadding: 8 * themeGlobalScale

    // 🌟 作用域与主题安全防御
    readonly property color themeSurfaceContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surfaceContainer !== 'undefined') ? MeoTheme.surfaceContainer : "#F3EDF7"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#CAC4D0"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int motionFast: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationFast !== 'undefined') ? MeoTheme.motionDurationFast : 150
    readonly property int motionMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.motionDurationMedium !== 'undefined') ? MeoTheme.motionDurationMedium : 300

    function itemLabel(item) {
        return item.label || item.text || ""
    }

    function itemEnabled(item) {
        return item.enabled === undefined ? true : item.enabled
    }

    function itemHasSubmenu(item) {
        return item.subItems !== undefined && item.subItems && item.subItems.length > 0
    }

    function openAt(anchor, offsetX, offsetY) {
        if (anchor) {
            var point = anchor.mapToItem(control.parent, offsetX || 0, offsetY || 0)
            control.x = point.x
            control.y = point.y
        }
        control.open()
    }

    padding: 0 // MD3: Menu content starts immediately

    background: Rectangle {
        id: bgRect
        color: control.vibrant ? control.themePrimaryContainer : control.themeSurfaceContainer
        radius: (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeMedium : 12 * control.themeGlobalScale)

        // MD3 Elevation Level 2
        layer.enabled: control.visible
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowBlur: 0.2
            shadowVerticalOffset: 2 * control.themeGlobalScale
            shadowColor: Qt.rgba(0,0,0,0.2)
        }
    }

    contentItem: Column {
        id: contentColumn
        spacing: control.itemSpacing
        topPadding: control.menuPadding
        bottomPadding: control.menuPadding

        Repeater {
            model: control.model
            delegate: Loader {
                width: contentColumn.width
                sourceComponent: modelData.type === "separator" ? separatorComponent : itemComponent

                Component {
                    id: separatorComponent
                    Item {
                        width: contentColumn.width
                        height: Math.max(1 * control.themeGlobalScale, 8 * control.themeGlobalScale)

                        MeoDivider {
                            anchors.left: parent.left
                            anchors.right: parent.right
                            anchors.verticalCenter: parent.verticalCenter
                            color: control.themeOutlineVariant
                        }
                    }
                }

                Component {
                    id: itemComponent
                    MeoListItem {
                        width: Math.max(112 * control.themeGlobalScale, Math.min(280 * control.themeGlobalScale, contentColumn.width))
                        implicitWidth: width
                        headline: control.itemLabel(modelData)
                        leadingIcon: modelData.icon || ""
                        padding: 12 * control.themeGlobalScale
                        implicitHeight: 48 * control.themeGlobalScale
                        enabled: control.itemEnabled(modelData)
                        interactive: enabled
                        opacity: enabled ? 1.0 : 0.38
                        selected: control.vibrant || modelData.isVibrant || false
                        isSegmented: control.itemSpacing > 0
                        trailingComponent: Component {
                            Row {
                                spacing: 8 * control.themeGlobalScale
                                visible: (modelData.trailingText || modelData.trailingIcon || control.itemHasSubmenu(modelData))

                                MeoText {
                                    text: modelData.trailingText || ""
                                    visible: text !== ""
                                    typeRole: "label"
                                    typeSize: "small"
                                    color: control.themeOnSurfaceVariant
                                    anchors.verticalCenter: parent.verticalCenter
                                }

                                MeoIcon {
                                    icon: control.itemHasSubmenu(modelData) ? "chevron_right" : (modelData.trailingIcon || "")
                                    visible: icon !== ""
                                    size: 20
                                    color: control.themeOnSurfaceVariant
                                    anchors.verticalCenter: parent.verticalCenter
                                }
                            }
                        }

                        onClicked: {
                            if (!enabled)
                                return
                            if (modelData.action)
                                modelData.action()
                            if (!control.itemHasSubmenu(modelData))
                                control.close()
                        }
                    }
                }
            }
        }
    }

}
