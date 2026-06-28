import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心对外属性
    property var columns: [] // [{ label: "Column", width: 100, property: "prop", sortable: true }]
    property var model: []   // [{ prop: "value", selected: false }]
    property bool selectable: false
    property string sortProperty: ""
    property bool sortAscending: true

    signal sortRequested(string property, bool ascending)
    signal selectionChanged()

    // 🌟 作用域防御与主题适配
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    readonly property color themeSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.surface !== 'undefined') ? MeoTheme.surface : "#FFFBFE"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
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
                    width: 48 * control.themeGlobalScale
                    height: parent.height
                    visible: control.selectable
                    MeoCheckbox {
                        anchors.centerIn: parent
                        checked: {
                            if (control.model.length === 0) return false;
                            return control.model.every(item => item.selected);
                        }
                        indeterminate: {
                            let selectedCount = control.model.filter(item => item.selected).length;
                            return selectedCount > 0 && selectedCount < control.model.length;
                        }
                        onToggled: (isChecked) => {
                            let newModel = [...control.model];
                            newModel.forEach(item => item.selected = isChecked);
                            control.model = newModel;
                            control.selectionChanged();
                        }
                    }
                }

                Repeater {
                    model: control.columns
                    delegate: Item {
                        width: modelData.width ? modelData.width * control.themeGlobalScale : (headerRow.width - (control.selectable ? 48 : 0) - 32) / control.columns.length
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
                                visible: modelData.sortable && control.sortProperty === modelData.property
                                color: control.themePrimary
                                anchors.verticalCenter: parent.verticalCenter
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            enabled: modelData.sortable
                            onClicked: {
                                if (control.sortProperty === modelData.property) {
                                    control.sortAscending = !control.sortAscending;
                                } else {
                                    control.sortProperty = modelData.property;
                                    control.sortAscending = true;
                                }
                                control.sortRequested(modelData.property, control.sortAscending);
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
                readonly property bool isSelected: row.selected || false

                Rectangle {
                    anchors.fill: parent
                    color: rowDelegate.isSelected ? control.themeSecondaryContainer : "transparent"

                    MeoStateLayer {
                        anchors.fill: parent
                        pressed: rowMouseArea.pressed
                        hovered: rowMouseArea.containsMouse
                    }
                }

                Row {
                    anchors.fill: parent
                    anchors.leftMargin: 16 * control.themeGlobalScale
                    anchors.rightMargin: 16 * control.themeGlobalScale

                    // Selection Cell
                    Item {
                        width: 48 * control.themeGlobalScale
                        height: parent.height
                        visible: control.selectable
                        MeoCheckbox {
                            anchors.centerIn: parent
                            checked: rowDelegate.isSelected
                            onToggled: (isChecked) => {
                                let newModel = [...control.model];
                                newModel[index].selected = isChecked;
                                control.model = newModel;
                                control.selectionChanged();
                            }
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
                                    text: columnData.property ? columnData.property.split('.').reduce((obj, i) => obj[i], rowData) : ""
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
                    visible: index < listView.count - 1
                }

                MouseArea {
                    id: rowMouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked: {
                        if (control.selectable) {
                            let newModel = [...control.model];
                            newModel[index].selected = !newModel[index].selected;
                            control.model = newModel;
                            control.selectionChanged();
                        }
                    }
                }
            }
        }
    }
}
