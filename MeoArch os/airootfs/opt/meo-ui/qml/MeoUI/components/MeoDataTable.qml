import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心对外属性
    property var columns: [] // [{ label: "Column", width: 100, property: "prop", sortable: true }]
    property var model: []   // [{ prop: "value", selected: false }]
    property var rowData: model
    property bool selectable: false
    property bool showCheckBoxes: selectable
    property bool showDividers: true
    property bool hoverEffect: true
    property string sortProperty: ""
    property bool sortAscending: true
    property var selectedIndices: []
    property bool allSelected: false
    property bool isIndeterminate: false

    signal sortRequested(string property, bool ascending)
    signal selectionChanged()

    function rowIsSelected(row) {
        return !!(row && (row.selected || row.isSelected))
    }

    function refreshSelectionState() {
        let indices = []
        for (let i = 0; i < control.model.length; i++) {
            if (rowIsSelected(control.model[i]))
                indices.push(i)
        }
        selectedIndices = indices
        allSelected = control.model.length > 0 && indices.length === control.model.length
        isIndeterminate = indices.length > 0 && indices.length < control.model.length
    }

    function toggleAll(selected) {
        let newModel = [...control.model]
        newModel.forEach(item => {
            item.selected = selected
            item.isSelected = selected
        })
        control.model = newModel
        refreshSelectionState()
        control.selectionChanged()
    }

    function toggleRow(rowIndex, selected) {
        if (rowIndex < 0 || rowIndex >= control.model.length)
            return
        let newModel = [...control.model]
        newModel[rowIndex].selected = selected
        newModel[rowIndex].isSelected = selected
        control.model = newModel
        refreshSelectionState()
        control.selectionChanged()
    }

    onRowDataChanged: {
        if (model !== rowData)
            model = rowData
    }
    onModelChanged: {
        if (rowData !== model)
            rowData = model
        refreshSelectionState()
    }
    onShowCheckBoxesChanged: selectable = showCheckBoxes
    onSelectableChanged: {
        if (showCheckBoxes !== selectable)
            showCheckBoxes = selectable
    }

    // 🌟 作用域防御与主题适配
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurface !== 'undefined') ? MeoTheme.contentOnSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property color themeOutlineVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outlineVariant !== 'undefined') ? MeoTheme.outlineVariant : "#C4C7C5"
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeSecondaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? MeoTheme.secondaryContainer : "#E8DEF8"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    readonly property var fontLabelLarge: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.labelLarge !== 'undefined') ? MeoTheme.labelLarge : { "size": 14, "weight": Font.Medium }
    readonly property var fontBodyMedium: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.bodyMedium !== 'undefined') ? MeoTheme.bodyMedium : { "size": 14, "weight": Font.Normal }

    implicitWidth: 600 * themeGlobalScale
    implicitHeight: 400 * themeGlobalScale

    background: Rectangle {
        color: control.themeSurface
        border.color: control.themeOutlineVariant
        border.width: 1 * control.themeGlobalScale
        radius: 8 * control.themeGlobalScale
    }

    contentItem: Column {
        // 🌟 Table Header
        Rectangle {
            id: headerRow
            width: parent.width
            height: 56 * control.themeGlobalScale
            color: "transparent"

            Row {
                anchors.fill: parent
                anchors.leftMargin: 16 * control.themeGlobalScale
                anchors.rightMargin: 16 * control.themeGlobalScale

                // Selection Header
                Item {
                    width: 56 * control.themeGlobalScale
                    height: parent.height
                    visible: control.selectable
                    MeoCheckbox {
                        anchors.centerIn: parent
                        checked: control.allSelected
                        indeterminate: control.isIndeterminate
                        onToggled: (isChecked) => control.toggleAll(isChecked)
                    }
                }

                Repeater {
                    model: control.columns
                    delegate: Item {
                            width: modelData.width ? modelData.width * control.themeGlobalScale : (headerRow.width - (control.selectable ? 56 : 0) - 32) / control.columns.length
                        height: parent.height

                        Row {
                            anchors.left: parent.left
                            anchors.verticalCenter: parent.verticalCenter
                            spacing: 4 * control.themeGlobalScale

                            Text {
                                text: modelData.label
                                font.pixelSize: control.fontLabelLarge.size * control.themeGlobalScale
                                font.weight: control.fontLabelLarge.weight
                                color: control.themeOnSurface
                                verticalAlignment: Text.AlignVCenter
                            }

                            MeoIcon {
                                icon: control.sortAscending ? "arrow_upward" : "arrow_downward"
                                size: 16
                                visible: !!modelData.sortable && control.sortProperty === (modelData.property || modelData.role)
                                color: control.themePrimary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: !!modelData.sortable
                            onClicked: {
                                let sortRole = modelData.property || modelData.role;
                                if (control.sortProperty === sortRole) {
                                    control.sortAscending = !control.sortAscending;
                                } else {
                                    control.sortProperty = sortRole;
                                    control.sortAscending = true;
                                }
                                control.sortRequested(sortRole, control.sortAscending);
                            }
                        }
                    }
                }
            }

            Rectangle {
                anchors.bottom: parent.bottom
                width: parent.width
                height: 1 * control.themeGlobalScale
                color: control.themeOutlineVariant
            }
        }

        // 🌟 Table Body
        ListView {
            id: listView
            width: parent.width
            height: parent.height - headerRow.height
            model: control.model
            clip: true

            delegate: Item {
                id: rowDelegate
                width: listView.width
                height: 52 * control.themeGlobalScale

                readonly property var row: modelData
                readonly property bool isSelected: control.rowIsSelected(row)

                Rectangle {
                    anchors.fill: parent
                    color: rowDelegate.isSelected ? control.themeSecondaryContainer : "transparent"

                    MeoStateLayer {
                        anchors.fill: parent
                        pressed: rowMouseArea.pressed
                        hovered: control.hoverEffect && rowMouseArea.containsMouse
                        color: rowDelegate.isSelected ? control.themeOnSurface : control.themeOnSurfaceVariant
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16 * control.themeGlobalScale
                    anchors.rightMargin: 16 * control.themeGlobalScale

                    // Selection Cell
                    Item {
                            width: 56 * control.themeGlobalScale
                        height: parent.height
                        visible: control.selectable
                        MeoCheckbox {
                            anchors.centerIn: parent
                            checked: rowDelegate.isSelected
                            onToggled: (isChecked) => control.toggleRow(index, isChecked)
                        }
                    }

                    Repeater {
                        model: control.columns
                        delegate: Item {
                            width: modelData.width ? modelData.width * control.themeGlobalScale : (rowDelegate.width - (control.selectable ? 48 : 0) - 32) / control.columns.length
                            height: parent.height

                            Loader {
                                anchors.fill: parent
                                anchors.rightMargin: 8 * control.themeGlobalScale
                                sourceComponent: modelData.delegate || defaultTextDelegate

                                property var rowData: rowDelegate.row
                                property var columnData: modelData
                            }

                            Component {
                                id: defaultTextDelegate
                                Text {
                                    text: {
                                        let path = columnData.property || columnData.role || "";
                                        return path ? path.split('.').reduce((obj, i) => obj ? obj[i] : "", rowData) : "";
                                    }
                                    font.family: (typeof MeoTheme !== "undefined" && MeoTheme.typefacePlain) ? MeoTheme.typefacePlain : "Roboto"
                                    font.pixelSize: control.fontBodyMedium.size * control.themeGlobalScale
                                    color: control.themeOnSurfaceVariant
                                    verticalAlignment: Text.AlignVCenter
                                    elide: Text.ElideRight
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    anchors.bottom: parent.bottom
                    width: parent.width
                    height: 1 * control.themeGlobalScale
                    color: control.themeOutlineVariant
                    visible: control.showDividers && index < listView.count - 1
                }

                MouseArea {
                    id: rowMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (control.selectable) {
                            control.toggleRow(index, !rowDelegate.isSelected);
                        }
                    }
                }
            }
        }
    }
}
