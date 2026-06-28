import QtQuick
import QtQuick.Controls
import MeoUI

Control {
    id: control

    // 🌟 核心对外属性
    property var model: [] // [{ label: "", icon: "", value: any }]
    property bool multiSelect: false
    property var selectedIndices: []
    property int currentIndex: -1
    property real chipSpacing: 8 * themeGlobalScale

    signal selected(int index, var data)

    // 🌟 作用域与主题安全防御
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: flowLayout.implicitWidth
    implicitHeight: flowLayout.implicitHeight

    contentItem: Flow {
        id: flowLayout
        width: control.width
        spacing: control.chipSpacing

        Repeater {
            model: control.model
            delegate: MeoFilterChip {
                label: modelData.label
                leadingIcon: modelData.icon || ""
                selected: control.multiSelect ? control.selectedIndices.includes(index) : control.currentIndex === index

                onClicked: {
                    if (control.multiSelect) {
                        let indices = [...control.selectedIndices]
                        let idx = indices.indexOf(index)
                        if (idx === -1) {
                            indices.push(index)
                        } else {
                            indices.splice(idx, 1)
                        }
                        control.selectedIndices = indices
                    } else {
                        control.currentIndex = (control.currentIndex === index ? -1 : index)
                    }
                    control.selected(index, modelData)
                }
            }
        }
    }
}
