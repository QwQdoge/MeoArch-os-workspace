pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import MeoUI 1.0
import Meo.System 1.0
import ".."
import "../components"

PageFrame {
    id: page
    primaryEnabled: SystemState.networkConnected
    primaryLabel: SystemState.networkConnected ? qsTr("Continue") : qsTr("Network required")

    function signalIcon(strength) {
        if (strength >= 70) return "signal_wifi_4_bar"
        if (strength >= 40) return "network_wifi_3_bar"
        if (strength >= 20) return "network_wifi_2_bar"
        return "network_wifi_1_bar"
    }

    Column {
        width: parent.width
        spacing: page.dp(14)

        PageHeading {
            width: parent.width
            title: qsTr("Network")
            subtitle: qsTr("Connect to a real NetworkManager connection before MeoArch downloads packages.")
        }
        InfoBanner {
            width: parent.width
            title: SystemState.networkConnected ? qsTr("Network connection detected") : qsTr("Internet connection required")
            message: SystemState.networkConnected
                     ? qsTr("The final installation preflight verifies DNS, mirror access, and the generated Archinstall configuration.")
                     : qsTr("Connect Ethernet or Wi-Fi to continue. The installer never invents available networks.")
            tone: SystemState.networkConnected ? "success" : "error"
        }
        SelectionCard {
            visible: SystemState.networkConnected
            width: parent.width
            iconText: "lan"
            title: SystemState.networkName.length ? SystemState.networkName : qsTr("Active connection")
            value: SystemState.networkStatus
            enabled: false
        }
        Item {
            width: parent.width
            height: page.dp(40)
            MeoText {
                anchors.left: parent.left
                anchors.verticalCenter: parent.verticalCenter
                text: qsTr("Wi-Fi")
                typeRole: "title"
                typeSize: "small"
                emphasized: true
                color: MeoTheme.contentOnSurface
            }
            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                spacing: page.dp(8)
                MeoSwitch {
                    id: wifiSwitch
                    checked: SystemState.wirelessEnabled
                    enabled: SystemState.networkAvailable
                    Accessible.name: qsTr("Wi-Fi enabled")
                    onToggled: checkedState => { SystemState.wirelessEnabled = checkedState }
                }
                MeoIconButton {
                    id: scanButton
                    icon.name: "refresh"
                    type: "tonal"
                    Accessible.name: qsTr("Scan for Wi-Fi networks")
                    enabled: SystemState.wirelessEnabled && !SystemState.wifiScanning && !SystemState.networkBusy
                    onClicked: SystemState.requestWifiScan()
                }
            }
        }
        Row {
            visible: SystemState.wifiScanning || SystemState.networkBusy
            spacing: page.dp(8)
            MeoLoadingIndicator { indeterminate: true; width: page.dp(20); height: width }
            MeoText {
                text: SystemState.wifiScanning ? qsTr("Scanning for Wi-Fi networks…") : qsTr("Connecting…")
                typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant
            }
        }
        InfoBanner {
            visible: SystemState.operationError.length > 0
            width: parent.width
            tone: "error"
            title: qsTr("Network operation failed")
            message: SystemState.operationError
        }
        ListView {
            id: networkList
            visible: SystemState.wirelessEnabled
            width: parent.width
            height: Math.min(contentHeight, page.compactHeight ? page.dp(200) : page.dp(270))
            clip: true
            spacing: page.dp(6)
            model: SystemState.wifiNetworks
            keyNavigationEnabled: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            delegate: SelectionCard {
                required property var modelData
                width: ListView.view.width
                height: page.dp(72)
                iconText: page.signalIcon(modelData.strength)
                title: modelData.ssid
                value: modelData.connected ? qsTr("Connected")
                       : modelData.connecting ? qsTr("Connecting…")
                       : modelData.saved ? qsTr("Saved · %1").arg(modelData.securityLabel)
                       : modelData.securityLabel
                selected: modelData.connected
                enabled: !SystemState.networkBusy
                onClicked: {
                    SystemState.clearOperationError()
                    if (modelData.connected) SystemState.disconnectWifi()
                    else if (modelData.saved || !modelData.secured) SystemState.connectWifi(modelData.ssid, "")
                    else { passwordDialog.ssid = modelData.ssid; passwordDialog.openFrom(this) }
                }
            }
        }
        MeoButton {
            visible: SystemState.wirelessEnabled && SystemState.wifiNetworks.length === 0
            text: SystemState.wifiScanning ? qsTr("Scanning…") : qsTr("Scan for networks")
            type: "tonal"
            loading: SystemState.wifiScanning
            enabled: !SystemState.wifiScanning
            onClicked: SystemState.requestWifiScan()
        }
    }

    MeoMotionPopup {
        id: passwordDialog
        presentation: MeoMotionPopup.Dialog
        property string ssid: ""
        anchors.centerIn: Overlay.overlay
        width: Math.min(page.dp(500), Overlay.overlay ? Overlay.overlay.width - page.dp(48) : page.dp(500))
        padding: page.dp(28)
        closePolicy: Popup.CloseOnEscape
        contentItem: Column {
            spacing: page.dp(16)
            MeoText { width: parent.width; text: qsTr("Connect to %1").arg(passwordDialog.ssid); typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
            MeoTextField { id: wifiPassword; width: parent.width; type: "outlined"; size: "l"; label: qsTr("Wi-Fi password"); echoMode: TextInput.Password; isPassword: true }
            Row {
                anchors.right: parent.right; spacing: page.dp(8)
                MeoButton { text: qsTr("Cancel"); type: "text"; onClicked: { wifiPassword.clear(); passwordDialog.close() } }
                MeoButton { text: qsTr("Connect"); type: "filled"; enabled: wifiPassword.text.length > 0; onClicked: { SystemState.connectWifi(passwordDialog.ssid, wifiPassword.text); wifiPassword.clear(); passwordDialog.close() } }
            }
        }
    }
}
