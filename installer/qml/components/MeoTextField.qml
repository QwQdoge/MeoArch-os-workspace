import QtQuick
import MeoUI 1.0 as Meo

Meo.MeoTextField {
    type: "outlined"
    size: "l"
    isPassword: echoMode === TextInput.Password
}
