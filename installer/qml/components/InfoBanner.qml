import QtQuick
import MeoUI 1.0 as Meo

Meo.MeoBanner {
    property string iconText: "i"
    property string iconFont: "Roboto"
    property string message: ""
    text: message
    icon: tone === "error" ? "warning" : tone === "success" ? "check_circle" : "info"
}
