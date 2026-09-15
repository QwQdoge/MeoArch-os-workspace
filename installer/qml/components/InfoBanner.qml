import QtQuick
import MeoUI 1.0

MeoBanner {
    property string iconText: "i"
    property string iconFont: "Roboto"
    property string message: ""
    text: message
    icon: tone === "error" || tone === "warning" ? "warning"
          : tone === "success" ? "check_circle" : "info"
}
