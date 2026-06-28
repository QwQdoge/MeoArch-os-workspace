import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心对外属性
    // model: [{ label: "suggestion", icon: "history", isHistory: true, ... }]
    property var model: []
    property string highlightText: "" // Text to highlight in bold within the label

    signal selected(int index, var data)
    signal removed(int index, var data)

    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: Math.min(400 * themeGlobalScale, contentColumn.implicitHeight)

    contentItem: Column {
        id: contentColumn
        spacing: 0
        width: parent.width

        Repeater {
            model: control.model
            delegate: MeoListItem {
                width: parent.width
                implicitHeight: 48 * control.themeGlobalScale
                interactive: true

                leadingIcon: modelData.icon || (modelData.isHistory ? "history" : "search")

                // Custom headline with highlighting logic
                headline: ""
                leadingComponent: null // Already handled by leadingIcon

                contentItem: Row {
                    spacing: 16 * control.themeGlobalScale
                    width: parent.width

                    // Leading Icon handled by MeoListItem logic (mostly)
                    // But we want to override the text rendering to support highlighting

                    Text {
                        width: parent.width - (modelData.isHistory ? 40 * control.themeGlobalScale : 0)
                        anchors.verticalCenter: parent.verticalCenter
                        textFormat: Text.StyledText
                        text: {
                            let label = modelData.label || "";
                            if (control.highlightText !== "" && label.toLowerCase().includes(control.highlightText.toLowerCase())) {
                                let regex = new RegExp("(" + control.highlightText + ")", "gi");
                                return label.replace(regex, "<b>$1</b>");
                            }
                            return label;
                        }
                        font.pixelSize: 16 * control.themeGlobalScale
                        color: control.themeOnSurface
                        elide: Text.ElideRight
                    }
                }

                trailingComponent: modelData.isHistory ? removeButtonComp : arrowButtonComp

                Component {
                    id: removeButtonComp
                    MeoIconButton {
                        icon.name: "close"
                        width: 40 * control.themeGlobalScale
                        height: 40 * control.themeGlobalScale
                        type: "standard"
                        onClicked: control.removed(index, modelData)
                    }
                }

                Component {
                    id: arrowButtonComp
                    MeoIcon {
                        icon: "north_west" // MD3 standard for "use this suggestion"
                        size: 20
                        color: control.themeOnSurfaceVariant
                        anchors.centerIn: parent
                    }
                }

                onClicked: control.selected(index, modelData)
            }
        }
    }
}
