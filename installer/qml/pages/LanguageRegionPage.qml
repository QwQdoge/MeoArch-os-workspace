import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI 1.0
import ".."
import "../components"

PageFrame {
    id: page
    pageTitle: qsTr("Language & Region")
    property bool adjustmentsOpen: false
    readonly property var recommendation: controller ? controller.regionRecommendation : ({})
    readonly property string secondaryCalendar: controller ? controller.selection("preferences", "secondaryCalendar", "none") : "none"

    function calendarLabel(id) {
        const all = controller ? controller.calendarCapabilities : []
        for (let index = 0; index < all.length; ++index)
            if (all[index].id === id)
                return all[index].name
        return id
    }

    Column {
        width: parent.width
        spacing: page.compactHeight ? page.dp(12) : page.dp(18)

        PageHeading {
            width: parent.width
            title: page.pageTitle
            subtitle: qsTr("Choose where you live. Meo will prepare a recommended language, format, time zone, and keyboard that you can adjust at any time.")
        }

        SelectionCard {
            width: parent.width
            iconText: "public"
            title: qsTr("Country or region")
            value: page.controller ? page.controller.formatCountry : ""
            onClicked: countryDialog.openFrom(this)
        }

        MeoCard {
            width: parent.width
            type: "filled"
            padding: page.dp(20)
            implicitHeight: preparedColumn.implicitHeight + page.dp(40)
            Accessible.name: qsTr("Prepared regional settings")

            Column {
                id: preparedColumn
                width: parent.width
                spacing: page.dp(10)
                Row {
                    width: parent.width
                    spacing: page.dp(12)
                    MeoIcon { icon: "auto_awesome"; size: page.dp(24); color: MeoTheme.primary }
                    MeoText { text: qsTr("Ready for you"); typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
                }
                MeoText {
                    width: parent.width
                    text: recommendation.automatic ? qsTr("Recommended from your country and installer language.")
                                                   : qsTr("Some values were adjusted by you and will be kept when you change country.")
                    typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap
                }
                Repeater {
                    model: [
                        { icon: "translate", label: qsTr("System language"), value: page.controller ? page.controller.systemLocale : "" },
                        { icon: "format_list_numbered", label: qsTr("Date and number format"), value: page.controller ? page.controller.formatLocale : "" },
                        { icon: "schedule", label: qsTr("Time zone"), value: page.controller ? page.controller.timeZone : "" },
                        { icon: "keyboard", label: qsTr("Keyboard"), value: page.controller ? page.controller.keyboardLayout : "" },
                        { icon: "calendar_month", label: qsTr("Calendar"), value: qsTr("Gregorian") + (page.secondaryCalendar !== "none" ? qsTr(" · %1").arg(page.calendarLabel(page.secondaryCalendar)) : "") }
                    ]
                    delegate: Row {
                        required property var modelData
                        width: parent.width
                        spacing: page.dp(10)
                        MeoIcon { anchors.verticalCenter: parent.verticalCenter; icon: modelData.icon; size: page.dp(18); color: MeoTheme.contentOnSurfaceVariant }
                        MeoText { width: parent.width - page.dp(170); text: modelData.label; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurface }
                        MeoText { anchors.verticalCenter: parent.verticalCenter; text: modelData.value; typeRole: "label"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurfaceVariant; elide: Text.ElideLeft }
                    }
                }
            }
        }

        MeoButton {
            text: page.adjustmentsOpen ? qsTr("Hide adjustments") : qsTr("Adjust language, format, time zone, and calendar")
            type: "tonal"
            onClicked: page.adjustmentsOpen = !page.adjustmentsOpen
        }

        Column {
            visible: page.adjustmentsOpen
            width: parent.width
            spacing: page.dp(12)
            MeoButton { visible: !recommendation.automatic; text: qsTr("Use country recommendations again"); type: "outlined"; onClicked: page.controller.useRegionRecommendations() }
            SelectionCard { width: parent.width; iconText: "translate"; title: qsTr("System language"); value: page.controller ? page.controller.systemLocale : ""; onClicked: localeDialog.openFrom(this) }
            SelectionCard { width: parent.width; iconText: "format_list_numbered"; title: qsTr("Date and number format"); value: page.controller ? page.controller.formatLocale : ""; onClicked: formatDialog.openFrom(this) }
            SelectionCard { width: parent.width; iconText: "schedule"; title: qsTr("Time zone"); value: page.controller ? page.controller.timeZone : ""; onClicked: zoneDialog.openFrom(this) }
            SelectionCard { width: parent.width; iconText: "keyboard"; title: qsTr("Keyboard"); value: page.controller ? page.controller.keyboardLayout : ""; onClicked: keyboardDialog.openFrom(this) }
            SelectionCard { width: parent.width; iconText: "calendar_month"; title: qsTr("Secondary calendar"); value: page.calendarLabel(page.secondaryCalendar); onClicked: calendarDialog.openFrom(this) }
            ToggleRow {
                visible: page.secondaryCalendar === "hebcal"
                width: parent.width
                title: qsTr("Hebcal calendar")
                subtitle: qsTr("Public calendar data can be configured after installation")
                checked: page.controller ? page.controller.selection("preferences", "hebcalEnabled", false) : false
                onToggled: checked => page.controller.setHebcalEnabled(checked)
            }
            InfoBanner {
                visible: page.secondaryCalendar === "hebcal"
                width: parent.width
                title: qsTr("Privacy")
                message: qsTr("The installer never contacts this service. When enabled after installation, only the current date and public calendar language are requested—never account, device, hardware, or location data.")
            }
            MeoTimezoneSelector {
                width: parent.width
                height: page.compactHeight ? page.dp(260) : page.dp(360)
                selectedTimeZone: page.controller ? page.controller.timeZone : ""
                onSelectedTimeZoneChanged: {
                    if (page.controller && selectedTimeZone.length > 0 && selectedTimeZone !== page.controller.timeZone)
                        page.controller.setTimeZone(selectedTimeZone)
                }
            }
            MeoText { width: parent.width; text: qsTr("The map is available offline. Changing it keeps this time zone when you choose another country."); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
        }
    }

    SelectorDialog { id: countryDialog; title: qsTr("Countries and regions"); sourceModel: page.controller ? page.controller.countries : []; primaryKey: "alpha2"; labelKey: "name"; secondaryKey: "alpha2"; selectedId: page.controller ? page.controller.formatCountry : ""; onApplied: id => page.controller.setFormatCountry(id) }
    SelectorDialog { id: localeDialog; title: qsTr("System languages"); sourceModel: page.controller ? page.controller.systemLocales : []; primaryKey: "id"; labelKey: "nativeName"; secondaryKey: "code"; selectedId: page.controller ? page.controller.systemLocale : ""; onApplied: id => page.controller.setSystemLocale(id) }
    SelectorDialog { id: formatDialog; title: qsTr("Date and number formats"); sourceModel: page.controller ? page.controller.systemLocales : []; primaryKey: "id"; labelKey: "nativeName"; secondaryKey: "code"; selectedId: page.controller ? page.controller.formatLocale : ""; onApplied: id => page.controller.setFormatLocale(id) }
    SelectorDialog { id: zoneDialog; title: qsTr("Time zones"); sourceModel: page.controller ? page.controller.timeZones : []; primaryKey: "id"; labelKey: "label"; secondaryKey: "id"; selectedId: page.controller ? page.controller.timeZone : ""; onApplied: id => page.controller.setTimeZone(id) }
    SelectorDialog { id: keyboardDialog; title: qsTr("Keyboard layouts"); sourceModel: page.controller ? page.controller.keyboardLayouts : []; primaryKey: "id"; labelKey: "name"; secondaryKey: "id"; selectedId: page.controller ? page.controller.keyboardLayout : ""; onApplied: id => page.controller.setKeyboardLayout(id) }
    SelectorDialog { id: calendarDialog; title: qsTr("Secondary calendar"); sourceModel: page.controller ? page.controller.calendarCapabilities : []; primaryKey: "id"; labelKey: "name"; secondaryKey: "description"; selectedId: page.secondaryCalendar; onApplied: id => page.controller.setSecondaryCalendar(id) }
}
