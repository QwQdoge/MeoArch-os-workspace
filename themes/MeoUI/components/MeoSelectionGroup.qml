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
            onToggled: {
                let target = !isAllSelected()
                let m = control.model
                for (let i = 0; i < m.length; i++) {
                    m[i].checked = target
                }
                control.modelChanged()
                control.changed(control.model)
            }
        }
        onClicked: {
            let target = !isAllSelected()
            let m = control.model
            for (let i = 0; i < m.length; i++) {
                m[i].checked = target
            }
            control.modelChanged()
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
                    onToggled: {
                        let m = control.model
                        m[index].checked = !m[index].checked
                        control.modelChanged()
                        control.changed(control.model)
                    }
                }
            }

            Component {
                id: radioComp
                MeoRadioButton {
                    checked: isChecked
                    onToggled: {
                        let m = control.model
                        for (let i = 0; i < m.length; i++) {
                            m[i].checked = (i === index)
                        }
                        control.modelChanged()
                        control.changed(control.model)
                    }
                }
            }

            onClicked: {
                let m = control.model
                if (control.type === "radio") {
                    for (let i = 0; i < m.length; i++) {
                        m[i].checked = (i === index)
                    }
                } else {
                    m[index].checked = !m[index].checked
                }
                control.modelChanged()
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
