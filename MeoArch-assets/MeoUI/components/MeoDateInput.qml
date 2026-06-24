import QtQuick
import QtQuick.Controls
import MeoUI

MeoTextField {
    id: control

    // 🌟 核心属性
    property string format: "yyyy/MM/dd"

    label: "Date"
    placeholder: format
    leadingIcon: "calendar_today"

    inputMask: "9999/99/99" // Simplified for default format

    validator: RegularExpressionValidator {
        regularExpression: /^\d{4}\/\d{2}\/\d{2}$/
    }

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    onTextChanged: {
        // Basic validation logic could go here
        if (text.length === format.length) {
            let d = Date.fromLocaleDateString(Qt.locale(), text, "yyyy/MM/dd")
            isError = isNaN(d.getTime())
            errorText = isError ? "Invalid date format" : ""
        }
    }
}
