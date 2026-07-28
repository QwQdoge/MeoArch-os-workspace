import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: componentsLabPage
    categoryId: "content-media"

    // 🌟 Size Configurations Section
    ShowcaseSection {
        title: "Media Card Sizes (大小配置)"
        subtitle: "A 3-step size variant scale ('s', 'm', 'l') with automatically scaled typography and layout metrics."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            // S Size
            MeoMediaCard {
                cardSize: "s"
                type: "filled"
                mediaSource: "https://picsum.photos/400/300?random=1"
                aspectRatio: 16/9
                title: "Small Card"
                supportingText: "A highly compact size variant designed for grid list layouts and tight spaces."
                actions: [
                    { "label": "View" },
                    { "label": "Share" }
                ]
            }

            // M Size
            MeoMediaCard {
                cardSize: "m"
                type: "filled"
                mediaSource: "https://picsum.photos/400/300?random=2"
                aspectRatio: 16/9
                title: "Medium Card"
                supportingText: "The standard default size variant. Excellent balance of media area and readability."
                actions: [
                    { "label": "View" },
                    { "label": "Share" }
                ]
            }

            // L Size
            MeoMediaCard {
                cardSize: "l"
                type: "filled"
                mediaSource: "https://picsum.photos/400/300?random=3"
                aspectRatio: 16/9
                title: "Large Card"
                supportingText: "Generous spacing and prominent typography for high-impact media features."
                actions: [
                    { "label": "View" },
                    { "label": "Share" }
                ]
            }
        }
    }

    // 🌟 Aspect Ratios Section
    ShowcaseSection {
        title: "Media Aspect Ratios (比例变体)"
        subtitle: "Supports customizable media aspect ratios such as 16:9, 4:3, or 1:1 square for different content layouts."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            // 16:9
            MeoMediaCard {
                type: "elevated"
                mediaSource: "https://picsum.photos/400/300?random=4"
                aspectRatio: 16/9
                title: "Cinematic 16:9"
                supportingText: "Perfect for video previews, movie posters, and horizontal landscapes."
            }

            // 4:3
            MeoMediaCard {
                type: "elevated"
                mediaSource: "https://picsum.photos/400/300?random=5"
                aspectRatio: 4/3
                title: "Classic 4:3"
                supportingText: "Traditional photograph aspect ratio. Great for portrait and landscape scenes."
            }

            // 1:1
            MeoMediaCard {
                type: "elevated"
                mediaSource: "https://picsum.photos/400/300?random=6"
                aspectRatio: 1/1
                title: "Square 1:1"
                supportingText: "Modern square crop. Highly popular for product showcases and social media avatars."
            }
        }
    }

    // 🌟 Thickness Variants Section
    ShowcaseSection {
        title: "Card Outline Thickness (粗细变体)"
        subtitle: "Outlined variants utilizing MeoTheme semantic stroke thickness tokens ('thin', 'medium', 'thick')."
        width: parent.width

        Flow {
            width: parent.width
            spacing: MeoTheme.space16

            // Thin
            MeoMediaCard {
                type: "outlined"
                thickness: "thin"
                mediaSource: "https://picsum.photos/400/300?random=7"
                aspectRatio: 16/9
                title: "strokeWidthThin (1dp)"
                supportingText: "Standard thin outline. Subtle separation from the background canvas."
            }

            // Medium
            MeoMediaCard {
                type: "outlined"
                thickness: "medium"
                mediaSource: "https://picsum.photos/400/300?random=8"
                aspectRatio: 16/9
                title: "strokeWidthMedium (2dp)"
                supportingText: "Medium outline. Increased visual structure and emphasis on the card boundaries."
            }

            // Thick
            MeoMediaCard {
                type: "outlined"
                thickness: "thick"
                mediaSource: "https://picsum.photos/400/300?random=9"
                aspectRatio: 16/9
                title: "strokeWidthThick (3dp)"
                supportingText: "Thick outline. Highly stylistic and expressive look for highlighted items."
            }
        }
    }

    // 🌟 States Section
    ShowcaseSection {
        title: "Card States & Positions (交互与多变体状态)"
        subtitle: "Demonstrates interactive feedback, selected checkbox indicator, disabled opacity, and horizontal positions."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            // Interactive / Selected / Disabled states
            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                // Interactive
                MeoMediaCard {
                    type: "elevated"
                    interactive: true
                    mediaSource: "https://picsum.photos/400/300?random=10"
                    aspectRatio: 16/9
                    title: "Interactive Card"
                    supportingText: "Click on this card to see organic hover scaling, smooth pressed response, and ripples."
                    actions: [
                        { "label": "Explore" }
                    ]
                }

                // Selected State
                MeoMediaCard {
                    type: "elevated"
                    selected: true
                    mediaSource: "https://picsum.photos/400/300?random=11"
                    aspectRatio: 16/9
                    title: "Selected State"
                    supportingText: "Features an MD3 check badge in the corner and primaryContainer colored background."
                    actions: [
                        { "label": "Deselect" }
                    ]
                }

                // Disabled State
                MeoMediaCard {
                    type: "elevated"
                    enabled: false
                    mediaSource: "https://picsum.photos/400/300?random=12"
                    aspectRatio: 16/9
                    title: "Disabled State"
                    supportingText: "Container and contents are visually dimmed and interaction is completely disabled."
                    actions: [
                        { "label": "Action", "enabled": false }
                    ]
                }
            }

            // Horizontal / Full-bleed Media position configurations
            RowLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                // Horizontal Left
                MeoMediaCard {
                    Layout.fillWidth: true
                    mediaPosition: "left"
                    type: "filled"
                    mediaSource: "https://picsum.photos/400/300?random=13"
                    aspectRatio: 4/3
                    headerTitle: "Jane Doe"
                    headerSubtitle: "Author & Photographer"
                    avatarSource: "https://api.dicebear.com/7.x/avataaars/svg?seed=Jane"
                    showOverflowButton: true
                    title: "Full-bleed Left Position"
                    supportingText: "Perfect horizontal split. The media section bleeds directly to the left edges."
                    actions: [
                        { "label": "Read Article", "type": "tonal" }
                    ]
                }

                // Horizontal Right
                MeoMediaCard {
                    Layout.fillWidth: true
                    mediaPosition: "right"
                    type: "outlined"
                    mediaSource: "https://picsum.photos/400/300?random=14"
                    aspectRatio: 4/3
                    headerTitle: "MeoDesign Team"
                    headerSubtitle: "System Updates"
                    avatarInitials: "MD"
                    showOverflowButton: true
                    title: "Full-bleed Right Position"
                    supportingText: "The media section bleeds directly to the right edges, providing a clean visual balance."
                    actions: [
                        { "label": "Dismiss" },
                        { "label": "Learn More", "type": "filled" }
                    ]
                }
            }
        }
    }
}
