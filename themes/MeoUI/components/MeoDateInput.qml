import QtQuick
import QtQuick.Controls
import MeoUI

MeoTextField {
    id: control

    // 🌟 核心属性
    property string format: "yyyy-MM-dd"
    property date value: new Date()
    property bool allowEmpty: false
    property bool hasValue: !allowEmpty || text.trim() !== ""

    signal dateAccepted(date date)
    signal cleared()

    label: "Date"
    placeholder: format
    leadingIcon: "calendar_today"

    inputMask: format.indexOf("/") !== -1 ? "9999/99/99" : "9999-99-99"

    validator: RegularExpressionValidator {
        regularExpression: control.format.indexOf("/") !== -1 ? /^\d{4}\/\d{2}\/\d{2}$/ : /^\d{4}-\d{2}-\d{2}$/
    }

    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    Component.onCompleted: syncTextFromValue()

    onValueChanged: {
        syncTextFromValue()
    }

    onTextChanged: {
        if (allowEmpty && text.trim() === "") {
            isError = false
            errorText = ""
            return
        }

        if (text.length !== format.length)
            return

        const d = parseDate(text)
        isError = d === null
        errorText = isError ? "Invalid date" : ""
    }

    onAccepted: commit()
    onEditingFinished: commit()

    function commit() {
        if (allowEmpty && text.trim() === "") {
            isError = false
            errorText = ""
            if (!value || isNaN(value.getTime()) || value.getTime() > 0)
                value = new Date(0)
            cleared()
            return
        }

        const d = parseDate(text)
        if (!d) {
            isError = true
            errorText = "Invalid date"
            text = allowEmpty ? "" : formatDate(value)
            return
        }

        isError = false
        errorText = ""
        if (value.getTime() !== d.getTime())
            value = d
        dateAccepted(d)
    }

    function syncTextFromValue() {
        if (allowEmpty && (!value || isNaN(value.getTime()) || value.getTime() <= 0)) {
            if (text !== "")
                text = ""
            return
        }

        const formatted = formatDate(value)
        if (text !== formatted)
            text = formatted
    }

    function formatDate(date) {
        if (!date || isNaN(date.getTime()))
            return ""
        const month = String(date.getMonth() + 1).padStart(2, "0")
        const day = String(date.getDate()).padStart(2, "0")
        const sep = format.indexOf("/") !== -1 ? "/" : "-"
        return date.getFullYear() + sep + month + sep + day
    }

    function parseDate(valueText) {
        const sep = format.indexOf("/") !== -1 ? "\\/" : "-"
        const match = new RegExp("^(\\d{4})" + sep + "(\\d{1,2})" + sep + "(\\d{1,2})$").exec(valueText.trim())
        if (!match)
            return null

        const year = Number(match[1])
        const month = Number(match[2])
        const day = Number(match[3])
        const parsed = new Date(year, month - 1, day)
        if (parsed.getFullYear() !== year || parsed.getMonth() !== month - 1 || parsed.getDate() !== day)
            return null
        parsed.setHours(0, 0, 0, 0)
        return parsed
    }
}
