import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control
    anchors.fill: parent

    property Component listComponent: null
    property Component detailComponent: null
    property bool isWide: width > 600 * themeGlobalScale

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    Row {
        anchors.fill: parent
        visible: control.isWide

        Loader {
            width: 360 * control.themeGlobalScale
            height: parent.height
            sourceComponent: control.listComponent
        }

        MeoDivider {
            height: parent.height
            width: 1
        }

        Loader {
            width: parent.width - 361 * control.themeGlobalScale
            height: parent.height
            sourceComponent: control.detailComponent
        }
    }

    StackView {
        id: stackView
        anchors.fill: parent
        visible: !control.isWide
        initialItem: control.listComponent
    }

    // Logic to handle navigation on narrow screens could be added here
}
