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
    readonly property bool existingPartitionReady: diskMode === "partition" && !!selectedRoot.path && !!selectedEfi.path

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

    readonly property bool planReady: existingPartitionReady || (diskMode !== "partition" && erasePlanReady)
    primaryEnabled: controller && !controller.diskDetecting && planReady
    // Say what is still missing instead of showing a silently disabled button.
    primaryLabel: !controller || controller.diskDetecting ? qsTr("Scanning disks…")
                  : planReady ? qsTr("Continue")
                  : activeDiskId.length === 0 ? qsTr("Choose a disk to continue")
                  : diskMode === "partition" ? qsTr("Choose a partition to continue")
                  : qsTr("Choose how to use the disk")
    primaryAccessibleDescription: planReady ? qsTr("Continue to the account step. Nothing is erased until you confirm on the Summary page")
                                            : qsTr("Complete the disk choices on this page to continue")

    // With exactly one disk that can be erased and nothing chosen yet, choose
    // it for the user. This is only a selection; the destructive confirmation
    // stays on the Summary page and the backend revalidates the disk.
    function autoSelectSingleDisk() {
        if (!controller || controller.diskDetecting || String(controller.selectedDisk || "").length > 0
                || focusedDiskId.length > 0)
            return
        const detected = controller.disks || []
        let candidate = null
        for (let index = 0; index < detected.length; ++index) {
            if (detected[index].eligible !== true)
                continue
            if (candidate)
                return
            candidate = detected[index]
        }
        if (candidate)
            selectDisk(candidate)
    }
    Component.onCompleted: autoSelectSingleDisk()
    Connections {
        target: page.controller
        ignoreUnknownSignals: true
        function onDisksChanged() { page.autoSelectSingleDisk() }
        function onDiskDetectionChanged() { page.autoSelectSingleDisk() }
    }

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

    function fsLabel(part) {
        const fs = String(part.fstype || "").toLowerCase()
        let text = fs === "ntfs" ? qsTr("NTFS, often Windows")
                 : fs === "vfat" || fs === "fat32" || fs === "fat" ? "FAT32"
                 : fs === "swap" ? qsTr("Swap")
                 : fs === "crypto_luks" ? qsTr("Encrypted")
                 : fs.length ? fs.toUpperCase() : qsTr("No filesystem")
        if (String(part.fslabel || "").length)
            text = "“" + part.fslabel + "” · " + text
        return text
    }

    // Current on-disk layout in order, including unallocated gaps, from the
    // detected start/size sectors. Gaps under 16 MiB are alignment slack.
    function currentSegments(disk) {
        const parts = (disk.partitions || []).slice()
        const total = Number(disk.sizeBytes || 0)
        if (total <= 0)
            return []
        parts.sort((a, b) => Number(a.startSectors || 0) - Number(b.startSectors || 0))
        const rows = []
        const slack = 16 * 1048576
        let cursor = 0
        for (let index = 0; index < parts.length; ++index) {
            const part = parts[index]
            const sector = Number(part.logicalSectorSize || disk.logicalSectorSize || 512)
            const start = Number(part.startSectors || 0) * sector
            const bytes = Number(part.sizeBytes || 0)
            if (start - cursor > slack)
                rows.push({ label: qsTr("Free space"), bytes: start - cursor, role: "free", path: "" })
            rows.push({ label: part.name, detail: part.isEfi ? qsTr("EFI") : page.fsLabel(part),
                        bytes: bytes, role: part.isEfi ? "efi" : "other", path: part.path })
            cursor = Math.max(cursor, start + bytes)
        }
        if (total - cursor > slack)
            rows.push({ label: qsTr("Free space"), bytes: total - cursor, role: "free", path: "" })
        return rows
    }
    readonly property var nowSegments: currentSegments(activeDisk)

    readonly property var planSegments: {
        const total = Math.max(1, Number(activeDisk.sizeBytes || diskSizeBytes))
        if (diskMode === "partition") {
            return nowSegments.map(row => {
                if (row.path && row.path === page.selectedRoot.path)
                    return { label: qsTr("MeoArch"), detail: qsTr("formatted"), bytes: row.bytes, role: "root" }
                if (row.path && row.path === page.selectedEfi.path)
                    return { label: qsTr("EFI"), detail: qsTr("kept, boot entry added"), bytes: row.bytes, role: "efi" }
                if (row.role === "free")
                    return { label: qsTr("Free space"), detail: qsTr("unused"), bytes: row.bytes, role: "free" }
                return { label: row.label, detail: qsTr("%1, untouched").arg(row.detail), bytes: row.bytes, role: "other" }
            })
        }
        const efi = 512 * 1048576
        if (diskMode === "guided")
            return [
                { label: qsTr("EFI"), bytes: efi, role: "efi" },
                { label: qsTr("System"), bytes: rootSizeGiB * 1073741824, role: "root" },
                { label: qsTr("Home"), detail: qsTr("your files"), bytes: homeSizeBytes, role: "home" }
            ]
        return [
            { label: qsTr("EFI"), bytes: efi, role: "efi" },
            { label: qsTr("MeoArch"), detail: qsTr("system and your files"), bytes: Math.max(0, total - efi), role: "root" }
        ]
    }
    // In erase modes everything that exists now is shown as going away.
    readonly property var beforeSegments: diskMode === "partition"
        ? nowSegments
        : nowSegments.map(row => row.role === "free" ? row
                                                     : Object.assign({}, row, { role: "erase", detail: qsTr("%1, erased").arg(row.detail) }))

    readonly property string consequenceTitle: existingPartitionReady
        ? qsTr("Only %1 will be erased").arg(String(page.selectedRoot.path || ""))
        : qsTr("Everything on %1 will be erased").arg(String(page.activeDisk.name || page.activeDisk.devicePath || ""))
    readonly property string consequenceMessage: {
        let text = existingPartitionReady
            ? qsTr("%1 is formatted for MeoArch. The EFI partition %2 is kept and other partitions are not touched.")
                  .arg(String(page.selectedRoot.path || "")).arg(String(page.selectedEfi.path || ""))
            : qsTr("All partitions and files on %1 are deleted. Back up anything you want to keep first.")
                  .arg(String(page.activeDisk.devicePath || ""))
        if (!existingPartitionReady && diskSizeGiB < 16)
            text += " " + qsTr("This disk is smaller than the recommended 16 GiB, so free space will be tight.")
        if (existingPartitionReady && String(page.selectedRoot.fstype || "").toLowerCase() === "ntfs")
            text += " " + qsTr("This is an NTFS partition and may hold Windows or its files; formatting it removes them.")
        if (existingPartitionReady && String(page.selectedRoot.warning || "").length)
            text += " " + String(page.selectedRoot.warning)
        return text + " " + qsTr("Nothing happens until you confirm on the Summary page.")
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
            message: qsTr("Connect or enable the disk you want to install to, then rescan. Nothing can be selected until a disk is found.")
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
        RowLayout {
            visible: page.controller && page.controller.disks.length > 0
            width: parent.width
            MeoText {
                Layout.fillWidth: true
                text: qsTr("1. Disk"); typeRole: "title"; typeSize: "small"; emphasized: true
                color: MeoTheme.contentOnSurface
            }
            MeoButton {
                visible: page.controller && !page.controller.diskDetecting
                text: qsTr("Rescan")
                type: "text"
                icon.name: "refresh"
                Accessible.description: qsTr("Scans again after you connect or make an installation disk available")
                onClicked: page.controller.refreshDisks()
            }
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
                             + " · " + (diskEntry.modelData.partitions.length === 0
                                        ? qsTr("empty")
                                        : qsTr("%n partition(s)", "", diskEntry.modelData.partitions.length))
                           : String(diskEntry.modelData.unavailableReason || diskEntry.modelData.partitionUnavailableReason || "")
                    selected: diskEntry.chosen
                    selectionIndicator: true
                    enabled: page.diskSelectable(diskEntry.modelData)
                    trailingIcon: ""
                    Accessible.description: qsTr("Choose this disk. Nothing is erased until the final confirmation.")
                    onClicked: page.selectDisk(diskEntry.modelData)
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
                    tone: "info"
                    title: qsTr("Only an existing partition can be used")
                    message: qsTr("Erasing this disk is not possible: %1").arg(String(diskEntry.modelData.unavailableReason || ""))
                }
            }
        }
        MeoButton {
            visible: page.controller && !page.controller.diskDetecting && page.controller.disks.length === 0
            text: qsTr("Rescan storage devices")
            type: "tonal"
            icon.name: "refresh"
            onClicked: page.controller.refreshDisks()
        }

        // ── 2. Installation type ───────────────────────────────────────
        MeoText {
            visible: page.activeDiskId.length > 0
            topPadding: page.dp(6)
            text: qsTr("2. How to use this disk"); typeRole: "title"; typeSize: "small"; emphasized: true
            color: MeoTheme.contentOnSurface
        }
        GridLayout {
            visible: page.activeDiskId.length > 0
            width: parent.width; columns: 1
            rowSpacing: page.dp(8); columnSpacing: page.dp(8)
            SelectionCard {
                Layout.fillWidth: true; iconText: "delete_sweep"
                title: qsTr("Erase disk and install"); value: qsTr("Recommended. Removes everything on this disk and gives all of it to MeoArch")
                wrapValue: true
                selected: page.diskMode === "erase"; selectionIndicator: true; enabled: page.eraseAvailable
                trailingIcon: ""
                onClicked: page.selectErase(false)
            }
            SelectionCard {
                Layout.fillWidth: true; iconText: "account_tree"
                title: qsTr("Erase disk, keep files on a separate home partition")
                value: page.separateHomeAvailable
                       ? qsTr("Removes everything. Your files get their own partition so a later reinstall can keep them")
                       : qsTr("Needs a disk of at least 13 GiB")
                wrapValue: true
                selected: page.diskMode === "guided"; selectionIndicator: true; enabled: page.separateHomeAvailable
                trailingIcon: ""
                onClicked: page.selectErase(true)
            }
            SelectionCard {
                Layout.fillWidth: true; iconText: "splitscreen"
                title: qsTr("Install next to what is already there"); value: page.partitionModeAvailable
                       ? qsTr("Formats one partition you pick and keeps the others, for example Windows or your data")
                       : qsTr("Not available: this disk needs an EFI System Partition and a free-to-format partition of at least 8 GiB")
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
                    text: qsTr("Drag to size the system partition; 32 GiB or more is comfortable for apps. Home gets the rest and keeps at least 4 GiB.")
                    typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap
                }
            }
        }

        // Existing partition: pick exactly one partition to format.
        Column {
            visible: page.diskMode === "partition" && page.activePartitions.length > 0
            width: parent.width; spacing: page.dp(8)
            MeoText {
                width: parent.width
                topPadding: page.dp(6)
                text: qsTr("3. Pick the partition to format")
                typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface
            }
            MeoText {
                width: parent.width
                text: qsTr("Only this partition is erased. Pick one with nothing you need on it; at least 8 GiB, 16 GiB or more recommended.")
                typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap
            }
            Repeater {
                model: page.activePartitions
                delegate: SelectionCard {
                    required property var modelData
                    width: parent.width; implicitHeight: page.dp(66)
                    iconText: modelData.isEfi ? "lock" : (modelData.eligibleRoot ? "hard_drive" : "block")
                    title: modelData.name + " · " + modelData.size + " · " + page.fsLabel(modelData)
                    value: modelData.isEfi
                           ? qsTr("Boot partition, kept. MeoArch adds its boot entry here")
                           : modelData.eligibleRoot
                             ? (modelData.path === page.selectedRoot.path
                                ? qsTr("Will be formatted for MeoArch")
                                : qsTr("Select to format this partition for MeoArch"))
                               + (String(modelData.warning || "").length ? " · " + String(modelData.warning) : "")
                             : String(modelData.unavailableReason || "")
                    wrapValue: true
                    selected: modelData.path === page.selectedRoot.path
                    selectionIndicator: modelData.eligibleRoot === true
                    enabled: modelData.eligibleRoot === true
                    actionable: modelData.eligibleRoot === true
                    trailingIcon: ""
                    Accessible.description: modelData.isEfi ? qsTr("Preserved boot partition") : qsTr("Formats only this selected partition")
                    onClicked: page.controller.selectExistingPartition(page.activeDiskId, modelData.path)
                }
            }
        }
        InfoBanner {
            visible: page.diskMode === "partition" && page.activePartitions.length > 0
                     && !page.hasUsableEfi(page.activePartitions)
            width: parent.width; tone: "warning"
            title: qsTr("No usable EFI System Partition")
            message: qsTr("Installing next to other systems needs a FAT EFI System Partition of at least 512 MiB on this same disk.")
        }

        // ── Result: before and after ───────────────────────────────────
        MeoCard {
            visible: page.activeDiskId.length > 0 && page.planReady
            width: parent.width; implicitHeight: planColumn.implicitHeight + page.dp(28)
            type: "outlined"; padding: page.dp(14)
            Column {
                id: planColumn
                width: parent.width; spacing: page.dp(14)
                MeoText {
                    text: page.diskMode === "partition" ? qsTr("4. Check the result") : qsTr("3. Check the result")
                    typeRole: "title"; typeSize: "small"; emphasized: true
                    color: MeoTheme.contentOnSurface
                }
                DiskLayoutBar {
                    visible: page.beforeSegments.length > 0
                    width: parent.width
                    caption: qsTr("Now")
                    segments: page.beforeSegments
                }
                DiskLayoutBar {
                    width: parent.width
                    caption: qsTr("After installation")
                    segments: page.planSegments
                }
                RowLayout {
                    width: parent.width
                    spacing: page.dp(8)
                    MeoText {
                        Layout.fillWidth: true
                        text: (page.controller ? page.controller.selection("disk", "filesystem", "btrfs").toUpperCase() : "BTRFS")
                              + " · " + qsTr("Swap: %1").arg(page.controller ? page.controller.selection("disk", "swap", "zram") : "zram")
                        typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant
                        wrapMode: Text.WordWrap
                    }
                    MeoButton {
                        text: qsTr("Change")
                        type: "text"
                        icon.name: "tune"
                        Accessible.name: qsTr("Change filesystem and swap")
                        onClicked: advanced.openFrom(this)
                    }
                }
            }
        }

        InfoBanner {
            visible: page.activeDiskId.length > 0 && page.planReady
            width: parent.width; tone: "error"
            title: page.consequenceTitle
            message: page.consequenceMessage
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
