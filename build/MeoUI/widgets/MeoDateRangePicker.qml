import QtQuick
import QtQuick.Controls
import MeoUI

MeoCard {
    id: control
    type: "elevated"
    padding: 0

    // 🌟 核心属性
    property date startDate: new Date(0) // Default to invalid/epoch
    property date endDate: new Date(0)
    property date displayDate: new Date()

    readonly property bool hasStartDate: startDate.getTime() > 0
    readonly property bool hasEndDate: endDate.getTime() > 0

    // 🌟 作用域与主题安全防御
    readonly property color themePrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primary !== 'undefined') ? MeoTheme.primary : "#6750A4"
    readonly property color themeOnPrimary: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimary !== 'undefined') ? MeoTheme.onPrimary : "#FFFFFF"
    readonly property color themePrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.primaryContainer !== 'undefined') ? MeoTheme.primaryContainer : "#EADDFF"
    readonly property color themeOnPrimaryContainer: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onPrimaryContainer !== 'undefined') ? MeoTheme.onPrimaryContainer : "#21005D"
    readonly property color themeOnSurface: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurface !== 'undefined') ? MeoTheme.onSurface : "#1C1B1F"
    readonly property color themeOnSurfaceVariant: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.onSurfaceVariant !== 'undefined') ? MeoTheme.onSurfaceVariant : "#49454F"
    readonly property real themeGlobalScale: (typeof MeoTheme !== 'undefined' && typeof MeoTheme.globalScale !== 'undefined') ? MeoTheme.globalScale : 1.0

    implicitWidth: 328 * themeGlobalScale
    implicitHeight: 520 * themeGlobalScale

    Column {
        anchors.fill: parent
        anchors.margins: 12 * control.themeGlobalScale
        spacing: 12 * control.themeGlobalScale

        // Header: Selection Summary
        Column {
            width: parent.width
            height: 84 * control.themeGlobalScale
            spacing: 4 * control.themeGlobalScale
            padding: 12 * control.themeGlobalScale

            Text {
                text: "Select range"
                font.pixelSize: 12 * control.themeGlobalScale
                font.weight: Font.Medium
                color: control.themeOnSurfaceVariant
            }

            Row {
                spacing: 12 * control.themeGlobalScale
                Text {
                    text: control.hasStartDate ? Qt.formatDate(control.startDate, "MMM d, yyyy") : "Start date"
                    font.pixelSize: 18 * control.themeGlobalScale
                    font.weight: Font.Medium
                    color: control.hasStartDate ? control.themeOnSurface : control.themeOnSurfaceVariant
                }
                Text {
                    text: "–"
                    font.pixelSize: 18 * control.themeGlobalScale
                    color: control.themeOnSurfaceVariant
                }
                Text {
                    text: control.hasEndDate ? Qt.formatDate(control.endDate, "MMM d, yyyy") : "End date"
                    font.pixelSize: 18 * control.themeGlobalScale
                    font.weight: Font.Medium
                    color: control.hasEndDate ? control.themeOnSurface : control.themeOnSurfaceVariant
                }
            }
        }

        MeoDivider {}

        // Month Selection
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

                MeoIconButton {
                    icon.name: "chevron_left"
                    onClicked: {
                        let d = new Date(control.displayDate)
                        d.setMonth(d.getMonth() - 1)
                        control.displayDate = d
                    }
                }
                MeoIconButton {
                    icon.name: "chevron_right"
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
                    readonly property bool isStart: isSameDate(dateInfo.date, control.startDate)
                    readonly property bool isEnd: isSameDate(dateInfo.date, control.endDate)
                    readonly property bool isInRange: isBetween(dateInfo.date, control.startDate, control.endDate)
                    readonly property bool isCurrentMonth: dateInfo.date.getMonth() === control.displayDate.getMonth()

                    // Range Bridge
                    Rectangle {
                        anchors.verticalCenter: parent.verticalCenter
                        height: 32 * control.themeGlobalScale
                        width: (isStart || isEnd) ? parent.width / 2 : parent.width
                        x: isStart ? parent.width / 2 : 0
                        color: (isInRange || isStart || isEnd) && control.hasStartDate && control.hasEndDate ? control.themePrimaryContainer : "transparent"
                        visible: control.hasStartDate && control.hasEndDate && (isInRange || isStart || isEnd)

                        // Rounding at row ends (Expressive MD3)
                        radius: (index % 7 === 0 || index % 7 === 6) ? 16 * control.themeGlobalScale : 0

                        // Use overlay rectangles to "square off" internal connections since QtQuick.Rectangle
                        // doesn't support per-corner radius.
                        Rectangle {
                            anchors.left: parent.left
                            width: 16 * control.themeGlobalScale
                            height: parent.height
                            color: parent.color
                            visible: parent.radius > 0 && index % 7 !== 0
                        }
                        Rectangle {
                            anchors.right: parent.right
                            width: 16 * control.themeGlobalScale
                            height: parent.height
                            color: parent.color
                            visible: parent.radius > 0 && index % 7 !== 6
                        }
                    }

                    // Selection Circle
                    Rectangle {
                        anchors.centerIn: parent
                        width: 32 * control.themeGlobalScale
                        height: 32 * control.themeGlobalScale
                        radius: 16 * control.themeGlobalScale
                        color: (isStart || isEnd) ? control.themePrimary : "transparent"

                        Text {
                            anchors.centerIn: parent
                            text: dateInfo.day
                            font.pixelSize: 12 * control.themeGlobalScale
                            font.weight: (isStart || isEnd || isInRange) ? Font.Medium : Font.Normal
                            color: (isStart || isEnd) ? control.themeOnPrimary : (isInRange ? control.themeOnPrimaryContainer : (isCurrentMonth ? control.themeOnSurface : control.themeOnSurfaceVariant))
                            opacity: isCurrentMonth ? 1.0 : 0.4
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            handleDateClick(dateInfo.date)
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
        // Reset time to midnight for accurate comparison
        targetDate.setHours(0, 0, 0, 0)
        return {
            day: targetDate.getDate(),
            date: targetDate
        }
    }

    function isSameDate(d1, d2) {
        if (!d1 || !d2) return false
        return d1.getFullYear() === d2.getFullYear() &&
               d1.getMonth() === d2.getMonth() &&
               d1.getDate() === d2.getDate()
    }

    function isBetween(date, start, end) {
        if (!control.hasStartDate || !control.hasEndDate) return false
        return date.getTime() > start.getTime() && date.getTime() < end.getTime()
    }

    function handleDateClick(date) {
        if (!control.hasStartDate || (control.hasStartDate && control.hasEndDate)) {
            control.startDate = date
            control.endDate = new Date(0)
        } else {
            if (date.getTime() < control.startDate.getTime()) {
                control.endDate = control.startDate
                control.startDate = date
            } else if (date.getTime() === control.startDate.getTime()) {
                // Toggle off
                control.startDate = new Date(0)
            } else {
                control.endDate = date
            }
        }
    }
}
