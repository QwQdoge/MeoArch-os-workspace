pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    primaryEnabled: controller && controller.selectedDisk.length > 0

    Column {
        width: parent.width
        spacing: page.compactHeight ? page.dp(10) : page.dp(14)

        PageHeading {
            width: parent.width
            title: qsTr("Disk Selection")
            subtitle: qsTr("Only verified, non-removable, unmounted disks can be selected. The running installation media is excluded.")
        }
        InfoBanner {
            visible: page.controller && page.controller.disks.length === 0
            width: parent.width
            tone: "error"
            title: qsTr("No eligible disk detected")
            message: qsTr("Disk detection must succeed before installation. Preview disks are never shown in the production installer.")
        }
        ListView {
            width: parent.width
            height: Math.min(contentHeight, page.compactHeight ? page.dp(180) : page.dp(230))
            clip: true
            spacing: page.dp(8)
            model: page.controller ? page.controller.disks : []
            keyNavigationEnabled: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            delegate: SelectionCard {
                required property var modelData
                width: ListView.view.width
                height: page.dp(82)
                iconText: "hard_drive"
                title: modelData.name + " · " + modelData.size
                value: modelData.eligible ? modelData.kind + " · " + modelData.id
                                         : modelData.unavailableReason
                selected: page.controller && page.controller.selectedDisk === modelData.id
                enabled: modelData.eligible
                Accessible.description: modelData.serial.length || modelData.wwn.length
                                        ? qsTr("Serial: %1  WWN: %2").arg(modelData.serial).arg(modelData.wwn) : ""
                onClicked: page.controller.setSelectedDisk(modelData.id)
            }
        }
        GridLayout {
            width: parent.width
            columns: 1
            rowSpacing: page.dp(12)
            columnSpacing: page.dp(12)
            SelectionCard {
                Layout.fillWidth: true
                Layout.preferredHeight: page.dp(72)
                iconText: "delete_sweep"
                title: qsTr("Erase disk and install")
                value: qsTr("Creates GPT, EFI and a root filesystem")
                selected: page.controller && page.controller.selection("disk", "mode", "erase") === "erase"
                onClicked: page.controller.setSelection("disk", "mode", "erase")
            }
            SelectionCard {
                visible: false
                Layout.fillWidth: true
                Layout.preferredHeight: page.dp(72)
                iconText: "tune"
                title: qsTr("Manual partitioning")
                value: qsTr("Unavailable until the real Archinstall disk-plan editor is integrated")
                enabled: false
                Accessible.description: value
            }
        }
        InfoBanner {
            width: parent.width
            tone: "error"
            title: qsTr("All data on the selected disk will be erased")
            message: qsTr("The installation plan and Archinstall preflight must both succeed before the final destructive confirmation.")
        }
        Row {
            spacing: page.dp(8)
            MeoButton { text: qsTr("Advanced options"); type: "text"; onClicked: advanced.openFrom(this) }
            MeoText {
                anchors.verticalCenter: parent.verticalCenter
                text: page.controller ? page.controller.selection("disk", "filesystem", "btrfs").toUpperCase()
                                        + " · " + page.controller.selection("disk", "swap", "zram") : ""
                typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant
            }
        }
    }

    MeoMotionPopup {
        id: advanced
        presentation: MeoMotionPopup.SideSheet
        parent: Overlay.overlay
        x: parent ? parent.width - width : 0
        y: 0
        width: Math.min(page.dp(520), parent ? parent.width : page.dp(520))
        height: parent ? parent.height : page.height
        padding: page.dp(32)
        closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Flickable {
            contentWidth: width
            contentHeight: advancedColumn.implicitHeight
            clip: true
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            Column {
                id: advancedColumn
                width: parent.width
                spacing: page.dp(18)
                MeoText { width: parent.width; text: qsTr("Advanced disk options"); typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoText { text: qsTr("Filesystem"); typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                Row {
                    spacing: page.dp(8)
                    Repeater {
                        model: [{ id: "btrfs", name: qsTr("Btrfs · Recommended") }, { id: "ext4", name: qsTr("ext4") }]
                        delegate: MeoButton { required property var modelData; text: modelData.name; type: page.controller && page.controller.selection("disk", "filesystem", "btrfs") === modelData.id ? "tonal" : "outlined"; onClicked: page.controller.setSelection("disk", "filesystem", modelData.id) }
                    }
                }
                MeoText { text: qsTr("Swap"); typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                Repeater {
                    model: [{ id: "zram", name: qsTr("Automatic ZRAM"), detail: qsTr("Compressed memory swap") }, { id: "file", name: qsTr("Swap file"), detail: qsTr("Creates a 4 GiB target swap file") }, { id: "none", name: qsTr("None"), detail: qsTr("No swap configured") }]
                    delegate: SelectionCard { required property var modelData; width: parent.width; height: page.dp(60); iconText: "swap_horiz"; title: modelData.name; value: modelData.detail; selected: page.controller && page.controller.selection("disk", "swap", "zram") === modelData.id; onClicked: page.controller.setSelection("disk", "swap", modelData.id) }
                }
                InfoBanner { width: parent.width; title: qsTr("Disk encryption unavailable"); message: qsTr("Encryption remains disabled until a tested Archinstall credential and cleanup path is available. No passphrase is collected."); tone: "error" }
                MeoButton { anchors.right: parent.right; text: qsTr("Done"); type: "filled"; onClicked: advanced.close() }
            }
        }
    }
}
