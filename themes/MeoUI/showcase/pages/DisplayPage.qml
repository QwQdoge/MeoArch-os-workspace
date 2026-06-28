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

        Text {
            text: "MD3 Cards Showcase (20+ Examples)"
            font.pixelSize: 24 * MeoTheme.globalScale
            font.bold: true
            color: MeoTheme.onSurface
        }

        Text {
            text: "Adaptive layout using Flow for dynamic resizing."
            font.pixelSize: 14 * MeoTheme.globalScale
            color: MeoTheme.onSurfaceVariant
        }

        Text {
            text: "MD3 Expressive Emphasized Typography"
            font.pixelSize: 20 * MeoTheme.globalScale
            font.bold: true
            color: MeoTheme.primary
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 12 * MeoTheme.globalScale

            Text {
                text: "Display Large Emphasized"
                font.pixelSize: MeoTheme.displayLargeEmphasized.size * MeoTheme.globalScale
                font.weight: MeoTheme.displayLargeEmphasized.weight
                color: MeoTheme.onSurface
            }
            Text {
                text: "Headline Medium Emphasized"
                font.pixelSize: MeoTheme.headlineMediumEmphasized.size * MeoTheme.globalScale
                font.weight: MeoTheme.headlineMediumEmphasized.weight
                color: MeoTheme.onSurface
            }
            Text {
                text: "Body Large Emphasized (Prominent)"
                font.pixelSize: MeoTheme.bodyLargeEmphasized.size * MeoTheme.globalScale
                font.weight: MeoTheme.bodyLargeEmphasized.weight
                color: MeoTheme.onSurface
            }
        }

        Text {
            text: "MD3 Toolbars (Expressive)"
            font.pixelSize: 20 * MeoTheme.globalScale
            font.bold: true
            color: MeoTheme.primary
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 16 * MeoTheme.globalScale

            Text { text: "Docked Toolbar (Full Width)"; font.pixelSize: 14 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
            MeoDockedToolbar {
                Layout.fillWidth: true
                actions: [
                    Component { MeoIconButton { icon.name: "menu" } },
                    Component { MeoIconButton { icon.name: "search" } },
                    Component { MeoIconButton { icon.name: "favorite" } },
                    Component { MeoIconButton { icon.name: "more_vert" } }
                ]
            }

            Text { text: "Floating Toolbar (Horizontal)"; font.pixelSize: 14 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
            MeoFloatingToolbar {
                Layout.alignment: Qt.AlignHCenter
                actions: [
                    Component { MeoIconButton { icon.name: "edit" } },
                    Component { MeoIconButton { icon.name: "content_copy" } },
                    Component { MeoIconButton { icon.name: "delete" } }
                ]
            }
        }

        Text {
            text: "MD3 Cards & Containers"
            font.pixelSize: 20 * MeoTheme.globalScale
            font.bold: true
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
                    Text { text: "1. Basic Elevated"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    Text { text: "Standard elevated card."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
                }
            }

            // 2. Basic Filled Card
            MeoCard {
                type: "filled"
                width: 300 * MeoTheme.globalScale; height: 120 * MeoTheme.globalScale
                ColumnLayout {
                    anchors.fill: parent
                    Text { text: "2. Basic Filled"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    Text { text: "Standard filled card."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
                }
            }

            // 3. Basic Outlined Card
            MeoCard {
                type: "outlined"
                width: 300 * MeoTheme.globalScale; height: 120 * MeoTheme.globalScale
                ColumnLayout {
                    anchors.fill: parent
                    Text { text: "3. Basic Outlined"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    Text { text: "Standard outlined card."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
                }
            }

            // 4. Action Card (Elevated)
            MeoCard {
                type: "elevated"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol4.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol4
                    anchors.fill: parent
                    Text { text: "4. Action Card"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    Text { text: "Card with primary and secondary actions."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale; Layout.fillWidth: true; wrapMode: Text.WordWrap }
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
                    Text { text: "5. Outlined Action"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    Text { text: "Actions inside outlined card."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale; Layout.fillWidth: true; wrapMode: Text.WordWrap }
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
                        Text { text: "6. Media Card"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                        Text { text: "Card with full-width media."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
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
                        Text { text: "7. Notifications"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                        Text { text: "Allow push notifications"; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
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
                    Text { text: "8. Select Options"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    MeoCheckbox { text: "Option A"; checked: true }
                    MeoCheckbox { text: "Option B" }
                    MeoCheckbox { text: "Option C" }
                }
            }

            // 9. Radio Button Group Card
            MeoCard {
                type: "elevated"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol9.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol9
                    anchors.fill: parent
                    Text { text: "9. Power Mode"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    MeoRadioButton { text: "Performance"; checked: true }
                    MeoRadioButton { text: "Balanced" }
                    MeoRadioButton { text: "Power Saver" }
                }
            }

            // 10. Slider Settings Card
            MeoCard {
                type: "filled"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol10.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol10
                    anchors.fill: parent
                    Text { text: "10. Brightness"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
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
                    Text { text: "11. User Info"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
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
                    MeoListItem { text: "12. List Item 1"; secondaryText: "Details here" }
                    MeoDivider { Layout.fillWidth: true }
                    MeoListItem { text: "List Item 2"; secondaryText: "More details" }
                }
            }

            // 13. Chips Container Card
            MeoCard {
                type: "filled"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol13.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol13
                    anchors.fill: parent
                    Text { text: "13. Categories"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    Flow {
                        Layout.fillWidth: true
                        spacing: 8 * MeoTheme.globalScale
                        MeoFilterChip { text: "Design"; selected: true }
                        MeoFilterChip { text: "Code" }
                        MeoFilterChip { text: "Music" }
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
                        Text { text: "14. Media Control"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                        Text { text: "Now playing..."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
                    }
                    MeoIconButton { icon: "play_arrow"; type: "filled" }
                }
            }

            // 15. Text Area Card
            MeoCard {
                type: "outlined"
                width: 300 * MeoTheme.globalScale; implicitHeight: contentCol15.implicitHeight + 32 * MeoTheme.globalScale
                ColumnLayout {
                    id: contentCol15
                    anchors.fill: parent
                    Text { text: "15. Feedback"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
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
                    Text { text: "16. Stats"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    Text { text: "+12.5%"; color: MeoTheme.primary; font.pixelSize: 14 * MeoTheme.globalScale }
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
                        Text { text: "17. Album Art"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                        Text { text: "Artist Name"; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
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
                        Text { text: "18. Complex"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale; Layout.fillWidth: true }
                        MeoIconButton { icon: "more_vert" }
                    }
                    MeoDivider { Layout.fillWidth: true }
                    Text { text: "Content goes here. It can span multiple lines."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                    RowLayout {
                        MeoFilterChip { text: "Tag" }
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
                    Text { text: "19. Downloading..."; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                    MeoProgressBar { Layout.fillWidth: true; value: 0.4 }
                    Text { text: "40% Complete"; color: MeoTheme.onSurfaceVariant; font.pixelSize: 12 * MeoTheme.globalScale; Layout.alignment: Qt.AlignRight }
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
                        Text { text: "20. Messages"; font.bold: true; color: MeoTheme.onSurface; font.pixelSize: 16 * MeoTheme.globalScale }
                        Text { text: "You have unread items."; color: MeoTheme.onSurfaceVariant; font.pixelSize: 14 * MeoTheme.globalScale }
                    }
                    Item {
                        width: 48 * MeoTheme.globalScale; height: 48 * MeoTheme.globalScale
                        MeoIcon { anchors.centerIn: parent; icon: "mail"; size: 24 * MeoTheme.globalScale; color: MeoTheme.onSurfaceVariant }
                        MeoBadge { count: 3 }
                    }
                }
            }
        }
    }
}
