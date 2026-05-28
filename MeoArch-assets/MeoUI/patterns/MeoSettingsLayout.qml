import QtQuick
import QtQuick.Controls
import MeoUI

ScrollView {
    id: control
    anchors.fill: parent
    clip: true

    property var sections: [] // [{ title: "", items: [{ type: "switch", label: "", value: true, onToggled: function }, { type: "navigation", label: "", subLabel: "", onClicked: function }] }]

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    Column {
        width: control.width
        spacing: 0

        Repeater {
            model: control.sections
            delegate: Column {
                width: parent.width

                // Section Title
                Text {
                    text: modelData.title
                    visible: text !== ""
                    font.pixelSize: 14 * control.themeGlobalScale
                    font.weight: Font.Medium
                    color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
                    padding: 16 * control.themeGlobalScale
                    bottomPadding: 8 * control.themeGlobalScale
                }

                Repeater {
                    model: modelData.items
                    delegate: MeoListItem {
                        width: parent.width
                        headline: modelData.label
                        supportingText: modelData.subLabel || ""
                        leadingIcon: modelData.icon || ""
                        trailingComponent: {
                            if (modelData.type === "switch") return switchComp
                            if (modelData.type === "navigation") return arrowComp
                            return null
                        }
                        interactive: modelData.type !== "switch"
                        onClicked: if (modelData.onClicked) modelData.onClicked()

                        Component {
                            id: switchComp
                            MeoSwitch {
                                checked: modelData.value
                                onToggled: if (modelData.onToggled) modelData.onToggled(checked)
                            }
                        }

                        Component {
                            id: arrowComp
                            MeoIcon {
                                icon: "chevron_right"
                                size: 24
                                color: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
                            }
                        }
                    }
                }

                MeoDivider {
                    width: parent.width
                    visible: index < control.sections.length - 1
                }
            }
        }
    }
}
