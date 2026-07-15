import QtQuick
import MeoUI

QtObject {
    id: metrics

    property real availableWidth: 0
    property real availableHeight: 0
    property real scale: MeoTheme.globalScale
    property int maxColumns: 3
    property real minimumColumnWidth: 280

    readonly property real effectiveWidth: Math.max(0, availableWidth) / Math.max(0.1, scale)
    readonly property real effectiveHeight: Math.max(0, availableHeight) / Math.max(0.1, scale)
    readonly property string sizeClass: effectiveWidth <= MeoTheme.windowBreakpointSmall
                                              ? "small"
                                              : effectiveWidth < MeoTheme.windowBreakpointLarge
                                                ? "medium" : "large"
    readonly property bool isSmall: sizeClass === "small"
    readonly property bool isMedium: sizeClass === "medium"
    readonly property bool isLarge: sizeClass === "large"
    readonly property bool isCompact: isSmall
    readonly property bool isExpanded: isLarge
    readonly property bool isShort: effectiveHeight > 0 && effectiveHeight < 640

    readonly property real pageMargin: (isSmall ? 12 : isMedium ? 24 : 32) * scale
    readonly property real sectionSpacing: (isSmall ? 16 : 24) * scale
    readonly property real controlSpacing: (isSmall ? 8 : 12) * scale
    readonly property real paneWidth: (isSmall ? Math.min(320, effectiveWidth)
                                               : isMedium ? 80 : 280) * scale
    readonly property real maximumContentWidth: (isSmall ? effectiveWidth
                                                          : isMedium ? 920 : 1200) * scale
    readonly property string navigationMode: isSmall ? "minimal" : isMedium ? "compact" : "expanded"
    readonly property bool usesOverlayPane: !isLarge
    readonly property bool supportsTwoPane: !isSmall

    readonly property int preferredColumns: {
        if (isSmall) return 1
        const usableWidth = Math.max(0, effectiveWidth - (pageMargin * 2 / Math.max(0.1, scale)))
        const byWidth = Math.max(1, Math.floor((usableWidth + 24) / (minimumColumnWidth + 24)))
        return Math.min(maxColumns, isMedium ? Math.min(2, byWidth) : byWidth)
    }
}
