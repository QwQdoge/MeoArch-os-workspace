import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: feedbackPage
    categoryId: "feedback"

    // 🌟 Progress Indicators (进度条的大小、粗细与波浪状态)
    ShowcaseSection {
        title: "Progress Indicators (进度条的大、小、粗、细与波形)"
        subtitle: "MD3 linear and circular progress bars illustrating various thickness variants, size scales, wavy state modulations, and vibrant gradient themes."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            // Linear Progress Section
            ColumnLayout {
                spacing: MeoTheme.space8
                Layout.fillWidth: true

                MeoText {
                    text: "Linear Progress Variants:"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                // Standard thin linear progress
                RowLayout {
                    spacing: MeoTheme.space12
                    MeoText { text: "Thin Standard (determinate 40%)"; typeRole: "body"; typeSize: "small"; Layout.preferredWidth: 220 * MeoTheme.globalScale }
                    MeoProgressBar { Layout.fillWidth: true; value: 0.40 }
                }

                // Thick vibrant gradient linear progress
                RowLayout {
                    spacing: MeoTheme.space12
                    MeoText { text: "Thick Vibrant (determinate 80%)"; typeRole: "body"; typeSize: "small"; Layout.preferredWidth: 220 * MeoTheme.globalScale }
                    MeoProgressBar { Layout.fillWidth: true; value: 0.80; isThick: true; vibrant: true }
                }

                // Wavy linear progress (determinate)
                RowLayout {
                    spacing: MeoTheme.space12
                    MeoText { text: "Wavy Determinate (75%)"; typeRole: "body"; typeSize: "small"; Layout.preferredWidth: 220 * MeoTheme.globalScale }
                    MeoProgressBar { Layout.fillWidth: true; value: 0.75; type: "linear"; wavy: true; isThick: true }
                }

                // Wavy linear progress (indeterminate)
                RowLayout {
                    spacing: MeoTheme.space12
                    MeoText { text: "Wavy Indeterminate"; typeRole: "body"; typeSize: "small"; Layout.preferredWidth: 220 * MeoTheme.globalScale }
                    MeoProgressBar { Layout.fillWidth: true; indeterminate: true; type: "linear"; wavy: true; isThick: true; vibrant: true }
                }
            }

            // Circular Progress Section
            ColumnLayout {
                spacing: MeoTheme.space12
                Layout.fillWidth: true

                MeoText {
                    text: "Circular Progress Scales & Thicknesses:"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: MeoTheme.space24

                    // XS Circular
                    Column {
                        spacing: MeoTheme.space4
                        MeoProgressBar {
                            type: "circular"
                            value: 0.33
                            width: 24 * MeoTheme.globalScale
                            height: 24 * MeoTheme.globalScale
                        }
                        MeoText { text: "XS Size"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                    }

                    // S Circular
                    Column {
                        spacing: MeoTheme.space4
                        MeoProgressBar {
                            type: "circular"
                            value: 0.50
                            width: 32 * MeoTheme.globalScale
                            height: 32 * MeoTheme.globalScale
                        }
                        MeoText { text: "S Size"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                    }

                    // M Circular Standard
                    Column {
                        spacing: MeoTheme.space4
                        MeoProgressBar {
                            type: "circular"
                            value: 0.70
                            width: 48 * MeoTheme.globalScale
                            height: 48 * MeoTheme.globalScale
                        }
                        MeoText { text: "M Size"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                    }

                    // L Circular Thick Indeterminate
                    Column {
                        spacing: MeoTheme.space4
                        MeoProgressBar {
                            type: "circular"
                            indeterminate: true
                            isThick: true
                            width: 64 * MeoTheme.globalScale
                            height: 64 * MeoTheme.globalScale
                        }
                        MeoText { text: "L Thick Indet."; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                    }

                    // XL Circular Thick Vibrant
                    Column {
                        spacing: MeoTheme.space4
                        MeoProgressBar {
                            type: "circular"
                            value: 0.90
                            isThick: true
                            vibrant: true
                            activeColor: MeoTheme.tertiary
                            width: 80 * MeoTheme.globalScale
                            height: 80 * MeoTheme.globalScale
                        }
                        MeoText { text: "XL Thick Vibr."; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                    }
                }
            }
        }
    }

    // 🌟 Morphing Loading Indicators (有机形变加载指示器)
    ShowcaseSection {
        title: "Morphing Loading Indicators (有机形变加载指示器)"
        subtitle: "Expressive loading blobs transitioning smoothly between organic multipoint shapes (Circle, Squircle, Sparkle, Heart) in 5-step sizes (XS to XL) and vibrant color palettes."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            MeoText {
                text: "Loading Sizes (XS to XL):"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space24

                // XS Morphing
                Column {
                    spacing: MeoTheme.space8
                    anchors.bottom: parent.bottom
                    MeoLoadingIndicator { size: "xs"; running: true }
                    MeoText { text: "XS (24dp)"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; horizontalAlignment: Text.AlignHCenter; width: 60 * MeoTheme.globalScale }
                }

                // S Morphing
                Column {
                    spacing: MeoTheme.space8
                    anchors.bottom: parent.bottom
                    MeoLoadingIndicator { size: "s"; running: true }
                    MeoText { text: "S (32dp)"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; horizontalAlignment: Text.AlignHCenter; width: 60 * MeoTheme.globalScale }
                }

                // M Morphing
                Column {
                    spacing: MeoTheme.space8
                    anchors.bottom: parent.bottom
                    MeoLoadingIndicator { size: "m"; running: true }
                    MeoText { text: "M (40dp)"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; horizontalAlignment: Text.AlignHCenter; width: 60 * MeoTheme.globalScale }
                }

                // L Morphing with Container
                Column {
                    spacing: MeoTheme.space8
                    anchors.bottom: parent.bottom
                    MeoLoadingIndicator { size: "l"; running: true; withContainer: true }
                    MeoText { text: "L Cont."; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; horizontalAlignment: Text.AlignHCenter; width: 60 * MeoTheme.globalScale }
                }

                // XL Morphing Vibrant
                Column {
                    spacing: MeoTheme.space8
                    anchors.bottom: parent.bottom
                    MeoLoadingIndicator { size: "xl"; running: true; vibrant: true }
                    MeoText { text: "XL Vibrant"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; horizontalAlignment: Text.AlignHCenter; width: 60 * MeoTheme.globalScale }
                }
            }

            MeoText {
                text: "Determinate Morphing Shapes Gallery:"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space24

                // Determinate Shape 1: Circle
                Column {
                    spacing: MeoTheme.space4
                    MeoLoadingIndicator { size: "l"; indeterminate: false; value: 0.0 }
                    MeoText { text: "Circle (0.0)"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }

                // Determinate Shape 2: Intermediate Morph
                Column {
                    spacing: MeoTheme.space4
                    MeoLoadingIndicator { size: "l"; indeterminate: false; value: 2.0; color: MeoTheme.tertiary }
                    MeoText { text: "Squircle (2.0)"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }

                // Determinate Shape 3: High-point lobed Sparkle
                Column {
                    spacing: MeoTheme.space4
                    MeoLoadingIndicator { size: "l"; indeterminate: false; value: 4.0; color: MeoTheme.success }
                    MeoText { text: "Sparkle (4.0)"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }

                // Determinate Shape 4: Maximum Lobe Morph
                Column {
                    spacing: MeoTheme.space4
                    MeoLoadingIndicator { size: "l"; indeterminate: false; value: 7.0; vibrant: true }
                    MeoText { text: "Lobe Max (7.0)"; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }
        }
    }

    // 🌟 Banners & Toaster Snackbars (横幅与提示框交互)
    ShowcaseSection {
        title: "Banners & Snackbars (横幅、气泡与提示框)"
        subtitle: "Persistent contextual headers and short-lived notification snackbars displaying quick actions and status states."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            RowLayout {
                spacing: MeoTheme.space16
                Layout.fillWidth: true

                MeoButton {
                    text: "Trigger Info Snackbar"
                    icon.name: "info"
                    type: "filled"
                    onClicked: {
                        snackbar.message = "System state saved successfully."
                        snackbar.actionText = "Undo"
                        snackbar.open()
                    }
                }

                MeoButton {
                    text: "Trigger Destructive Alert"
                    icon.name: "warning"
                    type: "tonal"
                    onClicked: {
                        snackbar.message = "Critical: High database memory usage!"
                        snackbar.actionText = "Clear Cache"
                        snackbar.open()
                    }
                }
            }

            // Inline Banner Previews
            ColumnLayout {
                spacing: MeoTheme.space12
                Layout.fillWidth: true

                MeoText {
                    text: "Inline Banner Configurations:"
                    typeRole: "title"
                    typeSize: "small"
                    emphasized: true
                }

                // Standard Banner
                MeoBanner {
                    Layout.fillWidth: true
                    text: "Your workspace subscription is expiring in 3 days. Please update billing preferences."
                    icon: "credit_card"
                    confirmText: "Renew"
                    cancelText: "Dismiss"
                }

                // Critical/Error Alert Banner
                MeoBanner {
                    Layout.fillWidth: true
                    text: "No internet connection detected. Offline sync will run when network becomes active."
                    icon: "wifi_off"
                    confirmText: "Reconnect"
                    cancelText: "Dismiss"
                    activeColor: MeoTheme.error
                }
            }
        }
    }

    // Background notifications snackbar
    MeoSnackbar {
        id: snackbar
        message: "Operation completed."
        actionText: "Undo"
    }
}
