pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import ".."
import "../components"

PageFrame {
    id: page
    property string pendingNetwork: ""
    property bool retrying: false
    readonly property var wifiNetworks: [
        {name:"MeoArch Wi-Fi",detail:"Saved · Strong signal"}, {name:"Home Network",detail:"Secured · Strong signal"},
        {name:"Coffee Shop",detail:"Open · Medium signal"}, {name:"Studio",detail:"Secured · Medium signal"},
        {name:"Guest Network",detail:"Secured · Weak signal"}
    ]
    Column {
        anchors.fill: parent; spacing: page.dp(16)
        PageHeading { width: parent.width; title: "Network"; subtitle: "MeoArch connects automatically when a usable Ethernet or saved Wi-Fi connection is available." }
        InfoBanner { width: parent.width; iconText: page.controller && page.controller.networkState === "connected" ? "OK" : "!"; title: page.controller && page.controller.networkState === "connected" ? "Connected to the Internet" : "You are offline"; message: page.controller && page.controller.networkState === "connected" ? "NetworkManager will keep this connection active during installation." : "Choose a Wi-Fi network, connect a cable, or continue offline."; tone: page.controller && page.controller.networkState === "connected" ? "success" : "error" }
        SelectionCard { visible: page.controller && page.controller.networkState === "connected"; width: parent.width; iconText: "N"; title: "Active network"; value: "Ethernet or Wi-Fi · Connected" }
        ListView {
            visible: page.controller && page.controller.networkState !== "connected"; width: parent.width; height: page.dp(280); clip: true; spacing: page.dp(4); model: page.wifiNetworks
            ScrollBar.vertical: ScrollBar { }
            delegate: SelectionCard {
                required property var modelData
                width: ListView.view.width; height: page.dp(52); iconText: "W"; title: modelData.name; value: modelData.detail
                onClicked: { page.pendingNetwork = modelData.name; passwordDialog.open() }
            }
        }
        Row { visible: page.controller && page.controller.networkState !== "connected"; spacing: page.dp(8); MeoButton { text: "Retry"; kind: "tonal"; busy: page.retrying; enabled: !page.retrying; onClicked: { page.retrying = true; page.controller.retryNetwork(); retryFeedback.restart() } } MeoButton { text: "Skip for now"; kind: "text" } }
    }
    Timer { id: retryFeedback; interval: 700; repeat: false; onTriggered: page.retrying = false }
    MotionPopup {
        id: passwordDialog
        anchors.centerIn: Overlay.overlay; width: Math.min(page.dp(500), Overlay.overlay ? Overlay.overlay.width - page.dp(48) : page.dp(500)); height: page.dp(250); modal: true; padding: page.dp(28); closePolicy: Popup.CloseOnEscape
        contentItem: Column {
            spacing: page.dp(16)
            Text { text: "Connect to " + page.pendingNetwork; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(24); color: MeoTheme.onSurface }
            MeoTextField { id: wifiPassword; width: parent.width; label: "Wi-Fi password"; echoMode: TextInput.Password }
            Row { anchors.right: parent.right; spacing: page.dp(8); MeoButton { text: "Cancel"; kind: "text"; onClicked: { wifiPassword.clear(); passwordDialog.close() } } MeoButton { text: "Connect"; onClicked: { wifiPassword.clear(); passwordDialog.close(); page.controller.retryNetwork() } } }
        }
    }
}
