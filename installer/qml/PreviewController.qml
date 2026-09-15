pragma Singleton
import QtQuick

QtObject {
    readonly property bool previewInstalling: Qt.application.arguments.indexOf("--preview-installing") >= 0
    readonly property bool previewComplete: Qt.application.arguments.indexOf("--preview-complete") >= 0
    property string uiLanguage: "en"
    property string systemLocale: "en_US.UTF-8"
    property string formatCountry: "US"
    property string formatLocale: "en_US.UTF-8"
    property string timeZone: "UTC"
    property string keyboardLayout: "us"
    property var regionRecommendation: ({ country: formatCountry, systemLocale: systemLocale, formatLocale: formatLocale, timeZone: timeZone, keyboardLayout: keyboardLayout, automatic: true, hasPreset: true })
    readonly property var calendarCapabilities: [
        {id:"none",name:"No secondary calendar",description:"Gregorian calendar only",state:"ready"},
        {id:"buddhist",name:"Buddhist Era",description:"Local display only",state:"ready"},
        {id:"islamic-civil",name:"Islamic Civil calendar",description:"Local Qt calendar display",state:"ready"},
        {id:"hebcal",name:"Hebrew calendar and holidays",description:"Optional online data after installation",state:"needs-online-setup"}
    ]
    property string networkState: "online"
    property string networkDetail: "Visual preview backend"
    property string networkHandoffState: "ready"
    property string networkHandoffMessage: "This current network can be remembered after installation."
    property bool networkHandoffEnabled: true
    property bool debugTerminalAvailable: true
    property string debugTerminalMessage: "Preview only"
    property string selectedDisk: "preview-disk-0"
    property string hardwareSummary: "Automatic PCI detection will select graphics drivers."
    property bool hardwareDetecting: false
    property bool diskDetecting: false
    property string installationState: previewComplete ? "complete" : previewInstalling ? "running" : "idle"
    property int installationProgress: previewComplete ? 100 : previewInstalling ? 35 : 0
    property string installationStage: previewComplete ? "complete" : previewInstalling ? "installing_base" : "idle"
    property string installationMessage: previewComplete ? qsTr("Installation complete.")
                                                       : previewInstalling ? qsTr("Installing the base system and packages") : ""
    property string preflightState: "ready"
    property string preflightMessage: "Visual preview only — no installation backend is invoked."
    property bool readyToInstall: true
    property bool productionMode: false
    property bool previewMode: true
    property string errorMessage: ""
    property bool realInstallEnabled: false
    property bool systemActionsEnabled: false
    // The visual preview must exercise the same numeric layout path as a
    // detected disk. Never render a zero-sized or invented partition chart.
    property var values: ({
        "disk.sizeBytes": 549755813888,
        "disk.mode": "erase",
        "disk.separateHome": false,
        "disk.rootSizeGiB": 32
    })
    property var installPlan: ({
        schemaVersion: 2,
        architecture: "x86_64",
        repository: {channel: "stable", mirror: "automatic", repositories: ["meo"]},
        package: {profile: "recommended", packages: ["meo-core-meta", "meo-desktop", "meo-icons", "meo-release", "meo-settings", "meoui-qml", "omnistore-bin"]},
        applications: {selected: ["org.kde.ark", "org.kde.kate", "org.kde.okular", "org.kde.spectacle"], nativePackages: ["ark", "kate", "okular", "spectacle"], source: "arch-official"}
    })
    readonly property var softwareCatalog: [
        {id:"org.kde.ark",name:"Ark",summary:"Open and create compressed archives.",category:"System",package:"ark",tier:"system",profiles:["recommended"]},
        {id:"org.kde.okular",name:"Okular",summary:"Read PDF documents and ebooks.",category:"System",package:"okular",tier:"system",profiles:["recommended"]},
        {id:"org.kde.kate",name:"Kate",summary:"Edit text and source code.",category:"System",package:"kate",tier:"system",profiles:["recommended"]},
        {id:"org.kde.spectacle",name:"Spectacle",summary:"Capture and annotate screenshots.",category:"System",package:"spectacle",tier:"system",profiles:["recommended"]},
        {id:"org.mozilla.firefox",name:"Firefox",summary:"Fast, private web browsing.",category:"Internet",package:"firefox",tier:"recommended",profiles:[]},
        {id:"org.libreoffice.LibreOffice",name:"LibreOffice",summary:"A complete, free office suite.",category:"Office",package:"libreoffice-fresh",tier:"recommended",profiles:[]},
        {id:"org.videolan.VLC",name:"VLC",summary:"Play almost any media format.",category:"Audio & Video",package:"vlc",tier:"recommended",profiles:[]},
        {id:"org.gimp.GIMP",name:"GIMP",summary:"Create and edit raster images.",category:"Creative",package:"gimp",tier:"third-party",profiles:[]},
        {id:"org.kde.krita",name:"Krita",summary:"Digital painting and illustration tools.",category:"Creative",package:"krita",tier:"third-party",profiles:[]},
        {id:"org.kde.kdenlive",name:"Kdenlive",summary:"Non-linear video editing.",category:"Creative",package:"kdenlive",tier:"third-party",profiles:[]},
        {id:"com.obsproject.Studio",name:"OBS Studio",summary:"Record and stream video.",category:"Creative",package:"obs-studio",tier:"third-party",profiles:[]}
    ]
    readonly property var uiLanguages: [
        {id:"en",nativeName:"English"}
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
        {id:"preview-disk-0",devicePath:"/dev/nvme0n1",name:"NVMe Solid State Drive",size:"512 GB",sizeBytes:549755813888,available:"Visual preview disk",kind:"SSD · Preview",eligible:true,unavailableReason:"",partitionInstallEligible:true,partitionUnavailableReason:"",serial:"PREVIEW",wwn:"",
         partitions:[
             {name:"nvme0n1p1",path:"/dev/nvme0n1p1",size:"512 MB",sizeBytes:536870912,startSectors:2048,sizeSectors:1048576,logicalSectorSize:512,parttype:"c12a7328-f81f-11d2-ba4b-00a0c93ec93b",fstype:"vfat",isEfi:true,eligibleRoot:false,eligibleEfi:true,unavailableReason:"EFI System Partition — preserved"},
             {name:"nvme0n1p4",path:"/dev/nvme0n1p4",size:"64 GB",sizeBytes:68719476736,startSectors:2099200,sizeSectors:134217728,logicalSectorSize:512,parttype:"0fc63daf-8483-4772-8e79-3d69d8477de4",fstype:"ext4",isEfi:false,eligibleRoot:true,eligibleEfi:false,unavailableReason:""}
         ]},
        {id:"preview-disk-1",devicePath:"/dev/sdb",name:"External Storage",size:"1 TB",sizeBytes:1099511627776,available:"Preview media excluded",kind:"Removable · Preview",eligible:false,unavailableReason:"This is preview-only removable media.",partitionInstallEligible:false,partitionUnavailableReason:"Removable media cannot be selected.",serial:"PREVIEW",wwn:"",partitions:[]}
    ]

    function setUiLanguage(id) { uiLanguage = id }
    function setSystemLocale(id) { systemLocale = id }
    function setFormatLocale(id) { formatLocale = id }
    function setFormatCountry(id) { formatCountry = id; formatLocale = systemLocale }
    function setTimeZone(id) { timeZone = id }
    function setKeyboardLayout(id) { keyboardLayout = id }
    function setSecondaryCalendar(id) { setSelection("preferences", "secondaryCalendar", id); if (id !== "hebcal") setSelection("preferences", "hebcalEnabled", false) }
    function setHebcalEnabled(enabled) { setSelection("preferences", "hebcalEnabled", enabled) }
    function useRegionRecommendations() {}
    function setNetworkHandoffEnabled(enabled) { networkHandoffEnabled = enabled }
    function setSelectedDisk(id) {
        selectedDisk = id
        if (id === "preview-disk-0")
            setSelection("disk", "sizeBytes", 549755813888)
    }
    function selectExistingPartition(diskId, partitionPath) {
        const disk = disks.find(entry => entry.id === diskId)
        const root = disk ? disk.partitions.find(entry => entry.path === partitionPath) : null
        const efi = disk ? disk.partitions.find(entry => entry.eligibleEfi) : null
        if (!root || !root.eligibleRoot || !efi) { errorMessage = "The preview partition plan is not available."; return }
        selectedDisk = diskId
        setSelection("disk", "sizeBytes", disk.sizeBytes)
        setSelection("disk", "devicePath", disk.devicePath)
        setSelection("disk", "stableId", diskId)
        setSelection("disk", "targetPartition", root)
        setSelection("disk", "efiPartition", efi)
        setSelection("disk", "mode", "partition")
    }
    function retryNetwork() { networkState = "connected" }
    function refreshDisks() {}
    function openDebugTerminal() { debugTerminalMessage = "Preview only: a Live-session terminal would open here." }
    function setSelection(section, key, value) { const next = Object.assign({}, values); next[section + "." + key] = value; values = next }
    function selection(section, key, fallback) { const id = section + "." + key; return typeof values[id] === "undefined" ? fallback : values[id] }
    signal accountReady()
    function saveAccount(fullName, username, hostname, password, confirmation) {
        if (!/^[a-z_][a-z0-9_-]{0,31}$/.test(username)) { errorMessage = "Enter a valid lowercase username."; return }
        if (!/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(hostname)) { errorMessage = "Enter a valid computer name."; return }
        if (password.length < 8 || password !== confirmation) { errorMessage = "Password must be 8 characters and match."; return }
        setSelection("user", "fullName", fullName); setSelection("user", "username", username); setSelection("user", "hostname", hostname)
        errorMessage = ""; accountReady()
    }
    function prepareInstallation() { preflightState = "ready"; preflightMessage = "Visual preview only — no installation backend is invoked." }
    function confirmSummary() {}
    function startInstallation() { installationState = "complete"; installationProgress = 100; installationStage = "complete"; installationMessage = "Visual preview complete." }
    function requestRestart() { errorMessage = "Restart is disabled in preview mode." }
    function requestShutdown() { errorMessage = "Shut down is disabled in preview mode." }
}
