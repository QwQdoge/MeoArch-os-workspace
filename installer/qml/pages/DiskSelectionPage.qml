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
    property int selectedPartition: -1

    ListModel {
        id: partitions
        ListElement { partition: "EFI System"; sizeText: "512 MiB"; filesystem: "FAT32"; mountPoint: "/boot" }
        ListElement { partition: "MeoArch root"; sizeText: "64 GiB"; filesystem: "Btrfs"; mountPoint: "/" }
        ListElement { partition: "Home"; sizeText: "Remaining"; filesystem: "Btrfs"; mountPoint: "/home" }
    }

    Column {
        width: parent.width
        spacing: page.compactHeight ? page.dp(10) : page.dp(14)

        PageHeading {
            width: parent.width
            title: "Disk Selection"
            subtitle: "Choose the destination and how MeoArch should use it."
        }
        ListView {
            width: parent.width
            height: page.compactHeight ? page.dp(144) : page.dp(188)
            clip: true
            spacing: page.dp(8)
            model: page.controller ? page.controller.disks : []
            keyNavigationEnabled: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            delegate: SelectionCard {
                required property var modelData
                width: ListView.view.width
                height: page.dp(88)
                iconText: "hard_drive"
                title: modelData.name + " · " + modelData.size
                value: modelData.available + " · " + modelData.kind
                selected: page.controller && page.controller.selectedDisk === modelData.id
                onClicked: page.controller.setSelectedDisk(modelData.id)
            }
        }
        GridLayout {
            width: parent.width
            columns: width < page.dp(620) ? 1 : 2
            rowSpacing: page.dp(12)
            columnSpacing: page.dp(12)

            SelectionCard {
                Layout.fillWidth: true
                Layout.preferredHeight: page.dp(72)
                iconText: "delete_sweep"
                title: "Erase disk and install"
                value: "Recommended"
                selected: page.controller && page.controller.selection("disk", "mode", "erase") === "erase"
                onClicked: page.controller.setSelection("disk", "mode", "erase")
            }
            SelectionCard {
                Layout.fillWidth: true
                Layout.preferredHeight: page.dp(72)
                iconText: "tune"
                title: "Manual partitioning"
                value: "Advanced"
                selected: page.controller && page.controller.selection("disk", "mode", "erase") === "manual"
                onClicked: {
                    page.controller.setSelection("disk", "mode", "manual")
                    manualDialog.openFrom(this)
                }
            }
        }
        InfoBanner {
            visible: page.controller && page.controller.selection("disk", "mode", "erase") === "erase"
            width: parent.width
            tone: "error"
            title: "All data on the selected disk will be erased"
            message: "You will confirm this destructive action again on the Summary page."
        }
        Row {
            spacing: page.dp(8)
            MeoButton { text: "Advanced options"; type: "text"; onClicked: advanced.openFrom(this) }
            MeoText {
                anchors.verticalCenter: parent.verticalCenter
                text: page.controller ? page.controller.selection("disk", "filesystem", "btrfs").toUpperCase()
                                        + " · " + page.controller.selection("disk", "swap", "zram") : ""
                typeRole: "body"
                typeSize: "medium"
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
    }

    MeoMotionPopup {
        id: manualDialog
        presentation: MeoMotionPopup.FullScreen
        parent: Overlay.overlay
        x: 0
        y: 0
        width: parent ? parent.width : page.width
        height: parent ? parent.height : page.height
        padding: page.dp(32)
        closePolicy: Popup.CloseOnEscape

        contentItem: Column {
            spacing: page.dp(18)

            MeoText { text: "Manual partitioning"; typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
            MeoText {
                width: parent.width
                text: "Review partitions, filesystems, and mount points. Existing EFI partitions are reused without formatting by default."
                typeRole: "body"
                typeSize: "medium"
                color: MeoTheme.contentOnSurfaceVariant
                wrapMode: Text.WordWrap
            }
            MeoCard {
                width: parent.width
                implicitHeight: parent.height - page.dp(150)
                type: "filled"
                padding: page.dp(16)

                Column {
                    width: parent.width
                    Row {
                        width: parent.width
                        height: page.dp(48)
                        spacing: page.dp(12)
                        Repeater {
                            model: ["Partition", "Size", "Filesystem", "Mount point"]
                            MeoText {
                                required property string modelData
                                width: (parent.width - page.dp(36)) / 4
                                text: modelData
                                typeRole: "label"
                                typeSize: "medium"
                                emphasized: true
                                color: MeoTheme.contentOnSurface
                            }
                        }
                    }
                    ListView {
                        width: parent.width
                        height: parent.parent.height - page.dp(48)
                        clip: true
                        model: partitions
                        keyNavigationEnabled: true
                        boundsBehavior: Flickable.StopAtBounds

                        delegate: Rectangle {
                            id: partitionRow
                            required property string partition
                            required property string sizeText
                            required property string filesystem
                            required property string mountPoint
                            required property int index
                            width: ListView.view.width
                            height: page.dp(56)
                            radius: page.dp(12)
                            color: page.selectedPartition === index ? MeoTheme.primaryContainer : "transparent"
                            activeFocusOnTab: true
                            Accessible.role: Accessible.ListItem
                            Accessible.name: partition + ", " + sizeText + ", " + filesystem + ", " + mountPoint
                            Accessible.selected: page.selectedPartition === index

                            Row {
                                anchors.fill: parent
                                spacing: page.dp(12)
                                Repeater {
                                    model: [partitionRow.partition, partitionRow.sizeText, partitionRow.filesystem, partitionRow.mountPoint]
                                    MeoText {
                                        required property string modelData
                                        width: (parent.width - page.dp(36)) / 4
                                        anchors.verticalCenter: parent.verticalCenter
                                        text: modelData
                                        typeRole: "body"
                                        typeSize: "medium"
                                        color: MeoTheme.contentOnSurface
                                        elide: Text.ElideRight
                                    }
                                }
                            }
                            MeoStateLayer {
                                anchors.fill: parent
                                radius: parent.radius
                                hovered: rowHover.hovered
                                pressed: rowTap.pressed
                                focused: partitionRow.activeFocus
                                color: MeoTheme.contentOnSurface
                            }
                            HoverHandler { id: rowHover }
                            TapHandler { id: rowTap; onTapped: { page.selectedPartition = partitionRow.index; partitionRow.forceActiveFocus() } }
                            Keys.onReturnPressed: page.selectedPartition = partitionRow.index
                            Keys.onSpacePressed: page.selectedPartition = partitionRow.index
                        }
                    }
                }
            }
            Row {
                width: parent.width
                spacing: page.dp(8)
                MeoButton { text: "Add"; type: "tonal"; onClicked: partitions.append({ partition: "New partition", sizeText: "20 GiB", filesystem: "Btrfs", mountPoint: "/mnt" }) }
                MeoButton { text: "Edit"; type: "text"; enabled: page.selectedPartition >= 0 }
                MeoButton { text: "Delete"; type: "text"; enabled: page.selectedPartition >= 0; onClicked: deleteConfirm.openFrom(this) }
                Item { width: Math.max(0, parent.width - page.dp(430)); height: 1 }
                MeoButton { text: "Cancel"; type: "text"; onClicked: manualDialog.close() }
                MeoButton { text: "Apply"; type: "filled"; onClicked: { page.controller.setSelection("disk", "manualConfigured", true); manualDialog.close() } }
            }
        }
    }

    MeoDialog {
        id: deleteConfirm
        parent: Overlay.overlay
        title: "Delete selected partition?"
        message: "This changes the proposed layout. Existing data is not modified until installation begins."
        confirmText: "Delete"
        cancelText: "Cancel"
        onConfirmed: {
            if (page.selectedPartition >= 0) {
                partitions.remove(page.selectedPartition)
                page.selectedPartition = -1
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
            id: advancedFlick
            contentWidth: width
            contentHeight: advancedColumn.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }

            Column {
                id: advancedColumn
                width: advancedFlick.width
                spacing: page.dp(18)

                MeoText { width: parent.width; text: "Advanced disk options"; typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoText { text: "Filesystem"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                Row {
                    spacing: page.dp(8)
                    Repeater {
                        model: [{ id: "btrfs", name: "Btrfs · Recommended" }, { id: "ext4", name: "ext4" }]
                        delegate: MeoButton {
                            required property var modelData
                            text: modelData.name
                            type: page.controller && page.controller.selection("disk", "filesystem", "btrfs") === modelData.id ? "tonal" : "outlined"
                            onClicked: page.controller.setSelection("disk", "filesystem", modelData.id)
                        }
                    }
                }
                MeoText { text: "Swap"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                Column {
                    width: parent.width
                    spacing: page.dp(8)
                    Repeater {
                        model: [{ id: "zram", name: "Automatic ZRAM" }, { id: "file", name: "Swap file" }, { id: "none", name: "None" }]
                        delegate: SelectionCard {
                            required property var modelData
                            width: parent.width
                            height: page.dp(60)
                            iconText: "swap_horiz"
                            title: modelData.name
                            value: modelData.id
                            selected: page.controller && page.controller.selection("disk", "swap", "zram") === modelData.id
                            onClicked: page.controller.setSelection("disk", "swap", modelData.id)
                        }
                    }
                }
                ToggleRow {
                    width: parent.width
                    title: "Disk encryption"
                    checked: page.controller ? page.controller.selection("privacy", "diskEncryption", false) : false
                    onToggled: checked => page.controller.setSelection("privacy", "diskEncryption", checked)
                }
                Column {
                    visible: page.controller && page.controller.selection("privacy", "diskEncryption", false)
                    width: parent.width
                    spacing: page.dp(12)
                    MeoTextField { width: parent.width; type: "outlined"; size: "l"; label: "Encryption passphrase"; echoMode: TextInput.Password; isPassword: true; text: InstallerSession.diskPassphrase; onTextChanged: InstallerSession.diskPassphrase = text }
                    MeoTextField { width: parent.width; type: "outlined"; size: "l"; label: "Confirm passphrase"; echoMode: TextInput.Password; isPassword: true; text: InstallerSession.diskPassphraseConfirmation; onTextChanged: InstallerSession.diskPassphraseConfirmation = text }
                }
                MeoButton { anchors.right: parent.right; text: "Done"; type: "filled"; onClicked: advanced.close() }
            }
        }
    }
}
