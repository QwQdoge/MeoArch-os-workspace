import QtQuick
import QtQuick.Controls
import MeoUI

Flickable {
    contentHeight: tableColumn.implicitHeight + 40 * MeoTheme.globalScale
    clip: true

    Component {
        id: statusDelegate

        Item {
            anchors.fill: parent
            Row {
                anchors.centerIn: parent
                spacing: 4 * MeoTheme.globalScale
                Rectangle {
                    width: 8 * MeoTheme.globalScale
                    height: 8 * MeoTheme.globalScale
                    radius: 4 * MeoTheme.globalScale
                    color: rowData.calories > 300 ? MeoTheme.error : "#4CAF50"
                    anchors.verticalCenter: parent.verticalCenter
                }
                Text {
                    text: rowData.calories > 300 ? "High" : "Normal"
                    font.pixelSize: 12 * MeoTheme.globalScale
                    color: MeoTheme.onSurfaceVariant
                    anchors.verticalCenter: parent.verticalCenter
                }
            }
        }
    }

    Column {
        id: tableColumn
        padding: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale
        width: parent.width

        Text { text: "MD3 Data Table"; font.pixelSize: 20 * MeoTheme.globalScale; color: MeoTheme.onSurface }
        MeoDataTable {
            width: parent.width - 48 * MeoTheme.globalScale
            selectable: true
            columns: [
                { label: "Dessert (100g serving)", property: "name", width: 250, sortable: true },
                { label: "Calories", property: "calories", width: 100, sortable: true },
                { label: "Fat (g)", property: "fat", width: 100, sortable: true },
                { label: "Carbs (g)", property: "carbs", width: 100, sortable: true },
                {
                    label: "Status",
                    width: 120,
                    delegate: statusDelegate
                }
            ]
            model: [
                { name: "Frozen yogurt", calories: 159, fat: 6.0, carbs: 24, selected: false },
                { name: "Ice cream sandwich", calories: 237, fat: 9.0, carbs: 37, selected: false },
                { name: "Eclair", calories: 262, fat: 16.0, carbs: 24, selected: false },
                { name: "Cupcake", calories: 305, fat: 3.7, carbs: 67, selected: false },
                { name: "Gingerbread", calories: 356, fat: 16.0, carbs: 49, selected: false }
            ]
        }
    }
}
