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
    property string size: "m" // "xs" | "s" | "m" | "l" | "xl"
    signal selected(int index, var data) // 选中时向外发射的信号

    // 🌟 消除外部作用域歧义
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnSurfaceVariant !== 'undefined') ? MeoTheme.contentOnSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int themeSpace4: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.space4 !== 'undefined') ? MeoTheme.space4 : 4
    readonly property int motionFast: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationFast !== "undefined") ? MeoTheme.motionDurationFast : 150
    readonly property int motionMedium: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationMedium !== "undefined") ? MeoTheme.motionDurationMedium : 300
    readonly property int motionExit: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionDurationShort2 !== "undefined") ? MeoTheme.motionDurationShort2 : 100

    readonly property var fontToken: {
        if (typeof MeoTheme === 'undefined') return { "size": 14, "weight": Font.Medium };
        if (size === "xs") return MeoTheme.labelSmall;
        if (size === "s") return MeoTheme.labelMedium;
        if (size === "l") return MeoTheme.titleSmall;
        if (size === "xl") return MeoTheme.titleMedium;
        return MeoTheme.labelLarge;
    }

    padding: 0
    implicitHeight: {
        if (size === "xs") return MeoTheme.buttonHeightXS || 32 * themeGlobalScale;
        if (size === "s") return MeoTheme.buttonHeightS || 40 * themeGlobalScale;
        if (size === "l") return MeoTheme.buttonHeightL || 56 * themeGlobalScale;
        if (size === "xl") return MeoTheme.buttonHeightXL || 72 * themeGlobalScale;
        return MeoTheme.buttonHeightM || 48 * themeGlobalScale;
    }
    
    implicitWidth: {
        let total = 0;
        for (let i = 0; i < model.length; i++) {
            let labelText = typeof model[i] === 'string' ? model[i] : (model[i].label || "");
            let hasIcon = typeof model[i] === 'object' && model[i].icon;
            let base = (size === "xs" ? 64 : (size === "xl" ? 100 : 80));
            total += Math.max(base * themeGlobalScale, labelText.length * 8 * themeGlobalScale + (hasIcon ? 48 : 32) * themeGlobalScale);
        }
        return Math.max(240 * themeGlobalScale, total);
    }

    background: Rectangle {
        color: "transparent"
        border.color: "transparent"
        border.width: 0
        radius: (typeof MeoTheme !== 'undefined' ? MeoTheme.shapeFull : 20 * control.themeGlobalScale)

        // 🌟 Sliding Selection Background (MD3 Expressive Pattern for single-select)
        Rectangle {
            id: slidingBg
            visible: !control.multiSelect && control.model.length > 0
            height: parent.height
            radius: parent.radius
            color: control.themePrimary

            readonly property Item currentItem: itemRepeater.itemAt(control.currentIndex)
            x: currentItem ? currentItem.x + rowLayout.x : 0
            width: currentItem ? currentItem.width : 0

            Behavior on x {
                NumberAnimation {
                    duration: control.motionMedium
                    easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.05, 0.7, 0.1, 1.0]
                }
            }
            Behavior on width {
                NumberAnimation {
                    duration: control.motionMedium
                    easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.05, 0.7, 0.1, 1.0]
                }
            }
        }
    }

    Row {
        id: rowLayout
        anchors.fill: parent
        spacing: 2 * control.themeGlobalScale

        Repeater {
            id: itemRepeater
            model: control.model
            
            delegate: Item {
                id: delegateItem
                width: (control.width - rowLayout.spacing * Math.max(0, control.model.length - 1)) / Math.max(1, control.model.length)
                height: control.height
                z: isSelected ? 2 : 1

                readonly property var itemData: modelData
                readonly property string itemLabel: typeof itemData === 'string' ? itemData : (itemData.label || "")
                readonly property string itemIcon: typeof itemData === 'object' ? (itemData.icon || "") : ""
                readonly property bool isSelected: control.multiSelect ? control.selectedIndices.includes(index) : control.currentIndex === index

                readonly property color activeBgColor: control.themePrimary
                
                readonly property color inactiveBgColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ?
                    MeoTheme.primaryContainer : Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.18)

                readonly property color activeTextColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimary !== 'undefined') ? 
                    MeoTheme.contentOnPrimary : "#FFFFFF"

                readonly property color inactiveTextColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.contentOnPrimaryContainer !== 'undefined') ?
                    MeoTheme.contentOnPrimaryContainer : control.themePrimary

                readonly property color textColor: isSelected ? activeTextColor : inactiveTextColor

                Item {
                    anchors.fill: parent
                    clip: true

                    Rectangle {
                        id: baseBg
                        anchors.fill: parent
                        radius: height / 2
                        color: delegateItem.inactiveBgColor

                        Behavior on color { 
                            ColorAnimation { 
                                duration: control.motionFast;
                                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
                            } 
                        }
                    }

                    Rectangle {
                        id: selectedBg
                        anchors.fill: parent
                        radius: height / 2
                        color: delegateItem.activeBgColor
                        // Only show individual selectedBg in multiSelect mode
                        opacity: control.multiSelect && delegateItem.isSelected ? 1 : 0
                        scale: mouseArea.pressed ? 0.98 : (delegateItem.isSelected ? 1 : 0.92)

                        Behavior on opacity {
                            NumberAnimation {
                                duration: delegateItem.isSelected ? control.motionMedium : control.motionExit
                                easing.bezierCurve: delegateItem.isSelected
                                                    ? ((typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1])
                                                    : ((typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedAccelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedAccelerate : [0.3, 0, 0.8, 0.15])
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: delegateItem.isSelected ? control.motionMedium : control.motionFast
                                easing.bezierCurve: delegateItem.isSelected
                                                    ? ((typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedDecelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedDecelerate : [0.05, 0.7, 0.1, 1])
                                                    : ((typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingEmphasizedAccelerate !== "undefined") ? MeoTheme.motionEasingEmphasizedAccelerate : [0.3, 0, 0.8, 0.15])
                            }
                        }
                    }

                    MeoStateLayer {
                        anchors.fill: parent
                        radius: height / 2
                        pressed: mouseArea.pressed
                        hovered: mouseArea.containsMouse
                        pressX: mouseArea.mouseX
                        pressY: mouseArea.mouseY
                        color: delegateItem.textColor
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
                        width: (isSelected || itemIcon !== "") ? (control.size === "xl" ? 24 : 18) * control.themeGlobalScale : 0
                        height: width
                        anchors.verticalCenter: parent.verticalCenter
                        clip: true
                        
                        MeoIcon {
                            anchors.centerIn: parent
                            icon: isSelected ? "check" : itemIcon
                            size: (control.size === "xl" ? 24 : 18)
                            color: delegateItem.textColor

                            opacity: (isSelected || itemIcon !== "") ? 1.0 : 0.0
                            scale: (isSelected || itemIcon !== "") ? 1.0 : 0.5

                            Behavior on opacity { NumberAnimation { duration: control.motionFast } }
                            Behavior on scale { NumberAnimation { duration: control.motionFast; easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0] } }
                        }

                        Behavior on width {
                            NumberAnimation {
                                duration: control.motionFast
                                easing.bezierCurve: (typeof MeoTheme !== "undefined" && typeof MeoTheme.motionEasingSoul !== "undefined") ? MeoTheme.motionEasingSoul : [0.34, 0.8, 0.34, 1.0]
                            }
                        }
                    }

                    Text {
                        text: delegateItem.itemLabel
                        font.pixelSize: control.fontToken.size * control.themeGlobalScale
                        font.weight: isSelected ? (control.fontToken.weight === Font.Normal ? Font.Medium : Font.Bold) : control.fontToken.weight
                        color: delegateItem.textColor
                        anchors.verticalCenter: parent.verticalCenter
                        visible: text !== ""
                        
                        Behavior on color { ColorAnimation { duration: control.motionFast } }
                    }
                }

                Rectangle {
                    width: 1
                    height: parent.height - 12 * control.themeGlobalScale
                    color: control.themeOutline
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    visible: false
                }
            }
        }
    }
}
