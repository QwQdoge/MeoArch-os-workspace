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

        Text { text: "Layouts lab"; color: MeoTheme.onSurface; font.pixelSize: MeoTheme.headlineLargeEmphasized.size * MeoTheme.globalScale; font.weight: Font.Bold }
        Text { Layout.fillWidth: true; text: "Responsive pattern previews. Resize the window to exercise their breakpoints."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 16 * MeoTheme.globalScale; wrapMode: Text.WordWrap }

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
                    required property var modelData
                    Layout.fillWidth: true
                    implicitHeight: 120 * MeoTheme.globalScale
                    type: "filled"
                    Column { anchors.fill: parent; spacing: 8 * MeoTheme.globalScale
                        Text { text: modelData.title; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
                        Text { text: modelData.value; color: MeoTheme.onSurface; font.pixelSize: 28 * MeoTheme.globalScale; font.weight: Font.Bold }
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
                    required property var modelData
                    width: parent ? parent.width : 240 * MeoTheme.globalScale
                    implicitHeight: modelData.height * MeoTheme.globalScale
                    Column { anchors.fill: parent; spacing: 8 * MeoTheme.globalScale
                        Text { text: modelData.title; color: MeoTheme.onSurface; font.pixelSize: 18 * MeoTheme.globalScale; font.weight: Font.DemiBold }
                        Text { width: parent.width; text: modelData.body; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale; wrapMode: Text.WordWrap }
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
                        Text { text: "Detail pane"; color: MeoTheme.onSurface; font.pixelSize: 24 * MeoTheme.globalScale }
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

    component SectionTitle: Text {
        Layout.fillWidth: true
        color: MeoTheme.primary
        font.pixelSize: 20 * MeoTheme.globalScale
        font.weight: Font.DemiBold
    }
}
