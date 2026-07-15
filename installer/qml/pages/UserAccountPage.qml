import QtQuick
import ".."
import "../components"

PageFrame {
    id: page
    primaryAdvances: false
    onPrimaryRequested: {
        if (controller.validateAccount(InstallerSession.username, InstallerSession.hostname, InstallerSession.password, InstallerSession.passwordConfirmation)) {
            controller.setSelection("user", "fullName", InstallerSession.fullName)
            controller.setSelection("user", "username", InstallerSession.username)
            controller.setSelection("user", "hostname", InstallerSession.hostname)
            nextRequested()
        }
    }
    Column {
        anchors.fill: parent; spacing: page.dp(20)
        PageHeading { width: parent.width; title: "User Account"; subtitle: "Create the account you will use to sign in to MeoArch." }
        Column {
            width: parent.width; spacing: page.dp(16)
            Row {
                width: parent.width; spacing: page.dp(16)
                MeoTextField { width: (parent.width - page.dp(16))/2; label: "Full name"; text: InstallerSession.fullName; onTextChanged: InstallerSession.fullName = text }
                MeoTextField { width: (parent.width - page.dp(16))/2; label: "Username"; text: InstallerSession.username; onTextChanged: InstallerSession.username = text }
            }
            MeoTextField { width: parent.width; label: "Computer name"; text: InstallerSession.hostname; onTextChanged: InstallerSession.hostname = text }
            Row {
                width: parent.width; spacing: page.dp(16)
                MeoTextField { width: (parent.width - page.dp(16))/2; label: "Password"; echoMode: TextInput.Password; text: InstallerSession.password; onTextChanged: InstallerSession.password = text }
                MeoTextField { width: (parent.width - page.dp(16))/2; label: "Confirm password"; echoMode: TextInput.Password; text: InstallerSession.passwordConfirmation; onTextChanged: InstallerSession.passwordConfirmation = text }
            }
        }
        ToggleRow { width: parent.width; title: "Automatic login"; subtitle: "Skip the sign-in screen after startup"; checked: page.controller ? page.controller.selection("user","automaticLogin",false) : false; onToggled: checked => page.controller.setSelection("user","automaticLogin",checked) }
    }
}
