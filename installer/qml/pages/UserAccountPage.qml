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
    readonly property bool rootPasswordValid: !InstallerSession.separateRootPassword
                                              || (InstallerSession.rootPassword.length >= 8
                                                  && InstallerSession.rootPassword === InstallerSession.rootPasswordConfirmation)
    readonly property bool accountReadyToSave: InstallerSession.fullName.trim().length > 0
                                             && page.usernameValid && page.hostnameValid
                                             && page.passwordValid && page.passwordsMatch
                                             && page.rootPasswordValid
    primaryEnabled: page.accountReadyToSave
    primaryAccessibleDescription: page.accountReadyToSave
                                  ? qsTr("Saves the local account and continues to software choices")
                                  : qsTr("Enter your full name and matching passwords to continue")

    function incompleteAccountMessage() {
        if (!InstallerSession.fullName.trim().length)
            return qsTr("Enter your full name to continue.")
        if (!page.usernameValid)
            return qsTr("Use 1–32 lowercase letters, numbers, _ or - for the username.")
        if (!page.hostnameValid)
            return qsTr("Use 1–63 lowercase letters, numbers, or hyphens for the computer name.")
        if (!page.passwordValid)
            return qsTr("Use a password with at least 8 characters.")
        if (!page.passwordsMatch)
            return qsTr("Enter the same password in both password fields.")
        if (!page.rootPasswordValid)
            return qsTr("Enter and confirm the separate root password.")
        return ""
    }

    onPrimaryRequested: {
        controller.saveAccount(InstallerSession.fullName, InstallerSession.username, InstallerSession.hostname,
                               InstallerSession.password, InstallerSession.passwordConfirmation,
                               InstallerSession.separateRootPassword, InstallerSession.rootPassword,
                               InstallerSession.rootPasswordConfirmation)
    }

    Connections {
        target: page.controller || null
        ignoreUnknownSignals: true
        function onAccountReady() {
            InstallerSession.password = ""
            InstallerSession.passwordConfirmation = ""
            InstallerSession.rootPassword = ""
            InstallerSession.rootPasswordConfirmation = ""
            page.nextRequested()
        }
    }

    GridLayout {
        width: parent.width
        y: Math.max(0, (parent.height - implicitHeight) / 2)
        columns: width < page.dp(760) ? 1 : 2
        columnSpacing: page.dp(44)
        rowSpacing: page.dp(20)

        Column {
            Layout.fillWidth: true
            Layout.preferredWidth: page.dp(390)
            Layout.alignment: Qt.AlignTop
            spacing: page.dp(20)
            PageHeading {
                width: parent.width
                title: qsTr("Create your account")
                subtitle: qsTr("Enter your full name and a password. We will make your sign-in name and computer name for you.")
            }
            InfoBanner {
                width: parent.width
                title: qsTr("One password by default")
                message: qsTr("Your password also works for administrator tasks. Set a separate root password only if you want one.")
                tone: "info"
            }
        }

        Column {
            Layout.fillWidth: true
            Layout.preferredWidth: page.dp(600)
            spacing: page.dp(12)
        GridLayout {
            id: form
            width: parent.width
            columns: width < page.dp(620) ? 1 : 2
            rowSpacing: page.dp(10)
            columnSpacing: page.dp(16)

            MeoTextField {
                Layout.fillWidth: true
                Layout.columnSpan: form.columns
                type: "outlined"
                size: "m"
                label: qsTr("Full name")
                text: InstallerSession.fullName
                onTextChanged: {
                    InstallerSession.fullName = text
                    InstallerSession.syncIdentity()
                }
            }
            InfoBanner {
                Layout.fillWidth: true
                Layout.columnSpan: form.columns
                title: qsTr("Your sign-in and network names")
                message: qsTr("Username: %1 · Computer on the network: %2")
                         .arg(InstallerSession.username || qsTr("Enter your name"))
                         .arg(InstallerSession.hostname || qsTr("Enter your name"))
                tone: "info"
            }
            MeoButton {
                Layout.alignment: Qt.AlignLeft
                Layout.columnSpan: form.columns
                text: InstallerSession.customIdentity ? qsTr("Use names from full name") : qsTr("Customize these names")
                type: "text"
                onClicked: {
                    InstallerSession.customIdentity = !InstallerSession.customIdentity
                    InstallerSession.syncIdentity()
                }
            }
            MeoTextField {
                visible: InstallerSession.customIdentity
                Layout.fillWidth: true
                type: "outlined"
                size: "m"
                label: qsTr("Username")
                text: InstallerSession.username
                supportingText: qsTr("Lowercase letters, numbers, _ and -")
                isError: text.length > 0 && !page.usernameValid
                errorText: qsTr("Use 1–32 lowercase letters, numbers, _ or -")
                onTextChanged: InstallerSession.username = text
            }
            MeoTextField {
                visible: InstallerSession.customIdentity
                Layout.fillWidth: true
                type: "outlined"
                size: "m"
                label: qsTr("Computer name")
                text: InstallerSession.hostname
                isError: text.length > 0 && !page.hostnameValid
                errorText: qsTr("Use 1–63 lowercase letters, numbers, or hyphens")
                onTextChanged: InstallerSession.hostname = text
            }
            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "m"
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
                size: "m"
                label: qsTr("Confirm password")
                echoMode: TextInput.Password
                isPassword: true
                text: InstallerSession.passwordConfirmation
                isError: text.length > 0 && text !== InstallerSession.password
                errorText: qsTr("Passwords do not match")
                onTextChanged: InstallerSession.passwordConfirmation = text
            }
            MeoButton {
                Layout.alignment: Qt.AlignLeft
                Layout.columnSpan: form.columns
                text: InstallerSession.separateRootPassword
                      ? qsTr("Use the sign-in password for root") : qsTr("Set a separate root password")
                type: "text"
                onClicked: {
                    InstallerSession.separateRootPassword = !InstallerSession.separateRootPassword
                    if (!InstallerSession.separateRootPassword) {
                        InstallerSession.rootPassword = ""
                        InstallerSession.rootPasswordConfirmation = ""
                    }
                }
            }
            MeoTextField {
                visible: InstallerSession.separateRootPassword
                Layout.fillWidth: true
                type: "outlined"
                size: "m"
                label: qsTr("Root password")
                echoMode: TextInput.Password
                isPassword: true
                text: InstallerSession.rootPassword
                isError: text.length > 0 && text.length < 8
                errorText: qsTr("Use at least 8 characters")
                onTextChanged: InstallerSession.rootPassword = text
            }
            MeoTextField {
                visible: InstallerSession.separateRootPassword
                Layout.fillWidth: true
                type: "outlined"
                size: "m"
                label: qsTr("Confirm root password")
                echoMode: TextInput.Password
                isPassword: true
                text: InstallerSession.rootPasswordConfirmation
                isError: text.length > 0 && text !== InstallerSession.rootPassword
                errorText: qsTr("Passwords do not match")
                onTextChanged: InstallerSession.rootPasswordConfirmation = text
            }
        }
            InfoBanner {
                visible: !page.accountReadyToSave && InstallerSession.fullName.trim().length > 0
                width: parent.width
                title: qsTr("Finish account details to continue")
                message: page.incompleteAccountMessage()
                tone: "info"
            }
        }
    }
}
