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
        { label: "Theme", icon: "palette" },
        { label: "Buttons", icon: "smart_button" },
        { label: "Inputs", icon: "edit" },
        { label: "Navigation", icon: "explore" },
        { label: "Selection", icon: "check_box" },
        { label: "Display", icon: "layers" },
        { label: "Feedback", icon: "info" },
        { label: "Patterns", icon: "grid_view" },
        { label: "Data Table", icon: "table_chart" },
        { label: "Expressive", icon: "auto_awesome" },
        { label: "Components Lab", icon: "extension" },
        { label: "Widgets Lab", icon: "widgets" },
        { label: "Layouts Lab", icon: "dashboard_customize" }
    ]

    MeoAppLayout {
        anchors.fill: parent
        navigationModel: window.categories
        safeAreaTop: 0
        safeAreaBottom: 0

        pages: [
            Component { ThemePage {} },
            Component { ButtonsPage {} },
            Component { InputsPage {} },
            Component { NavigationPage {} },
            Component { SelectionPage {} },
            Component { DisplayPage {} },
            Component { FeedbackPage {} },
            Component { PatternsPage {} },
            Component { DataTablePage {} },
            Component { ExpressivePage {} },
            Component { ComponentsLabPage {} },
            Component { WidgetsLabPage {} },
            Component { LayoutsLabPage {} }
        ]
    }
}
