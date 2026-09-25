pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import MeoUI 1.0
import Meo.System 1.0 as MeoSystem
import ".."
import "../components"

PageFrame {
    id: page
    readonly property bool hasActiveNetwork: page.controller
                                             && page.controller.networkState !== "no-interface"
                                             && page.controller.networkState !== "unknown"
    primaryEnabled: page.hasActiveNetwork
    primaryLabel: primaryEnabled ? qsTr("Continue") : qsTr("Connect to continue")
    primaryAccessibleDescription: primaryEnabled
                                  ? qsTr("Continue with the active network; Internet and package downloads are checked again before installation")
                                  : qsTr("Connect a network interface before continuing with installation")

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
            subtitle: qsTr("MeoArch downloads the system, desktop, and selected packages during installation. Connect to the Internet to continue.")
        }
        InfoBanner {
            width: parent.width
            title: page.controller && page.controller.networkState === "online" ? qsTr("Internet connection detected")
                   : page.controller && page.controller.networkState === "checking" ? qsTr("Checking Internet connection")
                   : page.controller && page.controller.networkState === "repository" ? qsTr("MeoArch package source unavailable")
                   : page.controller && page.controller.networkState === "portal" ? qsTr("Network sign-in may be required")
                   : qsTr("Internet connection required")
            message: page.controller ? page.controller.networkDetail : qsTr("Network status is unavailable.")
            tone: page.controller && page.controller.networkState === "online" ? "success"
                  : page.controller && page.controller.networkState === "no-interface" ? "error"
                  : page.controller && page.controller.networkState === "checking" ? "info" : "warning"
        }
        InfoBanner {
            visible: page.controller && (page.controller.networkState === "offline"
                                           || page.controller.networkState === "no-interface")
            width: parent.width
            tone: "info"
            title: qsTr("Offline installation is not available")
            message: qsTr("Connect with Wi-Fi or Ethernet to continue. No disk changes happen on this page or before the final confirmation.")
        }
        ToggleRow {
            width: parent.width
            visible: page.controller && page.controller.networkHandoffState === "ready"
            title: qsTr("Remember this network after installation")
            subtitle: page.controller ? page.controller.networkHandoffMessage : ""
            checked: page.controller ? page.controller.networkHandoffEnabled : false
            onToggled: checked => page.controller.setNetworkHandoffEnabled(checked)
        }
        InfoBanner {
            width: parent.width
            visible: page.controller
                     && (page.controller.networkState === "online"
                         || page.controller.networkState === "repository")
                     && page.controller.networkHandoffState !== "ready"
            title: qsTr("This network will not be copied")
            message: page.controller ? page.controller.networkHandoffMessage : ""
        }
        MeoButton {
            width: implicitWidth
            visible: page.controller && page.controller.networkState !== "online"
            text: page.controller && page.controller.networkState === "checking"
                  ? qsTr("Checking connection…") : qsTr("Check connection again")
            type: "tonal"
            loading: page.controller && page.controller.networkState === "checking"
            enabled: page.controller && page.controller.networkState !== "checking"
            Accessible.description: qsTr("Rechecks Internet and package-source reachability without blocking the rest of the setup wizard")
            onClicked: page.controller.retryNetwork()
        }
        SelectionCard {
            visible: MeoSystem.SystemState.networkConnected
            width: parent.width
            iconText: "lan"
            title: MeoSystem.SystemState.networkName.length ? MeoSystem.SystemState.networkName : qsTr("Active connection")
            value: MeoSystem.SystemState.networkStatus
            actionable: false
            trailingIcon: ""
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
                    checked: MeoSystem.SystemState.wirelessAvailable && MeoSystem.SystemState.wirelessEnabled
                    enabled: MeoSystem.SystemState.wirelessAvailable
                    Accessible.name: qsTr("Wi-Fi enabled")
                    onToggled: checkedState => { MeoSystem.SystemState.wirelessEnabled = checkedState }
                }
                MeoIconButton {
                    id: scanButton
                    icon.name: "refresh"
                    type: "tonal"
                    Accessible.name: qsTr("Scan for Wi-Fi networks")
                    enabled: MeoSystem.SystemState.wirelessAvailable && MeoSystem.SystemState.wirelessEnabled && !MeoSystem.SystemState.wifiScanning && !MeoSystem.SystemState.networkBusy
                    onClicked: MeoSystem.SystemState.requestWifiScan()
                }
            }
        }
        Row {
            visible: MeoSystem.SystemState.wifiScanning || MeoSystem.SystemState.networkBusy
            spacing: page.dp(8)
            MeoLoadingIndicator { indeterminate: true; width: page.dp(20); height: width }
            MeoText {
                text: MeoSystem.SystemState.wifiScanning ? qsTr("Scanning for Wi-Fi networks…") : qsTr("Connecting…")
                typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant
            }
        }
        InfoBanner {
            visible: !MeoSystem.SystemState.wirelessAvailable
            width: parent.width
            tone: "info"
            title: qsTr("Wi-Fi is not available")
            message: MeoSystem.SystemState.networkConnected
                     ? qsTr("This device is connected through Ethernet. Wi-Fi is not required.")
                     : qsTr("No Wi-Fi adapter was detected. Connect Ethernet or attach a supported Wi-Fi adapter.")
        }
        InfoBanner {
            visible: MeoSystem.SystemState.wirelessAvailable && MeoSystem.SystemState.operationError.length > 0
            width: parent.width
            tone: "error"
            title: qsTr("Network operation failed")
            message: MeoSystem.SystemState.operationError
        }
        ListView {
            id: networkList
            visible: MeoSystem.SystemState.wirelessAvailable && MeoSystem.SystemState.wirelessEnabled
            width: parent.width
            height: Math.min(contentHeight, page.compactHeight ? page.dp(200) : page.dp(270))
            clip: true
            spacing: page.dp(6)
            model: MeoSystem.SystemState.wifiNetworks
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
                selectionIndicator: true
                enabled: !MeoSystem.SystemState.networkBusy
                onClicked: {
                    MeoSystem.SystemState.clearOperationError()
                    if (modelData.connected) MeoSystem.SystemState.disconnectWifi()
                    else if (modelData.saved || !modelData.secured) MeoSystem.SystemState.connectWifi(modelData.ssid, "")
                    else { passwordDialog.ssid = modelData.ssid; passwordDialog.openFrom(this) }
                }
            }
        }
        MeoButton {
            visible: MeoSystem.SystemState.wirelessAvailable && MeoSystem.SystemState.wirelessEnabled && MeoSystem.SystemState.wifiNetworks.length === 0
            text: MeoSystem.SystemState.wifiScanning ? qsTr("Scanning…") : qsTr("Scan for networks")
            type: "tonal"
            loading: MeoSystem.SystemState.wifiScanning
            enabled: !MeoSystem.SystemState.wifiScanning
            onClicked: MeoSystem.SystemState.requestWifiScan()
        }
    }

    Timer {
        id: connectivityRetry
        interval: 900
        repeat: false
        onTriggered: {
            if (page.controller && MeoSystem.SystemState.networkConnected
                    && page.controller.networkState !== "online")
                page.controller.retryNetwork()
        }
    }

    Connections {
        target: MeoSystem.SystemState
        function onNetworkChanged() {
            // A successful NetworkManager activation should make the installer
            // re-check Internet reachability, but a short debounce avoids
            // issuing a probe for every intermediate activation state.
            if (MeoSystem.SystemState.networkConnected)
                connectivityRetry.restart()
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
                MeoButton { text: qsTr("Connect"); type: "filled"; enabled: wifiPassword.text.length > 0; onClicked: { MeoSystem.SystemState.connectWifi(passwordDialog.ssid, wifiPassword.text); wifiPassword.clear(); passwordDialog.close() } }
            }
        }
    }
}
