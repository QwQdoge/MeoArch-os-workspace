import QtQuick
import QtQuick.Layouts
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    primaryAdvances: false

    onPrimaryRequested: {
        controller.saveAccount(InstallerSession.fullName, InstallerSession.username, InstallerSession.hostname,
                               InstallerSession.password, InstallerSession.passwordConfirmation)
    }

    Connections {
        target: page.controller || null
        ignoreUnknownSignals: true
        function onAccountReady() {
            InstallerSession.password = ""
            InstallerSession.passwordConfirmation = ""
            page.nextRequested()
        }
    }

    Column {
        width: parent.width
        spacing: page.compactHeight ? page.dp(12) : page.dp(20)

        PageHeading {
            width: parent.width
            title: qsTr("User Account")
            subtitle: qsTr("Create the account you will use to sign in to MeoArch.")
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
                label: qsTr("Full name")
                text: InstallerSession.fullName
                onTextChanged: InstallerSession.fullName = text
            }
            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "l"
                label: qsTr("Username")
                text: InstallerSession.username
                supportingText: qsTr("Lowercase letters, numbers, _ and -")
                onTextChanged: InstallerSession.username = text
            }
            MeoTextField {
                Layout.fillWidth: true
                Layout.columnSpan: form.columns
                type: "outlined"
                size: "l"
                label: qsTr("Computer name")
                text: InstallerSession.hostname
                onTextChanged: InstallerSession.hostname = text
            }
            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "l"
                label: qsTr("Password")
                echoMode: TextInput.Password
                isPassword: true
                text: InstallerSession.password
                onTextChanged: InstallerSession.password = text
            }
            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "l"
                label: qsTr("Confirm password")
                echoMode: TextInput.Password
                isPassword: true
                text: InstallerSession.passwordConfirmation
                isError: text.length > 0 && text !== InstallerSession.password
                errorText: qsTr("Passwords do not match")
                onTextChanged: InstallerSession.passwordConfirmation = text
            }
        }
        ToggleRow {
            width: parent.width
            title: qsTr("Automatic login")
            subtitle: qsTr("Skip the sign-in screen after startup")
            checked: page.controller ? page.controller.selection("user", "automaticLogin", false) : false
            onToggled: checked => page.controller.setSelection("user", "automaticLogin", checked)
        }
    }
}
