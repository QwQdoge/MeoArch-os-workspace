import QtQuick
import QtQuick.Controls

Frame {
    id: control

    // 🌟 核心对外属性
    property var model: ["option1", "option2", "option3"] // 外部传入的文本数组
    property int currentIndex: 0 // 当前选中的索引
    signal selected(int index, string text) // 选中时向外发射的信号

    // 🌟 消除外部作用域歧义：将外部变量封装成内部属性，确保作为原子组件的独立性
    readonly property bool isDarkMode: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.isDarkMode !== 'undefined') ? MeoTheme.isDarkMode : false
    
    // 安全的主题属性转发与默认备用值，保证模块在独立使用时不会引发 ReferenceError
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOutline: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.outline !== 'undefined') ? MeoTheme.outline : "#79747E"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0
    readonly property int themeSpace4: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.space4 !== 'undefined') ? MeoTheme.space4 : 4

    padding: 0
    implicitHeight: 40
    
    // 🌟 斩断 Binding Loop (隐式宽度死循环) 的极客方案：
    // 通过直接基于 model 文本估算所需宽度，彻底避开内部 Repeater 宽度与外部 implicitWidth 的循环依赖，同时完美支持父级容器显式指定 width 拉伸
    implicitWidth: {
        let total = 0;
        for (let i = 0; i < model.length; i++) {
            // 每个分段估算宽度：字数 * 8px + 48px（左右边距与对勾预留空间）
            total += Math.max(80, model[i].length * 8 + 48);
        }
        return Math.max(240, total);
    }

    // 外层大胶囊容器
    background: Rectangle {
        color: "transparent"
        border.color: control.themeOutline
        border.width: 1
        radius: 20 // M3 规范：全圆角大胶囊
    }

    Row {
        id: rowLayout
        anchors.fill: parent

        Repeater {
            model: control.model
            
            delegate: Item {
                id: delegateItem
                // 动态平分宽度，支持拉伸
                width: control.width / control.model.length
                height: control.height

                readonly property bool isSelected: control.currentIndex === index

                // 前景色与背景色计算，为 M3 Tonal / Outlined 规范做适配
                readonly property color activeBgColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.secondaryContainer !== 'undefined') ? 
                    MeoTheme.secondaryContainer : Qt.rgba(control.themePrimary.r, control.themePrimary.g, control.themePrimary.b, 0.12)
                
                readonly property color activeTextColor: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSecondaryContainer !== 'undefined') ? 
                    MeoTheme.onSecondaryContainer : control.themePrimary

                readonly property color textColor: isSelected ? activeTextColor : control.themeOnSurfaceVariant
                
                readonly property color baseColor: isSelected ? activeBgColor : Qt.rgba(textColor.r, textColor.g, textColor.b, 0) // 纯透明但保留前景色相的基准色，避免 Qt.tint 边缘黑影 Bug

                // 交互层与圆角背景 (State Layer & Rounded Background)
                // 🌟 使用 Clip 巧妙实现首尾元素只在单侧有圆角的效果，完美贴合外层大胶囊边框
                Item {
                    anchors.fill: parent
                    clip: true

                    Rectangle {
                        id: bgRect
                        // 如果是头或尾，增加宽度以隐藏不需要圆角的另一侧
                        width: (index === 0 || index === control.model.length - 1) ? parent.width + 20 : parent.width
                        height: parent.height
                        // 首项靠左，尾项向左偏 20px 以隐藏左侧圆角
                        x: index === control.model.length - 1 ? -20 : 0
                        radius: (index === 0 || index === control.model.length - 1) ? 20 : 0

                        // 🌟 MD3 State Layer (状态层) 交互规范
                        color: {
                            let base = delegateItem.baseColor;
                            let overlay = delegateItem.textColor;
                            
                            if (mouseArea.pressed)
                                return Qt.tint(base, Qt.rgba(overlay.r, overlay.g, overlay.b, 0.12));
                            if (mouseArea.containsMouse)
                                return Qt.tint(base, Qt.rgba(overlay.r, overlay.g, overlay.b, 0.08));
                                
                            return base;
                        }

                        // 🌟 严格锁死 Fast Effects 贝塞尔曲线动效 (150ms)
                        Behavior on color { 
                            ColorAnimation { 
                                duration: 150; 
                                easing.bezierCurve: [0.34, 0.8, 0.34, 1.0] 
                            } 
                        }
                    }

                    // 鼠标悬浮与点击反馈
                    MouseArea {
                        id: mouseArea
                        anchors.fill: parent
                        hoverEnabled: true
                        onClicked: {
                            control.currentIndex = index;
                            control.selected(index, modelData);
                        }
                    }
                }

                // 按钮文本与选中小对勾
                Row {
                    anchors.centerIn: parent
                    spacing: control.themeSpace4

                    // 🌟 M3 规范：如果选中，丝滑滑出并淡入一个小对勾图标
                    Text {
                        text: "✓"
                        font.pixelSize: 14 * control.themeGlobalScale
                        font.weight: Font.Bold
                        color: delegateItem.textColor
                        anchors.verticalCenter: parent.verticalCenter
                        
                        // 用 width, opacity 和 scale 做三维组合动效，既能实现横向“滑出”不占空间，又有淡出缩小，完全符合 MD3 规范中的 "Slide and fade in"
                        width: isSelected ? implicitWidth : 0
                        opacity: isSelected ? 1.0 : 0.0
                        scale: isSelected ? 1.0 : 0.5
                        clip: true
                        horizontalAlignment: Text.AlignHCenter
                        verticalAlignment: Text.AlignVCenter
                        
                        Behavior on width {
                            NumberAnimation {
                                duration: 150
                                easing.bezierCurve: [0.34, 0.8, 0.34, 1.0]
                            }
                        }
                        Behavior on opacity {
                            NumberAnimation {
                                duration: 150
                                easing.bezierCurve: [0.34, 0.8, 0.34, 1.0]
                            }
                        }
                        Behavior on scale {
                            NumberAnimation {
                                duration: 150
                                easing.bezierCurve: [0.34, 0.8, 0.34, 1.0]
                            }
                        }
                    }

                    Text {
                        text: modelData
                        font.pixelSize: 14 * control.themeGlobalScale // 自动响应三级屏幕断点
                        font.weight: isSelected ? Font.DemiBold : Font.Normal
                        color: delegateItem.textColor
                        anchors.verticalCenter: parent.verticalCenter
                        
                        Behavior on color {
                            ColorAnimation {
                                duration: 150
                            }
                        }
                    }
                }

                // 分割线：除了最后一个按钮，每个按钮右边画一条细线
                Rectangle {
                    width: 1
                    height: parent.height - 12
                    color: control.themeOutline
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    // MD3 规范：如果相邻的任意一个按钮处于选中状态，则隐藏分割线
                    visible: index < control.model.length - 1 && !isSelected && (control.currentIndex !== index + 1)
                }
            }
        }
    }
}
