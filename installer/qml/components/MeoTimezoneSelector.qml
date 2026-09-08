import QtQuick
import MeoUI 1.0

/*
 * Meo owns the surrounding installer interaction, while Plasma owns the
 * maintained offline timezone map and its GeoJSON data.  Keeping the import in
 * the loaded child lets the installer retain a searchable, usable fallback if
 * an incomplete Live image is missing the optional Plasma module.
 */
Item {
    id: root

    property string selectedTimeZone: ""
    readonly property bool mapAvailable: mapLoader.status === Loader.Ready

    function applySelectedTimeZone(value) {
        const next = String(value || "")
        if (next.length > 0 && next !== root.selectedTimeZone)
            root.selectedTimeZone = next
    }

    Loader {
        id: mapLoader
        anchors.fill: parent
        source: "KdeTimezoneSelector.qml"
        onLoaded: {
            item.selectedTimeZone = root.selectedTimeZone
        }
    }

    Connections {
        target: mapLoader.item
        ignoreUnknownSignals: true
        function onSelectedTimeZoneChanged() {
            root.applySelectedTimeZone(mapLoader.item.selectedTimeZone)
        }
    }

    onSelectedTimeZoneChanged: {
        if (mapLoader.item && mapLoader.item.selectedTimeZone !== selectedTimeZone)
            mapLoader.item.selectedTimeZone = selectedTimeZone
    }

    MeoCard {
        anchors.fill: parent
        visible: !root.mapAvailable
        type: "filled"
        padding: 20
        Column {
            anchors.centerIn: parent
            width: parent.width - 40
            spacing: 10
            MeoIcon { anchors.horizontalCenter: parent.horizontalCenter; icon: "map"; size: 36; color: MeoTheme.primary }
            MeoText { width: parent.width; text: qsTr("Offline time-zone map is unavailable"); horizontalAlignment: Text.AlignHCenter; typeRole: "title"; typeSize: "small"; emphasized: true; color: MeoTheme.contentOnSurface }
            MeoText { width: parent.width; text: qsTr("Use the searchable time-zone list above. This image is missing Plasma's time-zone map data."); horizontalAlignment: Text.AlignHCenter; typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap }
        }
    }
}
