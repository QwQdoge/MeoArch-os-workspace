pragma Singleton
import QtQuick

QtObject {
    id: theme

    // 🌟 全局缩放因子（用于支持高分屏自适应）
    property real globalScale: 1.0

    // 🌟 主题模式开关
    property bool isDarkMode: false
    property bool isExpressive: false
    property bool isBouncy: true
    property bool reduceMotion: false
    property bool transparencyEnabled: true

    // Material 3 adaptive window classes, expressed in effective pixels.
    readonly property real windowBreakpointMedium: 600
    readonly property real windowBreakpointExpanded: 840
    readonly property real windowBreakpointLarge: 1200
    readonly property real windowBreakpointExtraLarge: 1600
    readonly property real windowHeightBreakpointMedium: 480
    readonly property real windowHeightBreakpointExpanded: 900

    function windowWidthSizeClass(availableWidth) {
        const effectiveWidth = Math.max(0, availableWidth) / Math.max(0.1, globalScale)
        if (effectiveWidth < windowBreakpointMedium) return "compact"
        if (effectiveWidth < windowBreakpointExpanded) return "medium"
        if (effectiveWidth < windowBreakpointLarge) return "expanded"
        if (effectiveWidth < windowBreakpointExtraLarge) return "large"
        return "extraLarge"
    }

    function windowHeightSizeClass(availableHeight) {
        const effectiveHeight = Math.max(0, availableHeight) / Math.max(0.1, globalScale)
        if (effectiveHeight < windowHeightBreakpointMedium) return "compact"
        if (effectiveHeight < windowHeightBreakpointExpanded) return "medium"
        return "expanded"
    }

    function windowPageMargin(availableWidth) {
        const sizeClass = windowWidthSizeClass(availableWidth)
        if (sizeClass === "compact") return 16 * globalScale
        if (sizeClass === "medium" || sizeClass === "expanded") return 24 * globalScale
        if (sizeClass === "large") return 32 * globalScale
        return 40 * globalScale
    }

    // 🎨 MeoArch MD3 fallback color schemes
    // Used role-by-role whenever a dynamic color scheme is unavailable or incomplete.
    readonly property var fallbackLightColorScheme: ({
        "primary": "#6750A4",
        "onPrimary": "#FFFFFF",
        "primaryContainer": "#CBC0E6",
        "onPrimaryContainer": "#201933",
        "secondary": "#625B71",
        "onSecondary": "#FFFFFF",
        "secondaryContainer": "#DCD8E6",
        "onSecondaryContainer": "#2C2933",
        "tertiary": "#7D5260",
        "onTertiary": "#FFFFFF",
        "tertiaryContainer": "#E6CDD5",
        "onTertiaryContainer": "#332227",
        "error": "#B3261E",
        "onError": "#FFFFFF",
        "errorContainer": "#E6ACA9",
        "onErrorContainer": "#330B09",
        "background": "#FCFCFC",
        "onBackground": "#323233",
        "surface": "#FCFCFC",
        "onSurface": "#323233",
        "surfaceVariant": "#E0DEE6",
        "onSurfaceVariant": "#5E5C66",
        "outline": "#8E8999",
        "outlineVariant": "#C4C7C5",
        "surfaceContainerLowest": "#FFFFFF",
        "surfaceContainerLow": "#F7F2FA",
        "surfaceContainer": "#F3EDF7",
        "surfaceContainerHigh": "#ECE6F0",
        "surfaceContainerHighest": "#E6E1E5",
        "inverseSurface": "#313033",
        "onInverseSurface": "#F4F0F4"
    })

    readonly property var fallbackDarkColorScheme: ({
        "primary": "#C0B1E6",
        "onPrimary": "#30254C",
        "primaryContainer": "#403266",
        "onPrimaryContainer": "#CBC0E6",
        "secondary": "#D8D2E6",
        "onSecondary": "#433E4C",
        "secondaryContainer": "#595366",
        "onSecondaryContainer": "#DCD8E6",
        "tertiary": "#E6C3CE",
        "onTertiary": "#4C323B",
        "tertiaryContainer": "#66434F",
        "onTertiaryContainer": "#E6CDD5",
        "error": "#E69490",
        "onError": "#4C100D",
        "errorContainer": "#661511",
        "onErrorContainer": "#E6ACA9",
        "background": "#323233",
        "onBackground": "#E4E4E6",
        "surface": "#323233",
        "onSurface": "#E4E4E6",
        "surfaceVariant": "#5E5C66",
        "onSurfaceVariant": "#DEDBE6",
        "outline": "#AAA7B3",
        "outlineVariant": "#44474F",
        "surfaceContainerLowest": "#0F0E11",
        "surfaceContainerLow": "#1D1B20",
        "surfaceContainer": "#211F26",
        "surfaceContainerHigh": "#2B2930",
        "surfaceContainerHighest": "#36343B",
        "inverseSurface": "#E6E1E5",
        "onInverseSurface": "#313033"
    })

    // 🎨 Dynamic color provider API
    // Replace the complete object through applyDynamicColorScheme() so QML bindings update.
    property bool dynamicColorsAvailable: false
    property var dynamicColorScheme: ({})

    function applyDynamicColorScheme(scheme) {
        dynamicColorScheme = scheme || ({})
        dynamicColorsAvailable = scheme !== null && typeof scheme === "object"
    }

    function clearDynamicColorScheme() {
        dynamicColorsAvailable = false
        dynamicColorScheme = ({})
    }

    function colorForRole(role, darkMode, dynamicAvailable, scheme) {
        const fallbackScheme = darkMode ? fallbackDarkColorScheme : fallbackLightColorScheme
        if (dynamicAvailable
                && scheme
                && typeof scheme[role] !== "undefined"
                && scheme[role] !== null
                && scheme[role] !== "") {
            return scheme[role]
        }
        return fallbackScheme[role]
    }

    function dynamicOrFallback(role) {
        if (dynamicColorsAvailable
                && dynamicColorScheme
                && typeof dynamicColorScheme[role] !== "undefined"
                && dynamicColorScheme[role] !== null
                && dynamicColorScheme[role] !== "") {
            return dynamicColorScheme[role]
        }
        return isDarkMode ? fallbackDarkColorScheme[role] : fallbackLightColorScheme[role]
    }

    // 🎨 Active MD3 roles. Content roles use a non-`onXxx` public name because
    // QML reserves that shape for signal handlers in several compiled paths.
    property color primary: dynamicColorsAvailable && dynamicColorScheme.primary ? dynamicColorScheme.primary : (isDarkMode ? "#C0B1E6" : "#6750A4")
    property color contentOnPrimary: dynamicColorsAvailable && dynamicColorScheme.onPrimary ? dynamicColorScheme.onPrimary : (isDarkMode ? "#30254C" : "#FFFFFF")
    property color primaryContainer: dynamicColorsAvailable && dynamicColorScheme.primaryContainer ? dynamicColorScheme.primaryContainer : (isDarkMode ? "#403266" : "#CBC0E6")
    property color contentOnPrimaryContainer: dynamicColorsAvailable && dynamicColorScheme.onPrimaryContainer ? dynamicColorScheme.onPrimaryContainer : (isDarkMode ? "#CBC0E6" : "#201933")

    property color secondary: dynamicColorsAvailable && dynamicColorScheme.secondary ? dynamicColorScheme.secondary : (isDarkMode ? "#D8D2E6" : "#625B71")
    property color contentOnSecondary: dynamicColorsAvailable && dynamicColorScheme.onSecondary ? dynamicColorScheme.onSecondary : (isDarkMode ? "#433E4C" : "#FFFFFF")
    property color secondaryContainer: dynamicColorsAvailable && dynamicColorScheme.secondaryContainer ? dynamicColorScheme.secondaryContainer : (isDarkMode ? "#595366" : "#DCD8E6")
    property color contentOnSecondaryContainer: dynamicColorsAvailable && dynamicColorScheme.onSecondaryContainer ? dynamicColorScheme.onSecondaryContainer : (isDarkMode ? "#DCD8E6" : "#2C2933")

    property color tertiary: dynamicColorsAvailable && dynamicColorScheme.tertiary ? dynamicColorScheme.tertiary : (isDarkMode ? "#E6C3CE" : "#7D5260")
    property color contentOnTertiary: dynamicColorsAvailable && dynamicColorScheme.onTertiary ? dynamicColorScheme.onTertiary : (isDarkMode ? "#4C323B" : "#FFFFFF")
    property color tertiaryContainer: dynamicColorsAvailable && dynamicColorScheme.tertiaryContainer ? dynamicColorScheme.tertiaryContainer : (isDarkMode ? "#66434F" : "#E6CDD5")
    property color contentOnTertiaryContainer: dynamicColorsAvailable && dynamicColorScheme.onTertiaryContainer ? dynamicColorScheme.onTertiaryContainer : (isDarkMode ? "#E6CDD5" : "#332227")

    property color error: dynamicColorsAvailable && dynamicColorScheme.error ? dynamicColorScheme.error : (isDarkMode ? "#E69490" : "#B3261E")
    property color contentOnError: dynamicColorsAvailable && dynamicColorScheme.onError ? dynamicColorScheme.onError : (isDarkMode ? "#4C100D" : "#FFFFFF")
    property color errorContainer: dynamicColorsAvailable && dynamicColorScheme.errorContainer ? dynamicColorScheme.errorContainer : (isDarkMode ? "#661511" : "#E6ACA9")
    property color contentOnErrorContainer: dynamicColorsAvailable && dynamicColorScheme.onErrorContainer ? dynamicColorScheme.onErrorContainer : (isDarkMode ? "#E6ACA9" : "#330B09")

    property color background: dynamicColorsAvailable && dynamicColorScheme.background ? dynamicColorScheme.background : (isDarkMode ? "#323233" : "#FCFCFC")
    property color contentOnBackground: dynamicColorsAvailable && dynamicColorScheme.onBackground ? dynamicColorScheme.onBackground : (isDarkMode ? "#E4E4E6" : "#323233")
    property color surface: dynamicColorsAvailable && dynamicColorScheme.surface ? dynamicColorScheme.surface : (isDarkMode ? "#323233" : "#FCFCFC")
    property color contentOnSurface: dynamicColorsAvailable && dynamicColorScheme.onSurface ? dynamicColorScheme.onSurface : (isDarkMode ? "#E4E4E6" : "#323233")
    property color surfaceVariant: dynamicColorsAvailable && dynamicColorScheme.surfaceVariant ? dynamicColorScheme.surfaceVariant : (isDarkMode ? "#5E5C66" : "#E0DEE6")
    property color contentOnSurfaceVariant: dynamicColorsAvailable && dynamicColorScheme.onSurfaceVariant ? dynamicColorScheme.onSurfaceVariant : (isDarkMode ? "#DEDBE6" : "#5E5C66")
    property color outline: dynamicColorsAvailable && dynamicColorScheme.outline ? dynamicColorScheme.outline : (isDarkMode ? "#AAA7B3" : "#8E8999")
    
    // M3 Surface Containers
    property color surfaceContainerLowest: dynamicOrFallback("surfaceContainerLowest")
    property color surfaceContainerLow: dynamicOrFallback("surfaceContainerLow")
    property color surfaceContainer: dynamicOrFallback("surfaceContainer")
    property color surfaceContainerHigh: dynamicOrFallback("surfaceContainerHigh")
    property color surfaceContainerHighest: dynamicOrFallback("surfaceContainerHighest")

    // 🌟 Surface Tint Helper (MD3 Elevation Overlay)
    function surfaceTint(level) {
        let opacities = [0, 0.05, 0.08, 0.11, 0.12, 0.14];
        let opacity = opacities[Math.min(Math.max(level, 0), 5)];
        return Qt.tint(surface, Qt.rgba(primary.r, primary.g, primary.b, opacity));
    }

    // 🌟 Motion Tokens (MD3 Standard)
    readonly property int motionDurationShort1: reduceMotion ? 0 : 50
    readonly property int motionDurationShort2: reduceMotion ? 0 : 100
    readonly property int motionDurationShort3: reduceMotion ? 0 : 150
    readonly property int motionDurationShort4: reduceMotion ? 0 : 200
    readonly property int motionDurationMedium1: reduceMotion ? 0 : 250
    readonly property int motionDurationMedium2: reduceMotion ? 0 : 300
    readonly property int motionDurationMedium3: reduceMotion ? 0 : 350
    readonly property int motionDurationMedium4: reduceMotion ? 0 : 400
    readonly property int motionDurationLong1: reduceMotion ? 0 : 450
    readonly property int motionDurationLong2: reduceMotion ? 0 : 500
    readonly property int motionDurationLong3: reduceMotion ? 0 : 550
    readonly property int motionDurationLong4: reduceMotion ? 0 : 600
    readonly property int motionDurationExtraLong1: reduceMotion ? 0 : 700
    readonly property int motionDurationExtraLong2: reduceMotion ? 0 : 800
    readonly property int motionDurationExtraLong3: reduceMotion ? 0 : 900
    readonly property int motionDurationExtraLong4: reduceMotion ? 0 : 1000

    // Material 3 semantic motion aliases for component code.
    readonly property var motionDurationInstant: motionDurationShort1
    // Interactive desktop feedback needs to acknowledge a pointer immediately.
    // Longer values stay reserved for spatial transitions rather than hover/press.
    readonly property var motionDurationFast: reduceMotion ? 0 : 120
    readonly property var motionDurationMedium: reduceMotion ? 0 : 220
    readonly property var motionDurationSlow: reduceMotion ? 0 : 320
    readonly property var motionDurationRippleExpand: reduceMotion ? 0 : 280
    readonly property var motionDurationRippleFade: reduceMotion ? 0 : 160
    readonly property int motionDurationState: reduceMotion ? 0 : 100
    readonly property int motionDurationSelection: reduceMotion ? 0 : 220
    readonly property int motionDurationShapeEnter: reduceMotion ? 0 : 140
    readonly property int motionDurationShapeSettle: reduceMotion ? 0 : 220
    readonly property int motionDurationDialogEnter: reduceMotion ? 0 : 240
    readonly property int motionDurationDialogExit: reduceMotion ? 0 : 160
    readonly property int motionDurationMenuEnter: reduceMotion ? 0 : 160
    readonly property int motionDurationMenuExit: reduceMotion ? 0 : 120
    readonly property int motionDurationSheetEnter: reduceMotion ? 0 : 320
    readonly property int motionDurationSheetExit: reduceMotion ? 0 : 220
    readonly property int motionDurationPage: reduceMotion ? 0 : 320

    readonly property list<real> motionEasingStandard: [0.2, 0, 0, 1]
    readonly property list<real> motionEasingStandardAccelerate: [0.3, 0, 1, 1]
    readonly property list<real> motionEasingStandardDecelerate: [0, 0, 0, 1]
    readonly property list<real> motionEasingEmphasized: [0.05, 0.7, 0.1, 1]
    readonly property list<real> motionEasingEmphasizedAccelerate: [0.3, 0, 0.8, 0.15]
    readonly property list<real> motionEasingEmphasizedDecelerate: [0.05, 0.7, 0.1, 1]
    readonly property list<real> motionEasingEnter: [0, 0, 0, 1]
    readonly property list<real> motionEasingExit: [1, 0, 1, 1]

    // Compatibility alias used by existing expressive components.
    readonly property list<real> motionEasingSoul: motionEasingEmphasized

    // MD3 state-layer opacity tokens.
    readonly property real stateOpacityHover: 0.10
    readonly property real stateOpacityFocus: 0.12
    readonly property real stateOpacityPressed: 0.14
    readonly property real stateOpacityDragged: 0.16

    // Semantic feedback and surface roles used by products consuming MeoUI.
    readonly property real disabledContainerOpacity: 0.12
    readonly property real disabledContentOpacity: 0.38
    readonly property color scrim: "#000000"
    readonly property color shadow: "#000000"
    readonly property color inverseSurface: dynamicOrFallback("inverseSurface")
    readonly property color contentOnInverseSurface: dynamicOrFallback("onInverseSurface")
    readonly property color success: isDarkMode ? "#8ED6A0" : "#256D3A"
    readonly property color successContainer: isDarkMode ? "#164A27" : "#D8F3DC"
    readonly property color contentOnSuccessContainer: isDarkMode ? "#C1F1CB" : "#123C20"

    property color outlineVariant: dynamicOrFallback("outlineVariant")

    // MD3 Fixed Colors (Same in both Light and Dark mode)
    property color primaryFixed: "#EADDFF"
    property color fixedOnPrimary: "#21005D"
    property color primaryFixedDim: "#D0BCFF"
    property color fixedOnPrimaryVariant: "#4F378B"

    property color secondaryFixed: "#E8DEF8"
    property color fixedOnSecondary: "#1D192B"
    property color secondaryFixedDim: "#CCC2DC"
    property color fixedOnSecondaryVariant: "#4A4458"

    property color tertiaryFixed: "#FFD8E4"
    property color fixedOnTertiary: "#31111D"
    property color tertiaryFixedDim: "#EFB8C8"
    property color fixedOnTertiaryVariant: "#633B48"

    // 🌟 辅助/窗口背景色
    property color windowBg: background

    // 🌟 M3 Shape Scale (MD3 Standard)
    readonly property real shapeNone: 0
    readonly property real shapeExtraSmall: 4 * globalScale
    readonly property real shapeSmall: 8 * globalScale
    readonly property real shapeMedium: 12 * globalScale
    readonly property real shapeLarge: 16 * globalScale
    readonly property real shapeLargeIncreased: 20 * globalScale
    readonly property real shapeExtraLarge: 28 * globalScale
    readonly property real shapeExtraLargeIncreased: 32 * globalScale
    readonly property real expressiveShapeCornerRadius: 32 * globalScale
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

    readonly property real sliderThumbWidthExpressive: 4 * globalScale
    readonly property real sliderThumbHeightExpressive: 44 * globalScale
    readonly property real sliderThumbGapExpressive: 6 * globalScale

    readonly property real shapeSquareRadius: 4 * globalScale

    // 🌟 Semantic thickness tokens
    readonly property real strokeWidthThin: 1 * globalScale
    readonly property real strokeWidthMedium: 2 * globalScale
    readonly property real strokeWidthThick: 3 * globalScale

    // 🌟 MD3 Expressive Shape Library (Conceptual Tokens)
    readonly property string shapeSquircle: "squircle"
    readonly property string shapeHexagon: "hexagon"
    readonly property string shapeDiamond: "diamond"
    readonly property string shapePentagon: "pentagon"
    readonly property string shapeOctagon: "octagon"

    // 🌟 M3 间距网格系统 (Spacing Tokens)
    readonly property real space2: 2 * globalScale
    readonly property real space4: 4 * globalScale
    readonly property real space8: 8 * globalScale
    readonly property real space12: 12 * globalScale
    readonly property real space16: 16 * globalScale
    readonly property real space24: 24 * globalScale
    readonly property real space32: 32 * globalScale
    readonly property real space40: 40 * globalScale
    readonly property real space48: 48 * globalScale

    // 🌟 兼容老版组件的 Padding 定义
    readonly property real compactPadding: 8 * globalScale
    readonly property real standardPadding: 16 * globalScale
    readonly property real largePadding: 24 * globalScale

    // 🌟 Material Design 3 Typography (Type Scale)
    // Format: { size, weight, lineHeight, letterSpacing }
    readonly property string typefacePlain: "Roboto"
    readonly property string typefaceBrand: "Comfortaa"
    readonly property string typefaceChineseFallback: "Noto Sans SC, Microsoft YaHei, Source Han Sans SC"

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

    // 🌟 Meo semantic typography tokens.
    // Use these in pages/components instead of raw pixel sizes.
    readonly property var titleBig: { "size": 40, "weight": Font.Bold, "lineHeight": 48, "letterSpacing": 0, "family": typefaceBrand }
    readonly property var titleMediumUi: { "size": 26, "weight": Font.Bold, "lineHeight": 34, "letterSpacing": 0, "family": typefacePlain }
    readonly property var titleSmallUi: { "size": 16, "weight": Font.Bold, "lineHeight": 24, "letterSpacing": 0, "family": typefacePlain }
    readonly property var bodyBig: { "size": 18, "weight": Font.Normal, "lineHeight": 28, "letterSpacing": 0, "family": typefacePlain }
    readonly property var bodyMediumUi: { "size": 15, "weight": Font.Normal, "lineHeight": 22, "letterSpacing": 0, "family": typefacePlain }
    readonly property var bodySmallUi: { "size": 14, "weight": Font.Normal, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelBig: { "size": 15, "weight": Font.Medium, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelMediumUi: { "size": 14, "weight": Font.Medium, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelSmallUi: { "size": 12, "weight": Font.Medium, "lineHeight": 16, "letterSpacing": 0, "family": typefacePlain }

    readonly property var titleBigEmphasized: titleBig
    readonly property var titleMediumUiEmphasized: titleMediumUi
    readonly property var titleSmallUiEmphasized: titleSmallUi
    readonly property var bodyBigEmphasized: { "size": 18, "weight": Font.Bold, "lineHeight": 28, "letterSpacing": 0, "family": typefacePlain }
    readonly property var bodyMediumUiEmphasized: { "size": 15, "weight": Font.Bold, "lineHeight": 22, "letterSpacing": 0, "family": typefacePlain }
    readonly property var bodySmallUiEmphasized: { "size": 14, "weight": Font.Bold, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelBigEmphasized: { "size": 15, "weight": Font.Bold, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelMediumUiEmphasized: { "size": 14, "weight": Font.Bold, "lineHeight": 20, "letterSpacing": 0, "family": typefacePlain }
    readonly property var labelSmallUiEmphasized: { "size": 12, "weight": Font.Bold, "lineHeight": 16, "letterSpacing": 0, "family": typefacePlain }

    function typeToken(role, size, emphasized) {
        const normalizedRole = role || "body"
        const normalizedSize = size || "medium"

        if (normalizedRole === "title") {
            if (normalizedSize === "big" || normalizedSize === "large") return emphasized ? titleBigEmphasized : titleBig
            if (normalizedSize === "small") return emphasized ? titleSmallUiEmphasized : titleSmallUi
            return emphasized ? titleMediumUiEmphasized : titleMediumUi
        }

        if (normalizedRole === "body") {
            if (normalizedSize === "big" || normalizedSize === "large") return emphasized ? bodyBigEmphasized : bodyBig
            if (normalizedSize === "small") return emphasized ? bodySmallUiEmphasized : bodySmallUi
            return emphasized ? bodyMediumUiEmphasized : bodyMediumUi
        }

        if (normalizedRole === "label") {
            if (normalizedSize === "big" || normalizedSize === "large") return emphasized ? labelBigEmphasized : labelBig
            if (normalizedSize === "small") return emphasized ? labelSmallUiEmphasized : labelSmallUi
            return emphasized ? labelMediumUiEmphasized : labelMediumUi
        }

        return bodyMediumUi
    }
}
