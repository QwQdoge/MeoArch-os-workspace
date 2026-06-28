import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心对外属性
    property string label: ""
    property var model: [] // 菜单项数组: ["Option 1", "Option 2", ...]
    property string text: ""
    property bool isError: false
    property string errorText: ""
    property string type: "filled" // "filled" | "outlined"

    signal selected(int index, string value)

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 280 * themeGlobalScale
    implicitHeight: textField.implicitHeight

    MeoTextField {
        id: textField
        width: parent.width
        label: control.label
        text: control.text
        isError: control.isError
        errorText: control.errorText
        type: control.type
        readOnly: true
        trailingIcon: menu.opened ? "arrow_drop_up" : "arrow_drop_down"

        MouseArea {
            anchors.fill: parent
            onClicked: menu.open()
        }
    }

    MeoMenu {
        id: menu
        width: control.width
        y: textField.containerHeight
        model: {
            let m = []
            for (let i = 0; i < control.model.length; i++) {
                m.push({
                    label: control.model[i],
                    action: (function(idx, val) {
                        return function() {
                            control.text = val
                            control.selected(idx, val)
                        }
                    })(i, control.model[i])
                })
            }
            return m
        }
    }
}
