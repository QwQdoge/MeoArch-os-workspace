import QtQuick
import MeoUI

Text {
    id: control

    property string typeRole: "body" // "title" | "body" | "label"
    property string typeSize: "medium" // "big" | "medium" | "small"
    property bool emphasized: false
    property string fontFamilyOverride: ""

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
    font.letterSpacing: (typeToken.letterSpacing || 0) * themeGlobalScale
    lineHeight: typeToken.lineHeight ? typeToken.lineHeight / typeToken.size : 1.2
}
