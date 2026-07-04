import MeoUI
import ".."

ShowcaseCategoryPage {
    categoryId: "search"

    ShowcaseSection {
        title: "Account Management"
        subtitle: "MD3 Expressive Account Switcher widget."
        width: parent.width

        MeoAccountSwitcher {
            anchors.horizontalCenter: parent.horizontalCenter
            model: [
                { name: "Meo Developer", email: "dev@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Meo" },
                { name: "Design Lead", email: "design@meo.ui", avatar: "https://api.dicebear.com/7.x/avataaars/svg?seed=Design" }
            ]
        }
    }
}
