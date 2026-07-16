import QtQuick
import ".."
import "../components"

PageFrame {
    id: page
    pageTitle: "Language & Region"

    Column {
        width: parent.width
        spacing: page.dp(22)

        PageHeading {
            width: parent.width
            title: page.pageTitle
            subtitle: "These settings control the language, formats, and time zone used by KDE after installation."
        }
        Column {
            width: parent.width
            spacing: page.dp(12)

            SelectionCard {
                width: parent.width
                iconText: "translate"
                title: "System Language"
                value: page.controller ? page.controller.systemLocale : ""
                onClicked: localeDialog.openFrom(this)
            }
            SelectionCard {
                width: parent.width
                iconText: "public"
                title: "Country or Region"
                value: page.controller ? page.controller.formatCountry + " · " + page.controller.formatLocale : ""
                onClicked: countryDialog.openFrom(this)
            }
            SelectionCard {
                width: parent.width
                iconText: "schedule"
                title: "Time Zone"
                value: page.controller ? page.controller.timeZone : ""
                onClicked: zoneDialog.openFrom(this)
            }
        }
    }

    SelectorDialog {
        id: localeDialog
        title: "System languages"
        sourceModel: page.controller ? page.controller.systemLocales : []
        primaryKey: "id"
        labelKey: "nativeName"
        secondaryKey: "code"
        selectedId: page.controller ? page.controller.systemLocale : ""
        onApplied: id => page.controller.setSystemLocale(id)
    }
    SelectorDialog {
        id: countryDialog
        title: "Countries and regions"
        sourceModel: page.controller ? page.controller.countries : []
        primaryKey: "alpha2"
        labelKey: "name"
        secondaryKey: "alpha2"
        selectedId: page.controller ? page.controller.formatCountry : ""
        onApplied: id => page.controller.setFormatCountry(id)
    }
    SelectorDialog {
        id: zoneDialog
        title: "Time zones"
        sourceModel: page.controller ? page.controller.timeZones : []
        primaryKey: "id"
        labelKey: "label"
        secondaryKey: "id"
        selectedId: page.controller ? page.controller.timeZone : ""
        onApplied: id => page.controller.setTimeZone(id)
    }
}
