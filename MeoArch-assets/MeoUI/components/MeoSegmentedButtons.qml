import QtQuick
import QtQuick.Controls
import MeoUI

Frame {
    id: control

    // 🌟 核心对外属性
    // model can be ["option1", "option2"] or [{ label: "option1", icon: "home" }, ...]
    property var model: ["option1", "option2", "option3"]
    property int currentIndex: 0 // 当前选中的索引
    property bool multiSelect: false
    property var selectedIndices: []
    signal selected(int index, var data) // 选中时向外发射的信号

    // 🌟 消除外部作用域歧义
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int themeSpace4: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.space4 !== 'undefined') ? MeoTheme.space4 : 4

    padding: 0
    implicitHeight: 40 * themeGlobalScale
    
    implicitWidth: {
        let total = 0;
        for (let i = 0; i < model.length; i++) {
            let labelText = typeof model[i] === 'string' ? model[i] : (model[i].label || "");
            let hasIcon = typeof model[i] === 'object' && model[i].icon;
            total += Math.max(80 * themeGlobalScale, labelText.length * 8 * themeGlobalScale + (hasIcon ? 48 : 32) * themeGlobalScale);
        }
        return Math.max(240 * themeGlobalScale, total);
    }

    background: Rectangle {
        color: "transparent"
        border.color: control.themeOutline
        border.width: 1
        radius: (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeFull : 20 * control.themeGlobalScale)
    }

    Row {
        id: rowLayout
        anchors.fill: parent

        Repeater {
            model: control.model
            
            delegate: Item {
                id: delegateItem
                width: control.width / control.model.length
                height: control.height

                readonly property var itemData: modelData
                readonly property string itemLabel: typeof itemData === 'string' ? itemData : (itemData.label || "")
                readonly property string itemIcon: typeof itemData === 'object' ? (itemData.icon || "") : ""
                readonly property bool isSelected: control.multiSelect ? control.selectedIndices.includes(index) : control.currentIndex === index

                readonly property color activeBgColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? 
                    MeoTheme.secondaryContainer : Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.12)
                
                readonly property color activeTextColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? 
                    MeoTheme.onSecondaryContainer : control.themePrimary

                readonly property color textColor: isSelected ? activeTextColor : control.themeOnSurfaceVariant
                readonly property color baseColor: isSelected ? activeBgColor : Qt.rgba(textColor.r, textColor.g, textColor.b, 0)

                Item {
                    anchors.fill: parent
                    clip: true

                    Rectangle {
                        id: bgRect
                        width: (index === 0 || index === control.model.length - 1) ? parent.width + 28 * control.themeGlobalScale : parent.width
                        height: parent.height
                        x: index === control.model.length - 1 ? -28 * control.themeGlobalScale : 0
                        radius: (index === 0 || index === control.model.length - 1) ? (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeFull : 20 * control.themeGlobalScale) : 0

                        color: {
                            let base = delegateItem.baseColor;
                            let overlay = delegateItem.textColor;
                            
                            if (mouseArea.pressed)
                                return Qt.tint(base, Qt.rgba(overlay.r, overlay.g, overlay.b, 0.12));
                            if (mouseArea.containsMouse)
                                return Qt.tint(base, Qt.rgba(overlay.r, overlay.g, overlay.b, 0.08));
                                
                            return base;
                        }

                        Behavior on color { 
                            ColorAnimation { 
                                duration: 150; 
                                easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] 
                            } 
                        }
                    }

                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            if (control.multiSelect) {
                                let arr = [...control.selectedIndices]
                                let idx = arr.indexOf(index)
                                if (idx === -1) arr.push(index)
                                else arr.splice(idx, 1)
                                control.selectedIndices = arr
                            } else {
                                control.currentIndex = index;
                            }
                            control.selected(index, itemData);
                        }
                    }
                }

                Row {
                    anchors.centerIn: parent
                    spacing: control.themeSpace4 * control.themeGlobalScale

                    // Checkmark or Icon
                    Item {
                        width: (isSelected || itemIcon !== "") ? 18 * control.themeGlobalScale : 0
                        height: 18 * control.themeGlobalScale
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true
                        
                        MeoIcon {
                            anchors.centerIn: parent
                            icon: isSelected ? "check" : itemIcon
                            size: 18
                            color: delegateItem.textColor

                            opacity: (isSelected || itemIcon !== "") ? 1.0 : 0.0
                            scale: (isSelected || itemIcon !== "") ? 1.0 : 0.5

                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            Behavior on scale { NumberAnimation { duration: 150; easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] } }
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: 150
                                easing.bezierCurve: [0.34, 0.8, 0.34, 1.0]
                            }
                        }
                    }

                    Text {
                        text: delegateItem.itemLabel
                        font.pixelSize: 14 * control.themeGlobalScale
                        font.weight: isSelected ? Font.DemiBold : Font.Normal
                        color: delegateItem.textColor
                        anchors.verticalCenter: parent.verticalCenter
                        visible: text !== ""
                        
                        Behavior on color { ColorAnimation { duration: 150 } }
                    }
                }

                Rectangle {
                    width: 1
                    height: parent.height - 12 * control.themeGlobalScale
                    color: control.themeOutline
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: index < control.model.length - 1 && !isSelected && (!control.multiSelect && control.currentIndex !== index + 1)
                }
            }
        }
    }
}
