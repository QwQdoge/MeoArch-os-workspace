pragma Singleton
import QtQuick
// macOS preview stub for the native Meo.System module (Linux/DBus only).
QtObject {
    signal networkChanged()
    property bool audioAvailable: true
    property string audioDevice: "alsa_output.pci-0000_00_1f.3.analog-stereo"
    property bool audioMuted: false
    property var audioOutputDevices: [
        { id: "alsa_output.analog", name: "Built-in Audio Analog Stereo", description: "Built-in Audio", active: true },
        { id: "alsa_output.hdmi", name: "HDMI / DisplayPort", description: "HDMI Output", active: false }
    ]
    property bool networkBusy: false
    property bool networkConnected: true
    property string networkName: "MeoNet"
    property string networkStatus: "connected"
    property bool operationBusy: false
    property string operationError: ""
    property int volumePercent: 60
    property var wifiNetworks: [
        { ssid: "MeoNet", signal: 82, secured: true, active: true, connected: true, connecting: false, saved: true, securityLabel: "WPA2" },
        { ssid: "Cafe-Guest", signal: 55, secured: false, active: false, connected: false, connecting: false, saved: false, securityLabel: "" }
    ]
    property bool wifiScanning: false
    property bool wirelessAvailable: true
    property bool wirelessEnabled: true
    function clearOperationError() {}
    function connectWifi(ssid, password) {}
    function disconnectWifi() {}
    function requestWifiScan() {}
    function setDefaultAudioOutput(id) {}
}
