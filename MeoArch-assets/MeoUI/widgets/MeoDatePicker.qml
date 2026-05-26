import QtQuick
import QtQuick.Controls
import MeoUI

MeoCard {
    id: control
    type: "elevated"
    padding: 0

    // 🌟 核心属性
    property date selectedDate: new Date()
    property date displayDate: new Date()

    // 🌟 作用域与主题安全防御
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 328 * themeGlobalScale
    implicitHeight: 460 * themeGlobalScale

    Column {
        anchors.fill: parent
        anchors.margins: 12 * control.themeGlobalScale
        spacing: 12 * control.themeGlobalScale

        // Header: Month Selection
        Row {
            width: parent.width
            height: 48 * control.themeGlobalScale

            Text {
                text: Qt.formatDate(control.displayDate, "MMMM yyyy")
                font.pixelSize: 14 * control.themeGlobalScale
                font.weight: Font.Medium
                color: control.themeOnSurfaceVariant
                anchors.verticalCenter: parent.verticalCenter
                anchors.left: parent.left
                anchors.leftMargin: 12 * control.themeGlobalScale
            }

            Row {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter

                MeoButton {
                    text: "<"
                    type: "text"
                    onClicked: {
                        let d = new Date(control.displayDate)
                        d.setMonth(d.getMonth() - 1)
                        control.displayDate = d
                    }
                }
                MeoButton {
                    text: ">"
                    type: "text"
                    onClicked: {
                        let d = new Date(control.displayDate)
                        d.setMonth(d.getMonth() + 1)
                        control.displayDate = d
                    }
                }
            }
        }

        // Weekday Labels
        Row {
            width: parent.width
            Repeater {
                model: ["S", "M", "T", "W", "T", "F", "S"]
                delegate: Text {
                    width: (parent.width) / 7
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                    font.pixelSize: 12 * control.themeGlobalScale
                    color: control.themeOnSurfaceVariant
                }
            }
        }

        // Days Grid
        Grid {
            id: daysGrid
            columns: 7
            width: parent.width

            Repeater {
                model: 42 // 6 weeks
                delegate: Item {
                    width: daysGrid.width / 7
                    height: width

                    readonly property var dateInfo: getDateForIndex(index)
                    readonly property bool isSelected: isSameDate(dateInfo.date, control.selectedDate)
                    readonly property bool isCurrentMonth: dateInfo.date.getMonth() === control.displayDate.getMonth()

                    Rectangle {
                        anchors.centerIn: parent
                        width: 32 * control.themeGlobalScale
                        height: 32 * control.themeGlobalScale
                        radius: 16 * control.themeGlobalScale
                        color: isSelected ? control.themePrimary : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: dateInfo.day
                            font.pixelSize: 12 * control.themeGlobalScale
                            color: isSelected ? control.themeOnPrimary : (isCurrentMonth ? control.themeOnSurface : control.themeOnSurfaceVariant)
                            opacity: isCurrentMonth ? 1.0 : 0.4
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            control.selectedDate = dateInfo.date
                            if (!isCurrentMonth) control.displayDate = dateInfo.date
                        }
                    }
                }
            }
        }
    }

    function getDateForIndex(index) {
        let firstDayOfMonth = new Date(control.displayDate.getFullYear(), control.displayDate.getMonth(), 1)
        let startOffset = firstDayOfMonth.getDay()
        let targetDate = new Date(firstDayOfMonth)
        targetDate.setDate(1 - startOffset + index)
        return {
            day: targetDate.getDate(),
            date: targetDate
        }
    }

    function isSameDate(d1, d2) {
        return d1.getFullYear() === d2.getFullYear() &&
               d1.getMonth() === d2.getMonth() &&
               d1.getDate() === d2.getDate()
    }
}
