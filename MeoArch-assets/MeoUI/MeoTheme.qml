pragma Singleton
import QtQuick

QtObject {
    id: theme

    // 🌟 全局缩放因子（用于支持高分屏自适应）
    property real globalScale: 1.0

    // 🌟 主题模式开关
    property bool isDarkMode: false

    // 🌟 Material Design 3 调色板定义 (基于动态浅色/深色切换)
    property color primary: isDarkMode ? "#D0BCFF" : "#6750A4"
    property color onPrimary: isDarkMode ? "#381E72" : "#FFFFFF"
    property color primaryContainer: isDarkMode ? "#4F378B" : "#EADDFF"
    property color onPrimaryContainer: isDarkMode ? "#EADDFF" : "#21005D"

    property color secondary: isDarkMode ? "#CCC2DC" : "#625B71"
    property color onSecondary: isDarkMode ? "#332D41" : "#FFFFFF"
    property color secondaryContainer: isDarkMode ? "#4A4458" : "#E8DEF8"
    property color onSecondaryContainer: isDarkMode ? "#E8DEF8" : "#1D192B"

    property color tertiary: isDarkMode ? "#EFB8C8" : "#7D5260"
    property color onTertiary: isDarkMode ? "#492532" : "#FFFFFF"
    property color tertiaryContainer: isDarkMode ? "#633B48" : "#FFD8E4"
    property color onTertiaryContainer: isDarkMode ? "#FFD8E4" : "#31111D"

    property color surface: isDarkMode ? "#1C1B1F" : "#FFFBFE"
    property color onSurface: isDarkMode ? "#E6E1E5" : "#1C1B1F"
    property color surfaceVariant: isDarkMode ? "#49454F" : "#E7E0EC"
    property color onSurfaceVariant: isDarkMode ? "#CAC4D0" : "#49454F"
    
    // M3 Surface Containers
    property color surfaceContainerLowest: isDarkMode ? "#0F0E11" : "#FFFFFF"
    property color surfaceContainerLow: isDarkMode ? "#1D1B20" : "#F7F2FA"
    property color surfaceContainer: isDarkMode ? "#211F26" : "#F3EDF7"
    property color surfaceContainerHigh: isDarkMode ? "#2B2930" : "#ECE6F0"
    property color surfaceContainerHighest: isDarkMode ? "#36343B" : "#E6E1E5"

    property color outline: isDarkMode ? "#938F99" : "#79747E"
    property color outlineVariant: isDarkMode ? "#44474F" : "#C4C7C5"

    property color error: isDarkMode ? "#F2B8B5" : "#B3261E"
    property color onError: isDarkMode ? "#601410" : "#FFFFFF"
    property color errorContainer: isDarkMode ? "#8C1D18" : "#F9DEDC"
    property color onErrorContainer: isDarkMode ? "#F9DEDC" : "#410E0B"

    // 🌟 辅助/窗口背景色
    property color windowBg: isDarkMode ? "#121212" : "#F4F4F6"
    property color background: windowBg

    // 🌟 M3 间距网格系统 (Spacing Tokens)
    property int space2: 2
    property int space4: 4
    property int space8: 8
    property int space12: 12
    property int space16: 16
    property int space24: 24
    property int space32: 32
    property int space40: 40
    property int space48: 48

    // 🌟 兼容老版组件的 Padding 定义
    property int compactPadding: 8
    property int standardPadding: 16
    property int largePadding: 24
}
