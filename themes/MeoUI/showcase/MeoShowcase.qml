import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import "pages"

ApplicationWindow {
    id: window
    width: 1280 * MeoTheme.globalScale
    height: 800 * MeoTheme.globalScale
    minimumWidth: 360 * MeoTheme.globalScale
    minimumHeight: 480 * MeoTheme.globalScale
    visible: true
    title: "MeoUI MD3 Expressive Showcase"
    color: MeoTheme.background
    Component.onCompleted: {
        for (let index = 0; index < Qt.application.arguments.length; ++index) {
            const argument = Qt.application.arguments[index]
            if (argument.indexOf("--width=") === 0)
                width = Math.max(minimumWidth, Number(argument.substring(8)))
            else if (argument.indexOf("--height=") === 0)
                height = Math.max(minimumHeight, Number(argument.substring(9)))
            else if (argument.indexOf("--page=") === 0)
                appLayout.currentIndex = Math.max(0, Math.min(categories.length - 1, Number(argument.substring(7))))
        }
    }

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
        id: appLayout
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
