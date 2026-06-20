import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Flickable {
    id: page
    contentWidth: width
    contentHeight: contentColumn.implicitHeight + 48 * MeoTheme.globalScale
    clip: true
    boundsBehavior: Flickable.StopAtBounds
    ScrollBar.vertical: ScrollBar {}

    ColumnLayout {
        id: contentColumn
        width: page.width - 48 * MeoTheme.globalScale
        x: 24 * MeoTheme.globalScale
        y: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale

        LabTitle { title: "Components lab"; subtitle: "Direct, interactive coverage for the remaining atomic MeoUI components." }

        LabSection {
            title: "Chips & grouped actions"
            Flow {
                Layout.fillWidth: true
                spacing: 8 * MeoTheme.globalScale
                MeoAssistChip { label: "Directions"; icon: "directions" }
                MeoAssistChip { label: "Elevated"; icon: "star"; elevated: true }
                MeoChip { label: "Generic chip"; icon: "bolt"; closable: true }
                MeoInputChip { label: "Input chip"; leadingIcon: "person"; selected: true }
                MeoSuggestionChip { label: "Suggestion" }
            }
            MeoFilterGroup {
                Layout.fillWidth: true
                model: [
                    { "label": "All", "icon": "apps" },
                    { "label": "Design", "icon": "palette" },
                    { "label": "Code", "icon": "code" }
                ]
                currentIndex: 0
            }
            MeoButtonGroup {
                model: [
                    { "label": "Cut", "icon": "content_cut" },
                    { "label": "Copy", "icon": "content_copy" },
                    { "label": "Paste", "icon": "content_paste" }
                ]
            }
        }

        LabSection {
            title: "Inputs & navigation helpers"
            Flow {
                Layout.fillWidth: true
                spacing: 12 * MeoTheme.globalScale
                MeoDateInput { width: 220 * MeoTheme.globalScale; label: "Date" }
                MeoTimeInput { width: 220 * MeoTheme.globalScale; label: "Time" }
                MeoExposedDropdown {
                    width: 240 * MeoTheme.globalScale
                    label: "Environment"
                    model: ["Development", "Staging", "Production"]
                }
            }
            MeoBreadcrumbs {
                Layout.fillWidth: true
                model: [
                    { "label": "Home", "icon": "home" },
                    { "label": "Library" },
                    { "label": "Component" }
                ]
            }
            MeoTabs {
                Layout.fillWidth: true
                model: ["Overview", "Tokens", "Usage"]
                currentIndex: 0
            }
            RowLayout {
                MeoIconButton { icon.name: "chevron_left"; onClicked: pageIndicator.currentIndex = Math.max(0, pageIndicator.currentIndex - 1) }
                MeoPageIndicator { id: pageIndicator; count: 5; currentIndex: 2 }
                MeoIconButton { icon.name: "chevron_right"; onClicked: pageIndicator.currentIndex = Math.min(pageIndicator.count - 1, pageIndicator.currentIndex + 1) }
            }
        }

        LabSection {
            title: "Visual primitives"
            RowLayout {
                Layout.fillWidth: true
                spacing: 16 * MeoTheme.globalScale
                Repeater {
                    model: [
                        { "initials": "ME", "variant": "circle" },
                        { "initials": "UI", "variant": "squircle" },
                        { "initials": "M3", "variant": "hexagon" }
                    ]
                    delegate: MeoAvatar {
                        required property var modelData
                        initials: modelData.initials
                        variant: modelData.variant
                        size: 56
                    }
                }
                Item { Layout.fillWidth: true }
                MeoPullToRefresh { pullDistance: 0.72; width: 48 * MeoTheme.globalScale; height: 48 * MeoTheme.globalScale }
            }
            Flow {
                Layout.fillWidth: true
                spacing: 12 * MeoTheme.globalScale
                Repeater {
                    model: ["squircle", "hexagon", "diamond", "pentagon"]
                    delegate: Column {
                        required property string modelData
                        spacing: 4 * MeoTheme.globalScale
                        MeoShape { width: 72 * MeoTheme.globalScale; height: 72 * MeoTheme.globalScale; type: parent.modelData; color: MeoTheme.primaryContainer; radius: 18 * MeoTheme.globalScale }
                        Text { anchors.horizontalCenter: parent.horizontalCenter; text: parent.modelData; color: MeoTheme.onSurfaceVariant; font.pixelSize: 11 * MeoTheme.globalScale }
                    }
                }
            }
            RowLayout {
                Layout.fillWidth: true
                spacing: 12 * MeoTheme.globalScale
                MeoSkeleton { Layout.preferredWidth: 72 * MeoTheme.globalScale; Layout.preferredHeight: 72 * MeoTheme.globalScale; radius: 36 * MeoTheme.globalScale }
                ColumnLayout {
                    Layout.fillWidth: true
                    MeoSkeleton { Layout.fillWidth: true; Layout.preferredHeight: 18 * MeoTheme.globalScale }
                    MeoSkeleton { Layout.fillWidth: true; Layout.preferredHeight: 12 * MeoTheme.globalScale }
                    MeoSkeleton { Layout.preferredWidth: 160 * MeoTheme.globalScale; Layout.preferredHeight: 12 * MeoTheme.globalScale }
                }
            }
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: 72 * MeoTheme.globalScale
                radius: MeoTheme.shapeLarge
                color: MeoTheme.surfaceContainerHighest
                Text { anchors.centerIn: parent; text: "Standalone MeoStateLayer — hover or press"; color: MeoTheme.onSurface; font.pixelSize: 14 * MeoTheme.globalScale }
                MeoStateLayer { anchors.fill: parent; radius: parent.radius; hovered: stateMouse.containsMouse; pressed: stateMouse.pressed; color: MeoTheme.onSurface }
                MouseArea { id: stateMouse; anchors.fill: parent; hoverEnabled: true }
            }
        }

        LabSection {
            title: "Carousel"
            MeoCarousel {
                Layout.fillWidth: true
                Layout.preferredHeight: 220 * MeoTheme.globalScale
                itemWidth: 220 * MeoTheme.globalScale
                itemHeight: 180 * MeoTheme.globalScale
                model: [
                    { "title": "Color system", "icon": "palette" },
                    { "title": "Type scale", "icon": "text_fields" },
                    { "title": "Motion", "icon": "animation" }
                ]
                delegate: Component {
                    Rectangle {
                        required property var modelData
                        radius: MeoTheme.shapeExtraLarge
                        color: MeoTheme.secondaryContainer
                        Column {
                            anchors.centerIn: parent
                            spacing: 8 * MeoTheme.globalScale
                            MeoIcon { anchors.horizontalCenter: parent.horizontalCenter; icon: modelData.icon; size: 36; color: MeoTheme.onSecondaryContainer }
                            Text { text: modelData.title; color: MeoTheme.onSecondaryContainer; font.pixelSize: 16 * MeoTheme.globalScale; font.weight: Font.DemiBold }
                        }
                    }
                }
            }
        }

        LabSection {
            title: "Overlays & tooltips"
            Flow {
                Layout.fillWidth: true
                spacing: 8 * MeoTheme.globalScale
                MeoButton { text: "Dialog"; onClicked: dialog.open() }
                MeoButton { text: "Full screen"; type: "outlined"; onClicked: fullScreenDialog.open() }
                MeoButton { id: menuButton; text: "Menu"; type: "outlined"; onClicked: menu.open() }
                MeoButton { id: tooltipButton; text: "Hover tooltip"; type: "outlined"; hoverEnabled: true
                    MeoTooltip { visible: tooltipButton.hovered; text: "Plain MD3 tooltip" }
                }
                MeoButton { text: "Rich tooltip"; type: "outlined"; onClicked: richTooltip.open() }
            }
        }
    }

    MeoDialog { id: dialog; title: "MeoDialog"; message: "Dialogs interrupt the current task with a focused decision."; icon: "info" }
    MeoMenu {
        id: menu
        parent: menuButton
        y: menuButton.height
        model: [
            { "label": "Edit", "icon": "edit" },
            { "label": "Duplicate", "icon": "content_copy" },
            { "label": "Delete", "icon": "delete" }
        ]
    }
    MeoRichTooltip {
        id: richTooltip
        title: "Rich tooltip"
        text: "Rich tooltips can explain unfamiliar controls and provide actions."
        actions: [{ "text": "Got it" }]
    }
    MeoFullScreenDialog {
        id: fullScreenDialog
        title: "Full-screen dialog"
        actions: [{ "text": "Save" }]
        content: Component {
            Column {
                spacing: 16 * MeoTheme.globalScale
                padding: 24 * MeoTheme.globalScale
                Text { text: "Focused editing surface"; color: MeoTheme.onSurface; font.pixelSize: 24 * MeoTheme.globalScale }
                MeoTextField { width: 420 * MeoTheme.globalScale; label: "Document title" }
                MeoTextArea { width: 420 * MeoTheme.globalScale; height: 160 * MeoTheme.globalScale; placeholderText: "Write something…" }
            }
        }
    }

    component LabTitle: ColumnLayout {
        property string title: ""
        property string subtitle: ""
        Layout.fillWidth: true
        Text { text: parent.title; color: MeoTheme.onSurface; font.pixelSize: MeoTheme.headlineLargeEmphasized.size * MeoTheme.globalScale; font.weight: Font.Bold }
        Text { Layout.fillWidth: true; text: parent.subtitle; color: MeoTheme.onSurfaceVariant; font.pixelSize: MeoTheme.bodyLarge.size * MeoTheme.globalScale; wrapMode: Text.WordWrap }
    }
    component LabSection: ColumnLayout {
        default property alias contents: sectionContent.data
        property string title: ""
        Layout.fillWidth: true
        spacing: 12 * MeoTheme.globalScale
        Text { text: parent.title; color: MeoTheme.primary; font.pixelSize: 20 * MeoTheme.globalScale; font.weight: Font.DemiBold }
        ColumnLayout { id: sectionContent; Layout.fillWidth: true; spacing: 12 * MeoTheme.globalScale }
    }
}
