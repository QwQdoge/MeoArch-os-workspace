import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: displayPage
    categoryId: "surfaces"

    // 🌟 Top Media Cards (Standard vertical)
    ShowcaseSection {
        title: "Standard Media Cards (Top Media Position)"
        subtitle: "MD3 media cards with full-bleed media at the top, supporting headers, body copy, and interactive buttons."
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Elevated Media Card
            MeoMediaCard {
                Layout.fillWidth: true
                type: "elevated"
                size: "m"
                title: "Glassmorphism Art"
                subtitle: "By Meo Creative Studio"
                supportingText: "Explore the fascinating world of digital art combining frosted glass reflections and vibrant color gradients."
                mediaSource: "https://images.unsplash.com/photo-1618005182384-a83a8bd57fbe?w=500&auto=format&fit=crop"
                mediaAspectRatio: 16 / 9
                mediaPosition: "top"
                avatarInitials: "MC"
                interactive: true
                bouncy: true

                actions: [
                    Component {
                        MeoButton {
                            text: "Read More"
                            type: "tonal"
                            size: "s"
                        }
                    },
                    Component {
                        MeoButton {
                            text: "Bookmark"
                            type: "text"
                            size: "s"
                            icon.name: "bookmark"
                        }
                    }
                ]
            }

            // Filled Media Card
            MeoMediaCard {
                Layout.fillWidth: true
                type: "filled"
                size: "m"
                title: "Neon Cityscapes"
                subtitle: "Photography Column"
                supportingText: "A collection of stunning late-night urban views captured in metropolitan areas during rain showers."
                mediaSource: "https://images.unsplash.com/photo-1514565131-fce0801e5785?w=500&auto=format&fit=crop"
                mediaAspectRatio: 16 / 9
                mediaPosition: "top"
                avatarSource: "https://api.dicebear.com/7.x/avataaars/svg?seed=Neon"
                interactive: true
                bouncy: true

                actions: [
                    Component {
                        MeoButton {
                            text: "Explore"
                            type: "filled"
                            size: "s"
                        }
                    }
                ]
            }
        }
    }

    // 🌟 Side-by-Side Horizontal Media Cards
    ShowcaseSection {
        title: "Horizontal Media Cards (Left & Right Positions)"
        subtitle: "Compact cards with media side-aligned, ideal for lists, feeds, or article index layouts."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Left Media (Outlined)
            MeoMediaCard {
                Layout.fillWidth: true
                height: 160 * MeoTheme.globalScale
                type: "outlined"
                size: "m"
                title: "Modern Architecture"
                subtitle: "Design Digest"
                supportingText: "An in-depth analysis of brutalist forms adapting to modern ecological standards in city planning."
                mediaSource: "https://images.unsplash.com/photo-1600585154340-be6161a56a0c?w=500&auto=format&fit=crop"
                mediaAspectRatio: 4 / 3
                mediaPosition: "left"
                interactive: true
                bouncy: true

                actions: [
                    Component {
                        MeoButton {
                            text: "Read"
                            type: "text"
                            size: "s"
                        }
                    }
                ]
            }

            // Right Media (Filled)
            MeoMediaCard {
                Layout.fillWidth: true
                height: 160 * MeoTheme.globalScale
                type: "filled"
                size: "m"
                title: "Minimal Interior Design"
                subtitle: "Home Style"
                supportingText: "Discover the serenity of beige-toned Scandinavian design and minimal space planning for tiny homes."
                mediaSource: "https://images.unsplash.com/photo-1586023492125-27b2c045efd7?w=500&auto=format&fit=crop"
                mediaAspectRatio: 4 / 3
                mediaPosition: "right"
                interactive: true
                bouncy: true

                actions: [
                    Component {
                        MeoButton {
                            text: "Inspire Me"
                            type: "filled"
                            size: "s"
                        }
                    }
                ]
            }
        }
    }

    // 🌟 Expressive Shapes & Sizes
    ShowcaseSection {
        title: "Expressive Custom Shapes & Sizing"
        subtitle: "Using size 's' and size 'l' configurations along with expressive shapes like squircle, clover, and hexagon."
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Small Card with Squircle Shape
            MeoMediaCard {
                Layout.fillWidth: true
                type: "elevated"
                size: "s"
                shape: "squircle"
                title: "Compact Post"
                subtitle: "Small Sizing Scale"
                supportingText: "This small card utilizes squircle organic curves and tight compact spacing."
                mediaSource: "https://images.unsplash.com/photo-1550684848-fac1c5b4e853?w=500&auto=format&fit=crop"
                mediaAspectRatio: 16 / 9
                mediaPosition: "top"
                interactive: true
                bouncy: true
            }

            // Large Card with Clover Shape
            MeoMediaCard {
                Layout.fillWidth: true
                type: "outlined"
                size: "l"
                shape: "clover"
                title: "Clover Collection"
                subtitle: "Large Sizing Scale"
                supportingText: "This large card features rich margin spacing, clover outline shape, and large-sized typography."
                mediaSource: "https://images.unsplash.com/photo-1541701494587-cb58502866ab?w=500&auto=format&fit=crop"
                mediaAspectRatio: 16 / 10
                mediaPosition: "top"
                interactive: true
                bouncy: true
                avatarSource: "https://api.dicebear.com/7.x/avataaars/svg?seed=Clover"

                actions: [
                    Component {
                        MeoButton {
                            text: "Learn"
                            type: "filled"
                            size: "l"
                        }
                    }
                ]
            }
        }
    }
}
