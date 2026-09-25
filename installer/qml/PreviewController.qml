pragma Singleton
import QtQuick

QtObject {
    readonly property bool previewInstalling: Qt.application.arguments.indexOf("--preview-installing") >= 0
    readonly property bool previewComplete: Qt.application.arguments.indexOf("--preview-complete") >= 0
    // The mock controller is used only for visual-regression runs, but it
    // must model the same system-language default as the native controller.
    property string uiLanguage: Qt.uiLanguage.toLowerCase().startsWith("zh") ? "zh_CN" : "en"
    property string systemLocale: uiLanguage === "zh_CN" ? "zh_CN.UTF-8" : "en_US.UTF-8"
    property string formatCountry: uiLanguage === "zh_CN" ? "CN" : "US"
    property string formatLocale: systemLocale
    property string timeZone: uiLanguage === "zh_CN" ? "Asia/Shanghai" : "UTC"
    property string keyboardLayout: "us"
    property var regionRecommendation: ({ country: formatCountry, systemLocale: systemLocale, formatLocale: formatLocale, timeZone: timeZone, keyboardLayout: keyboardLayout, automatic: true, hasPreset: true })
    readonly property var calendarCapabilities: [
        {id:"none",name:qsTr("No secondary calendar"),description:qsTr("Gregorian calendar only"),state:"ready"},
        {id:"buddhist",name:qsTr("Buddhist Era"),description:qsTr("Local display only"),state:"ready"},
        {id:"islamic-civil",name:qsTr("Islamic Civil calendar"),description:qsTr("Local Qt calendar display"),state:"ready"},
        {id:"hebcal",name:qsTr("Online Hebrew calendar data"),description:qsTr("After installation, you can turn on public holiday data for the Hebrew calendar."),state:"needs-online-setup"}
    ]
    property string runtimeEnvironment: "live"
    property string firmwareMode: "uefi"
    property string networkState: "online"
    property string networkDetail: qsTr("Visual preview data")
    property string networkHandoffState: "ready"
    property string networkHandoffMessage: qsTr("This current network can be remembered after installation.")
    property bool networkHandoffEnabled: false
    property bool diagnosticConsoleAvailable: true
    property bool diagnosticConsoleRunning: false
    property string diagnosticConsoleOutput: qsTr("Preview only — commands are not executed.")
    property string selectedDisk: "preview-disk-0"
    property string hardwareSummary: qsTr("Automatic PCI detection will select graphics drivers.")
    property string hardwareWarning: ""
    property bool hardwareDetecting: false
    property bool diskDetecting: false
    property string installationState: previewComplete ? "complete" : previewInstalling ? "running" : "idle"
    property int installationProgress: previewComplete ? 100 : previewInstalling ? 35 : 0
    property string installationStage: previewComplete ? "complete" : previewInstalling ? "installing_base" : "idle"
    property string installationMessage: previewComplete ? qsTr("Installation complete.")
                                                       : previewInstalling ? qsTr("Installing the base system and packages") : ""
    property string preflightState: "ready"
    property string preflightMessage: qsTr("Visual preview only — no installation backend is invoked.")
    property bool readyToInstall: true
    property bool productionMode: false
    property bool previewMode: true
    property string errorMessage: ""
    property bool realInstallEnabled: false
    property bool systemActionsEnabled: false
    // Keep the preview controller contract aligned with InstallerController.
    // Pages that read selection() need an observable dependency so their
    // checked/selected visuals update in the same view after a click.
    property int selectionRevision: 0
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
        {id:"org.kde.ark",name:"Ark",summary:qsTr("Open and create compressed archives."),category:qsTr("System"),package:"ark",tier:"system",profiles:["recommended"]},
        {id:"org.kde.okular",name:"Okular",summary:qsTr("Read PDF documents and ebooks."),category:qsTr("System"),package:"okular",tier:"system",profiles:["recommended"]},
        {id:"org.kde.kate",name:"Kate",summary:qsTr("Edit text and source code."),category:qsTr("System"),package:"kate",tier:"system",profiles:["recommended"]},
        {id:"org.kde.spectacle",name:"Spectacle",summary:qsTr("Capture and annotate screenshots."),category:qsTr("System"),package:"spectacle",tier:"system",profiles:["recommended"]},
        {id:"org.mozilla.firefox",name:"Firefox",summary:qsTr("Fast, private web browsing."),category:qsTr("Internet"),package:"firefox",tier:"recommended",profiles:[]},
        {id:"org.libreoffice.LibreOffice",name:"LibreOffice",summary:qsTr("A complete, free office suite."),category:qsTr("Office"),package:"libreoffice-fresh",tier:"recommended",profiles:[]},
        {id:"org.videolan.VLC",name:"VLC",summary:qsTr("Play almost any media format."),category:qsTr("Audio & Video"),package:"vlc",tier:"recommended",profiles:[]},
        {id:"org.gimp.GIMP",name:"GIMP",summary:qsTr("Create and edit raster images."),category:qsTr("Creative"),package:"gimp",tier:"third-party",profiles:[]},
        {id:"org.kde.krita",name:"Krita",summary:qsTr("Digital painting and illustration tools."),category:qsTr("Creative"),package:"krita",tier:"third-party",profiles:[]},
        {id:"org.kde.kdenlive",name:"Kdenlive",summary:qsTr("Non-linear video editing."),category:qsTr("Creative"),package:"kdenlive",tier:"third-party",profiles:[]},
        {id:"com.obsproject.Studio",name:"OBS Studio",summary:qsTr("Record and stream video."),category:qsTr("Creative"),package:"obs-studio",tier:"third-party",profiles:[]}
    ]
    readonly property var uiLanguages: [
        {id:"en",nativeName:"English",englishName:"English"},
        {id:"zh_CN",nativeName:"简体中文",englishName:"Chinese (Simplified)"}
    ]
    readonly property var systemLocales: [
        {id:"en_US.UTF-8",nativeName:"English",code:"en_US.UTF-8"},
        {id:"de_DE.UTF-8",nativeName:"Deutsch",code:"de_DE.UTF-8"},
        {id:"ja_JP.UTF-8",nativeName:"日本語",code:"ja_JP.UTF-8"},
        {id:"zh_CN.UTF-8",nativeName:"简体中文",code:"zh_CN.UTF-8"}
    ]
    readonly property var countries: [
        {alpha2:"US",alpha3:"USA",name:qsTr("United States")},{alpha2:"DE",alpha3:"DEU",name:qsTr("Germany")},
        {alpha2:"JP",alpha3:"JPN",name:qsTr("Japan")},{alpha2:"SG",alpha3:"SGP",name:qsTr("Singapore")}
    ]
    readonly property var timeZones: [
        {id:"UTC",label:"UTC · UTC+00:00"},{id:"Asia/Singapore",label:qsTr("Singapore · UTC+08:00")},
        {id:"Europe/Berlin",label:qsTr("Berlin · UTC+02:00")},{id:"America/New_York",label:qsTr("New York · UTC-04:00")}
    ]
    readonly property var keyboardLayouts: [
        {id:"us",name:qsTr("English (US)")},{id:"gb",name:qsTr("English (UK)")},{id:"jp",name:qsTr("Japanese")},
        {id:"de",name:qsTr("German")},{id:"fr",name:qsTr("French")},{id:"es",name:qsTr("Spanish")}
    ]
    readonly property var disks: [
        {id:"preview-disk-0",devicePath:"/dev/nvme0n1",name:qsTr("NVMe Solid State Drive"),size:"512 GB",sizeBytes:549755813888,logicalSectorSize:512,available:qsTr("Visual preview disk"),kind:qsTr("SSD · Preview"),eligible:true,unavailableReason:"",partitionInstallEligible:true,partitionUnavailableReason:"",serial:"PREVIEW",wwn:"",
         partitions:[
             {name:"nvme0n1p1",path:"/dev/nvme0n1p1",size:"512 MB",sizeBytes:536870912,startSectors:2048,sizeSectors:1048576,logicalSectorSize:512,parttype:"c12a7328-f81f-11d2-ba4b-00a0c93ec93b",fstype:"vfat",isEfi:true,eligibleRoot:false,eligibleEfi:true,unavailableReason:qsTr("EFI System Partition — preserved")},
             {name:"nvme0n1p4",path:"/dev/nvme0n1p4",size:"64 GB",sizeBytes:68719476736,startSectors:2099200,sizeSectors:134217728,logicalSectorSize:512,parttype:"0fc63daf-8483-4772-8e79-3d69d8477de4",fstype:"ext4",isEfi:false,eligibleRoot:true,eligibleEfi:false,unavailableReason:""}
         ]},
        {id:"preview-disk-1",devicePath:"/dev/sdb",name:qsTr("External Storage"),size:"1 TB",sizeBytes:1099511627776,logicalSectorSize:512,available:qsTr("Preview media excluded"),kind:qsTr("Removable · Preview"),eligible:false,unavailableReason:qsTr("This is preview-only removable media."),partitionInstallEligible:false,partitionUnavailableReason:qsTr("Removable media cannot be selected."),serial:"PREVIEW",wwn:"",partitions:[]}
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
        if (!root || !root.eligibleRoot || !efi) { errorMessage = qsTr("The preview partition plan is not available."); return }
        selectedDisk = diskId
        setSelection("disk", "sizeBytes", disk.sizeBytes)
        setSelection("disk", "devicePath", disk.devicePath)
        setSelection("disk", "stableId", diskId)
        setSelection("disk", "targetPartition", root)
        setSelection("disk", "efiPartition", efi)
        setSelection("disk", "mode", "partition")
    }
    function retryNetwork() { networkState = "online" }
    function refreshDisks() {}
    function runDiagnosticCommand(command) {
        diagnosticConsoleOutput += "\n$ " + command + "\n" + qsTr("Preview only — command not executed.")
    }
    function clearDiagnosticConsole() { diagnosticConsoleOutput = "" }
    function setSelection(section, key, value) {
        const next = Object.assign({}, values)
        next[section + "." + key] = value
        values = next
        ++selectionRevision
    }
    function selection(section, key, fallback) { const id = section + "." + key; return typeof values[id] === "undefined" ? fallback : values[id] }
    signal accountReady()
    function saveAccount(fullName, username, hostname, password, confirmation) {
        if (!/^[a-z_][a-z0-9_-]{0,31}$/.test(username)) { errorMessage = qsTr("Enter a valid lowercase username."); return }
        if (!/^[a-z0-9](?:[a-z0-9-]{0,61}[a-z0-9])?$/.test(hostname)) { errorMessage = qsTr("Enter a valid computer name."); return }
        if (password.length < 8 || password !== confirmation) { errorMessage = qsTr("Password must be 8 characters and match."); return }
        setSelection("user", "fullName", fullName); setSelection("user", "username", username); setSelection("user", "hostname", hostname)
        errorMessage = ""; accountReady()
    }
    function prepareInstallation() { preflightState = "ready"; preflightMessage = qsTr("Visual preview only — no installation backend is invoked.") }
    function confirmSummary() {}
    function startInstallation() { installationState = "complete"; installationProgress = 100; installationStage = "complete"; installationMessage = qsTr("Visual preview complete.") }
    function requestRestart() { errorMessage = qsTr("Restart is disabled in preview mode.") }
    function requestShutdown() { errorMessage = qsTr("Shut down is disabled in preview mode.") }
}
