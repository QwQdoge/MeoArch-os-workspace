import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    property Component listComponent: null
    property Component detailComponent: null
    property bool showDetail: false

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property bool isCompact: windowMetrics.isCompactWidth || windowMetrics.isMediumWidth
    readonly property bool isMedium: windowMetrics.isExpandedWidth
    readonly property bool isExpanded: windowMetrics.isLargeWidth || windowMetrics.isExtraLargeWidth

    MeoWindowMetrics {
        id: windowMetrics
        availableWidth: control.width
        availableHeight: control.height
    }

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
        pushEnter: Transition { NumberAnimation { property: "x"; from: MeoTheme.reduceMotion ? 0 : stackView.width * 0.08; to: 0; duration: MeoTheme.motionDurationPage; easing.bezierCurve: MeoTheme.motionEasingEmphasizedDecelerate } }
        pushExit: Transition { NumberAnimation { property: "opacity"; from: 1; to: 0; duration: MeoTheme.motionDurationState } }
        popEnter: Transition { NumberAnimation { property: "opacity"; from: 0; to: 1; duration: MeoTheme.motionDurationState } }
        popExit: Transition { NumberAnimation { property: "x"; from: 0; to: MeoTheme.reduceMotion ? 0 : stackView.width * 0.08; duration: MeoTheme.motionDurationPage; easing.bezierCurve: MeoTheme.motionEasingEmphasizedAccelerate } }

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
