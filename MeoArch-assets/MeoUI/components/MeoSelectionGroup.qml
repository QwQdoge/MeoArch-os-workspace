import QtQuick
import QtQuick.Layouts
import MeoUI

Item {
    id: control

    // 🌟 核心对外属性
    property string title: "" // 组标题
    property var model: [] // 选项数组: [{ label: "Option 1", value: "opt1", checked: false }]
    property bool multiSelect: true // 是否多选 (true: Checkbox, false: Radio)
    property bool showSelectAll: false // 是否显示“全选”选项 (仅多选有效)

    signal selectionChanged(var selectedValues)

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"

    readonly property var fontTitleSmall: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.titleSmall !== 'undefined') ? MeoTheme.titleSmall : { "size": 14, "weight": Font.Medium }

    implicitWidth: 320 * themeGlobalScale
    implicitHeight: mainLayout.implicitHeight

    Column {
        id: mainLayout
        width: parent.width
        spacing: 0

        // 🌟 Group Title
        Text {
            text: control.title
            visible: control.title !== ""
            width: parent.width
            font.pixelSize: control.fontTitleSmall.size * control.themeGlobalScale
            font.weight: control.fontTitleSmall.weight
            color: control.themeOnSurfaceVariant
            padding: 12 * control.themeGlobalScale
            leftPadding: 16 * control.themeGlobalScale
        }

        // 🌟 Select All (Optional)
        MeoCheckbox {
            id: selectAllBox
            visible: control.multiSelect && control.showSelectAll
            label: "Select All"
            width: parent.width
            checked: {
                if (!control.model || control.model.length === 0) return false;
                for (let i = 0; i < control.model.length; i++) {
                    if (!control.model[i].checked) return false;
                }
                return true;
            }
            indeterminate: {
                if (!control.model) return false;
                let checkedCount = 0;
                for (let i = 0; i < control.model.length; i++) {
                    if (control.model[i].checked) checkedCount++;
                }
                return checkedCount > 0 && checkedCount < control.model.length;
            }
            onToggled: (isChecked) => {
                let newModel = JSON.parse(JSON.stringify(control.model)); // Deep copy to ensure update
                for (let i = 0; i < newModel.length; i++) {
                    newModel[i].checked = isChecked;
                }
                control.model = newModel;
                emitSelection();
            }
        }

        // 🌟 Options List
        Repeater {
            model: control.model
            delegate: Item {
                width: mainLayout.width
                height: 48 * control.themeGlobalScale

                Loader {
                    anchors.fill: parent
                    sourceComponent: control.multiSelect ? checkboxComp : radioComp

                    // Pass data through properties for delegate safety
                    property var itemData: modelData
                    property int itemIndex: index
                }
            }
        }
    }

    Component {
        id: checkboxComp
        MeoCheckbox {
            label: itemData.label
            checked: itemData.checked
            width: parent.width
            height: parent.height
            onToggled: (isChecked) => {
                let newModel = JSON.parse(JSON.stringify(control.model));
                newModel[itemIndex].checked = isChecked;
                control.model = newModel;
                emitSelection();
            }
        }
    }

    Component {
        id: radioComp
        MeoRadioButton {
            label: itemData.label
            checked: itemData.checked
            width: parent.width
            height: parent.height
            onToggled: (isChecked) => {
                if (isChecked) {
                    let newModel = JSON.parse(JSON.stringify(control.model));
                    for (let i = 0; i < newModel.length; i++) {
                        newModel[i].checked = (i === itemIndex);
                    }
                    control.model = newModel;
                    emitSelection();
                }
            }
        }
    }

    function emitSelection() {
        let selected = [];
        if (!control.model) return;
        for (let i = 0; i < control.model.length; i++) {
            if (control.model[i].checked) {
                selected.push(control.model[i].value);
            }
        }
        control.selectionChanged(selected);
    }
}
