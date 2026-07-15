import QtQuick
import MeoUI 1.0 as Meo

Meo.MeoIconButton {
    id: control
    property string iconText: ""
    property string iconFont: "Roboto"
    property string accessibleName: ""
    readonly property string mappedIcon: iconText === "?" ? "help"
                                               : iconText === "L" ? "language"
                                               : iconText === "P" ? "power_settings_new"
                                               : iconText
    size: "l"
    type: selected ? "filled" : "tonal"
    icon.name: mappedIcon
    Accessible.name: accessibleName
}
