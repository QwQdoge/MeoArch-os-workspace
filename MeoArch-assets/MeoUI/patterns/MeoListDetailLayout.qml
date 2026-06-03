import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control
    anchors.fill: parent

    property Component listComponent: null
    property Component detailComponent: null
    property bool showDetail: false

    // MD3 Adaptive Breakpoints
    readonly property bool isCompact: width < 600 * themeGlobalScale
    readonly property bool isMedium: width >= 600 * themeGlobalScale && width < 840 * themeGlobalScale
    readonly property bool isExpanded: width >= 840 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property real paneWidth: {
        if (isExpanded) return 400 * themeGlobalScale
        if (isMedium) return 320 * themeGlobalScale
        return width
    }

    Row {
        anchors.fill: parent
        visible: !control.isCompact

        Loader {
            width: control.paneWidth
            height: parent.height
            sourceComponent: control.listComponent
        }

        MeoDivider {
            height: parent.height
            width: 1
            visible: !control.isCompact
        }

        Loader {
            width: parent.width - control.paneWidth - (control.isCompact ? 0 : 1)
            height: parent.height
            sourceComponent: control.detailComponent
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        visible: control.isCompact

        initialItem: control.listComponent

        onCurrentItemChanged: {
            // Logic to sync with showDetail if needed
        }
    }

    onShowDetailChanged: {
        if (isCompact) {
            if (showDetail) stackView.push(detailComponent)
            else stackView.pop()
        }
    }
}
