import QtQuick
import QtQuick.Layouts
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    primaryAdvances: false

    onPrimaryRequested: {
        if (controller.validateAccount(InstallerSession.username, InstallerSession.hostname,
                                       InstallerSession.password, InstallerSession.passwordConfirmation)) {
            controller.setSelection("user", "fullName", InstallerSession.fullName)
            controller.setSelection("user", "username", InstallerSession.username)
            controller.setSelection("user", "hostname", InstallerSession.hostname)
            nextRequested()
        }
    }

    Column {
        width: parent.width
        spacing: page.compactHeight ? page.dp(12) : page.dp(20)

        PageHeading {
            width: parent.width
            title: "User Account"
            subtitle: "Create the account you will use to sign in to MeoArch."
        }
        GridLayout {
            id: form
            width: parent.width
            columns: width < page.dp(620) ? 1 : 2
            rowSpacing: page.compactHeight ? page.dp(8) : page.dp(16)
            columnSpacing: page.dp(16)

            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "l"
                label: "Full name"
                text: InstallerSession.fullName
                onTextChanged: InstallerSession.fullName = text
            }
            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "l"
                label: "Username"
                text: InstallerSession.username
                supportingText: "Lowercase letters, numbers, _ and -"
                onTextChanged: InstallerSession.username = text
            }
            MeoTextField {
                Layout.fillWidth: true
                Layout.columnSpan: form.columns
                type: "outlined"
                size: "l"
                label: "Computer name"
                text: InstallerSession.hostname
                onTextChanged: InstallerSession.hostname = text
            }
            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "l"
                label: "Password"
                echoMode: TextInput.Password
                isPassword: true
                text: InstallerSession.password
                onTextChanged: InstallerSession.password = text
            }
            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "l"
                label: "Confirm password"
                echoMode: TextInput.Password
                isPassword: true
                text: InstallerSession.passwordConfirmation
                isError: text.length > 0 && text !== InstallerSession.password
                errorText: "Passwords do not match"
                onTextChanged: InstallerSession.passwordConfirmation = text
            }
        }
        ToggleRow {
            width: parent.width
            title: "Automatic login"
            subtitle: "Skip the sign-in screen after startup"
            checked: page.controller ? page.controller.selection("user", "automaticLogin", false) : false
            onToggled: checked => page.controller.setSelection("user", "automaticLogin", checked)
        }
    }
}
