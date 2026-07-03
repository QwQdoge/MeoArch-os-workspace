import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

MeoPageLayout {
    id: page
    title: "MD3 Data Table"
    subtitle: "Interactive table with selection, sorting, toolbar actions, status chips, and pagination anatomy."

    readonly property real s: MeoTheme.globalScale

    Component {
        id: statusDelegate
        Item {
            anchors.fill: parent
            Rectangle {
                anchors.centerIn: parent
                width: 76 * page.s
                height: 28 * page.s
                radius: 14 * page.s
                color: rowData.calories > 300 ? MeoTheme.errorContainer : "#D7F2DF"
                MeoText {
                    anchors.centerIn: parent
                    text: rowData.calories > 300 ? "High" : "Normal"
                    typeRole: "label"
                    typeSize: "small"
                    color: rowData.calories > 300 ? MeoTheme.contentOnErrorContainer : "#154C24"
                }
            }
        }
    }

    Rectangle {
        width: parent.width
        implicitHeight: tableColumn.implicitHeight + 24 * page.s
        radius: MeoTheme.shapeLarge
        color: MeoTheme.surfaceContainerLow

        ColumnLayout {
            id: tableColumn
            anchors.fill: parent
            anchors.margins: 12 * page.s
            spacing: 12 * page.s

            RowLayout {
                Layout.fillWidth: true
                spacing: 8 * page.s
                MeoTextField { Layout.preferredWidth: 280 * page.s; label: "Search desserts"; leadingIcon: "search"; type: "outlined"; size: "s" }
                Item { Layout.fillWidth: true }
                MeoButton { text: "Filter"; type: "outlined"; icon.name: "filter_list"; size: "s" }
                MeoButton { text: "Export"; type: "tonal"; icon.name: "download"; size: "s" }
            }

            MeoDataTable {
                Layout.fillWidth: true
                Layout.preferredHeight: 360 * page.s
                selectable: true
                sortProperty: "calories"
                sortAscending: true
                columns: [
                    { label: "Dessert (100g serving)", property: "name", width: 260, sortable: true },
                    { label: "Calories", property: "calories", width: 116, sortable: true },
                    { label: "Fat (g)", property: "fat", width: 104, sortable: true },
                    { label: "Carbs (g)", property: "carbs", width: 112, sortable: true },
                    { label: "Status", width: 124, delegate: statusDelegate }
                ]
                model: [
                    { name: "Frozen yogurt", calories: 159, fat: 6.0, carbs: 24, selected: true },
                    { name: "Ice cream sandwich", calories: 237, fat: 9.0, carbs: 37, selected: false },
                    { name: "Eclair", calories: 262, fat: 16.0, carbs: 24, selected: false },
                    { name: "Cupcake", calories: 305, fat: 3.7, carbs: 67, selected: false },
                    { name: "Gingerbread", calories: 356, fat: 16.0, carbs: 49, selected: false }
                ]
            }

            RowLayout {
                Layout.fillWidth: true
                MeoText { text: "Rows per page: 5"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                Item { Layout.fillWidth: true }
                MeoText { text: "1-5 of 5"; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                MeoIconButton { icon.name: "chevron_left"; type: "standard"; enabled: false }
                MeoIconButton { icon.name: "chevron_right"; type: "standard" }
            }
        }
    }
}
