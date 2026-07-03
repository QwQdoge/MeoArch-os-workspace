import QtQuick
import QtQuick.Controls
import MeoUI

MeoTextField {
    id: control

    // 🌟 核心属性
    property string format: "HH:mm"

    label: "Time"
    placeholder: format
    leadingIcon: "schedule"

    inputMask: "99:99"

    validator: RegularExpressionValidator {
        regularExpression: /^([01]\d|2[0-3]):([0-5]\d)$/
    }

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    onTextChanged: {
        if (text.length === format.length) {
            let parts = text.split(":")
            let h = parseInt(parts[0])
            let m = parseInt(parts[1])
            isError = (h > 23 || m > 59)
            errorText = isError ? "Invalid time" : ""
        }
    }
}
