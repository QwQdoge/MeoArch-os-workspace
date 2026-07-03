import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

ScrollView {
    id: page
    contentWidth: availableWidth

    ColumnLayout {
        width: page.availableWidth - 48 * MeoTheme.globalScale
        x: 24 * MeoTheme.globalScale
        y: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale

        MeoText { text: "Layouts lab"; typeRole: "title"; typeSize: "big"; emphasized: true; color: MeoTheme.contentOnSurface }
        MeoText { Layout.fillWidth: true; text: "Responsive pattern previews. Resize the window to exercise their breakpoints."; typeRole: "body"; typeSize: "big"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }

        SectionTitle { text: "Responsive primitives" }
        Flow {
            Layout.fillWidth: true
            spacing: 12 * MeoTheme.globalScale
            LayoutCard { title: "Row"; iconName: "view_column"; body: "Horizontal alignment with fixed icon/button slots." }
            LayoutCard { title: "Column"; iconName: "view_agenda"; body: "Vertical groups for forms, sections, and settings." }
            LayoutCard { title: "Grid"; iconName: "grid_view"; body: "Repeatable cards with stable tracks." }
            LayoutCard { title: "Flow"; iconName: "auto_awesome_mosaic"; body: "Wrap chips, controls, and responsive actions." }
            LayoutCard { title: "Stack"; iconName: "layers"; body: "Overlay surfaces, scrims, and transient UI." }
            LayoutCard { title: "Split view"; iconName: "splitscreen"; body: "Master-detail panes for wide screens." }
        }

        SectionTitle { text: "Breakpoint concepts" }
        RowLayout {
            Layout.fillWidth: true
            spacing: 12 * MeoTheme.globalScale
            BreakpointCard { label: "< 840px"; pattern: "Compact / bottom nav" }
            BreakpointCard { label: ">= 840px"; pattern: "Rail + content" }
            BreakpointCard { label: ">= 1200px"; pattern: "Drawer + wide content" }
        }

        SectionTitle { text: "Common page compositions" }
        Flow {
            Layout.fillWidth: true
            spacing: 12 * MeoTheme.globalScale
            LayoutCard { title: "Two-column"; iconName: "view_week"; body: "Primary work area with secondary inspector." }
            LayoutCard { title: "Card grid"; iconName: "dashboard"; body: "Equal-width cards for scanning and comparison." }
            LayoutCard { title: "Form layout"; iconName: "dynamic_form"; body: "Labels, inputs, helper text, and actions." }
            LayoutCard { title: "Master-detail"; iconName: "view_sidebar"; body: "List selection opens persistent detail." }
            LayoutCard { title: "Dialog layout"; iconName: "web_asset"; body: "Focused decisions with compact actions." }
            LayoutCard { title: "Sidebar + content"; iconName: "dock_to_right"; body: "Dense desktop navigation and main content." }
        }

        SectionTitle { text: "Dashboard layout" }
        MeoDashboardLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 300 * MeoTheme.globalScale
            model: [
                { "title": "Revenue", "value": "$24.8k" },
                { "title": "Sessions", "value": "18,420" },
                { "title": "Conversion", "value": "12.4%" }
            ]
            delegate: Component {
                MeoCard {
                    property var modelData: ({ "title": "", "value": "" })
                    Layout.fillWidth: true
                    implicitHeight: 120 * MeoTheme.globalScale
                    type: "filled"
                    Column { anchors.fill: parent; spacing: 8 * MeoTheme.globalScale
                        MeoText { text: modelData.title; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                        MeoText { text: modelData.value; typeRole: "title"; typeSize: "big"; emphasized: true; color: MeoTheme.contentOnSurface }
                    }
                }
            }
        }

        SectionTitle { text: "Feed layout" }
        MeoFeedLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 360 * MeoTheme.globalScale
            model: [
                { "title": "Design tokens", "body": "A compact token update.", "height": 120 },
                { "title": "Expressive motion", "body": "Soul Curve makes transitions feel responsive.", "height": 180 },
                { "title": "Adaptive layout", "body": "Resize to see the pattern react.", "height": 150 },
                { "title": "Accessible color", "body": "Semantic pairs preserve contrast.", "height": 130 }
            ]
            delegate: Component {
                MeoCard {
                    property var modelData: ({ "title": "", "body": "", "height": 120 })
                    width: parent ? parent.width : 240 * MeoTheme.globalScale
                    implicitHeight: modelData.height * MeoTheme.globalScale
                    Column { anchors.fill: parent; spacing: 8 * MeoTheme.globalScale
                        MeoText { text: modelData.title; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                        MeoText { width: parent.width; text: modelData.body; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
                    }
                }
            }
        }

        SectionTitle { text: "List-detail layout" }
        MeoListDetailLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 320 * MeoTheme.globalScale
            showDetail: true
            listComponent: Component {
                Rectangle {
                    color: MeoTheme.surfaceContainerLow
                    Column {
                        anchors.fill: parent
                        MeoListHeader { text: "Components" }
                        MeoListItem { width: parent.width; headline: "MeoButton"; supportingText: "Actions"; leadingIcon: "smart_button" }
                        MeoListItem { width: parent.width; headline: "MeoCard"; supportingText: "Surfaces"; leadingIcon: "dashboard" }
                    }
                }
            }
            detailComponent: Component {
                Rectangle {
                    color: MeoTheme.surface
                    Column {
                        anchors.centerIn: parent
                        spacing: 12 * MeoTheme.globalScale
                        MeoIcon { anchors.horizontalCenter: parent.horizontalCenter; icon: "view_sidebar"; size: 48; color: MeoTheme.primary }
                        MeoText { text: "Detail pane"; typeRole: "title"; typeSize: "medium"; color: MeoTheme.contentOnSurface }
                    }
                }
            }
        }

        SectionTitle { text: "Settings layout" }
        MeoSettingsLayout {
            Layout.fillWidth: true
            Layout.preferredHeight: 420 * MeoTheme.globalScale
            title: "Showcase settings"
            model: [
                { "sectionTitle": "Appearance", "items": [
                    { "title": "Dark theme", "subtitle": "Use the dark color scheme", "icon": "dark_mode", "type": "switch", "checked": MeoTheme.isDarkMode },
                    { "title": "Dynamic color", "subtitle": "Follow the selected palette", "icon": "palette", "type": "chevron" }
                ]},
                { "sectionTitle": "About", "items": [
                    { "title": "MeoUI", "subtitle": "Material Design 3 component library", "icon": "info", "type": "chevron" }
                ]}
            ]
        }

        Item { Layout.preferredHeight: 24 * MeoTheme.globalScale }
    }

    component SectionTitle: MeoText {
        Layout.fillWidth: true
        typeRole: "title"
        typeSize: "medium"
        emphasized: true
        color: MeoTheme.primary
    }

    component LayoutCard: Rectangle {
        property string title: ""
        property string iconName: "grid_view"
        property string body: ""
        width: 176 * MeoTheme.globalScale
        height: 148 * MeoTheme.globalScale
        radius: MeoTheme.shapeLarge
        color: MeoTheme.surfaceContainerLow
        Column {
            anchors.fill: parent
            anchors.margins: 16 * MeoTheme.globalScale
            spacing: 8 * MeoTheme.globalScale
            MeoIcon { icon: parent.parent.iconName; size: 28; color: MeoTheme.primary }
            MeoText { width: parent.width; text: parent.parent.title; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
            MeoText { width: parent.width; text: parent.parent.body; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
        }
    }

    component BreakpointCard: Rectangle {
        property string label: ""
        property string pattern: ""
        Layout.fillWidth: true
        implicitHeight: 92 * MeoTheme.globalScale
        radius: MeoTheme.shapeLarge
        color: MeoTheme.surfaceContainer
        Column {
            anchors.centerIn: parent
            spacing: 4 * MeoTheme.globalScale
            MeoText { anchors.horizontalCenter: parent.horizontalCenter; text: parent.parent.label; typeRole: "label"; typeSize: "big"; color: MeoTheme.primary }
            MeoText { anchors.horizontalCenter: parent.horizontalCenter; text: parent.parent.pattern; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
        }
    }
}
