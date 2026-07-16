import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Flickable {
    id: control
    contentWidth: width
    contentHeight: grid.implicitHeight + padding * 2
    clip: true

    property var model: []
    property Component delegate: null
    property real padding: 24 * themeGlobalScale
    property real spacing: 24 * themeGlobalScale
    property int columns: 3 // Default for expanded
    property bool adaptive: true

    // Adaptive Columns
    readonly property bool isCompact: windowMetrics.isCompactWidth
    readonly property bool isMedium: windowMetrics.isMediumWidth
    readonly property bool isExpanded: windowMetrics.isExpandedWidth || windowMetrics.isLargeWidth || windowMetrics.isExtraLargeWidth
    readonly property int effectiveColumns: adaptive ? windowMetrics.preferredColumns : Math.max(1, columns)

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.width
        availableHeight: control.height
        maxColumns: control.columns
    }

    GridLayout {
        id: grid
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
