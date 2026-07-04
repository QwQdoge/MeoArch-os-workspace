import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import "pages"

ApplicationWindow {
    id: window
    width: 1180 * MeoTheme.globalScale
    height: 820 * MeoTheme.globalScale
    minimumWidth: 720 * MeoTheme.globalScale
    minimumHeight: 560 * MeoTheme.globalScale
    visible: true
    title: "MeoUI MD3 Expressive Showcase"
    color: MeoTheme.background

    readonly property var categories: [
        { label: "Foundations", icon: "palette" },
        { label: "Actions", icon: "smart_button" },
        { label: "Text Input", icon: "edit" },
        { label: "Selection", icon: "check_box" },
        { label: "Navigation", icon: "explore" },
        { label: "Data Display", icon: "table_chart" },
        { label: "Surfaces", icon: "layers" },
        { label: "Feedback", icon: "info" },
        { label: "Search", icon: "search" },
        { label: "Content & Media", icon: "perm_media" },
        { label: "Chips", icon: "label" },
        { label: "Layouts", icon: "dashboard_customize" },
        { label: "Expressive", icon: "auto_awesome" }
    ]

    MeoAppLayout {
        anchors.fill: parent
        navigationModel: window.categories
        compactNavigationLimit: 5
        safeAreaTop: 0
        safeAreaBottom: 0

        pages: [
            Component { ThemePage {} },
            Component { ButtonsPage {} },
            Component { InputsPage {} },
            Component { SelectionPage {} },
            Component { NavigationPage {} },
            Component { DataTablePage {} },
            Component { DisplayPage {} },
            Component { FeedbackPage {} },
            Component { WidgetsLabPage {} },
            Component { ComponentsLabPage {} },
            Component { PatternsPage {} },
            Component { LayoutsLabPage {} },
            Component { ExpressivePage {} }
        ]
    }
}
