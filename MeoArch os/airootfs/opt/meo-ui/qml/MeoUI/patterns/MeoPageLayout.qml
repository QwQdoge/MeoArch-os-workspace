import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    id: control

    property string title: ""
    property string subtitle: ""
    property Component topBar: null
    property list<Component> actions
    property real compactWidth: 680 * themeGlobalScale
    property real mediumWidth: 920 * themeGlobalScale
    property real expandedWidth: 1180 * themeGlobalScale
    property real padding: (isCompact ? 16 : 24) * themeGlobalScale
    property real sectionSpacing: 24 * themeGlobalScale
    default property alias content: bodyColumn.data

    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property bool isCompact: width < 600 * themeGlobalScale
    readonly property bool isMedium: width >= 600 * themeGlobalScale && width < 840 * themeGlobalScale
    readonly property real maxContentWidth: isCompact ? compactWidth : (isMedium ? mediumWidth : expandedWidth)
    readonly property var fontPageTitle: (typeof MeoTheme !== "undefined" && typeof MeoTheme.titleBig !== "undefined") ? MeoTheme.titleBig : { "size": 28, "weight": Font.DemiBold, "lineHeight": 36, "letterSpacing": 0 }
    readonly property var fontPageSubtitle: (typeof MeoTheme !== "undefined" && typeof MeoTheme.bodyBig !== "undefined") ? MeoTheme.bodyBig : { "size": 16, "weight": Font.Normal, "lineHeight": 24, "letterSpacing": 0.5 }

    contentWidth: width
    contentHeight: rootColumn.implicitHeight + padding * 2
    clip: true
    boundsBehavior: Flickable.StopAtBounds

    Column {
        id: rootColumn
        width: control.width
        y: control.padding
        spacing: control.sectionSpacing

        Loader {
            width: parent.width
            sourceComponent: control.topBar
            visible: control.topBar !== null
        }

        Column {
            id: contentShell
            width: Math.min(control.width - control.padding * 2, control.maxContentWidth)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: control.sectionSpacing

            Row {
                width: parent.width
                spacing: 16 * control.themeGlobalScale
                visible: control.title !== "" || control.subtitle !== "" || control.actions.length > 0

                Column {
                    width: parent.width - actionsRow.width - (actionsRow.visible ? parent.spacing : 0)
                    spacing: 4 * control.themeGlobalScale

                    MeoText {
                        width: parent.width
                        text: control.title
                        visible: text !== ""
                        typeRole: "title"
                        typeSize: "big"
                        emphasized: true
                        color: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurface !== "undefined") ? MeoTheme.contentOnSurface : "#1C1B1F"
                        wrapMode: Text.WordWrap
                    }

                    MeoText {
                        width: parent.width
                        text: control.subtitle
                        visible: text !== ""
                        typeRole: "body"
                        typeSize: "big"
                        color: (typeof MeoTheme !== "undefined" && typeof MeoTheme.contentOnSurfaceVariant !== "undefined") ? MeoTheme.contentOnSurfaceVariant : "#49454F"
                        wrapMode: Text.WordWrap
                    }
                }

                Row {
                    id: actionsRow
                    visible: control.actions.length > 0
                    spacing: 4 * control.themeGlobalScale
                    anchors.verticalCenter: parent.verticalCenter

                    Repeater {
                        model: control.actions
                        delegate: Loader { sourceComponent: modelData }
                    }
                }
            }

            Column {
                id: bodyColumn
                width: parent.width
                spacing: control.sectionSpacing
            }
        }
    }
}
