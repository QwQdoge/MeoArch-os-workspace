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

    // Adaptive Columns
    readonly property bool isCompact: width < 600 * themeGlobalScale
    readonly property bool isMedium: width >= 600 * themeGlobalScale && width < 840 * themeGlobalScale

    onWidthChanged: {
        if (isCompact) columns = 1
        else if (isMedium) columns = 2
        else columns = 3
    }

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    GridLayout {
        id: grid
        x: control.padding
        y: control.padding
        width: parent.width - control.padding * 2
        columns: control.columns
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
