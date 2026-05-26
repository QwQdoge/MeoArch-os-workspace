import QtQuick
import QtQuick.Controls

Button {
    // 16px
    // 注：生产环境可以配合 MultiEffect 挂载阴影

    id: control

    // 🌟 核心开关：通过这个属性直接控制按钮长相
    // 可选值: "filled" (默认) | "tonal" | "outlined" | "elevated" | "text"
    property string type: "filled"

    // 🌟 消除作用域歧义：将外部变量封装成内部属性，确保作为原子组件的独立性
    readonly property bool isDarkMode: MeoTheme.isDarkMode

    // ==========================================
    // 🎨 幕后色板映射逻辑 (根据 type 动态给皮肤)
    // ==========================================
    readonly property color bgColor: {
        if (!control.enabled) {
            if (type === "outlined" || type === "text")
                return Qt.rgba(textColor.r, textColor.g, textColor.b, 0); // 纯透明但保留前景色相的基准色，抹平 transparent 在 Qt.tint 里的渲染边缘黑影 Bug
            // MD3 禁用状态容器背景色为 onSurface 12% 透明度
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
        }

        if (type === "filled")
            return MeoTheme.primary;

        if (type === "tonal")
            return MeoTheme.surfaceVariant;

        // MD3 调色板专属
        if (type === "elevated")
            return MeoTheme.surface;

        return Qt.rgba(textColor.r, textColor.g, textColor.b, 0); // outlined 和 text 纯透明但保留前景色相的基准色
    }

    readonly property color textColor: {
        if (!control.enabled) {
            // MD3 禁用状态文字颜色为 onSurface 38% 透明度
            return isDarkMode ? Qt.rgba(1, 1, 1, 0.38) : Qt.rgba(0, 0, 0, 0.38);
        }

        if (type === "filled")
            return isDarkMode ? "#141218" : "#FFFFFF";

        if (type === "tonal")
            return MeoTheme.onSurfaceVariant;

        return MeoTheme.primary; // outlined, elevated, text 默认走主色文字
    }

    // ==========================================
    // 📐 规范 (间距与排版)
    // ==========================================
    // MD3 规范：Text 按钮左右间距为 12px，其他带有容器的按钮为 24px
    leftPadding: (control.type === "text" ? 12 : 24) * MeoTheme.globalScale
    rightPadding: (control.type === "text" ? 12 : 24) * MeoTheme.globalScale
    topPadding: 10 * MeoTheme.globalScale
    bottomPadding: 10 * MeoTheme.globalScale

    // ==========================================
    // 🔤 文字内容区 (严格对齐你的 Label Large 规范)
    // ==========================================
    contentItem: Text {
        text: control.text
        font.pixelSize: 14 * MeoTheme.globalScale // 自动吃你的三级屏幕缩放公式
        font.weight: Font.Medium // Label Large 标准 500 字重
        font.letterSpacing: 0.1 // MD3 Label Large 字距规范
        color: control.textColor
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter

        // 丝滑变色动画
        Behavior on color {
            ColorAnimation {
                duration: 150
            }
        }
    }

    // ==========================================
    // 🖼️ 容器外观区 (处理边框、阴影和圆角)
    // ==========================================
    background: Rectangle {
        // 🌟 implicitWidth 体验优化：取最小宽度与“文本实际尺寸 + Padding”的最大值，防止长文本溢出
        implicitWidth: Math.max((control.type === "text" ? 48 : 64) * MeoTheme.globalScale, contentItem.implicitWidth + leftPadding + rightPadding)
        implicitHeight: 40 * MeoTheme.globalScale // MD3 标准高度
        radius: 20 * MeoTheme.globalScale // M3 标准全圆角胶囊状
        
        // 🌟 MD3 State Layer (状态层) 交互规范
        color: {
            let base = control.bgColor;
            let overlay = control.textColor;
            
            if (control.pressed)
                return Qt.tint(base, Qt.rgba(overlay.r, overlay.g, overlay.b, 0.12));
            if (control.hovered)
                return Qt.tint(base, Qt.rgba(overlay.r, overlay.g, overlay.b, 0.08));
            if (control.visualFocus)
                return Qt.tint(base, Qt.rgba(overlay.r, overlay.g, overlay.b, 0.10));
                
            return base;
        }

        // 只有 outlined 模式下才画边框
        border.color: {
            if (control.type !== "outlined") return "transparent";
            if (!control.enabled) return isDarkMode ? Qt.rgba(1, 1, 1, 0.12) : Qt.rgba(0, 0, 0, 0.12);
            return MeoTheme.outline;
        }
        border.width: control.type === "outlined" ? 1 : 0
        // 只有 elevated 模式下才开高度投影
        layer.enabled: control.type === "elevated"

        // 🌟 严格锁死你在文档里指定的 Fast Effects 贝塞尔曲线动效
        Behavior on color {
            ColorAnimation {
                duration: 150
                easing.bezierCurve: [0.34, 0.8, 0.34, 1] // 你的灵魂曲线
            }
        }
        
        Behavior on border.color {
            ColorAnimation {
                duration: 150
            }
        }
    }
}
