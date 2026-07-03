import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Flickable {
    contentHeight: displayColumn.implicitHeight + 40 * MeoTheme.globalScale
    contentWidth: parent.width
    clip: true

    ColumnLayout {
        id: displayColumn
        anchors.fill: parent
        anchors.margins: 24 * MeoTheme.globalScale
        spacing: 24 * MeoTheme.globalScale

        MeoText {
            text: "MD3 Cards Showcase (20+ Examples)"
            typeRole: "title"
            typeSize: "big"
            emphasized: true
            color: MeoTheme.contentOnSurface
        }

        MeoText {
            text: "Adaptive layout using Flow for dynamic resizing."
            typeRole: "body"
            typeSize: "medium"
            color: MeoTheme.contentOnSurfaceVariant
        }

        MeoText {
            text: "MD3 Expressive Emphasized Typography"
            typeRole: "title"
            typeSize: "medium"
            emphasized: true
            color: MeoTheme.primary
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12 * MeoTheme.globalScale

            Text {
                text: "Display Large Emphasized"
                font.pixelSize: MeoTheme.displayLargeEmphasized.size * MeoTheme.globalScale
                font.weight: MeoTheme.displayLargeEmphasized.weight
                color: MeoTheme.contentOnSurface
            }
            Text {
                text: "Headline Medium Emphasized"
                font.pixelSize: MeoTheme.headlineMediumEmphasized.size * MeoTheme.globalScale
                font.weight: MeoTheme.headlineMediumEmphasized.weight
                color: MeoTheme.contentOnSurface
            }
            Text {
                text: "Body Large Emphasized (Prominent)"
                font.pixelSize: MeoTheme.bodyLargeEmphasized.size * MeoTheme.globalScale
                font.weight: MeoTheme.bodyLargeEmphasized.weight
                color: MeoTheme.contentOnSurface
            }
        }

        MeoText {
            text: "MD3 Toolbars (Expressive)"
            typeRole: "title"
            typeSize: "medium"
            emphasized: true
            color: MeoTheme.primary
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16 * MeoTheme.globalScale

            MeoText { text: "Docked Toolbar (Full Width)"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
            MeoDockedToolbar {
                Layout.fillWidth: true
                actions: [
                    Component { MeoIconButton { icon.name: "menu" } },
                    Component { MeoIconButton { icon.name: "search" } },
                    Component { MeoIconButton { icon.name: "favorite" } },
                    Component { MeoIconButton { icon.name: "more_vert" } }
                ]
            }

            MeoText { text: "Floating Toolbar (Horizontal)"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
            MeoFloatingToolbar {
                Layout.alignment: Qt.AlignHCenter
                actions: [
                    Component { MeoIconButton { icon.name: "edit" } },
                    Component { MeoIconButton { icon.name: "content_copy" } },
                    Component { MeoIconButton { icon.name: "delete" } }
                ]
            }
        }

        MeoText {
            text: "MD3 Cards & Containers"
            typeRole: "title"
            typeSize: "medium"
            emphasized: true
            color: MeoTheme.primary
        }

        Flow {
            Layout.fillWidth: true
            spacing: 24 * MeoTheme.globalScale

            // 1. Basic Elevated Card
            MeoCard {
                type: "elevated"
                width: 300 * MeoTheme.globalScale; height: 120 * MeoTheme.globalScale
                ColumnLayout {
                    anchors.fill: parent
                    MeoText { text: "1. Basic Elevated"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoText { text: "Standard elevated card."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }

            // 2. Basic Filled Card
            MeoCard {
                type: "filled"
                width: 300 * MeoTheme.globalScale; height: 120 * MeoTheme.globalScale
                ColumnLayout {
                    anchors.fill: parent
                    MeoText { text: "2. Basic Filled"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoText { text: "Standard filled card."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }

            // 3. Basic Outlined Card
            MeoCard {
                type: "outlined"
                width: 300 * MeoTheme.globalScale; height: 120 * MeoTheme.globalScale
                ColumnLayout {
                    anchors.fill: parent
                    MeoText { text: "3. Basic Outlined"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoText { text: "Standard outlined card."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                }
            }

            // 4. Action Card (Elevated)
            MeoCard {
                type: "elevated"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol4.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol4
                    anchors.fill: parent
                    MeoText { text: "4. Action Card"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoText { text: "Card with primary and secondary actions."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        MeoButton { text: "Cancel"; type: "text" }
                        MeoButton { text: "Confirm"; type: "filled" }
                    }
                }
            }

            // 5. Action Card (Outlined)
            MeoCard {
                type: "outlined"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol5.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol5
                    anchors.fill: parent
                    MeoText { text: "5. Outlined Action"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoText { text: "Actions inside outlined card."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                    RowLayout {
                        Layout.alignment: Qt.AlignRight
                        MeoButton { text: "Decline"; type: "outlined" }
                        MeoButton { text: "Accept"; type: "filled" }
                    }
                }
            }

            // 6. Media Card (Color Placeholder)
            MeoCard {
                type: "elevated"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol6.implicitHeight
                padding: 0
                ColumnLayout {
                    id: contentCol6
                    anchors.fill: parent
                    spacing: 0
                    Rectangle {
                        Layout.fillWidth: true
                        height: 120 * MeoTheme.globalScale
                        color: MeoTheme.primaryContainer
                        radius: 12 * MeoTheme.globalScale // Match card radius
                        Rectangle { anchors.bottom: parent.bottom; width: parent.width; height: 12 * MeoTheme.globalScale; color: MeoTheme.primaryContainer } // Square bottom
                    }
                    ColumnLayout {
                        Layout.margins: 16 * MeoTheme.globalScale
                        MeoText { text: "6. Media Card"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                        MeoText { text: "Card with full-width media."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                    }
                }
            }

            // 7. Toggle Card (Switch)
            MeoCard {
                type: "filled"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentRow7.implicitHeight + 32 * MeoTheme.globalScale
                RowLayout {
                    id: contentRow7
                    anchors.fill: parent
                    ColumnLayout {
                        Layout.fillWidth: true
                        MeoText { text: "7. Notifications"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                        MeoText { text: "Allow push notifications"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                    }
                    MeoSwitch { checked: true }
                }
            }

            // 8. Checkbox Selection Card
            MeoCard {
                type: "outlined"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol8.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol8
                    anchors.fill: parent
                    MeoText { text: "8. Select Options"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoCheckbox { label: "Option A"; checked: true }
                    MeoCheckbox { label: "Option B" }
                    MeoCheckbox { label: "Option C" }
                }
            }

            // 9. Radio Button Group Card
            MeoCard {
                type: "elevated"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol9.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol9
                    anchors.fill: parent
                    MeoText { text: "9. Power Mode"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoRadioButton { label: "Performance"; checked: true }
                    MeoRadioButton { label: "Balanced" }
                    MeoRadioButton { label: "Power Saver" }
                }
            }

            // 10. Slider Settings Card
            MeoCard {
                type: "filled"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol10.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol10
                    anchors.fill: parent
                    MeoText { text: "10. Brightness"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoSlider { Layout.fillWidth: true; value: 0.7 }
                }
            }

            // 11. Form Input Card
            MeoCard {
                type: "elevated"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol11.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol11
                    anchors.fill: parent
                    MeoText { text: "11. User Info"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoTextField { Layout.fillWidth: true; placeholderText: "Username" }
                    MeoTextField { Layout.fillWidth: true; placeholderText: "Email" }
                }
            }

            // 12. List Items Card
            MeoCard {
                type: "outlined"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol12.implicitHeight + 32 * MeoTheme.globalScale
                padding: 0
                ColumnLayout {
                    id: contentCol12
                    anchors.fill: parent
                    spacing: 0
                    MeoListItem { headline: "12. List Item 1"; supportingText: "Details here" }
                    MeoDivider { Layout.fillWidth: true }
                    MeoListItem { headline: "List Item 2"; supportingText: "More details" }
                }
            }

            // 13. Chips Container Card
            MeoCard {
                type: "filled"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol13.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol13
                    anchors.fill: parent
                    MeoText { text: "13. Categories"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    Flow {
                        Layout.fillWidth: true
                        spacing: 8 * MeoTheme.globalScale
                        MeoFilterChip { label: "Design"; selected: true }
                        MeoFilterChip { label: "Code" }
                        MeoFilterChip { label: "Music" }
                    }
                }
            }

            // 14. Icon Buttons Action Card
            MeoCard {
                type: "elevated"
                width: 300 * MeoTheme.globalScale; height: 120 * MeoTheme.globalScale
                RowLayout {
                    anchors.fill: parent
                    ColumnLayout {
                        Layout.fillWidth: true
                        MeoText { text: "14. Media Control"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                        MeoText { text: "Now playing..."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                    }
                    MeoIconButton { icon.name: "play_arrow"; type: "filled" }
                }
            }

            // 15. Text Area Card
            MeoCard {
                type: "outlined"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol15.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol15
                    anchors.fill: parent
                    MeoText { text: "15. Feedback"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoTextArea { Layout.fillWidth: true; placeholderText: "Enter your thoughts..."; height: 80 * MeoTheme.globalScale }
                    MeoButton { Layout.alignment: Qt.AlignRight; text: "Submit" }
                }
            }

            // 16. Small Info Card
            MeoCard {
                type: "filled"
                width: 140 * MeoTheme.globalScale; height: 140 * MeoTheme.globalScale
                ColumnLayout {
                    anchors.fill: parent
                    MeoIcon { icon: "analytics"; color: MeoTheme.primary; size: 32 * MeoTheme.globalScale }
                    MeoText { text: "16. Stats"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoText { text: "+12.5%"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.primary }
                }
            }

            // 17. Horizontal Layout Card
            MeoCard {
                type: "elevated"
                width: 300 * MeoTheme.globalScale; height: 120 * MeoTheme.globalScale
                RowLayout {
                    anchors.fill: parent
                    Rectangle {
                        width: 80 * MeoTheme.globalScale; height: 80 * MeoTheme.globalScale
                        radius: 8 * MeoTheme.globalScale
                        color: MeoTheme.secondaryContainer
                    }
                    ColumnLayout {
                        Layout.fillWidth: true
                        MeoText { text: "17. Album Art"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                        MeoText { text: "Artist Name"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                    }
                }
            }

            // 18. Complex Mixed Card
            MeoCard {
                type: "outlined"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol18.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol18
                    anchors.fill: parent
                    RowLayout {
                        Layout.fillWidth: true
                        MeoText { text: "18. Complex"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface; Layout.fillWidth: true }
                        MeoIconButton { icon.name: "more_vert" }
                    }
                    MeoDivider { Layout.fillWidth: true }
                    MeoText { text: "Content goes here. It can span multiple lines."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                    RowLayout {
                        MeoFilterChip { label: "Tag" }
                        Item { Layout.fillWidth: true }
                        MeoButton { text: "Action"; type: "tonal" }
                    }
                }
            }

            // 19. Progress Card
            MeoCard {
                type: "filled"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol19.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol19
                    anchors.fill: parent
                    MeoText { text: "19. Downloading..."; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                    MeoProgressBar { Layout.fillWidth: true; value: 0.4 }
                    MeoText { text: "40% Complete"; typeRole: "label"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; Layout.alignment: Qt.AlignRight }
                }
            }

            // 20. Badge Card
            MeoCard {
                type: "elevated"
                width: 300 * MeoTheme.globalScale; height: 120 * MeoTheme.globalScale
                RowLayout {
                    anchors.fill: parent
                    ColumnLayout {
                        Layout.fillWidth: true
                        MeoText { text: "20. Messages"; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
                        MeoText { text: "You have unread items."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant }
                    }
                    Item {
                        width: 48 * MeoTheme.globalScale; height: 48 * MeoTheme.globalScale
                        MeoIcon { anchors.centerIn: parent; icon: "mail"; size: 24 * MeoTheme.globalScale; color: MeoTheme.contentOnSurfaceVariant }
                        MeoBadge { text: "3" }
                    }
                }
            }
        }
    }
}
