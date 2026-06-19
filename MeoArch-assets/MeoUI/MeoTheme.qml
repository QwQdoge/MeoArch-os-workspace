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

    // 🌟 Surface Tint Helper (MD3 Elevation Overlay)
    function surfaceTint(level) {
        let opacities = [0, 0.05, 0.08, 0.11, 0.12, 0.14];
        let opacity = opacities[Math.min(Math.max(level, 0), 5)];
        return Qt.tint(surface, Qt.rgba(primary.r, primary.g, primary.b, opacity));
    }

    // 🌟 Motion Tokens (MD3 Standard)
    readonly property var motionDurationShort1: 50
    readonly property var motionDurationShort2: 100
    readonly property var motionDurationShort3: 150
    readonly property var motionDurationShort4: 200
    readonly property var motionDurationMedium1: 250
    readonly property var motionDurationMedium2: 300
    readonly property var motionDurationMedium3: 350
    readonly property var motionDurationMedium4: 400
    readonly property var motionDurationLong1: 450
    readonly property var motionDurationLong2: 500
    readonly property var motionDurationLong3: 550
    readonly property var motionDurationLong4: 600

    readonly property var motionEasingStandard: [0.2, 0, 0, 1]
    readonly property var motionEasingStandardAccelerate: [0.3, 0, 1, 1]
    readonly property var motionEasingStandardDecelerate: [0, 0, 0, 1]
    readonly property var motionEasingEmphasized: [0.2, 0, 0, 1] // Simplified for Soul Curve compatibility
    readonly property var motionEasingEmphasizedAccelerate: [0.3, 0, 0.8, 0.15]
    readonly property var motionEasingEmphasizedDecelerate: [0.05, 0.7, 0.1, 1]

    // 🌟 Soul Curve (MD3 Expressive Standard)
    readonly property var motionEasingSoul: [0.34, 0.8, 0.34, 1.0]

    property color outline: isDarkMode ? "#938F99" : "#79747E"
    property color outlineVariant: isDarkMode ? "#44474F" : "#C4C7C5"

    property color error: isDarkMode ? "#F2B8B5" : "#B3261E"
    property color onError: isDarkMode ? "#601410" : "#FFFFFF"
    property color errorContainer: isDarkMode ? "#8C1D18" : "#F9DEDC"
    property color onErrorContainer: isDarkMode ? "#F9DEDC" : "#410E0B"

    // MD3 Fixed Colors (Same in both Light and Dark mode)
    property color primaryFixed: "#EADDFF"
    property color onPrimaryFixed: "#21005D"
    property color primaryFixedDim: "#D0BCFF"
    property color onPrimaryFixedVariant: "#4F378B"

    property color secondaryFixed: "#E8DEF8"
    property color onSecondaryFixed: "#1D192B"
    property color secondaryFixedDim: "#CCC2DC"
    property color onSecondaryFixedVariant: "#4A4458"

    property color tertiaryFixed: "#FFD8E4"
    property color onTertiaryFixed: "#31111D"
    property color tertiaryFixedDim: "#EFB8C8"
    property color onTertiaryFixedVariant: "#633B48"

    // 🌟 辅助/窗口背景色
    property color windowBg: isDarkMode ? "#121212" : "#F4F4F6"
    property color background: windowBg

    // 🌟 M3 Shape Scale (MD3 Standard)
    readonly property real shapeNone: 0
    readonly property real shapeExtraSmall: 4 * globalScale
    readonly property real shapeSmall: 8 * globalScale
    readonly property real shapeMedium: 12 * globalScale
    readonly property real shapeLarge: 16 * globalScale
    readonly property real shapeLargeIncreased: 20 * globalScale
    readonly property real shapeExtraLarge: 28 * globalScale
    readonly property real shapeExtraLargeIncreased: 32 * globalScale
    readonly property real shapeExtraExtraLarge: 48 * globalScale
    readonly property real shapeFull: 1000 * globalScale // Large value for full rounding

    // 🌟 MD3 Expressive Dimension Tokens
    readonly property real buttonHeightXS: 32 * globalScale
    readonly property real buttonHeightS: 40 * globalScale
    readonly property real buttonHeightM: 48 * globalScale
    readonly property real buttonHeightL: 56 * globalScale
    readonly property real buttonHeightXL: 72 * globalScale

    readonly property real sliderTrackHeightXS: 4 * globalScale
    readonly property real sliderTrackHeightS: 16 * globalScale
    readonly property real sliderTrackHeightM: 28 * globalScale
    readonly property real sliderTrackHeightL: 36 * globalScale
    readonly property real sliderTrackHeightXL: 44 * globalScale

    readonly property real shapeSquareRadius: 4 * globalScale

    // 🌟 MD3 Expressive Shape Library (Conceptual Tokens)
    readonly property string shapeSquircle: "squircle"
    readonly property string shapeHexagon: "hexagon"
    readonly property string shapeDiamond: "diamond"
    readonly property string shapePentagon: "pentagon"
    readonly property string shapeOctagon: "octagon"

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

    // 🌟 Material Design 3 Typography (Type Scale)
    // Format: { size, weight, lineHeight, letterSpacing }

    // Display
    readonly property var displayLarge: { "size": 57, "weight": Font.Normal, "lineHeight": 64, "letterSpacing": -0.25 }
    readonly property var displayMedium: { "size": 45, "weight": Font.Normal, "lineHeight": 52, "letterSpacing": 0 }
    readonly property var displaySmall: { "size": 36, "weight": Font.Normal, "lineHeight": 44, "letterSpacing": 0 }

    // Headline
    readonly property var headlineLarge: { "size": 32, "weight": Font.Normal, "lineHeight": 40, "letterSpacing": 0 }
    readonly property var headlineMedium: { "size": 28, "weight": Font.Normal, "lineHeight": 36, "letterSpacing": 0 }
    readonly property var headlineSmall: { "size": 24, "weight": Font.Normal, "lineHeight": 32, "letterSpacing": 0 }

    // Title
    readonly property var titleLarge: { "size": 22, "weight": Font.Normal, "lineHeight": 28, "letterSpacing": 0 }
    readonly property var titleMedium: { "size": 16, "weight": Font.Medium, "lineHeight": 24, "letterSpacing": 0.15 }
    readonly property var titleSmall: { "size": 14, "weight": Font.Medium, "lineHeight": 20, "letterSpacing": 0.1 }

    // Body
    readonly property var bodyLarge: { "size": 16, "weight": Font.Normal, "lineHeight": 24, "letterSpacing": 0.5 }
    readonly property var bodyMedium: { "size": 14, "weight": Font.Normal, "lineHeight": 20, "letterSpacing": 0.25 }
    readonly property var bodySmall: { "size": 12, "weight": Font.Normal, "lineHeight": 16, "letterSpacing": 0.4 }

    // Label
    readonly property var labelLarge: { "size": 14, "weight": Font.Medium, "lineHeight": 20, "letterSpacing": 0.1 }
    readonly property var labelMedium: { "size": 12, "weight": Font.Medium, "lineHeight": 16, "letterSpacing": 0.5 }
    readonly property var labelSmall: { "size": 11, "weight": Font.Medium, "lineHeight": 16, "letterSpacing": 0.5 }

    // 🌟 MD3 Expressive Typography (Emphasized Type Scale)
    // Display Emphasized (Bold weight 700)
    readonly property var displayLargeEmphasized: { "size": 57, "weight": Font.Bold, "lineHeight": 64, "letterSpacing": -0.25 }
    readonly property var displayMediumEmphasized: { "size": 45, "weight": Font.Bold, "lineHeight": 52, "letterSpacing": 0 }
    readonly property var displaySmallEmphasized: { "size": 36, "weight": Font.Bold, "lineHeight": 44, "letterSpacing": 0 }

    // Headline Emphasized (Bold weight 700)
    readonly property var headlineLargeEmphasized: { "size": 32, "weight": Font.Bold, "lineHeight": 40, "letterSpacing": 0 }
    readonly property var headlineMediumEmphasized: { "size": 28, "weight": Font.Bold, "lineHeight": 36, "letterSpacing": 0 }
    readonly property var headlineSmallEmphasized: { "size": 24, "weight": Font.Bold, "lineHeight": 32, "letterSpacing": 0 }

    // Title Emphasized (DemiBold weight 600)
    readonly property var titleLargeEmphasized: { "size": 22, "weight": Font.DemiBold, "lineHeight": 28, "letterSpacing": 0 }
    readonly property var titleMediumEmphasized: { "size": 16, "weight": Font.DemiBold, "lineHeight": 24, "letterSpacing": 0.15 }
    readonly property var titleSmallEmphasized: { "size": 14, "weight": Font.DemiBold, "lineHeight": 20, "letterSpacing": 0.1 }

    // Body Emphasized (DemiBold weight 600)
    readonly property var bodyLargeEmphasized: { "size": 16, "weight": Font.DemiBold, "lineHeight": 24, "letterSpacing": 0.5 }
    readonly property var bodyMediumEmphasized: { "size": 14, "weight": Font.DemiBold, "lineHeight": 20, "letterSpacing": 0.25 }
    readonly property var bodySmallEmphasized: { "size": 12, "weight": Font.DemiBold, "lineHeight": 16, "letterSpacing": 0.4 }

    // Label Emphasized (DemiBold weight 600)
    readonly property var labelLargeEmphasized: { "size": 14, "weight": Font.DemiBold, "lineHeight": 20, "letterSpacing": 0.1 }
    readonly property var labelMediumEmphasized: { "size": 12, "weight": Font.DemiBold, "lineHeight": 16, "letterSpacing": 0.5 }
    readonly property var labelSmallEmphasized: { "size": 11, "weight": Font.DemiBold, "lineHeight": 16, "letterSpacing": 0.5 }
}
