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
    readonly property string widthSizeClass: MeoTheme.windowWidthSizeClass(availableWidth)
    readonly property string heightSizeClass: MeoTheme.windowHeightSizeClass(availableHeight)
    readonly property bool isCompactWidth: widthSizeClass === "compact"
    readonly property bool isMediumWidth: widthSizeClass === "medium"
    readonly property bool isExpandedWidth: widthSizeClass === "expanded"
    readonly property bool isLargeWidth: widthSizeClass === "large"
    readonly property bool isExtraLargeWidth: widthSizeClass === "extraLarge"
    readonly property bool isCompactHeight: heightSizeClass === "compact"
    readonly property bool isMediumHeight: heightSizeClass === "medium"
    readonly property bool isExpandedHeight: heightSizeClass === "expanded"

    readonly property real pageMargin: MeoTheme.windowPageMargin(availableWidth)
    readonly property real sectionSpacing: (isCompactWidth ? 16 : 24) * scale
    readonly property real controlSpacing: (isCompactWidth ? 8 : 12) * scale
    readonly property real paneWidth: (isCompactWidth ? Math.min(360, effectiveWidth)
                                                       : isMediumWidth ? 80
                                                       : isExpandedWidth ? 256 : 280) * scale
    readonly property real maximumContentWidth: (isCompactWidth ? effectiveWidth
                                                                  : isMediumWidth ? 840
                                                                  : isExpandedWidth ? 1040
                                                                  : isLargeWidth ? 1200 : 1440) * scale
    readonly property string navigationMode: isCompactWidth ? "bottomBar"
                                                              : isMediumWidth ? "rail"
                                                              : isExpandedWidth ? "expandedRail" : "drawer"
    readonly property bool usesOverlayPane: isCompactWidth || isMediumWidth
    readonly property bool supportsTwoPane: isExpandedWidth || isLargeWidth || isExtraLargeWidth

    readonly property int preferredColumns: {
        if (isCompactWidth) return 1
        const usableWidth = Math.max(0, effectiveWidth - (pageMargin * 2 / Math.max(0.1, scale)))
        const byWidth = Math.max(1, Math.floor((usableWidth + 24) / (minimumColumnWidth + 24)))
        return Math.min(maxColumns, isMediumWidth ? Math.min(2, byWidth) : byWidth)
    }
}
