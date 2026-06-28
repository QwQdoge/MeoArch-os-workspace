import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Flickable {
    id: control
    contentWidth: width
    contentHeight: Math.max(leftColumn.implicitHeight, rightColumn.implicitHeight) + padding * 2
    clip: true

    property var model: []
    property Component delegate: null
    property real padding: 16 * themeGlobalScale
    property real spacing: 16 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    // Extremely simple masonry-like feed (staggered 2 columns)
    Row {
        x: control.padding
        y: control.padding
        width: parent.width - control.padding * 2
        spacing: control.spacing

        Column {
            id: leftColumn
            width: (parent.width - control.spacing) / 2
            spacing: control.spacing
            Repeater {
                model: control.model
                delegate: Loader {
                    width: parent.width
                    sourceComponent: index % 2 === 0 ? control.delegate : null
                    property var modelData: model
                }
            }
        }

        Column {
            id: rightColumn
            width: (parent.width - control.spacing) / 2
            spacing: control.spacing
            Repeater {
                model: control.model
                delegate: Loader {
                    width: parent.width
                    sourceComponent: index % 2 !== 0 ? control.delegate : null
                    property var modelData: model
                }
            }
        }
    }
}
