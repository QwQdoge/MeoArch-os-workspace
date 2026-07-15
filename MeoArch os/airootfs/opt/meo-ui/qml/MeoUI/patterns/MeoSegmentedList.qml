import QtQuick
import QtQuick.Controls
import MeoUI

Column {
    id: control

    // 🌟 核心属性
    property string title: ""
    property var model: []
    property Component delegate: null
    property bool isSegmented: true
    property real itemSpacing: 2 * themeGlobalScale

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property var fontTitleSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleSmall !== 'undefined') ? MeoTheme.titleSmall : { "size": 14, "weight": Font.Medium }

    width: parent ? parent.width : 360 * themeGlobalScale
    spacing: 0

    // Header Title for the list group
    MeoText {
        text: control.title
        visible: text !== ""
        typeRole: "label"
        typeSize: "large"
        emphasized: true
        color: control.themeOnSurface
        leftPadding: 16 * control.themeGlobalScale
        bottomPadding: 8 * control.themeGlobalScale
    }

    Column {
        id: itemsColumn
        width: parent.width
        spacing: control.itemSpacing

        Repeater {
            model: control.model
            delegate: Loader {
                id: itemLoader
                width: itemsColumn.width
                sourceComponent: control.delegate

                // Pass roundingStrategy to the delegate if it's a MeoListItem or supports it
                onLoaded: {
                    if (item && item.hasOwnProperty("roundingStrategy")) {
                        if (control.model.length === 1) {
                            item.roundingStrategy = "all";
                        } else if (index === 0) {
                            item.roundingStrategy = "top";
                        } else if (index === control.model.length - 1) {
                            item.roundingStrategy = "bottom";
                        } else {
                            item.roundingStrategy = "middle";
                        }

                        if (item.hasOwnProperty("isSegmented")) {
                            item.isSegmented = control.isSegmented;
                        }
                    }
                }
            }
        }
    }
}
