pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI 1.0
import ".."
import "../components"

// Disk selection: 1. pick a detected disk, 2. pick how to use it (erase,
// erase with a separate home of an adjustable size, or one existing
// partition), 3. review the resulting layout. Nothing is written here; the
// Summary page holds the final destructive confirmation and the backend
// revalidates every value against the live disk.
PageFrame {
    id: page
    readonly property string diskMode: controller ? controller.selection("disk", "mode", "erase") : "erase"
    readonly property var selectedRoot: controller ? controller.selection("disk", "targetPartition", {}) : ({})
    readonly property var selectedEfi: controller ? controller.selection("disk", "efiPartition", {}) : ({})
    readonly property bool existingPartitionReady: diskMode === "partition" && selectedRoot.path && selectedEfi.path

    // A disk that is shown as chosen. For erase-capable disks this is the
    // controller's selected disk; a disk that only offers the partition path
    // becomes selected when one of its partitions is chosen.
    property string focusedDiskId: ""
    readonly property string activeDiskId: controller && String(controller.selectedDisk || "").length > 0
                                           && (focusedDiskId === "" || focusedDiskId === String(controller.selectedDisk))
                                           ? String(controller.selectedDisk) : focusedDiskId
    readonly property var activeDisk: {
        const detected = controller ? (controller.disks || []) : []
        for (let index = 0; index < detected.length; ++index)
            if (String(detected[index].id) === activeDiskId)
                return detected[index]
        return ({})
    }
    readonly property var activePartitions: activeDisk.partitions || []

    // The detected disk model is authoritative for whether an erase flow is
    // safe to offer. Persisted selections are retained for the backend plan,
    // but an asynchronous write must not leave an already selected real disk
    // with a transient zero capacity and a permanently disabled Continue.
    readonly property real diskSizeBytes: {
        if (!controller)
            return 0
        const selectedId = String(controller.selectedDisk || "")
        const detected = controller.disks || []
        for (let index = 0; index < detected.length; ++index) {
            if (String(detected[index].id) !== selectedId)
                continue
            const detectedBytes = Number(detected[index].sizeBytes || 0)
            if (detectedBytes > 0)
                return detectedBytes
            // Some hot-plug/slow storage briefly reports transient zero capacity
            // during a rescan. Keep the last confirmed capacity for navigation only;
            // the destructive handoff revalidates the live capacity exactly.
            break
        }
        return Number(controller.selection("disk", "sizeBytes", 0))
    }
    readonly property int diskSizeGiB: Math.floor(diskSizeBytes / 1073741824)
    readonly property real fullDiskMinimumBytes: 8 * 1073741824 + 515 * 1048576
    readonly property real guidedMinimumBytes: 12 * 1073741824 + 515 * 1048576
    readonly property bool eraseAvailable: controller && controller.selectedDisk.length > 0
                                           && activeDiskId === String(controller.selectedDisk)
                                           && diskSizeBytes >= fullDiskMinimumBytes
    readonly property bool separateHomeAvailable: eraseAvailable && diskSizeBytes >= guidedMinimumBytes
    readonly property bool erasePlanReady: diskMode === "guided" ? separateHomeAvailable : eraseAvailable
    readonly property bool partitionModeAvailable: activeDisk.partitionInstallEligible === true
                                                   && hasUsableEfi(activePartitions) && hasEligibleRoot(activePartitions)

    // Same bounds as generate-config.py: root >= 8 GiB, home >= 4 GiB of the
    // space left after the 515 MiB EFI/alignment overhead.
    readonly property int rootMinimumGiB: 8
    readonly property int rootMaximumGiB: Math.max(rootMinimumGiB,
                                                   Math.floor((diskSizeBytes / 1048576 - 515 - 4096) / 1024))
    readonly property int rootSizeGiB: {
        const stored = Number(controller ? controller.selection("disk", "rootSizeGiB", 32) : 32)
        return Math.max(rootMinimumGiB, Math.min(rootMaximumGiB, Math.round(stored)))
    }
    readonly property real homeSizeBytes: Math.max(0, diskSizeBytes - 515 * 1048576 - rootSizeGiB * 1073741824)

    primaryEnabled: controller && !controller.diskDetecting
                    && (existingPartitionReady || (diskMode !== "partition" && erasePlanReady))

    function formatBytes(bytes) {
        const value = Math.max(0, Number(bytes) || 0)
        if (value >= 1099511627776)
            return qsTr("%1 TiB").arg((value / 1099511627776).toFixed(1))
        if (value >= 1073741824)
            return qsTr("%1 GiB").arg(Math.round(value / 1073741824))
        return qsTr("%1 MiB").arg(Math.round(value / 1048576))
    }

    function diskSummary(disk) {
        const parts = [String(disk.kind || "")]
        if (String(disk.transport || "").length)
            parts.push(String(disk.transport).toUpperCase())
        parts.push(String(disk.devicePath || ""))
        return parts.filter(part => part.length > 0).join(" · ")
    }

    function diskSelectable(disk) {
        return disk.eligible === true || disk.partitionInstallEligible === true
    }

    function selectDisk(disk) {
        if (!diskSelectable(disk))
            return
        page.focusedDiskId = String(disk.id)
        if (disk.eligible === true) {
            page.controller.setSelectedDisk(disk.id)
            if (page.diskMode === "partition") {
                // Stay on the partition path when the new disk offers it.
                if (!(disk.partitionInstallEligible && hasUsableEfi(disk.partitions || [])
                      && hasEligibleRoot(disk.partitions || [])))
                    selectErase(false)
            }
        } else {
            // Only the existing-partition path is possible on this disk.
            page.controller.setSelection("disk", "mode", "partition")
            page.controller.setSelection("disk", "targetPartition", {})
            page.controller.setSelection("disk", "efiPartition", {})
        }
    }

    function selectErase(separateHomeLayout) {
        controller.setSelection("disk", "mode", separateHomeLayout ? "guided" : "erase")
        controller.setSelection("disk", "separateHome", separateHomeLayout)
        controller.setSelection("disk", "targetPartition", {})
        controller.setSelection("disk", "efiPartition", {})
        if (separateHomeLayout) {
            const stored = Number(controller.selection("disk", "rootSizeGiB", 0))
            const initial = stored >= rootMinimumGiB && stored <= rootMaximumGiB
                            ? stored : Math.max(8, Math.min(32, diskSizeGiB - 5))
            controller.setSelection("disk", "rootSizeGiB", Math.min(rootMaximumGiB, initial))
        }
    }

    function selectPartitionMode() {
        controller.setSelection("disk", "mode", "partition")
        controller.setSelection("disk", "separateHome", false)
        if (!page.selectedRoot.path || String(controller.selectedDisk) !== activeDiskId) {
            controller.setSelection("disk", "targetPartition", {})
            controller.setSelection("disk", "efiPartition", {})
        }
    }

    function hasUsableEfi(partitions) {
        for (let index = 0; index < partitions.length; ++index) {
            if (partitions[index].eligibleEfi)
                return true
        }
        return false
    }

    function hasEligibleRoot(partitions) {
        for (let index = 0; index < partitions.length; ++index) {
            if (partitions[index].eligibleRoot)
                return true
        }
        return false
    }

    // Segments of the layout after installation, for the plan preview.
    readonly property var planSegments: {
        const total = Math.max(1, Number(activeDisk.sizeBytes || diskSizeBytes))
        if (diskMode === "partition") {
            const rows = []
            for (let index = 0; index < activePartitions.length; ++index) {
                const part = activePartitions[index]
                const isRoot = part.path === page.selectedRoot.path
                const isEfi = part.path === page.selectedEfi.path || (part.eligibleEfi && !page.selectedEfi.path)
                rows.push({
                    "label": isRoot ? qsTr("MeoArch (formatted)")
                           : (isEfi ? qsTr("EFI (kept)") : qsTr("%1 (untouched)").arg(part.name)),
                    "bytes": Number(part.sizeBytes || 0),
                    "role": isRoot ? "root" : (isEfi ? "efi" : "other")
                })
            }
            return rows
        }
        const efi = 512 * 1048576
        if (diskMode === "guided")
            return [
                { "label": qsTr("EFI"), "bytes": efi, "role": "efi" },
                { "label": qsTr("System"), "bytes": rootSizeGiB * 1073741824, "role": "root" },
                { "label": qsTr("Home"), "bytes": homeSizeBytes, "role": "home" }
            ]
        return [
            { "label": qsTr("EFI"), "bytes": efi, "role": "efi" },
            { "label": qsTr("System and home"), "bytes": Math.max(0, total - efi), "role": "root" }
        ]
    }

    function roleColor(role) {
        if (role === "root") return MeoTheme.primary
        if (role === "home") return MeoTheme.tertiary
        if (role === "efi") return MeoTheme.secondary
        return MeoTheme.surfaceContainerHighest
    }

    Column {
        width: parent.width
        spacing: page.compactHeight ? page.dp(10) : page.dp(14)

        PageHeading {
            width: parent.width
            title: qsTr("Choose where MeoArch is installed")
            subtitle: qsTr("Pick a disk, then choose how to use it. Nothing is changed until you confirm on the Summary page.")
        }

        InfoBanner {
            visible: page.controller && !page.controller.diskDetecting && page.controller.disks.length === 0
            width: parent.width; tone: "error"
            title: qsTr("No disk detected")
            message: qsTr("Disk detection must complete before installation. The installer does not invent preview disks in production.")
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

        // ── 1. Disk ────────────────────────────────────────────────────
        MeoText {
            visible: page.controller && page.controller.disks.length > 0
            text: qsTr("1. Disk"); typeRole: "title"; typeSize: "small"; emphasized: true
            color: MeoTheme.contentOnSurface
        }
        Repeater {
            model: page.controller ? page.controller.disks : []
            delegate: Column {
                id: diskEntry
                required property var modelData
                readonly property bool chosen: String(modelData.id) === page.activeDiskId
                width: parent.width
                spacing: page.dp(6)

                SelectionCard {
                    width: parent.width; implicitHeight: page.dp(72)
                    iconText: String(diskEntry.modelData.kind || "").indexOf("Removable") >= 0 ? "usb" : "hard_drive"
                    title: diskEntry.modelData.name + " · " + diskEntry.modelData.size
                    value: page.diskSelectable(diskEntry.modelData)
                           ? page.diskSummary(diskEntry.modelData)
                           : String(diskEntry.modelData.unavailableReason || diskEntry.modelData.partitionUnavailableReason || "")
                    selected: diskEntry.chosen
                    selectionIndicator: true
                    enabled: page.diskSelectable(diskEntry.modelData)
                    trailingIcon: ""
                    Accessible.description: qsTr("Choose this disk. Nothing is erased until the final confirmation.")
                    onClicked: page.selectDisk(diskEntry.modelData)
                }

                // Actual lsblk topology of the chosen disk. It does not imply
                // an erase plan.
                Row {
                    id: topology
                    visible: diskEntry.chosen && diskEntry.modelData.partitions.length > 0
                    width: parent.width; height: visible ? page.dp(12) : 0; spacing: page.dp(2)
                    Repeater {
                        model: diskEntry.modelData.partitions
                        delegate: MeoShape {
                            required property var modelData
                            type: "rect"; strokeWidth: 0
                            readonly property real ratio: Number(modelData.sizeBytes) / Math.max(1, Number(diskEntry.modelData.sizeBytes))
                            width: Math.max(page.dp(6), Math.round(topology.width * ratio) - topology.spacing)
                            height: topology.height; radius: page.dp(3)
                            color: modelData.isEfi ? MeoTheme.secondary : MeoTheme.outlineVariant
                            Accessible.name: modelData.name + ", " + modelData.size
                        }
                    }
                }
                MeoText {
                    visible: diskEntry.chosen
                    width: parent.width
                    text: diskEntry.modelData.partitions.length === 0
                          ? qsTr("No existing partitions detected")
                          : qsTr("Currently %n partition(s): %1", "", diskEntry.modelData.partitions.length)
                                .arg(diskEntry.modelData.partitions.map(p => p.name + " " + p.size
                                                                         + (p.fstype ? " " + String(p.fstype).toUpperCase() : "")).join(", "))
                    typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap
                }
                InfoBanner {
                    visible: diskEntry.chosen && String(diskEntry.modelData.warning || "").length > 0
                    width: parent.width
                    tone: "warning"
                    title: qsTr("Storage warning")
                    message: String(diskEntry.modelData.warning || "")
                }
                InfoBanner {
                    visible: diskEntry.chosen && String(diskEntry.modelData.unavailableReason || "").length > 0
                    width: parent.width
                    tone: "error"
                    title: qsTr("Storage unavailable")
                    message: qsTr("Erasing this disk is not possible: %1").arg(String(diskEntry.modelData.unavailableReason || ""))
                }
            }
        }
        MeoButton {
            visible: page.controller && !page.controller.diskDetecting
            text: qsTr("Rescan storage devices")
            type: page.controller && page.controller.disks.length === 0 ? "tonal" : "text"
            icon.name: "refresh"
            Accessible.description: qsTr("Scans again after you connect or make an installation disk available")
            onClicked: page.controller.refreshDisks()
        }

        // ── 2. Installation type ───────────────────────────────────────
        MeoText {
            visible: page.activeDiskId.length > 0
            text: qsTr("2. How to use this disk"); typeRole: "title"; typeSize: "small"; emphasized: true
            color: MeoTheme.contentOnSurface
        }
        GridLayout {
            visible: page.activeDiskId.length > 0
            width: parent.width; columns: page.width >= page.dp(760) ? 3 : 1
            rowSpacing: page.dp(8); columnSpacing: page.dp(8)
            SelectionCard {
                Layout.fillWidth: true; implicitHeight: page.dp(84); iconText: "delete_sweep"
                title: qsTr("Erase entire disk"); value: qsTr("Recommended. Deletes all data, then creates EFI and one system partition")
                wrapValue: true
                selected: page.diskMode === "erase"; selectionIndicator: true; enabled: page.eraseAvailable
                trailingIcon: ""
                onClicked: page.selectErase(false)
            }
            SelectionCard {
                Layout.fillWidth: true; implicitHeight: page.dp(84); iconText: "account_tree"
                title: qsTr("Erase disk with separate home"); value: qsTr("Deletes all data. Your files live on their own partition, sized below")
                wrapValue: true
                selected: page.diskMode === "guided"; selectionIndicator: true; enabled: page.separateHomeAvailable
                trailingIcon: ""
                onClicked: page.selectErase(true)
            }
            SelectionCard {
                Layout.fillWidth: true; implicitHeight: page.dp(84); iconText: "splitscreen"
                title: qsTr("Use one existing partition"); value: page.partitionModeAvailable
                       ? qsTr("Keeps other partitions, for example another system. Formats only the partition you pick")
                       : qsTr("Needs an EFI System Partition and a root partition of at least 8 GiB on this disk")
                wrapValue: true
                selected: page.diskMode === "partition"; selectionIndicator: true; enabled: page.partitionModeAvailable
                trailingIcon: ""
                onClicked: page.selectPartitionMode()
            }
        }

        // Separate home: size of the system partition.
        MeoCard {
            visible: page.diskMode === "guided" && page.separateHomeAvailable
            width: parent.width; implicitHeight: sizeColumn.implicitHeight + page.dp(28)
            type: "filled"; padding: page.dp(14)
            Column {
                id: sizeColumn
                width: parent.width; spacing: page.dp(8)
                MeoText {
                    width: parent.width
                    text: qsTr("System %1 · Home %2").arg(page.formatBytes(page.rootSizeGiB * 1073741824))
                                                      .arg(page.formatBytes(page.homeSizeBytes))
                    typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface
                }
                MeoSlider {
                    width: parent.width
                    from: page.rootMinimumGiB
                    to: page.rootMaximumGiB
                    stepSize: 1
                    value: page.rootSizeGiB
                    accessibleName: qsTr("System partition size in GiB")
                    onMoved: (value) => page.controller.setSelection("disk", "rootSizeGiB", Math.round(value))
                }
                MeoText {
                    width: parent.width
                    text: qsTr("The system partition holds MeoArch and installed apps; 32 GiB or more is comfortable. Home gets the rest and keeps at least 4 GiB.")
                    typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap
                }
            }
        }

        // Existing partition: choose the root partition.
        Column {
            visible: page.diskMode === "partition" && page.activePartitions.length > 0
            width: parent.width; spacing: page.dp(8)
            InfoBanner {
                width: parent.width; tone: "info"
                title: qsTr("Use one existing partition")
                message: qsTr("Select a supported root partition of at least 8 GiB below. 16 GiB is recommended, not required. Active filesystems, swap, and supported storage mappings are released only after final confirmation.")
            }
            Repeater {
                model: page.activePartitions
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
                    onClicked: page.controller.selectExistingPartition(page.activeDiskId, modelData.path)
                }
            }
        }
        InfoBanner {
            visible: page.activeDiskId.length > 0 && page.activePartitions.length > 0
                     && !page.hasUsableEfi(page.activePartitions)
            width: parent.width; tone: "warning"
            title: qsTr("No usable EFI System Partition")
            message: qsTr("One-partition installation requires a FAT EFI System Partition of at least 512 MiB on this same disk. Meo preserves the EFI partition and modifies only the selected root partition.")
        }

        // ── 3. Result ──────────────────────────────────────────────────
        MeoCard {
            visible: page.activeDiskId.length > 0
                     && (page.existingPartitionReady || (page.diskMode !== "partition" && page.erasePlanReady))
            width: parent.width; implicitHeight: planColumn.implicitHeight + page.dp(28)
            type: "outlined"; padding: page.dp(14)
            Column {
                id: planColumn
                width: parent.width; spacing: page.dp(10)
                MeoText {
                    text: qsTr("3. After installation"); typeRole: "title"; typeSize: "small"; emphasized: true
                    color: MeoTheme.contentOnSurface
                }
                Row {
                    id: planBar
                    width: parent.width; height: page.dp(28); spacing: page.dp(2)
                    readonly property real totalBytes: page.planSegments.reduce((sum, item) => sum + Math.max(0, item.bytes), 0)
                    Repeater {
                        model: page.planSegments
                        delegate: MeoShape {
                            required property var modelData
                            type: "rect"; strokeWidth: 0
                            width: Math.max(page.dp(8), Math.round(planBar.width * modelData.bytes / Math.max(1, planBar.totalBytes)) - planBar.spacing)
                            height: planBar.height; radius: page.dp(6)
                            color: page.roleColor(modelData.role)
                            Accessible.name: modelData.label + ", " + page.formatBytes(modelData.bytes)
                        }
                    }
                }
                Flow {
                    width: parent.width; spacing: page.dp(14)
                    Repeater {
                        model: page.planSegments
                        delegate: Row {
                            required property var modelData
                            spacing: page.dp(6)
                            MeoShape {
                                type: "rect"; strokeWidth: 0
                                anchors.verticalCenter: parent.verticalCenter
                                width: page.dp(10); height: width; radius: width / 2
                                color: page.roleColor(modelData.role)
                            }
                            MeoText {
                                text: modelData.label + " · " + page.formatBytes(modelData.bytes)
                                typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant
                            }
                        }
                    }
                }
                MeoText {
                    width: parent.width
                    text: (page.controller ? page.controller.selection("disk", "filesystem", "btrfs").toUpperCase() : "BTRFS")
                          + " · " + qsTr("Swap: %1").arg(page.controller ? page.controller.selection("disk", "swap", "zram") : "zram")
                    typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant
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
            message: qsTr("All data on %1 (%2) will be deleted. Existing partitions are not preserved in this mode.")
                     .arg(String(page.activeDisk.name || "")).arg(String(page.activeDisk.devicePath || ""))
        }
        InfoBanner {
            visible: page.eraseAvailable && page.diskMode !== "partition" && page.diskSizeGiB < 16
            width: parent.width; tone: "warning"; title: qsTr("Below recommended capacity")
            message: qsTr("This disk is smaller than the recommended 16 GiB. You can continue, but installation may leave little free space.")
        }
        MeoButton { text: qsTr("Advanced options"); type: "text"; icon.name: "tune"; onClicked: advanced.openFrom(this) }
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
            ScrollBar.vertical: MeoScrollBar {
                policy: advancedFlick.interactive ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff
            }

            Column {
                id: advancedContent
                width: parent.width; spacing: page.dp(16)
                MeoText { text: qsTr("Advanced disk options"); typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoText { text: qsTr("Filesystem"); typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                Repeater {
                    model: [{ id: "btrfs", name: qsTr("Btrfs · Recommended"), detail: qsTr("Snapshots let Meo roll back a failed update") },
                            { id: "ext4", name: qsTr("ext4"), detail: qsTr("Simple and widely compatible; no snapshots") }]
                    delegate: SelectionCard { required property var modelData; width: parent.width; implicitHeight: page.dp(60); iconText: "storage"; title: modelData.name; value: modelData.detail; selected: page.controller && page.controller.selection("disk", "filesystem", "btrfs") === modelData.id; selectionIndicator: true; trailingIcon: ""; onClicked: page.controller.setSelection("disk", "filesystem", modelData.id) }
                }
                MeoText { text: qsTr("Swap"); typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                Repeater {
                    model: [{ id: "zram", name: qsTr("Automatic ZRAM"), detail: qsTr("Compressed memory swap") }, { id: "file", name: qsTr("Swap file"), detail: qsTr("Creates a 4 GiB target swap file") }, { id: "none", name: qsTr("None"), detail: qsTr("No swap configured") }]
                    delegate: SelectionCard { required property var modelData; width: parent.width; implicitHeight: page.dp(60); iconText: "swap_horiz"; title: modelData.name; value: modelData.detail; selected: page.controller && page.controller.selection("disk", "swap", "zram") === modelData.id; selectionIndicator: true; trailingIcon: ""; onClicked: page.controller.setSelection("disk", "swap", modelData.id) }
                }
                InfoBanner { width: parent.width; title: qsTr("Disk encryption and manual partitioning"); message: qsTr("Both stay unavailable until creation, resizing, encryption, recovery, and rollback have one tested transaction path. Use only the safe choices on this page."); tone: "info" }
                MeoButton { anchors.right: parent.right; text: qsTr("Done"); type: "filled"; onClicked: advanced.close() }
            }
        }
    }
}
