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
                    && (controller.selection("disk", "mode", "erase") !== "guided" || page.guidedAvailable)
    readonly property int diskSizeGiB: controller ? Math.floor(Number(controller.selection("disk", "sizeBytes", 0)) / 1073741824) : 0
    readonly property int maximumRootGiB: Math.max(16, page.diskSizeGiB - 10)
    readonly property int rootSizeGiB: controller ? Number(controller.selection("disk", "rootSizeGiB", 32)) : 32
    readonly property bool guidedAvailable: page.diskSizeGiB >= 26 && page.rootSizeGiB >= 16 && page.rootSizeGiB <= page.maximumRootGiB

    function selectDiskMode(mode) {
        controller.setSelection("disk", "mode", mode)
        if (mode === "guided") {
            controller.setSelection("disk", "separateHome", true)
            controller.setSelection("disk", "rootSizeGiB", Math.max(16, Math.min(32, page.maximumRootGiB)))
        }
    }

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
                selectionIndicator: true
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
                selectionIndicator: true
                onClicked: page.selectDiskMode("erase")
            }
            SelectionCard {
                Layout.fillWidth: true
                Layout.preferredHeight: page.dp(72)
                iconText: "tune"
                title: qsTr("Custom full-disk layout")
                value: qsTr("Adjust the root partition and create a separate home partition")
                selected: page.controller && page.controller.selection("disk", "mode", "erase") === "guided"
                selectionIndicator: true
                enabled: page.diskSizeGiB >= 26
                onClicked: page.selectDiskMode("guided")
                Accessible.description: value
            }
        }
        MeoCard {
            visible: page.controller && page.controller.selection("disk", "mode", "erase") === "guided"
            width: parent.width
            implicitHeight: partitionColumn.implicitHeight + page.dp(24)
            type: "filled"
            padding: page.dp(12)
            Column {
                id: partitionColumn
                width: parent.width
                spacing: page.dp(10)
                MeoText { text: qsTr("Integrated partition plan"); typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                MeoText { width: parent.width; text: qsTr("This layout still erases the selected disk. It creates a 1 GiB EFI partition, an adjustable root partition, and a separate home partition."); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
                Row {
                    width: parent.width
                    spacing: page.dp(8)
                    MeoText { anchors.verticalCenter: parent.verticalCenter; text: qsTr("Root: %1 GiB").arg(page.rootSizeGiB); typeRole: "label"; typeSize: "large"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoText { anchors.verticalCenter: parent.verticalCenter; text: qsTr("Home: about %1 GiB").arg(Math.max(0, page.diskSizeGiB - page.rootSizeGiB - 1)); typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                }
                MeoSlider {
                    width: parent.width
                    from: 16
                    to: page.maximumRootGiB
                    value: page.rootSizeGiB
                    discrete: true
                    stepSize: 1
                    valueLabelEnabled: true
                    enabled: page.diskSizeGiB >= 26
                    onMoved: value => page.controller.setSelection("disk", "rootSizeGiB", Math.round(value))
                }
                Row {
                    id: partitionVisual
                    width: parent.width
                    height: page.dp(54)
                    spacing: page.dp(6)
                    readonly property real remainingWidth: Math.max(0, width - efiSegment.width - spacing * 2)
                    MeoCard {
                        id: efiSegment
                        width: page.dp(82)
                        height: parent.height
                        type: "outlined"
                        padding: page.dp(8)
                        MeoText { anchors.centerIn: parent; text: qsTr("EFI\n1 GiB"); horizontalAlignment: Text.AlignHCenter; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurface }
                    }
                    MeoCard {
                        id: rootSegment
                        width: partitionVisual.remainingWidth * page.rootSizeGiB / Math.max(1, page.diskSizeGiB - 1)
                        height: parent.height
                        type: "filled"
                        padding: page.dp(8)
                        MeoText { anchors.centerIn: parent; text: qsTr("Root\n%1 GiB").arg(page.rootSizeGiB); horizontalAlignment: Text.AlignHCenter; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurface }
                    }
                    MeoCard {
                        width: Math.max(0, partitionVisual.remainingWidth - rootSegment.width)
                        height: parent.height
                        type: "outlined"
                        padding: page.dp(8)
                        MeoText { anchors.centerIn: parent; text: qsTr("Home\n%1 GiB").arg(Math.max(0, page.diskSizeGiB - page.rootSizeGiB - 1)); horizontalAlignment: Text.AlignHCenter; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurface }
                    }
                }
                InfoBanner { visible: !page.guidedAvailable; width: parent.width; tone: "error"; title: qsTr("Custom layout unavailable"); message: qsTr("Select a disk of at least 26 GiB and leave at least 16 GiB for root and 8 GiB for home.") }
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
                    delegate: SelectionCard { required property var modelData; width: parent.width; height: page.dp(60); iconText: "swap_horiz"; title: modelData.name; value: modelData.detail; selected: page.controller && page.controller.selection("disk", "swap", "zram") === modelData.id; selectionIndicator: true; onClicked: page.controller.setSelection("disk", "swap", modelData.id) }
                }
                InfoBanner { width: parent.width; title: qsTr("Disk encryption unavailable"); message: qsTr("Encryption remains disabled until a tested Archinstall credential and cleanup path is available. No passphrase is collected."); tone: "error" }
                MeoButton { anchors.right: parent.right; text: qsTr("Done"); type: "filled"; onClicked: advanced.close() }
            }
        }
    }
}
