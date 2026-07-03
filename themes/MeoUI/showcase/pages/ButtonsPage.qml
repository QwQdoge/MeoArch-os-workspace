import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

MeoPageLayout {
    id: page
    title: "Common Buttons"
    subtitle: "Button families are shown by type and state: enabled, disabled, icon, loading, selected, and focus-ready."

    readonly property real s: MeoTheme.globalScale

    Section {
        title: "Type x state"

        Column {
            width: parent.width
            spacing: 12 * page.s

            HeaderRow {}
            ButtonRow { label: "Filled"; buttonType: "filled" }
            ButtonRow { label: "Tonal"; buttonType: "tonal" }
            ButtonRow { label: "Outlined"; buttonType: "outlined" }
            ButtonRow { label: "Elevated"; buttonType: "elevated" }
            ButtonRow { label: "Text"; buttonType: "text" }
        }
    }

    Section {
        title: "Segmented buttons"

        Column {
            width: parent.width
            spacing: 12 * page.s
            MeoText { text: "Compact segmented"; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant }
            MeoSegmentedButtons {
                width: 360 * page.s
                model: [
                    { label: "Day", icon: "wb_sunny" },
                    { label: "Night", icon: "dark_mode" }
                ]
            }
            MeoText { text: "Full-width segmented"; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant }
            MeoSegmentedButtons {
                width: parent.width
                multiSelect: true
                model: [
                    { label: "Bold", icon: "format_bold" },
                    { label: "Italic", icon: "format_italic" },
                    { label: "Underline", icon: "format_underlined" }
                ]
                selectedIndices: [0]
            }
        }
    }

    Section {
        title: "Floating action buttons"

        Flow {
            width: parent.width
            spacing: 20 * page.s
            FabSample { label: "Small FAB"; fabType: "small"; iconName: "edit" }
            FabSample { label: "Regular FAB"; fabType: "regular"; iconName: "add" }
            FabSample { label: "Large FAB"; fabType: "large"; iconName: "palette" }
            Column {
                spacing: 8 * page.s
                MeoFAB { type: "extended"; icon.name: "mail"; text: "Compose" }
                MeoText { anchors.horizontalCenter: parent.horizontalCenter; text: "Extended FAB"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
            }
        }
    }

    Section {
        title: "Icon buttons"

        Flow {
            width: parent.width
            spacing: 16 * page.s
            IconButtonSample { label: "Standard"; buttonType: "standard"; iconName: "settings" }
            IconButtonSample { label: "Filled"; buttonType: "filled"; iconName: "favorite" }
            IconButtonSample { label: "Tonal"; buttonType: "tonal"; iconName: "bookmark" }
            IconButtonSample { label: "Outlined"; buttonType: "outlined"; iconName: "share" }
            IconButtonSample { label: "Selected"; buttonType: "filled"; iconName: "favorite"; isSelected: true }
            IconButtonSample { label: "Disabled"; buttonType: "outlined"; iconName: "block"; isEnabled: false }
        }
    }

    component Section: Column {
        property string title: ""
        width: parent.width
        spacing: 12 * page.s
        MeoText { text: parent.title; typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
    }

    component HeaderRow: Row {
        width: parent.width
        spacing: 12 * page.s
        Repeater {
            model: ["Type", "Normal", "Disabled", "With icon", "Loading", "Selected"]
            delegate: MeoText {
                required property string modelData
                width: index === 0 ? 120 * page.s : 150 * page.s
                text: modelData
                typeRole: "label"
                typeSize: "medium"
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
    }

    component ButtonRow: Row {
        property string label: ""
        property string buttonType: "filled"
        width: parent.width
        spacing: 12 * page.s
        MeoText { width: 120 * page.s; anchors.verticalCenter: parent.verticalCenter; text: parent.label; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurface }
        MeoButton { width: 150 * page.s; text: parent.label; type: parent.buttonType }
        MeoButton { width: 150 * page.s; text: parent.label; type: parent.buttonType; enabled: false }
        MeoButton { width: 150 * page.s; text: "Create"; type: parent.buttonType; icon.name: "add" }
        MeoButton { width: 150 * page.s; text: "Loading"; type: parent.buttonType; loading: true }
        MeoButton { width: 150 * page.s; text: "Selected"; type: parent.buttonType; checkable: true; checked: true }
    }

    component FabSample: Column {
        property string label: ""
        property string fabType: "regular"
        property string iconName: "add"
        spacing: 8 * page.s
        MeoFAB { anchors.horizontalCenter: parent.horizontalCenter; type: parent.fabType; icon.name: parent.iconName }
        MeoText { anchors.horizontalCenter: parent.horizontalCenter; text: parent.label; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
    }

    component IconButtonSample: Column {
        property string label: ""
        property string buttonType: "standard"
        property string iconName: "settings"
        property bool isSelected: false
        property bool isEnabled: true
        spacing: 8 * page.s
        MeoIconButton { anchors.horizontalCenter: parent.horizontalCenter; type: parent.buttonType; icon.name: parent.iconName; selected: parent.isSelected; enabled: parent.isEnabled }
        MeoText { anchors.horizontalCenter: parent.horizontalCenter; text: parent.label; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
    }
}
