import QtQuick
import QtQuick.Layouts
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    primaryAdvances: false
    readonly property bool usernameValid: /^[a-z_][a-z0-9_-]{0,31}$/.test(InstallerSession.username)
    readonly property bool hostnameValid: /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(InstallerSession.hostname)
    readonly property bool passwordValid: InstallerSession.password.length >= 8
    readonly property bool passwordsMatch: InstallerSession.password === InstallerSession.passwordConfirmation
    readonly property bool accountReadyToSave: page.usernameValid && page.hostnameValid
                                             && page.passwordValid && page.passwordsMatch
    primaryEnabled: page.accountReadyToSave
    primaryAccessibleDescription: page.accountReadyToSave
                                  ? qsTr("Saves the local account and continues to software choices")
                                  : qsTr("Complete the valid username, computer name, and matching password fields to continue")

    function incompleteAccountMessage() {
        if (!InstallerSession.username.length)
            return qsTr("Enter a username to continue.")
        if (!page.usernameValid)
            return qsTr("Use 1–32 lowercase letters, numbers, _ or - for the username.")
        if (!page.hostnameValid)
            return qsTr("Use 1–63 lowercase letters, numbers, or hyphens for the computer name.")
        if (!page.passwordValid)
            return qsTr("Use a password with at least 8 characters.")
        if (!page.passwordsMatch)
            return qsTr("Enter the same password in both password fields.")
        return ""
    }

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
                isError: text.length > 0 && !page.usernameValid
                errorText: qsTr("Use 1–32 lowercase letters, numbers, _ or -")
                onTextChanged: InstallerSession.username = text
            }
            MeoTextField {
                Layout.fillWidth: true
                Layout.columnSpan: form.columns
                type: "outlined"
                size: "l"
                label: qsTr("Computer name")
                text: InstallerSession.hostname
                isError: text.length > 0 && !page.hostnameValid
                errorText: qsTr("Use 1–63 lowercase letters, numbers, or hyphens")
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
                isError: text.length > 0 && !page.passwordValid
                errorText: qsTr("Use at least 8 characters")
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
        InfoBanner {
            visible: !page.accountReadyToSave
            width: parent.width
            title: qsTr("Finish account details to continue")
            message: page.incompleteAccountMessage()
            tone: "info"
        }
        InfoBanner {
            width: parent.width
            title: qsTr("Password sign-in required")
            message: qsTr("Automatic login is not offered because Plasma Login Manager has no tested password-preserving Meo backend yet.")
            tone: "info"
        }
    }
}
