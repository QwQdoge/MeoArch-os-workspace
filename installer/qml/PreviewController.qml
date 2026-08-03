pragma Singleton
import QtQuick

QtObject {
    property string uiLanguage: "en"
    property string systemLocale: "en_US.UTF-8"
    property string formatCountry: "US"
    property string formatLocale: "en_US.UTF-8"
    property string timeZone: "UTC"
    property string keyboardLayout: "us"
    property string networkState: "connected"
    property string selectedDisk: "preview-disk-0"
    property string hardwareSummary: "Automatic PCI detection will select graphics drivers."
    property string installationState: "idle"
    property int installationProgress: 0
    property string errorMessage: ""
    property bool realInstallEnabled: false
    property bool systemActionsEnabled: false
    property var values: ({})
    readonly property var uiLanguages: [
        {id:"en",nativeName:"English"},{id:"zh_CN",nativeName:"简体中文"},{id:"zh_TW",nativeName:"繁體中文"},
        {id:"ja",nativeName:"日本語"},{id:"ko",nativeName:"한국어"},{id:"es",nativeName:"Español"},
        {id:"fr",nativeName:"Français"},{id:"de",nativeName:"Deutsch"},{id:"pt_BR",nativeName:"Português (Brasil)"},
        {id:"ru",nativeName:"Русский"},{id:"it",nativeName:"Italiano"}
    ]
    readonly property var systemLocales: [
        {id:"en_US.UTF-8",nativeName:"English",code:"en_US.UTF-8"},
        {id:"de_DE.UTF-8",nativeName:"Deutsch",code:"de_DE.UTF-8"},
        {id:"ja_JP.UTF-8",nativeName:"日本語",code:"ja_JP.UTF-8"},
        {id:"zh_CN.UTF-8",nativeName:"简体中文",code:"zh_CN.UTF-8"}
    ]
    readonly property var countries: [
        {alpha2:"US",alpha3:"USA",name:"United States"},{alpha2:"DE",alpha3:"DEU",name:"Germany"},
        {alpha2:"JP",alpha3:"JPN",name:"Japan"},{alpha2:"SG",alpha3:"SGP",name:"Singapore"}
    ]
    readonly property var timeZones: [
        {id:"UTC",label:"UTC · UTC+00:00"},{id:"Asia/Singapore",label:"Singapore · UTC+08:00"},
        {id:"Europe/Berlin",label:"Berlin · UTC+02:00"},{id:"America/New_York",label:"New York · UTC-04:00"}
    ]
    readonly property var keyboardLayouts: [
        {id:"us",name:"English (US)"},{id:"gb",name:"English (UK)"},{id:"jp",name:"Japanese"},
        {id:"de",name:"German"},{id:"fr",name:"French"},{id:"es",name:"Spanish"}
    ]
    readonly property var disks: [
        {id:"preview-disk-0",name:"NVMe Solid State Drive",size:"512 GB",available:"382 GB available",kind:"SSD · Preview"},
        {id:"preview-disk-1",name:"External Storage",size:"1 TB",available:"740 GB available",kind:"Removable · Preview"}
    ]

    function setUiLanguage(id) { uiLanguage = id }
    function setSystemLocale(id) { systemLocale = id }
    function setFormatCountry(id) { formatCountry = id; formatLocale = systemLocale }
    function setTimeZone(id) { timeZone = id }
    function setKeyboardLayout(id) { keyboardLayout = id }
    function setSelectedDisk(id) { selectedDisk = id }
    function retryNetwork() { networkState = "connected" }
    function setSelection(section, key, value) { const next = Object.assign({}, values); next[section + "." + key] = value; values = next }
    function selection(section, key, fallback) { const id = section + "." + key; return typeof values[id] === "undefined" ? fallback : values[id] }
    function validateAccount(username, hostname, password, confirmation) {
        if (!/^[a-z_][a-z0-9_-]{0,31}$/.test(username)) { errorMessage = "Enter a valid lowercase username."; return false }
        if (!/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(hostname)) { errorMessage = "Enter a valid computer name."; return false }
        if (password.length < 8 || password !== confirmation) { errorMessage = "Password must be 8 characters and match."; return false }
        errorMessage = ""; return true
    }
    function generatePreview() { return "preview" }
    function confirmSummary() {}
    function startInstallation() { installationState = "complete"; installationProgress = 100 }
    function requestRestart() { errorMessage = "Restart is disabled in preview mode." }
    function requestShutdown() { errorMessage = "Shut down is disabled in preview mode." }
}
