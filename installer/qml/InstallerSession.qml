pragma Singleton
import QtQuick
QtObject {
    property string fullName: ""
    property string username: ""
    property string hostname: "meoarch"
    property string password: ""
    property string passwordConfirmation: ""
    property bool customIdentity: false
    property bool separateRootPassword: false
    property string rootPassword: ""
    property string rootPasswordConfirmation: ""
    property string keyboardTest: ""

    function usernameFromFullName(value) {
        const name = value.trim().split(/\s+/)[0]
        if (!name)
            return ""
        let result = name.normalize("NFKD").toLowerCase()
                         .replace(/[\u0300-\u036f]/g, "")
                         .replace(/[^a-z0-9_-]/g, "")
                         .replace(/^[-_]+|[-_]+$/g, "")
        // Names without Latin letters (for example Chinese) get a plain,
        // valid default; the account page explains it and offers Edit.
        if (!result)
            result = "user"
        if (/^[0-9]/.test(result))
            result = "u" + result
        return result.slice(0, 32)
    }

    function syncIdentity() {
        if (customIdentity)
            return
        username = usernameFromFullName(fullName)
        hostname = username.length && username !== "user" ? username.replace(/_/g, "-") : "meoarch"
    }
}
