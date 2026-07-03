import QtQuick
import QtQuick.Controls
import MeoUI

MeoPageLayout {
    id: page
    title: "Inputs"
    subtitle: "Filled and outlined fields cover default, focused, error, disabled, icon, helper, password, and multiline states."

    readonly property real s: MeoTheme.globalScale

    Section {
        title: "Text fields"
        Flow {
            width: parent.width
            spacing: 16 * page.s
            MeoTextField { label: "Filled"; placeholder: "Placeholder"; type: "filled"; helperText: "Helper text" }
            MeoTextField { label: "Outlined"; placeholder: "Placeholder"; type: "outlined"; helperText: "Supporting text" }
            MeoTextField { label: "Focused"; placeholder: "Tab here"; type: "outlined"; leadingIcon: "search"; helperText: "Visible focus ring" }
            MeoTextField { label: "Error"; text: "bad-value"; type: "outlined"; isError: true; errorText: "Invalid input" }
            MeoTextField { label: "Disabled"; placeholder: "Unavailable"; type: "filled"; enabled: false }
            MeoTextField { label: "Leading icon"; placeholder: "Search"; type: "filled"; leadingIcon: "search" }
            MeoTextField { label: "Trailing icon"; placeholder: "Amount"; type: "outlined"; trailingIcon: "payments"; suffixText: "USD" }
            MeoTextField { label: "Password"; placeholder: "Password"; type: "outlined"; echoMode: TextInput.Password; trailingIcon: "visibility_off" }
        }
    }

    Section {
        title: "Text area"
        Flow {
            width: parent.width
            spacing: 16 * page.s
            MeoTextArea {
                width: 420 * page.s
                height: 148 * page.s
                label: "Description"
                placeholder: "Enter multiline text..."
                type: "outlined"
                helperText: "0 / 200 style counter"
                maxLength: 200
                showCounter: true
            }
            MeoTextArea {
                width: 420 * page.s
                height: 148 * page.s
                label: "Error description"
                text: "Too short"
                type: "filled"
                isError: true
                errorText: "Add more detail"
            }
        }
    }

    Section {
        title: "Menus and pickers"
        Flow {
            width: parent.width
            spacing: 16 * page.s
            MeoDateInput { width: 220 * page.s; label: "Date" }
            MeoTimeInput { width: 220 * page.s; label: "Time" }
            MeoExposedDropdown { width: 240 * page.s; label: "Environment"; model: ["Development", "Staging", "Production"] }
            MeoExposedDropdown { width: 240 * page.s; label: "Disabled"; model: ["Unavailable"]; enabled: false }
        }
    }

    component Section: Column {
        property string title: ""
        width: parent.width
        spacing: 12 * page.s
        MeoText { text: parent.title; typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
    }
}
