import QtQuick
import MeoUI

Text {
    id: control

    property string typeRole: "body" // "title" | "body" | "label"
    property string typeSize: "medium" // "big" | "medium" | "small"
    property bool emphasized: false
    property string fontFamilyOverride: ""
    property int weightValue: {
        if (typeToken.weight === Font.Bold) return 700;
        if (typeToken.weight === Font.DemiBold) return 600;
        if (typeToken.weight === Font.Medium) return 500;
        return 400;
    }

    readonly property real themeGlobalScale: (typeof MeoTheme !== "undefined" && typeof MeoTheme.globalScale !== "undefined") ? MeoTheme.globalScale : 1.0
    readonly property var typeToken: (typeof MeoTheme !== "undefined" && typeof MeoTheme.typeToken !== "undefined")
                                     ? MeoTheme.typeToken(typeRole, typeSize, emphasized)
                                     : { "size": 14, "weight": Font.Normal, "lineHeight": 20, "letterSpacing": 0 }
    readonly property bool usesBrandTypeface: typeRole === "title" && (typeSize === "big" || typeSize === "large")

    font.family: fontFamilyOverride !== "" ? fontFamilyOverride
                 : (typeToken.family ? typeToken.family
                 : (usesBrandTypeface && typeof MeoTheme !== "undefined" ? MeoTheme.typefaceBrand : MeoTheme.typefacePlain))
    font.pixelSize: typeToken.size * themeGlobalScale
    font.weight: typeToken.weight
    font.variableAxes: ({ "wght": weightValue })
    font.letterSpacing: (typeToken.letterSpacing || 0) * themeGlobalScale
    // Fixed MD3 line boxes avoid the apparent baseline drift that proportional
    // line height causes when labels sit beside icons or controls.
    lineHeightMode: Text.FixedHeight
    lineHeight: typeToken.lineHeight ? typeToken.lineHeight * themeGlobalScale : font.pixelSize * 1.2
    verticalAlignment: Text.AlignVCenter
}
