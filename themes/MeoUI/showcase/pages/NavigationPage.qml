import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

MeoPageLayout {
    id: page

    title: "Navigation & page patterns"
    subtitle: "Reusable MD3E shells for app navigation, searchable headers, centered pages, and grouped lists."
    topBar: MeoSearchHeader {
        title: "MeoUI"
        placeholder: "Search components and patterns"
        actions: [
            Component { MeoIconButton { icon.name: "help"; type: "standard" } },
            Component { MeoIconButton { icon.name: "more_vert"; type: "standard" } }
        ]
    }

    readonly property real scaleFactor: MeoTheme.globalScale
    readonly property var navModel: [
        { label: "Theme", icon: "palette" },
        { label: "Buttons", icon: "smart_button", badgeText: "4" },
        { label: "Inputs", icon: "edit" },
        { label: "Navigation", icon: "explore" },
        { label: "Patterns", icon: "grid_view" }
    ]
    readonly property var groupedModel: [
        { label: "One-line item", icon: "inbox", trailingText: "56dp" },
        { label: "Two-line item", supportingText: "Supporting text creates a 72dp row", icon: "article", badgeText: "New" },
        { label: "Selected item", supportingText: "The selected pill stays inside the rounded group", icon: "check_circle" }
    ]

    SectionBlock {
        title: "MeoNavigationSuite"
        subtitle: "One navigation model adapts between bottom navigation, rail, and drawer."

        RowLayout {
            width: parent.width
            spacing: 16 * page.scaleFactor

            PreviewPane {
                Layout.fillWidth: true
                Layout.preferredHeight: 260 * page.scaleFactor
                title: "Expanded drawer"

                MeoNavigationSuite {
                    height: parent.height - 56 * page.scaleFactor
                    availableWidth: 960 * page.scaleFactor
                    anchors.left: parent.left
                    anchors.leftMargin: 24 * page.scaleFactor
                    anchors.bottom: parent.bottom
                    model: page.navModel
                    currentIndex: 3
                }
            }

            PreviewPane {
                Layout.fillWidth: true
                Layout.preferredHeight: 260 * page.scaleFactor
                title: "Medium rail"

                MeoNavigationSuite {
                    height: parent.height - 56 * page.scaleFactor
                    availableWidth: 720 * page.scaleFactor
                    anchors.left: parent.left
                    anchors.leftMargin: 24 * page.scaleFactor
                    anchors.bottom: parent.bottom
                    model: page.navModel
                    currentIndex: 3
                }
            }
        }
    }

    SectionBlock {
        title: "MeoPageLayout + MeoSearchHeader"
        subtitle: "Use these together for centered desktop pages with a 64dp searchable header."

        PreviewPane {
            width: parent.width
            height: 300 * page.scaleFactor
            title: "Page shell"

            Rectangle {
                anchors.left: parent.left
                anchors.right: parent.right
                anchors.bottom: parent.bottom
                height: parent.height - 56 * page.scaleFactor
                radius: 24 * page.scaleFactor
                color: MeoTheme.surfaceContainerLow
                clip: true

                MeoPageLayout {
                    anchors.fill: parent
                    title: "Page title"
                    subtitle: "A small amount of QML creates a balanced page with consistent content width."
                    padding: 16 * page.scaleFactor
                    topBar: MeoSearchHeader {
                        title: "Product"
                        placeholder: "Search within this page"
                        actions: [ Component { MeoIconButton { icon.name: "account_circle"; type: "tonal"; selected: true } } ]
                    }

                    Rectangle {
                        width: parent.width
                        height: 72 * page.scaleFactor
                        radius: 20 * page.scaleFactor
                        color: MeoTheme.surfaceContainerLowest
                    }
                }
            }
        }
    }

    SectionBlock {
        title: "MeoGroupedList"
        subtitle: "A card-like list group with 24dp outer corners, 72dp divider inset, and an internal selected pill."

        MeoGroupedList {
            width: parent.width
            title: "Grouped list anatomy"
            subtitle: "Model-driven rows keep app code short while preserving MD3 spacing."
            model: page.groupedModel
            selectedIndex: 2
        }
    }

    SectionBlock {
        title: "Top app bar modes"
        subtitle: "Small top app bars use a 64dp container with 48dp icon-button slots."

        Column {
            width: parent.width
            spacing: 12 * page.scaleFactor

            MeoTopAppBar {
                width: parent.width
                title: "Small app bar"
                type: "small"
                navigationIcon: MeoIconButton { icon.name: "menu"; type: "standard" }
                actions: [
                    Component { MeoIconButton { icon.name: "search"; type: "standard" } },
                    Component { MeoIconButton { icon.name: "more_vert"; type: "standard" } }
                ]
            }

            MeoTopAppBar {
                width: parent.width
                title: "Contextual selection"
                type: "small"
                isContextual: true
                selectionCount: 3
                navigationIcon: MeoIconButton { icon.name: "close"; type: "standard" }
                actions: [
                    Component { MeoIconButton { icon.name: "delete"; type: "standard" } },
                    Component { MeoIconButton { icon.name: "share"; type: "standard" } }
                ]
            }
        }
    }

    component SectionBlock: Column {
        property string title: ""
        property string subtitle: ""

        width: parent.width
        spacing: 12 * page.scaleFactor

        Column {
            width: parent.width
            spacing: 2 * page.scaleFactor

            Text {
                width: parent.width
                text: title
                font.pixelSize: MeoTheme.titleMedium.size * page.scaleFactor
                font.weight: MeoTheme.titleMedium.weight
                lineHeight: MeoTheme.titleMedium.lineHeight / MeoTheme.titleMedium.size
                color: MeoTheme.contentOnSurface
            }

            Text {
                width: parent.width
                text: subtitle
                visible: text !== ""
                wrapMode: Text.WordWrap
                font.pixelSize: MeoTheme.bodyMedium.size * page.scaleFactor
                font.weight: MeoTheme.bodyMedium.weight
                lineHeight: MeoTheme.bodyMedium.lineHeight / MeoTheme.bodyMedium.size
                color: MeoTheme.contentOnSurfaceVariant
            }
        }
    }

    component PreviewPane: Rectangle {
        property string title: ""

        radius: 24 * page.scaleFactor
        color: MeoTheme.surfaceContainer
        clip: true

        Text {
            text: parent.title
            anchors.left: parent.left
            anchors.top: parent.top
            anchors.margins: 16 * page.scaleFactor
            font.pixelSize: MeoTheme.labelLarge.size * page.scaleFactor
            font.weight: MeoTheme.labelLarge.weight
            color: MeoTheme.contentOnSurfaceVariant
        }
    }
}
