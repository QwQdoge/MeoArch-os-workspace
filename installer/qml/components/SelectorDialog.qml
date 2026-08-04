pragma ComponentBehavior: Bound
import QtQuick
import QtQuick.Controls
import MeoUI 1.0

MeoMotionPopup {
    id: popup
    presentation: MeoMotionPopup.Dialog
    property string title: "Select"
    property var sourceModel: []
    property string primaryKey: "id"
    property string labelKey: "name"
    property string secondaryKey: ""
    property string selectedId: ""
    property string pendingId: selectedId
    property string searchText: ""
    property var filteredModel: []
    property var _searchHaystacks: []
    signal applied(string id)
    anchors.centerIn: Overlay.overlay
    width: Math.min(720, Overlay.overlay ? Overlay.overlay.width - 64 : 720)
    height: Math.min(620, Overlay.overlay ? Overlay.overlay.height - 64 : 620)
    padding: 24
    closePolicy: Popup.CloseOnEscape
    initialFocusItem: search

    function updateHaystacks() {
        const haystacks = new Array(sourceModel.length)
        for (let i = 0; i < sourceModel.length; ++i) {
            const item = sourceModel[i]
            haystacks[i] = (String(item[labelKey] || "") + " " + String(item[secondaryKey] || "") + " " + String(item[primaryKey] || "") + " " + String(item.alpha2 || "") + " " + String(item.alpha3 || "")).toLowerCase()
        }
        _searchHaystacks = haystacks
    }

    function rebuild() {
        const needle = searchText.trim().toLowerCase()
        if (!needle) {
            filteredModel = sourceModel
            return
        }

        if (_searchHaystacks.length !== sourceModel.length) {
            updateHaystacks()
        }

        const result = []
        for (let i = 0; i < sourceModel.length; ++i) {
            if (_searchHaystacks[i] !== undefined && _searchHaystacks[i].indexOf(needle) >= 0)
                result.push(sourceModel[i])
        }
        filteredModel = result
    }
    onSourceModelChanged: { updateHaystacks(); rebuild() }
    onSearchTextChanged: rebuild()
    onOpened: { pendingId = selectedId; search.forceActiveFocus(); rebuild(); list.positionViewAtIndex(Math.max(0, list.currentIndex), ListView.Center) }

    contentItem: Column {
        spacing: 16
        MeoText { width: parent.width; text: popup.title + " · " + popup.filteredModel.length; typeRole: "title"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface }
        MeoTextField { id: search; width: parent.width; type: "outlined"; size: "l"; label: "Search"; placeholder: "Type a name or code"; onTextChanged: popup.searchText = text }
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
            Keys.onDownPressed: incrementCurrentIndex()
            Keys.onUpPressed: decrementCurrentIndex()
            ScrollBar.vertical: ScrollBar { policy: ScrollBar.AsNeeded }
            delegate: Rectangle {
                id: option
                required property var modelData
                required property int index
                width: ListView.view.width; height: 56; radius: 16; color: "transparent"
                activeFocusOnTab: true
                Accessible.role: Accessible.RadioButton
                Accessible.name: String(option.modelData[popup.labelKey] || option.modelData[popup.primaryKey])
                Accessible.checked: String(option.modelData[popup.primaryKey]) === popup.pendingId
                MeoStateLayer { anchors.fill: parent; radius: option.radius; hovered: optionHover.hovered; pressed: optionTap.pressed; focused: option.activeFocus; color: MeoTheme.contentOnSurface }
                MeoText { anchors.left: parent.left; anchors.leftMargin: 16; anchors.right: code.left; anchors.rightMargin: 12; anchors.verticalCenter: parent.verticalCenter; text: String(option.modelData[popup.labelKey] || option.modelData[popup.primaryKey]); typeRole: "body"; typeSize: "medium"; emphasized: true; color: MeoTheme.contentOnSurface; elide: Text.ElideRight }
                MeoText { id: code; anchors.right: parent.right; anchors.rightMargin: 16; anchors.verticalCenter: parent.verticalCenter; text: String(option.modelData[popup.secondaryKey] || option.modelData[popup.primaryKey]); typeRole: "body"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant }
                HoverHandler { id: optionHover }
                TapHandler { id: optionTap; onTapped: { popup.pendingId = String(option.modelData[popup.primaryKey]); list.currentIndex = option.index; option.forceActiveFocus() } }
                Keys.onReturnPressed: { popup.pendingId = String(option.modelData[popup.primaryKey]); list.currentIndex = option.index }
            }
        }
        Row {
            anchors.right: parent.right; spacing: 8
            MeoButton { text: "Cancel"; type: "text"; onClicked: popup.close() }
            MeoButton { text: "Apply"; type: "filled"; enabled: popup.pendingId.length > 0; onClicked: { popup.applied(popup.pendingId); popup.close() } }
        }
    }
}
