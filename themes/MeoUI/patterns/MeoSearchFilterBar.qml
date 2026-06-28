import QtQuick
import QtQuick.Controls
import MeoUI

Item {
    id: control

    // 🌟 核心对外属性
    property string text: ""
    property string placeholder: "Search..."
    property var filterModel: []
    property var selectedFilterIndices: []
    property bool multiSelectFilters: true

    signal searchClicked()
    signal filterChanged(var indices)

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 360 * themeGlobalScale
    implicitHeight: column.implicitHeight

    Column {
        id: column
        width: parent.width
        spacing: 12 * control.themeGlobalScale

        MeoSearchBar {
            width: parent.width
            text: control.text
            placeholder: control.placeholder
            onTextChanged: control.text = text
            // Optional: add trailing icon action if needed
        }

        ScrollView {
            width: parent.width
            height: 48 * control.themeGlobalScale
            contentWidth: filterGroup.implicitWidth + 32 * control.themeGlobalScale
            clip: true
            ScrollBar.horizontal.policy: ScrollBar.AlwaysOff

            MeoFilterGroup {
                id: filterGroup
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 16 * control.themeGlobalScale
                model: control.filterModel
                multiSelect: control.multiSelectFilters
                selectedIndices: control.selectedFilterIndices

                onSelected: {
                    control.selectedFilterIndices = selectedIndices
                    control.filterChanged(selectedIndices)
                }
            }
        }
    }
}
