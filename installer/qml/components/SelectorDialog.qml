pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import MeoUI 1.0 as Meo
import ".."

MotionPopup {
    id: popup
    property string title: "Select"
    property var sourceModel: []
    property string primaryKey: "id"
    property string labelKey: "name"
    property string secondaryKey: ""
    property string selectedId: ""
    property string pendingId: selectedId
    property string searchText: ""
    property var filteredModel: []
    signal applied(string id)
    anchors.centerIn: Overlay.overlay
    width: Math.min(720, Overlay.overlay ? Overlay.overlay.width - 64 : 720)
    height: Math.min(620, Overlay.overlay ? Overlay.overlay.height - 64 : 620)
    padding: 24
    closePolicy: Popup.CloseOnEscape

    function rebuild() {
        const needle = searchText.trim().toLowerCase()
        const result = []
        for (let i = 0; i < sourceModel.length; ++i) {
            const item = sourceModel[i]
            const haystack = (String(item[labelKey] || "") + " " + String(item[secondaryKey] || "") + " " + String(item[primaryKey] || "") + " " + String(item.alpha2 || "") + " " + String(item.alpha3 || "")).toLowerCase()
            if (!needle || haystack.indexOf(needle) >= 0)
                result.push(item)
        }
        filteredModel = result
    }
    onSourceModelChanged: rebuild()
    onSearchTextChanged: rebuild()
    onOpened: { pendingId = selectedId; search.forceActiveFocus(); rebuild(); list.positionViewAtIndex(Math.max(0, list.currentIndex), ListView.Center) }

    contentItem: Column {
        spacing: 16
        Text { width: parent.width; text: popup.title + " · " + popup.filteredModel.length; font.family: "Comfortaa"; font.bold: true; font.pixelSize: 26; color: MeoTheme.onSurface }
        MeoTextField { id: search; width: parent.width; label: "Search"; placeholder: "Type a name or code"; onTextChanged: popup.searchText = text }
        ListView {
            id: list
            width: parent.width; height: parent.height - 150; clip: true; model: popup.filteredModel
            keyNavigationEnabled: true; highlightMoveDuration: MeoTheme.motionDurationMedium2
            highlightMoveVelocity: -1
            currentIndex: {
                for (let i = 0; i < popup.filteredModel.length; ++i)
                    if (String(popup.filteredModel[i][popup.primaryKey]) === popup.pendingId) return i
                return -1
            }
            highlight: Rectangle { radius: 16; color: MeoTheme.primaryContainer }
            highlightFollowsCurrentItem: true
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            delegate: Rectangle {
                id: option
                required property var modelData
                required property int index
                width: ListView.view.width; height: 56; radius: 16; color: "transparent"
                activeFocusOnTab: true
                Meo.MeoStateLayer { anchors.fill: parent; radius: option.radius; hovered: optionHover.hovered; pressed: optionTap.pressed; focused: option.activeFocus; color: MeoTheme.onSurface }
                Text { anchors.left: parent.left; anchors.leftMargin: 16; anchors.right: code.left; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: String(option.modelData[popup.labelKey] || option.modelData[popup.primaryKey]); font.family: "Roboto"; font.pixelSize: 15; font.weight: Font.Medium; color: MeoTheme.onSurface; elide: Text.ElideRight }
                Text { id: code; anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: String(option.modelData[popup.secondaryKey] || option.modelData[popup.primaryKey]); font.family: "Roboto"; font.pixelSize: 13; color: MeoTheme.onSurfaceVariant }
                HoverHandler { id: optionHover }
                TapHandler { id: optionTap; onTapped: { popup.pendingId = String(option.modelData[popup.primaryKey]); list.currentIndex = option.index; option.forceActiveFocus() } }
                Keys.onReturnPressed: { popup.pendingId = String(option.modelData[popup.primaryKey]); list.currentIndex = option.index }
            }
        }
        Row {
            anchors.right: parent.right; spacing: 8
            MeoButton { text: "Cancel"; kind: "text"; onClicked: popup.close() }
            MeoButton { text: "Apply"; enabled: popup.pendingId.length > 0; onClicked: { popup.applied(popup.pendingId); popup.close() } }
        }
    }
}
