import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI
import ".."

ShowcaseCategoryPage {
    id: displayPage
    categoryId: "surfaces"

    // 🌟 Size Configurations & Grid Ratios Section (大小配置与比例布局)
    ShowcaseSection {
        title: "Card Sizes & Grid Ratios (大小配置与比例布局)"
        subtitle: "MD3 containment structures presenting multi-column card layouts, precise size scales (S, M, L), and grid aspect ratios (16:9, 4:3, 1:1)."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            MeoText {
                text: "Size Scale (S, M, L Cards):"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                // Small Card
                MeoCard {
                    width: 140 * MeoTheme.globalScale
                    height: 100 * MeoTheme.globalScale
                    type: "filled"
                    Column {
                        anchors.fill: parent
                        spacing: MeoTheme.space4
                        MeoText { text: "Small Card"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: "Width: 140dp"; typeRole: "body"; typeSize: "small" }
                    }
                }

                // Medium Card
                MeoCard {
                    width: 240 * MeoTheme.globalScale
                    height: 120 * MeoTheme.globalScale
                    type: "filled"
                    Column {
                        anchors.fill: parent
                        spacing: MeoTheme.space8
                        MeoText { text: "Medium Card"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: "Standard container size with default spacing."; typeRole: "body"; typeSize: "medium" }
                    }
                }

                // Large Card
                MeoCard {
                    width: 360 * MeoTheme.globalScale
                    height: 140 * MeoTheme.globalScale
                    type: "filled"
                    Column {
                        anchors.fill: parent
                        spacing: MeoTheme.space8
                        MeoText { text: "Large Card"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: "Wider canvas. Ideal for dashboards, reports, and detailed layouts."; typeRole: "body"; typeSize: "medium" }
                    }
                }
            }

            MeoText {
                text: "Proportions & Aspect Ratios:"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                // 16:9 cinematic
                MeoCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width * (9/16)
                    type: "elevated"
                    Column {
                        anchors.fill: parent
                        spacing: MeoTheme.space4
                        MeoText { text: "16:9 Aspect Ratio"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: "Cinematic proportions"; typeRole: "body"; typeSize: "small" }
                    }
                }

                // 4:3 classic
                MeoCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width * (3/4)
                    type: "elevated"
                    Column {
                        anchors.fill: parent
                        spacing: MeoTheme.space4
                        MeoText { text: "4:3 Aspect Ratio"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: "Standard photo box"; typeRole: "body"; typeSize: "small" }
                    }
                }

                // 1:1 square
                MeoCard {
                    Layout.fillWidth: true
                    Layout.preferredHeight: width
                    type: "elevated"
                    Column {
                        anchors.fill: parent
                        spacing: MeoTheme.space4
                        MeoText { text: "1:1 Aspect Ratio"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: "Square profile container"; typeRole: "body"; typeSize: "small" }
                    }
                }
            }
        }
    }

    // 🌟 Thickness Variants Section (粗细与轮廓变体)
    ShowcaseSection {
        title: "Card Border Thickness (粗细与轮廓变体)"
        subtitle: "Demonstrating the outline card structures mapped to semantic thickness tokens of MeoTheme (`strokeWidthThin`, `strokeWidthMedium`, `strokeWidthThick`)."
        width: parent.width

        RowLayout {
            width: parent.width
            spacing: MeoTheme.space16

            // Thin border
            MeoCard {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "outlined"
                // Standard outlined card uses strokeWidthThin internally (1dp)
                Column {
                    anchors.fill: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "strokeWidthThin"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.primary }
                    MeoText { text: "Outline width: 1dp\nDelicate separation of container boundaries."; typeRole: "body"; typeSize: "small" }
                }
            }

            // Medium border
            MeoCard {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "outlined"
                radius: MeoTheme.shapeMedium
                // Customize border or represent medium thickness
                background: Item {
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.parent.radius
                        color: "transparent"
                        border.color: MeoTheme.outlineVariant
                        border.width: MeoTheme.strokeWidthMedium
                    }
                }
                Column {
                    anchors.fill: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "strokeWidthMedium"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.primary }
                    MeoText { text: "Outline width: 2dp\nIncreased visual framing and structural emphasis."; typeRole: "body"; typeSize: "small" }
                }
            }

            // Thick border
            MeoCard {
                Layout.fillWidth: true
                height: 120 * MeoTheme.globalScale
                type: "outlined"
                radius: MeoTheme.shapeMedium
                background: Item {
                    Rectangle {
                        anchors.fill: parent
                        radius: parent.parent.radius
                        color: "transparent"
                        border.color: MeoTheme.outlineVariant
                        border.width: MeoTheme.strokeWidthThick
                    }
                }
                Column {
                    anchors.fill: parent
                    spacing: MeoTheme.space4
                    MeoText { text: "strokeWidthThick"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.primary }
                    MeoText { text: "Outline width: 3dp\nBold border thickness for expressive highlighted sections."; typeRole: "body"; typeSize: "small" }
                }
            }
        }
    }

    // 🌟 Card States & Expressive Shapes Section (交互状态与异形卡片)
    ShowcaseSection {
        title: "Card States & Expressive Shapes (交互状态与异形卡片)"
        subtitle: "Visualizing the interactive states matrix (Hover, Pressed, Selected, Disabled) alongside organic expressive shapes (Squircle, Clover, Flower, Sparkle)."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space24

            MeoText {
                text: "Interactive States Matrix:"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                // Normal Interactive
                MeoCard {
                    width: 170 * MeoTheme.globalScale
                    height: 130 * MeoTheme.globalScale
                    type: "elevated"
                    interactive: true
                    Column {
                        anchors.fill: parent
                        spacing: MeoTheme.space4
                        MeoText { text: "Interactive (Normal)"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: "Hover & press feedback enabled."; typeRole: "body"; typeSize: "small" }
                    }
                }

                // Selected State
                MeoCard {
                    width: 170 * MeoTheme.globalScale
                    height: 130 * MeoTheme.globalScale
                    type: "filled"
                    interactive: true
                    selected: true
                    Column {
                        anchors.fill: parent
                        spacing: MeoTheme.space4
                        MeoText { text: "Selected State"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnPrimaryContainer }
                        MeoText { text: "Uses primaryContainer tint & bold outline."; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnPrimaryContainer }
                    }
                }

                // Bouncy Pressed State
                MeoCard {
                    width: 170 * MeoTheme.globalScale
                    height: 130 * MeoTheme.globalScale
                    type: "outlined"
                    interactive: true
                    bouncy: true
                    Column {
                        anchors.fill: parent
                        spacing: MeoTheme.space4
                        MeoText { text: "Bouncy Interactive"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: "Overshoot scale spring animations on click."; typeRole: "body"; typeSize: "small" }
                    }
                }

                // Disabled State
                MeoCard {
                    width: 170 * MeoTheme.globalScale
                    height: 130 * MeoTheme.globalScale
                    type: "elevated"
                    enabled: false
                    Column {
                        anchors.fill: parent
                        spacing: MeoTheme.space4
                        MeoText { text: "Disabled State"; typeRole: "title"; typeSize: "small"; emphasized: true }
                        MeoText { text: "Visual interaction is entirely muted."; typeRole: "body"; typeSize: "small" }
                    }
                }
            }

            MeoText {
                text: "Expressive Shapes (异形容器):"
                typeRole: "title"
                typeSize: "small"
                emphasized: true
            }

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space16

                // Squircle
                MeoCard {
                    width: 120 * MeoTheme.globalScale
                    height: 120 * MeoTheme.globalScale
                    type: "filled"
                    shape: "squircle"
                    Column {
                        anchors.centerIn: parent
                        MeoText { text: "Squircle"; typeRole: "label"; typeSize: "big"; emphasized: true; horizontalAlignment: Text.AlignHCenter }
                    }
                }

                // Clover
                MeoCard {
                    width: 120 * MeoTheme.globalScale
                    height: 120 * MeoTheme.globalScale
                    type: "filled"
                    shape: "clover"
                    Column {
                        anchors.centerIn: parent
                        MeoText { text: "Clover"; typeRole: "label"; typeSize: "big"; emphasized: true; horizontalAlignment: Text.AlignHCenter }
                    }
                }

                // Flower
                MeoCard {
                    width: 120 * MeoTheme.globalScale
                    height: 120 * MeoTheme.globalScale
                    type: "filled"
                    shape: "flower"
                    Column {
                        anchors.centerIn: parent
                        MeoText { text: "Flower"; typeRole: "label"; typeSize: "big"; emphasized: true; horizontalAlignment: Text.AlignHCenter }
                    }
                }

                // Sparkle
                MeoCard {
                    width: 120 * MeoTheme.globalScale
                    height: 120 * MeoTheme.globalScale
                    type: "filled"
                    shape: "sparkle"
                    Column {
                        anchors.centerIn: parent
                        MeoText { text: "Sparkle"; typeRole: "label"; typeSize: "big"; emphasized: true; horizontalAlignment: Text.AlignHCenter }
                    }
                }
            }
        }
    }

    // 🌟 Dialogs & Sheet Controllers Section (弹出、底部栏与侧边栏控制器)
    ShowcaseSection {
        title: "Dialogs & Sheet Controllers (弹出与抽屉控制器)"
        subtitle: "Triggers for modern M3 popup surfaces, action lists, modal bottom sheets, and supplementary side sheets."
        width: parent.width

        ColumnLayout {
            width: parent.width
            spacing: MeoTheme.space16

            Flow {
                Layout.fillWidth: true
                spacing: MeoTheme.space12

                MeoButton {
                    text: "Show Confirmation Dialog"
                    icon.name: "info"
                    type: "filled"
                    onClicked: modalDialog.open()
                }

                MeoButton {
                    text: "Show Expressive Dialog"
                    icon.name: "auto_awesome"
                    type: "tonal"
                    onClicked: modalExpressive.open()
                }

                MeoButton {
                    text: "Toggle Standard Bottom Sheet"
                    icon.name: "expand_less"
                    type: "outlined"
                    onClicked: bottomSheet.isOpen = !bottomSheet.isOpen
                }

                MeoButton {
                    text: "Open Modal Bottom Sheet"
                    icon.name: "view_day"
                    type: "outlined"
                    onClicked: modalBottomSheet.open()
                }

                MeoButton {
                    text: "Toggle Side Sheet Pane"
                    icon.name: "view_sidebar"
                    type: "outlined"
                    onClicked: sideSheet.isOpen = !sideSheet.isOpen
                }

                MeoButton {
                    text: "Show Action Sheet"
                    icon.name: "share"
                    type: "outlined"
                    onClicked: actionSheet.open()
                }
            }

            // Embedded Containers representing the open sheets / interactive areas
            RowLayout {
                Layout.fillWidth: true
                height: 240 * MeoTheme.globalScale
                spacing: MeoTheme.space16

                // Embedded Standard Bottom Sheet container area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: MeoTheme.surfaceContainerLow
                    radius: MeoTheme.shapeLarge
                    clip: true

                    MeoText {
                        anchors.top: parent.top
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.topMargin: MeoTheme.space16
                        text: "Standard Bottom Sheet Space"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                    }

                    MeoStandardBottomSheet {
                        id: bottomSheet
                        anchors.fill: parent
                        isOpen: false
                        content: Component {
                            Column {
                                anchors.fill: parent
                                anchors.margins: MeoTheme.space16
                                spacing: MeoTheme.space8
                                MeoText { text: "Standard Bottom Sheet Content"; typeRole: "title"; typeSize: "small"; emphasized: true }
                                MeoText { text: "This sheet remains docked within its container and doesn't block background clicks."; typeRole: "body"; typeSize: "medium" }
                            }
                        }
                    }
                }

                // Embedded Side Sheet container area
                Rectangle {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    color: MeoTheme.surfaceContainerLow
                    radius: MeoTheme.shapeLarge
                    clip: true

                    MeoText {
                        anchors.centerIn: parent
                        text: "Supplementary Side Sheet Space"
                        typeRole: "title"
                        typeSize: "small"
                        emphasized: true
                        horizontalAlignment: Text.AlignHCenter
                    }

                    MeoSideSheet {
                        id: sideSheet
                        anchors.right: parent.right
                        height: parent.height
                        width: 160 * MeoTheme.globalScale
                        isOpen: false
                        content: Component {
                            Column {
                                anchors.fill: parent
                                anchors.margins: MeoTheme.space12
                                spacing: MeoTheme.space8
                                MeoText { text: "Details Pane"; typeRole: "title"; typeSize: "small"; emphasized: true }
                                MeoText { text: "Supplemental information.", typeRole: "body", typeSize: "small" }
                            }
                        }
                    }
                }
            }
        }
    }

    // Modal dialogs and other popup targets defined at the bottom level of page scope
    MeoDialog {
        id: modalDialog
        title: "Delete Account?"
        message: "This operation is permanent and all user configurations will be completely discarded. Are you sure you want to proceed?"
        confirmText: "Discard"
        cancelText: "Cancel"
    }

    MeoExpressiveDialog {
        id: modalExpressive
        title: "Expressive Customization"
        message: "This expressive popup can host any QML component inside its scrollable content area."
        icon: "palette"
        confirmText: "Save"
        cancelText: "Cancel"
        content: Component {
            Column {
                spacing: MeoTheme.space12
                MeoText { text: "Custom Interactive Controls:"; typeRole: "label"; typeSize: "medium"; emphasized: true }
                Row {
                    spacing: MeoTheme.space8
                    MeoChip { label: "Performance"; selected: true }
                    MeoChip { label: "Battery Saver" }
                }
            }
        }
    }

    MeoBottomSheet {
        id: modalBottomSheet
        content: Component {
            Column {
                spacing: MeoTheme.space12
                MeoText { text: "Modal Task Actions"; typeRole: "title"; typeSize: "medium"; emphasized: true }
                MeoText { text: "Modal sheets are highly interactive, dim background content with scrims, and intercept user actions."; typeRole: "body"; typeSize: "medium" }
                Row {
                    spacing: MeoTheme.space8
                    MeoButton { text: "Save Preferences"; type: "filled" }
                    MeoButton { text: "Close"; type: "text"; onClicked: modalBottomSheet.close() }
                }
            }
        }
    }

    MeoActionSheet {
        id: actionSheet
        title: "Share Resource"
        model: [
            { label: "Copy Secret Link", icon: "content_copy" },
            { label: "Share to Email", icon: "mail" },
            { label: "Post on Feed", icon: "share" }
        ]
    }
}
