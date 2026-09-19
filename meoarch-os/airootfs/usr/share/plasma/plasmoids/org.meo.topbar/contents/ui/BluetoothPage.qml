import QtQuick
import QtQuick.Layouts
import MeoUI 1.0
import MeoKDE 1.0
import Meo.System 1.0

Item {
    id: root
    signal backRequested()
    implicitWidth: ShellMetrics.quickSettingsWidth
    implicitHeight: ShellMetrics.quickSettingsHeight

    ColumnLayout {
        anchors.fill: parent
        spacing: ShellMetrics.popupItemSpacing

        PopupPageHeader {
            Layout.fillWidth: true
            title: i18n("Bluetooth")
            subtitle: SystemState.bluetoothEnabled ? i18n("Connect and manage devices") : i18n("Bluetooth is off")
            onBackRequested: root.backRequested()
            trailingContent: Component {
                RowLayout {
                    spacing: MeoTheme.space4
                    MeoSwitch {
                        size: "s"
                        checked: SystemState.bluetoothEnabled
                        enabled: SystemState.bluetoothAvailable && !SystemState.bluetoothBusy
                        Accessible.name: i18n("Bluetooth")
                        onToggled: function(checked) { SystemState.bluetoothEnabled = checked }
                    }
                    MeoIconButton {
                        type: "standard"
                        size: "m"
                        icon.name: SystemState.bluetoothDiscovering ? "stop" : "refresh"
                        enabled: SystemState.bluetoothEnabled && !SystemState.bluetoothBusy
                        Accessible.name: SystemState.bluetoothDiscovering
                                         ? i18n("Stop Bluetooth discovery") : i18n("Discover Bluetooth devices")
                        onClicked: {
                            if (SystemState.bluetoothDiscovering) SystemState.stopBluetoothDiscovery()
                            else SystemState.startBluetoothDiscovery()
                        }
                    }
                }
            }
        }

        PopupInlineMessage {
            Layout.fillWidth: true
            text: SystemState.operationError
            dismissible: true
            onDismissed: SystemState.clearOperationError()
        }

        RowLayout {
            Layout.fillWidth: true
            visible: SystemState.bluetoothDiscovering
            spacing: MeoTheme.space8
            MeoLoadingIndicator { indeterminate: true; width: 20 * MeoTheme.globalScale; height: width }
            MeoText {
                text: i18n("Looking for nearby devices…")
                typeRole: "body"
                typeSize: "small"
                color: MeoTheme.onSurfaceVariant
            }
        }

        Item {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: bluetoothList
                anchors.fill: parent
                visible: SystemState.bluetoothAvailable && SystemState.bluetoothEnabled
                         && SystemState.bluetoothDevices.length > 0
                clip: true
                spacing: MeoTheme.space4
                model: SystemState.bluetoothDevices
                delegate: MeoListItem {
                    required property var modelData
                    width: bluetoothList.width
                    isDense: true
                    isSegmented: true
                    roundingStrategy: "all"
                    headline: modelData.name
                    supportingText: modelData.connected
                                    ? (modelData.batteryAvailable
                                       ? i18n("Connected · %1%").arg(modelData.batteryPercent) : i18n("Connected"))
                                    : (modelData.paired ? i18n("Paired") : i18n("Available"))
                    leadingIcon: modelData.icon
                    selected: modelData.connected
                    interactive: !SystemState.bluetoothBusy
                    trailingComponent: Component {
                        RowLayout {
                            spacing: MeoTheme.space4
                            MeoIcon { visible: modelData.connected; icon: "check"; size: 18; fill: true; color: MeoTheme.primary }
                            MeoIconButton {
                                visible: modelData.paired && !modelData.connected
                                type: "standard"
                                size: "s"
                                icon.name: "delete"
                                Accessible.name: i18n("Forget %1").arg(modelData.name)
                                onClicked: SystemState.forgetBluetoothDevice(modelData.address)
                            }
                        }
                    }
                    onClicked: SystemState.toggleBluetoothDevice(modelData.address)
                }
            }

            PopupEmptyState {
                anchors.fill: parent
                visible: !bluetoothList.visible
                iconName: "bluetooth"
                title: !SystemState.bluetoothAvailable ? i18n("Bluetooth is unavailable")
                       : (!SystemState.bluetoothEnabled ? i18n("Bluetooth is turned off") : i18n("No devices found"))
                description: !SystemState.bluetoothAvailable
                             ? i18n("Check that a Bluetooth adapter and the BlueZ service are available.")
                             : (!SystemState.bluetoothEnabled
                                ? i18n("Turn on Bluetooth to connect accessories.")
                                : i18n("Put the device in pairing mode, then search again."))
                actionText: !SystemState.bluetoothAvailable ? i18n("Bluetooth Settings")
                            : (!SystemState.bluetoothEnabled ? i18n("Turn on Bluetooth")
                                                            : (SystemState.bluetoothDiscovering ? "" : i18n("Find devices")))
                onActionRequested: {
                    if (!SystemState.bluetoothAvailable)
                        Qt.openUrlExternally("systemsettings:kcm_bluetooth")
                    else if (!SystemState.bluetoothEnabled)
                        SystemState.bluetoothEnabled = true
                    else
                        SystemState.startBluetoothDiscovery()
                }
            }
        }
    }
}
