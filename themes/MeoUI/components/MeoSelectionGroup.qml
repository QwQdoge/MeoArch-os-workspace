import QtQuick
import QtQuick.Controls
import MeoUI

Column {
    id: control

    // 🌟 核心属性
    property var model: [] // Array of { label: "", checked: false, ... }
    property string type: "checkbox" // "checkbox" | "radio"
    property bool showSelectAll: false
    property string selectAllLabel: "Select All"

    signal changed(var model)

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    spacing: 0
    width: parent ? parent.width : 300 * themeGlobalScale

    // 🌟 Select All Option
    MeoListItem {
        visible: control.showSelectAll && control.type === "checkbox"
        width: parent.width
        headline: control.selectAllLabel
        interactive: true
        trailingComponent: MeoCheckbox {
            checked: isAllSelected()
            indeterminate: !isAllSelected() && isAnySelected()
            onClicked: {
                let target = !isAllSelected()
                let newModel = [...control.model]
                for (let i = 0; i < newModel.length; i++) {
                    newModel[i].checked = target
                }
                control.model = newModel
                control.changed(control.model)
            }
        }
        onClicked: {
            let target = !isAllSelected()
            let newModel = [...control.model]
            for (let i = 0; i < newModel.length; i++) {
                newModel[i].checked = target
            }
            control.model = newModel
            control.changed(control.model)
        }
    }

    MeoDivider {
        visible: control.showSelectAll && control.type === "checkbox" && control.model.length > 0
    }

    // 🌟 Group Items
    Repeater {
        model: control.model
        delegate: MeoListItem {
            width: control.width
            headline: modelData.label
            interactive: true
            trailingComponent: Loader {
                sourceComponent: control.type === "radio" ? radioComp : checkComp
                property bool isChecked: modelData.checked || false
            }

            Component {
                id: checkComp
                MeoCheckbox {
                    checked: isChecked
                    onClicked: {
                        let newModel = [...control.model]
                        newModel[index].checked = !newModel[index].checked
                        control.model = newModel
                        control.changed(control.model)
                    }
                }
            }

            Component {
                id: radioComp
                MeoRadioButton {
                    checked: isChecked
                    onClicked: {
                        let newModel = [...control.model]
                        for (let i = 0; i < newModel.length; i++) {
                            newModel[i].checked = (i === index)
                        }
                        control.model = newModel
                        control.changed(control.model)
                    }
                }
            }

            onClicked: {
                let newModel = [...control.model]
                if (control.type === "radio") {
                    for (let i = 0; i < newModel.length; i++) {
                        newModel[i].checked = (i === index)
                    }
                } else {
                    newModel[index].checked = !newModel[index].checked
                }
                control.model = newModel
                control.changed(control.model)
            }
        }
    }

    function isAllSelected() {
        if (model.length === 0) return false
        for (let i = 0; i < model.length; i++) {
            if (!model[i].checked) return false
        }
        return true
    }

    function isAnySelected() {
        for (let i = 0; i < model.length; i++) {
            if (model[i].checked) return true
        }
        return false
    }
}
