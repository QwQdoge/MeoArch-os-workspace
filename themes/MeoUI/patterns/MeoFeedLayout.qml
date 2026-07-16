import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Flickable {
    id: control
    contentWidth: width
    contentHeight: feedGrid.implicitHeight + padding * 2
    clip: true

    property var model: []
    property Component delegate: null
    property real padding: 16 * themeGlobalScale
    property real spacing: 16 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int effectiveColumns: windowMetrics.isCompactWidth ? 1 : 2

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.width
        availableHeight: control.height
        maxColumns: 2
    }

    GridLayout {
        id: feedGrid
        x: control.padding
        y: control.padding
        width: parent.width - control.padding * 2
        columns: control.effectiveColumns
        rowSpacing: control.spacing
        columnSpacing: control.spacing

        Repeater {
            model: control.model
            delegate: Loader {
                Layout.fillWidth: true
                sourceComponent: control.delegate
                property var modelData: model
            }
        }
    }
}
