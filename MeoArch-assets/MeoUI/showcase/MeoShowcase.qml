import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import "pages"

ApplicationWindow {
    id: window
    width: 1024
    height: 768
    visible: true
    title: "MeoUI MD3 Expressive Showcase"
    color: MeoTheme.background

    readonly property var categories: [
        { label: "Buttons", icon: "smart_button" },
        { label: "Inputs", icon: "edit" },
        { label: "Navigation", icon: "explore" },
        { label: "Selection", icon: "check_box" },
        { label: "Display", icon: "layers" },
        { label: "Feedback", icon: "info" },
        { label: "Patterns", icon: "grid_view" },
        { label: "Data Table", icon: "table_chart" }
    ]

    MeoAppLayout {
        anchors.fill: parent
        navigationModel: window.categories
        safeAreaTop: 0
        safeAreaBottom: 0

        pages: [
            Component { ButtonsPage {} },
            Component { InputsPage {} },
            Component { NavigationPage {} },
            Component { SelectionPage {} },
            Component { DisplayPage {} },
            Component { FeedbackPage {} },
            Component { PatternsPage {} },
            Component { DataTablePage {} }
        ]
    }
}
