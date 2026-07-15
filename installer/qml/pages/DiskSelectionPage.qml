pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
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
        anchors.fill: parent; spacing: page.dp(14)
        PageHeading { width: parent.width; title: "Disk Selection"; subtitle: "Choose the destination and how MeoArch should use it." }
        ListView {
            width: parent.width; height: page.dp(188); clip: true; spacing: page.dp(8); model: page.controller ? page.controller.disks : []
            ScrollBar.vertical: ScrollBar { }
            delegate: SelectionCard {
                required property var modelData
                width: ListView.view.width; height: page.dp(88); iconText: "D"; title: modelData.name + " · " + modelData.size; value: modelData.available + " · " + modelData.kind
                selected: page.controller && page.controller.selectedDisk === modelData.id
                onClicked: page.controller.setSelectedDisk(modelData.id)
            }
        }
        Row {
            width: parent.width; spacing: page.dp(12)
            SelectionCard { width: (parent.width - page.dp(12)) / 2; height: page.dp(72); iconText: "E"; title: "Erase disk and install"; value: "Recommended"; selected: page.controller && page.controller.selection("disk", "mode", "erase") === "erase"; onClicked: page.controller.setSelection("disk", "mode", "erase") }
            SelectionCard { width: (parent.width - page.dp(12)) / 2; height: page.dp(72); iconText: "M"; title: "Manual partitioning"; value: "Advanced"; selected: page.controller && page.controller.selection("disk", "mode", "erase") === "manual"; onClicked: { page.controller.setSelection("disk", "mode", "manual"); manualDialog.open() } }
        }
        Row { spacing: page.dp(8); MeoButton { text: "Advanced options"; kind: "text"; onClicked: advanced.open() } Text { anchors.verticalCenter: parent.verticalCenter; text: page.controller ? page.controller.selection("disk", "filesystem", "btrfs").toUpperCase() + " · " + page.controller.selection("disk", "swap", "zram") : ""; color: MeoTheme.onSurfaceVariant; font.family: page.roboto; font.pixelSize: page.dp(14) } }
    }

    MotionPopup {
        id: manualDialog
        parent: Overlay.overlay; anchors.centerIn: parent
        width: parent ? parent.width - page.dp(64) : page.width; height: parent ? parent.height - page.dp(64) : page.height
        modal: true; padding: page.dp(32); closePolicy: Popup.CloseOnEscape
        contentItem: Column {
            spacing: page.dp(18)
            Text { text: "Manual partitioning"; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(30); color: MeoTheme.onSurface }
            Text { text: "Review partitions, filesystems, and mount points. Existing EFI partitions are reused without formatting by default."; font.family: page.roboto; font.pixelSize: page.dp(15); color: MeoTheme.onSurfaceVariant }
            Rectangle {
                width: parent.width; height: parent.height - page.dp(150); radius: page.dp(16); color: MeoTheme.surfaceContainerLow
                Column {
                    anchors.fill: parent; anchors.margins: page.dp(16)
                    Row { width: parent.width; height: page.dp(48); spacing: page.dp(12); Repeater { model: ["Partition","Size","Filesystem","Mount point"]; Text { required property string modelData; width: (parent.width - page.dp(36))/4; text: modelData; font.family: page.roboto; font.bold: true; font.pixelSize: page.dp(14); color: MeoTheme.onSurface } } }
                    ListView {
                        width: parent.width; height: parent.height - page.dp(48); clip: true; model: partitions
                        delegate: Rectangle {
                            id: partitionRow
                            required property string partition; required property string sizeText; required property string filesystem; required property string mountPoint; required property int index
                            width: ListView.view.width; height: page.dp(56); radius: page.dp(10); color: page.selectedPartition === partitionRow.index ? MeoTheme.primaryContainer : "transparent"
                            Row { anchors.fill: parent; spacing: page.dp(12); Repeater { model: [partitionRow.partition,partitionRow.sizeText,partitionRow.filesystem,partitionRow.mountPoint]; Text { required property string modelData; width: (parent.width - page.dp(36))/4; anchors.verticalCenter: parent.verticalCenter; text: modelData; font.family: page.roboto; font.pixelSize: page.dp(14); color: MeoTheme.onSurface } } }
                            TapHandler { onTapped: page.selectedPartition = partitionRow.index }
                        }
                    }
                }
            }
            Row {
                width: parent.width; spacing: page.dp(8)
                MeoButton { text: "Add"; kind: "tonal"; onClicked: partitions.append({partition:"New partition",sizeText:"20 GiB",filesystem:"Btrfs",mountPoint:"/mnt"}) }
                MeoButton { text: "Edit"; kind: "text"; enabled: page.selectedPartition >= 0 }
                MeoButton { text: "Delete"; kind: "text"; enabled: page.selectedPartition >= 0; onClicked: { partitions.remove(page.selectedPartition); page.selectedPartition = -1 } }
                Item { width: Math.max(0, parent.width - page.dp(410)); height: 1 }
                MeoButton { text: "Cancel"; kind: "text"; onClicked: manualDialog.close() }
                MeoButton { text: "Apply"; onClicked: { page.controller.setSelection("disk","manualConfigured",true); manualDialog.close() } }
            }
        }
    }

    MotionPopup {
        id: advanced
        presentation: "sheet"
        parent: Overlay.overlay
        x: parent ? parent.width - width : 0
        y: 0
        width: Math.min(page.dp(520), parent ? parent.width : page.dp(520)); height: parent ? parent.height : page.height; modal: true; padding: page.dp(32); closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
        contentItem: Column {
            spacing: page.dp(18)
            Text { width: parent.width; text: "Advanced disk options"; font.family: page.comfortaa; font.bold: true; font.pixelSize: page.dp(28); color: MeoTheme.onSurface }
            Text { text: "Filesystem"; font.family: page.roboto; font.bold: true; font.pixelSize: page.dp(16); color: MeoTheme.onSurface }
            Row { spacing: page.dp(8); Repeater { model: [{id:"btrfs",name:"Btrfs · Recommended"},{id:"ext4",name:"ext4"}]; delegate: MeoButton { required property var modelData; text: modelData.name; kind: page.controller && page.controller.selection("disk","filesystem","btrfs") === modelData.id ? "tonal" : "outlined"; onClicked: page.controller.setSelection("disk","filesystem",modelData.id) } } }
            Text { text: "Swap"; font.family: page.roboto; font.bold: true; font.pixelSize: page.dp(16); color: MeoTheme.onSurface }
            Column { width: parent.width; Repeater { model: [{id:"zram",name:"Automatic ZRAM"},{id:"file",name:"Swap file"},{id:"none",name:"None"}]; delegate: SelectionCard { required property var modelData; width: parent.width; height: page.dp(60); title: modelData.name; value: modelData.id; selected: page.controller && page.controller.selection("disk","swap","zram") === modelData.id; onClicked: page.controller.setSelection("disk","swap",modelData.id) } } }
            ToggleRow { width: parent.width; title: "Disk encryption"; checked: page.controller ? page.controller.selection("privacy","diskEncryption",false) : false; onToggled: checked => page.controller.setSelection("privacy","diskEncryption",checked) }
            Column { visible: page.controller && page.controller.selection("privacy","diskEncryption",false); width: parent.width; spacing: page.dp(12); MeoTextField { width: parent.width; label: "Encryption passphrase"; echoMode: TextInput.Password; text: InstallerSession.diskPassphrase; onTextChanged: InstallerSession.diskPassphrase = text } MeoTextField { width: parent.width; label: "Confirm passphrase"; echoMode: TextInput.Password; text: InstallerSession.diskPassphraseConfirmation; onTextChanged: InstallerSession.diskPassphraseConfirmation = text } }
            MeoButton { anchors.right: parent.right; text: "Done"; onClicked: advanced.close() }
        }
    }
}
