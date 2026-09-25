pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    readonly property string diskMode: controller ? controller.selection("disk", "mode", "erase") : "erase"
    readonly property var selectedRoot: controller ? controller.selection("disk", "targetPartition", {}) : ({})
    readonly property var selectedEfi: controller ? controller.selection("disk", "efiPartition", {}) : ({})
    readonly property bool existingPartitionReady: diskMode === "partition" && selectedRoot.path && selectedEfi.path
    // The detected disk model is authoritative for whether an erase flow is
    // safe to offer. Persisted selections are retained for the backend plan,
    // but an asynchronous write must not leave an already selected real disk
    // with a transient zero capacity and a permanently disabled Continue.
    readonly property int diskSizeGiB: {
        if (!controller)
            return 0
        const selectedId = String(controller.selectedDisk || "")
        const detected = controller.disks || []
        for (let index = 0; index < detected.length; ++index) {
            if (String(detected[index].id) === selectedId)
                return Math.floor(Number(detected[index].sizeBytes || 0) / 1073741824)
        }
        return Math.floor(Number(controller.selection("disk", "sizeBytes", 0)) / 1073741824)
    }
    readonly property bool eraseAvailable: controller && controller.selectedDisk.length > 0 && diskSizeGiB >= 8
    readonly property bool separateHomeAvailable: eraseAvailable && diskSizeGiB >= 13
    readonly property bool erasePlanReady: diskMode === "guided" ? separateHomeAvailable : eraseAvailable

    primaryEnabled: controller && !controller.diskDetecting
                    && (existingPartitionReady || (diskMode !== "partition" && erasePlanReady))

    function selectErase(separateHomeLayout) {
        controller.setSelection("disk", "mode", separateHomeLayout ? "guided" : "erase")
        controller.setSelection("disk", "separateHome", separateHomeLayout)
        controller.setSelection("disk", "targetPartition", {})
        controller.setSelection("disk", "efiPartition", {})
        if (separateHomeLayout)
            controller.setSelection("disk", "rootSizeGiB", Math.max(8, Math.min(32, diskSizeGiB - 5)))
    }

    function hasUsableEfi(partitions) {
        for (let index = 0; index < partitions.length; ++index) {
            if (partitions[index].eligibleEfi)
                return true
        }
        return false
    }

    Column {
        width: parent.width
        spacing: page.compactHeight ? page.dp(10) : page.dp(14)

        PageHeading {
            width: parent.width
            title: qsTr("Choose where MeoArch is installed")
            subtitle: qsTr("Use one existing partition, or explicitly erase an entire disk. The installer never guesses.")
        }
        InfoBanner {
            width: parent.width; tone: "info"
            title: qsTr("Use one existing partition")
            message: qsTr("Select a supported root partition of at least 8 GiB below. 16 GiB is recommended, not required. Mounted target partitions are unmounted only after final confirmation.")
        }
        InfoBanner {
            visible: page.controller && !page.controller.diskDetecting && page.controller.disks.length === 0
            width: parent.width; tone: "error"
            title: qsTr("No disk detected")
            message: qsTr("Disk detection must complete before installation. The installer does not invent preview disks in production.")
        }
        MeoButton {
            visible: page.controller && !page.controller.diskDetecting && page.controller.disks.length === 0
            text: qsTr("Rescan storage devices")
            type: "tonal"
            icon.name: "refresh"
            Accessible.description: qsTr("Scans again after you connect or make an installation disk available")
            onClicked: page.controller.refreshDisks()
        }
        Item {
            visible: page.controller && page.controller.diskDetecting
            width: parent.width
            height: visible ? page.dp(72) : 0

            MeoLoadingFeedback {
                anchors.fill: parent
                active: parent.visible
                delay: 0
                minimumVisibleDuration: 0
                accessibleName: qsTr("Scanning storage devices")
            }
        }

        Repeater {
            model: page.controller ? page.controller.disks : []
            delegate: MeoCard {
                id: diskCard
                required property var modelData
                width: parent.width
                implicitHeight: diskColumn.implicitHeight + page.dp(28)
                type: "outlined"; interactive: false; padding: page.dp(14)
                Column {
                    id: diskColumn
                    width: parent.width; spacing: page.dp(10)
                    Row {
                        width: parent.width; spacing: page.dp(10)
                        MeoIcon { anchors.verticalCenter: parent.verticalCenter; icon: "hard_drive"; size: page.dp(24); color: MeoTheme.primary }
                        Column {
                            width: parent.width - parent.spacing - page.dp(34)
                            MeoText { width: parent.width; text: diskCard.modelData.name + " · " + diskCard.modelData.size; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface; elide: Text.ElideRight }
                            MeoText { width: parent.width; text: diskCard.modelData.devicePath + " · " + diskCard.modelData.kind; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; elide: Text.ElideRight }
                        }
                    }
                    // Actual lsblk topology. It does not imply an erase plan.
                    Row {
                        id: topology
                        width: parent.width; height: page.dp(30); spacing: page.dp(3)
                        Repeater {
                            model: diskCard.modelData.partitions
                            delegate: MeoCard {
                                required property var modelData
                                readonly property real ratio: Number(modelData.sizeBytes) / Math.max(1, Number(diskCard.modelData.sizeBytes))
                                width: Math.max(page.dp(16), Math.round((topology.width - topology.spacing * Math.max(0, topology.children.length - 1)) * ratio))
                                height: topology.height; radius: page.dp(5); padding: 0; interactive: false
                                type: modelData.isEfi || modelData.eligibleRoot ? "filled" : "outlined"
                                selected: modelData.path === page.selectedRoot.path
                                Accessible.name: modelData.name + ", " + modelData.size
                            }
                        }
                        MeoText {
                            visible: diskCard.modelData.partitions.length === 0
                            anchors.verticalCenter: parent.verticalCenter; text: qsTr("No existing partitions detected")
                            typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant
                        }
                    }
                    MeoText {
                        width: parent.width
                        text: diskCard.modelData.partitions.length === 0
                              ? qsTr("To use one existing partition, create the EFI and root partitions outside this installer first. Otherwise choose Erase entire disk below.")
                              : qsTr("Choose a partition for MeoArch root. EFI is recognized from its GPT type and is never reformatted here.")
                        typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap
                    }
                    InfoBanner {
                        visible: String(diskCard.modelData.warning || "").length > 0
                        width: parent.width
                        tone: "warning"
                        title: qsTr("Storage warning")
                        message: String(diskCard.modelData.warning || "")
                    }
                    InfoBanner {
                        visible: String(diskCard.modelData.unavailableReason || "").length > 0
                        width: parent.width
                        tone: "error"
                        title: qsTr("Storage unavailable")
                        message: String(diskCard.modelData.unavailableReason || "")
                    }
                    MeoButton {
                        visible: diskCard.modelData.eligible
                        text: qsTr("Erase and use entire %1").arg(diskCard.modelData.devicePath)
                        type: "outlined"
                        Accessible.description: qsTr("Erases every partition on this disk after final confirmation")
                        onClicked: {
                            page.controller.setSelectedDisk(diskCard.modelData.id)
                            page.selectErase(false)
                        }
                    }
                    Repeater {
                        model: diskCard.modelData.partitions
                        delegate: SelectionCard {
                            required property var modelData
                            width: parent.width; implicitHeight: page.dp(66)
                            iconText: modelData.isEfi ? "memory" : "hard_drive"
                            title: modelData.name + " · " + modelData.size
                            value: modelData.isEfi
                                   ? qsTr("EFI System Partition — preserved")
                                     + (String(modelData.warning || "").length ? " · " + String(modelData.warning) : "")
                                   : (modelData.fstype.length ? modelData.fstype.toUpperCase() + " · " : "")
                                     + (modelData.eligibleRoot
                                        ? qsTr("Use as MeoArch root — will be formatted")
                                          + (String(modelData.warning || "").length ? " · " + String(modelData.warning) : "")
                                        : modelData.unavailableReason)
                            selected: modelData.path === page.selectedRoot.path
                            selectionIndicator: !modelData.isEfi
                            enabled: modelData.eligibleRoot
                            actionable: !modelData.isEfi
                            trailingIcon: ""
                            Accessible.description: modelData.isEfi ? qsTr("Preserved boot partition") : qsTr("Formats only this selected partition")
                            onClicked: page.controller.selectExistingPartition(diskCard.modelData.id, modelData.path)
                        }
                    }
                    InfoBanner {
                        visible: diskCard.modelData.partitions.length > 0 && !page.hasUsableEfi(diskCard.modelData.partitions)
                        width: parent.width; tone: "error"
                        title: qsTr("No usable EFI System Partition")
                        message: qsTr("One-partition installation requires a FAT EFI System Partition of at least 64 MiB on this same disk. 512 MiB is recommended. Meo preserves the EFI partition and modifies only the selected root partition.")
                    }
                }
            }
        }

        MeoCard {
            visible: page.controller && page.controller.selectedDisk.length > 0
            width: parent.width; implicitHeight: installModeColumn.implicitHeight + page.dp(28)
            type: "filled"; padding: page.dp(14)
            Column {
                id: installModeColumn
                width: parent.width; spacing: page.dp(10)
                MeoText { text: qsTr("Other installation choice"); typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoText { width: parent.width; text: qsTr("Use this only when the selected disk may be erased completely. It is separate from the existing-partition path above."); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
                GridLayout {
                    width: parent.width; columns: page.width >= page.dp(700) ? 2 : 1; rowSpacing: page.dp(8); columnSpacing: page.dp(8)
                    SelectionCard {
                        Layout.fillWidth: true; implicitHeight: page.dp(72); iconText: "delete_sweep"
                        title: qsTr("Erase entire disk"); value: qsTr("Deletes all data. Creates EFI and one Linux root partition")
                        selected: page.diskMode === "erase"; selectionIndicator: true; enabled: page.eraseAvailable
                        onClicked: page.selectErase(false)
                    }
                    SelectionCard {
                        Layout.fillWidth: true; implicitHeight: page.dp(72); iconText: "account_tree"
                        title: qsTr("Erase disk with separate home"); value: qsTr("Deletes all data. Creates EFI, root, and home partitions")
                        selected: page.diskMode === "guided"; selectionIndicator: true; enabled: page.separateHomeAvailable
                        onClicked: page.selectErase(true)
                    }
                }
            }
        }
        InfoBanner {
            visible: page.existingPartitionReady
            width: parent.width; tone: "error"; title: qsTr("Selected root partition will be erased")
            message: qsTr("MeoArch will preserve %1 and erase only %2. Other partitions are not selected for modification.").arg(page.selectedEfi.path).arg(page.selectedRoot.path)
        }
        InfoBanner {
            visible: !page.existingPartitionReady && page.diskMode !== "partition" && page.erasePlanReady
            width: parent.width; tone: "error"; title: qsTr("Entire selected disk will be erased")
            message: qsTr("Review the disk path above carefully. Existing partitions are not preserved in this mode.")
        }
        InfoBanner {
            visible: page.eraseAvailable && page.diskSizeGiB < 16
            width: parent.width; tone: "warning"; title: qsTr("Below recommended capacity")
            message: qsTr("This disk is smaller than the recommended 16 GiB. You can continue, but installation may leave little free space.")
        }
        Row {
            spacing: page.dp(8)
            MeoButton { text: qsTr("Advanced options"); type: "text"; onClicked: advanced.openFrom(this) }
            MeoText { anchors.verticalCenter: parent.verticalCenter; text: page.controller ? page.controller.selection("disk", "filesystem", "btrfs").toUpperCase() + " · " + page.controller.selection("disk", "swap", "zram") : ""; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
        }
    }

    MeoMotionPopup {
        id: advanced
        presentation: MeoMotionPopup.SideSheet; parent: Overlay.overlay
        x: parent ? parent.width - width : 0; y: 0
        width: Math.min(page.dp(520), parent ? parent.width : page.dp(520)); height: parent ? parent.height : page.height
        padding: page.dp(32); closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Flickable {
            id: advancedFlick
            contentWidth: width
            contentHeight: advancedContent.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds
            interactive: contentHeight > height
            ScrollBar.vertical: ScrollBar {
                policy: advancedFlick.interactive ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }

            Column {
                id: advancedContent
                width: parent.width; spacing: page.dp(16)
                MeoText { text: qsTr("Advanced disk options"); typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
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
                    delegate: SelectionCard { required property var modelData; width: parent.width; implicitHeight: page.dp(60); iconText: "swap_horiz"; title: modelData.name; value: modelData.detail; selected: page.controller && page.controller.selection("disk", "swap", "zram") === modelData.id; selectionIndicator: true; onClicked: page.controller.setSelection("disk", "swap", modelData.id) }
                }
                InfoBanner { width: parent.width; title: qsTr("Manual partition editor unavailable"); message: qsTr("It remains unavailable until creation, resizing, encryption, recovery, and rollback have one tested transaction path. Use only the safe choices on this page."); tone: "error" }
                MeoButton { anchors.right: parent.right; text: qsTr("Done"); type: "filled"; onClicked: advanced.close() }
            }
        }
    }
}
