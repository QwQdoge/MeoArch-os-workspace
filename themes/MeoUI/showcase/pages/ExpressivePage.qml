import MeoUI
import ".."

ShowcaseCategoryPage {
    categoryId: "expressive"

    // 🌟 Additional Expressive Samples
    ShowcaseSection {
        title: "Adaptive Segmented Groups"
        subtitle: "Items with connected corner radii forming unified containers."
        width: parent.width

        MeoGroupedList {
            width: parent.width
            title: "System Settings"
            subtitle: "Grouped with adaptive corners"
            model: [
                { label: "Wi-Fi", icon: "wifi", trailingText: "Connected" },
                { label: "Bluetooth", icon: "bluetooth", trailingText: "On" },
                { label: "Mobile Network", icon: "signal_cellular_4_bar" }
            ]
        }
    }

    ShowcaseSection {
        title: "Expressive Search Morphing"
        subtitle: "Fluid expansion from bar to full surface."
        width: parent.width

        MeoSearchBar {
            id: demoSearchBar
            width: parent.width
            placeholder: "Click to see morphing..."
            onActivated: searchView.open()
        }

        MeoSearchView {
            id: searchView
            width: parent.width
            height: 400 * MeoTheme.globalScale
            suggestions: [
                { label: "Material Design 3", icon: "history" },
                { label: "Expressive Motion", icon: "history" },
                { label: "QML Components", icon: "search" }
            ]
        }
    }
}
