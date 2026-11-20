import QtQuick
import QtQuick.Layouts
import MeoUI 1.0
import ".."
import "../components"

// One top-aligned form: name -> generated sign-in/computer names (editable)
// -> password with a live checklist -> optional separate root password.
// Validation rules match the controller; the controller re-validates and
// hashes the password before anything is written.
PageFrame {
    id: page
    primaryAdvances: false
    readonly property bool nameValid: InstallerSession.fullName.trim().length > 0
    readonly property bool usernameValid: /^[a-z_][a-z0-9_-]{0,31}$/.test(InstallerSession.username)
    readonly property bool hostnameValid: /^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(InstallerSession.hostname)
    readonly property bool passwordLongEnough: InstallerSession.password.length >= 8
    readonly property bool passwordsMatch: InstallerSession.password.length > 0
                                           && InstallerSession.password === InstallerSession.passwordConfirmation
    readonly property bool passwordValid: passwordLongEnough
    readonly property bool rootLongEnough: InstallerSession.rootPassword.length >= 8
    readonly property bool rootMatches: InstallerSession.rootPassword.length > 0
                                        && InstallerSession.rootPassword === InstallerSession.rootPasswordConfirmation
    readonly property bool rootPasswordValid: !InstallerSession.separateRootPassword || (rootLongEnough && rootMatches)
    readonly property bool accountReadyToSave: nameValid && usernameValid && hostnameValid
                                             && passwordLongEnough && passwordsMatch && rootPasswordValid
    // The automatic name could not use any letter of the full name, for
    // example a name written only in Chinese characters.
    readonly property bool genericUsername: !InstallerSession.customIdentity && nameValid
                                            && InstallerSession.username === "user"
    readonly property real formWidth: Math.min(width, dp(720))

    primaryEnabled: page.accountReadyToSave
    primaryLabel: page.accountReadyToSave ? qsTr("Continue")
                  : !page.nameValid ? qsTr("Enter your name")
                  : !page.usernameValid || !page.hostnameValid ? qsTr("Fix the names")
                  : !page.passwordLongEnough || !page.passwordsMatch ? qsTr("Set a password")
                  : qsTr("Set the root password")
    primaryAccessibleDescription: page.accountReadyToSave
                                  ? qsTr("Saves the local account and continues to software choices")
                                  : page.incompleteAccountMessage()

    function incompleteAccountMessage() {
        if (!page.nameValid)
            return qsTr("Enter your full name to continue.")
        if (!page.usernameValid)
            return qsTr("Use 1–32 lowercase letters, numbers, _ or - for the username.")
        if (!page.hostnameValid)
            return qsTr("Use 1–63 lowercase letters, numbers, or hyphens for the computer name.")
        if (!page.passwordLongEnough)
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

    component CheckItem: Row {
        id: check
        property bool met: false
        property string text: ""
        spacing: page.dp(6)
        MeoIcon {
            anchors.verticalCenter: parent.verticalCenter
            icon: check.met ? "check_circle" : "radio_button_unchecked"
            size: page.dp(18)
            color: check.met ? MeoTheme.primary : MeoTheme.outline
        }
        MeoText {
            anchors.verticalCenter: parent.verticalCenter
            text: check.text
            typeRole: "body"; typeSize: "small"
            color: check.met ? MeoTheme.contentOnSurface : MeoTheme.contentOnSurfaceVariant
        }
        Accessible.role: Accessible.StaticText
        Accessible.name: check.text + (check.met ? qsTr(": done") : qsTr(": not yet"))
    }

    Column {
        width: page.formWidth
        spacing: page.compactHeight ? page.dp(12) : page.dp(16)

        PageHeading {
            width: parent.width
            title: qsTr("Create your account")
            subtitle: qsTr("You sign in to MeoArch with this account. Its password also unlocks administrator tasks.")
        }

        MeoTextField {
            width: parent.width
            type: "outlined"
            size: "m"
            label: qsTr("Full name")
            helperText: qsTr("Shown on the sign-in screen")
            text: InstallerSession.fullName
            onTextChanged: {
                InstallerSession.fullName = text
                InstallerSession.syncIdentity()
            }
        }

        // Generated names, shown as facts with one Edit action.
        MeoCard {
            width: parent.width
            type: "filled"
            padding: page.dp(14)
            implicitHeight: identityColumn.implicitHeight + page.dp(28)
            Column {
                id: identityColumn
                width: parent.width
                spacing: page.dp(10)
                RowLayout {
                    width: parent.width
                    spacing: page.dp(12)
                    MeoIcon { icon: "badge"; size: page.dp(24); color: MeoTheme.primary }
                    Column {
                        Layout.fillWidth: true
                        spacing: page.dp(2)
                        MeoText {
                            width: parent.width
                            text: qsTr("Sign-in name: %1").arg(InstallerSession.username.length ? InstallerSession.username : "—")
                            typeRole: "body"; typeSize: "large"; color: MeoTheme.contentOnSurface
                            elide: Text.ElideRight
                        }
                        MeoText {
                            width: parent.width
                            text: qsTr("Computer name: %1").arg(InstallerSession.hostname.length ? InstallerSession.hostname : "—")
                            typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant
                            elide: Text.ElideRight
                        }
                    }
                    MeoButton {
                        text: InstallerSession.customIdentity ? qsTr("Use automatic names") : qsTr("Edit")
                        type: "text"
                        icon.name: InstallerSession.customIdentity ? "auto_fix_high" : "edit"
                        onClicked: {
                            InstallerSession.customIdentity = !InstallerSession.customIdentity
                            InstallerSession.syncIdentity()
                        }
                    }
                }
                MeoText {
                    visible: page.genericUsername
                    width: parent.width
                    text: qsTr("Your name has no Latin letters, so the sign-in name is “user”. Choose Edit to pick your own, for example in pinyin.")
                    typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant
                    wrapMode: Text.WordWrap
                }
                GridLayout {
                    visible: InstallerSession.customIdentity
                    width: parent.width
                    columns: width < page.dp(520) ? 1 : 2
                    columnSpacing: page.dp(12)
                    rowSpacing: page.dp(8)
                    MeoTextField {
                        Layout.fillWidth: true
                        type: "outlined"
                        size: "m"
                        label: qsTr("Sign-in name")
                        text: InstallerSession.username
                        helperText: qsTr("Lowercase letters, numbers, _ and -")
                        isError: text.length > 0 && !page.usernameValid
                        errorText: qsTr("Use 1–32 lowercase letters, numbers, _ or -")
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText
                        onTextChanged: InstallerSession.username = text
                    }
                    MeoTextField {
                        Layout.fillWidth: true
                        type: "outlined"
                        size: "m"
                        label: qsTr("Computer name")
                        text: InstallerSession.hostname
                        helperText: qsTr("How this computer appears on the network")
                        isError: text.length > 0 && !page.hostnameValid
                        errorText: qsTr("Use 1–63 lowercase letters, numbers, or hyphens")
                        inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhPreferLowercase | Qt.ImhNoPredictiveText
                        onTextChanged: InstallerSession.hostname = text
                    }
                }
            }
        }

        GridLayout {
            id: passwordGrid
            width: parent.width
            columns: width < page.dp(520) ? 1 : 2
            columnSpacing: page.dp(12)
            rowSpacing: page.dp(8)
            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "m"
                label: qsTr("Password")
                echoMode: TextInput.Password
                isPassword: true
                text: InstallerSession.password
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
        }
        Flow {
            width: parent.width
            spacing: page.dp(20)
            CheckItem { met: page.passwordLongEnough; text: qsTr("At least 8 characters") }
            CheckItem { met: page.passwordsMatch; text: qsTr("Both passwords match") }
        }

        ToggleRow {
            width: parent.width
            title: qsTr("Use a separate root password")
            subtitle: InstallerSession.separateRootPassword
                      ? qsTr("The root account gets its own password. Your password still works for administrator tasks.")
                      : qsTr("Off: no separate root password is needed. Most people leave this off.")
            checked: InstallerSession.separateRootPassword
            onToggled: checked => {
                InstallerSession.separateRootPassword = checked
                if (!checked) {
                    InstallerSession.rootPassword = ""
                    InstallerSession.rootPasswordConfirmation = ""
                }
            }
        }
        GridLayout {
            visible: InstallerSession.separateRootPassword
            width: parent.width
            columns: width < page.dp(520) ? 1 : 2
            columnSpacing: page.dp(12)
            rowSpacing: page.dp(8)
            MeoTextField {
                Layout.fillWidth: true
                type: "outlined"
                size: "m"
                label: qsTr("Root password")
                echoMode: TextInput.Password
                isPassword: true
                text: InstallerSession.rootPassword
                onTextChanged: InstallerSession.rootPassword = text
            }
            MeoTextField {
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
        Flow {
            visible: InstallerSession.separateRootPassword
            width: parent.width
            spacing: page.dp(20)
            CheckItem { met: page.rootLongEnough; text: qsTr("At least 8 characters") }
            CheckItem { met: page.rootMatches; text: qsTr("Both root passwords match") }
        }
    }
}
