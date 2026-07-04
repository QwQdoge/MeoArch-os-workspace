import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Item {
    id: control

    property var componentData: ({})

    implicitWidth: sampleLoader.implicitWidth
    implicitHeight: sampleLoader.implicitHeight

    readonly property var navItems: [
        { "label": "Home", "icon": "home" },
        { "label": "Explore", "icon": "explore", "badgeText": "3" },
        { "label": "Profile", "icon": "person" }
    ]
    readonly property var chipItems: [
        { "label": "All", "icon": "apps" },
        { "label": "Design", "icon": "palette" },
        { "label": "Code", "icon": "code" }
    ]
    readonly property var tableColumns: [
        { "label": "Dessert", "property": "name", "width": 160, "sortable": true },
        { "label": "Calories", "property": "calories", "width": 100, "sortable": true },
        { "label": "Status", "property": "status", "width": 100 }
    ]
    readonly property var tableRows: [
        { "name": "Cupcake", "calories": 305, "status": "High", "selected": true },
        { "name": "Donut", "calories": 452, "status": "High" },
        { "name": "Eclair", "calories": 262, "status": "Normal" }
    ]

    Loader {
        id: sampleLoader
        sourceComponent: sampleFor(control.componentData.name || "")
    }

    function sampleFor(name) {
        if (name === "MeoTheme") return foundationsSample
        if (name === "MeoText") return textSample
        if (name === "MeoIcon") return iconSample
        if (name === "MeoStateLayer") return stateLayerSample
        if (name === "MeoButton" || name === "Expressive buttons") return buttonSample
        if (name === "MeoIconButton") return iconButtonSample
        if (name === "MeoFAB") return fabSample
        if (name === "MeoFABMenu") return fabMenuSample
        if (name === "MeoSplitButton") return splitButtonSample
        if (name === "MeoButtonGroup") return buttonGroupSample
        if (name === "MeoSegmentedButtons") return segmentedSample
        if (name === "MeoTextField") return textFieldSample
        if (name === "MeoTextArea") return textAreaSample
        if (name === "MeoExposedDropdown") return dropdownSample
        if (name === "MeoDateInput") return dateInputSample
        if (name === "MeoTimeInput") return timeInputSample
        if (name === "MeoDatePicker") return datePickerSample
        if (name === "MeoDateRangePicker") return dateRangeSample
        if (name === "MeoTimePicker") return timePickerSample
        if (name === "MeoCheckbox") return checkboxSample
        if (name === "MeoRadioButton") return radioSample
        if (name === "MeoSwitch") return switchSample
        if (name === "MeoSlider") return sliderSample
        if (name === "MeoRangeSlider") return rangeSliderSample
        if (name === "MeoSelectionGroup") return selectionGroupSample
        if (name === "MeoFilterGroup") return filterGroupSample
        if (name === "MeoStepper") return stepperSample
        if (name === "MeoNavigationBar") return navigationBarSample
        if (name === "MeoNavigationRail" || name === "Expressive navigation") return navigationRailSample
        if (name === "MeoNavigationDrawer") return navigationDrawerSample
        if (name === "MeoNavigationDrawerModal") return modalDrawerSample
        if (name === "MeoNavigationDrawerItem") return drawerItemSample
        if (name === "MeoNavigationSuite") return navigationSuiteSample
        if (name === "MeoBreadcrumbs") return breadcrumbsSample
        if (name === "MeoTabs") return tabsSample
        if (name === "MeoTopAppBar") return topAppBarSample
        if (name === "MeoBottomAppBar") return bottomAppBarSample
        if (name === "MeoMenu") return menuSample
        if (name === "MeoDataTable") return dataTableSample
        if (name === "MeoListItem") return listItemSample
        if (name === "MeoListHeader") return listHeaderSample
        if (name === "MeoGroupedList") return groupedListSample
        if (name === "MeoBadge") return badgeSample
        if (name === "MeoAvatar") return avatarSample
        if (name === "MeoDivider") return dividerSample
        if (name === "MeoSkeleton") return skeletonSample
        if (name === "MeoCard") return cardSample
        if (name === "MeoDialog") return dialogSample
        if (name === "MeoFullScreenDialog") return fullDialogSample
        if (name === "MeoExpressiveDialog") return expressiveDialogSample
        if (name === "MeoBottomSheet") return bottomSheetSample
        if (name === "MeoStandardBottomSheet") return standardSheetSample
        if (name === "MeoSideSheet") return sideSheetSample
        if (name === "MeoSideSheetModal") return modalSideSheetSample
        if (name === "MeoActionSheet") return actionSheetSample
        if (name === "MeoBanner") return bannerSample
        if (name === "MeoSnackbar") return snackbarSample
        if (name === "MeoTooltip") return tooltipSample
        if (name === "MeoRichTooltip") return richTooltipSample
        if (name === "MeoProgressBar" || name === "Expressive progress") return progressSample
        if (name === "MeoLoadingIndicator") return loadingSample
        if (name === "MeoPullToRefresh") return pullRefreshSample
        if (name === "MeoEmptyState") return emptyStateSample
        if (name === "MeoSearchBar") return searchBarSample
        if (name === "MeoDockedSearchBar") return dockedSearchSample
        if (name === "MeoSearchAppBar") return searchAppBarSample
        if (name === "MeoSearchView") return searchViewSample
        if (name === "MeoSearchSuggestions") return searchSuggestionsSample
        if (name === "MeoSearchHeader") return searchHeaderSample
        if (name === "MeoSearchFilterBar") return searchFilterSample
        if (name === "MeoCarousel") return carouselSample
        if (name === "MeoPageIndicator") return pageIndicatorSample
        if (name === "MeoMediaController") return mediaSample
        if (name === "MeoToolbar") return toolbarSample
        if (name === "MeoDockedToolbar") return dockedToolbarSample
        if (name === "MeoFloatingToolbar") return floatingToolbarSample
        if (name === "MeoAccountHeader") return accountHeaderSample
        if (name === "MeoSwipeToDismiss") return swipeToDismissSample
        if (name === "MeoChip" || name === "Expressive chips") return chipSample
        if (name === "MeoAssistChip") return assistChipSample
        if (name === "MeoFilterChip") return filterChipSample
        if (name === "MeoInputChip") return inputChipSample
        if (name === "MeoSuggestionChip") return suggestionChipSample
        if (name === "MeoPageLayout") return pageLayoutSample
        if (name === "MeoScaffold") return scaffoldSample
        if (name === "MeoAppLayout") return appLayoutSample
        if (name === "MeoDashboardLayout") return dashboardSample
        if (name === "MeoFeedLayout") return feedSample
        if (name === "MeoListDetailLayout") return listDetailSample
        if (name === "MeoSettingsLayout") return settingsSample
        if (name === "MeoShape") return shapeSample
        return fallbackSample
    }

    Component {
        id: foundationsSample
        Flow {
            spacing: MeoTheme.space8
            TokenSwatch { label: "Primary"; swatchColor: MeoTheme.primary; contentColor: MeoTheme.contentOnPrimary }
            TokenSwatch { label: "Surface"; swatchColor: MeoTheme.surfaceContainer; contentColor: MeoTheme.contentOnSurface }
            TokenSwatch { label: "Error"; swatchColor: MeoTheme.error; contentColor: MeoTheme.contentOnError }
        }
    }
    Component { id: textSample; Column { spacing: MeoTheme.space4; MeoText { text: "Display title"; typeRole: "title"; typeSize: "big"; emphasized: true; color: MeoTheme.contentOnSurface } MeoText { text: "Roboto body text with semantic type tokens."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component { id: iconSample; Flow { spacing: MeoTheme.space12; Repeater { model: ["palette", "smart_button", "edit", "search", "auto_awesome"]; delegate: MeoIcon { required property string modelData; icon: modelData; color: MeoTheme.primary; size: 32 } } } }
    Component { id: stateLayerSample; Rectangle { width: 180 * MeoTheme.globalScale; height: MeoTheme.buttonHeightM; radius: MeoTheme.shapeMedium; color: MeoTheme.surfaceContainer; MeoStateLayer { anchors.fill: parent; radius: parent.radius; hovered: true; focused: true; color: MeoTheme.primary } MeoText { anchors.centerIn: parent; text: "Hover + focus"; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurface } } }
    Component { id: buttonSample; Flow { spacing: MeoTheme.space8; MeoButton { text: "Filled"; type: "filled" } MeoButton { text: "Tonal"; type: "tonal"; icon.name: "star" } MeoButton { text: "Loading"; loading: true; loadingWithContainer: true } MeoButton { text: "Disabled"; enabled: false } MeoButton { text: "XL"; size: "xl"; vibrant: true } } }
    Component { id: iconButtonSample; Flow { spacing: MeoTheme.space8; MeoIconButton { icon.name: "settings" } MeoIconButton { icon.name: "favorite"; type: "filled"; selected: true } MeoIconButton { icon.name: "bookmark"; type: "tonal"; badgeDot: true } MeoIconButton { icon.name: "share"; type: "outlined"; enabled: false } } }
    Component { id: fabSample; Flow { spacing: MeoTheme.space12; MeoFAB { type: "small"; icon.name: "edit" } MeoFAB { type: "regular"; icon.name: "add" } MeoFAB { type: "large"; icon.name: "palette" } MeoFAB { type: "extended"; icon.name: "send"; text: "Send" } } }
    Component { id: fabMenuSample; Item { width: 220 * MeoTheme.globalScale; height: 96 * MeoTheme.globalScale; MeoFABMenu { anchors.centerIn: parent; model: control.chipItems } } }
    Component { id: splitButtonSample; MeoSplitButton { text: "Create"; icon: "add"; menuModel: control.chipItems } }
    Component { id: buttonGroupSample; MeoButtonGroup { model: [{ "label": "Day" }, { "label": "Week" }, { "label": "Month" }]; currentIndex: 1 } }
    Component { id: segmentedSample; MeoSegmentedButtons { width: 420 * MeoTheme.globalScale; model: [{ "label": "List", "icon": "view_list" }, { "label": "Grid", "icon": "grid_view" }, { "label": "Map", "icon": "map" }]; currentIndex: 1 } }
    Component { id: textFieldSample; Flow { spacing: MeoTheme.space12; MeoTextField { label: "Filled"; placeholder: "Placeholder"; helperText: "Helper text" } MeoTextField { label: "Outlined"; type: "outlined"; leadingIcon: "mail"; placeholder: "Email" } MeoTextField { label: "Error"; type: "outlined"; text: "bad"; isError: true; errorText: "Invalid input" } MeoTextField { label: "Disabled"; enabled: false } } }
    Component { id: textAreaSample; MeoTextArea { width: 420 * MeoTheme.globalScale; height: 150 * MeoTheme.globalScale; label: "Description"; type: "outlined"; placeholder: "Enter multiline text"; helperText: "Supporting text"; maxLength: 200; showCounter: true } }
    Component { id: dropdownSample; Flow { spacing: MeoTheme.space12; MeoExposedDropdown { width: 240 * MeoTheme.globalScale; label: "Environment"; model: ["Development", "Staging", "Production"] } MeoExposedDropdown { width: 220 * MeoTheme.globalScale; label: "Disabled"; model: ["Unavailable"]; enabled: false } } }
    Component { id: dateInputSample; MeoDateInput { width: 220 * MeoTheme.globalScale } }
    Component { id: timeInputSample; MeoTimeInput { width: 220 * MeoTheme.globalScale } }
    Component { id: datePickerSample; MeoDatePicker { selectedDate: new Date() } }
    Component { id: dateRangeSample; MeoDateRangePicker { startDate: new Date(2026, 6, 1); endDate: new Date(2026, 6, 12) } }
    Component { id: timePickerSample; MeoTimePicker { hours: 10; minutes: 30 } }
    Component { id: checkboxSample; Flow { spacing: MeoTheme.space12; MeoCheckbox { label: "Checked"; checked: true } MeoCheckbox { label: "Unchecked" } MeoCheckbox { label: "Indeterminate"; indeterminate: true } } }
    Component { id: radioSample; Flow { spacing: MeoTheme.space12; MeoRadioButton { label: "Option A"; checked: true } MeoRadioButton { label: "Option B" } } }
    Component { id: switchSample; Flow { spacing: MeoTheme.space12; MeoSwitch { label: "On"; checked: true; icon: "check" } MeoSwitch { label: "Off"; uncheckedIcon: "close" } } }
    Component { id: sliderSample; Column { spacing: MeoTheme.space12; MeoSlider { width: 360 * MeoTheme.globalScale; value: 35 } MeoSlider { width: 360 * MeoTheme.globalScale; value: 70; discrete: true; wavy: true; isThick: true } } }
    Component { id: rangeSliderSample; MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 24; secondValue: 78 } }
    Component { id: selectionGroupSample; MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "checkbox"; showSelectAll: true; model: [{ "label": "Design", "checked": true }, { "label": "Code", "checked": false }] } }
    Component { id: filterGroupSample; MeoFilterGroup { width: 420 * MeoTheme.globalScale; model: control.chipItems; currentIndex: 0 } }
    Component { id: stepperSample; Flow { spacing: MeoTheme.space16; MeoStepper { width: 420 * MeoTheme.globalScale; model: [{ "label": "Account" }, { "label": "Profile" }, { "label": "Review" }]; currentIndex: 1 } MeoStepper { height: 220 * MeoTheme.globalScale; orientation: "vertical"; model: [{ "label": "Draft" }, { "label": "Check" }, { "label": "Publish" }]; currentIndex: 2 } } }
    Component { id: navigationBarSample; MeoNavigationBar { width: 420 * MeoTheme.globalScale; model: control.navItems; currentIndex: 1 } }
    Component { id: navigationRailSample; MeoNavigationRail { height: 300 * MeoTheme.globalScale; model: control.navItems; currentIndex: 1; isExpanded: true } }
    Component { id: navigationDrawerSample; MeoNavigationDrawer { width: 260 * MeoTheme.globalScale; height: 260 * MeoTheme.globalScale; model: control.navItems; currentIndex: 0; title: "MeoUI" } }
    Component { id: modalDrawerSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open modal drawer"; onClicked: drawer.open() } MeoNavigationDrawerModal { id: drawer; model: control.navItems } } }
    Component { id: drawerItemSample; Column { width: 360 * MeoTheme.globalScale; spacing: MeoTheme.space4; MeoNavigationDrawerItem { width: parent.width; label: "Inbox"; icon: "inbox"; selected: true; badgeText: "8" } MeoNavigationDrawerItem { width: parent.width; label: "Archive"; icon: "archive"; supportingText: "Grouped row"; mode: "group" } } }
    Component { id: navigationSuiteSample; MeoNavigationSuite { width: 520 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; model: control.navItems; currentIndex: 0; availableWidth: width } }
    Component { id: breadcrumbsSample; MeoBreadcrumbs { model: [{ "label": "Home", "icon": "home" }, { "label": "Library" }, { "label": "Component" }] } }
    Component { id: tabsSample; MeoTabs { width: 420 * MeoTheme.globalScale; model: [{ "label": "Overview", "icon": "info" }, { "label": "Tokens", "icon": "palette", "badgeDot": true }, { "label": "Usage", "icon": "code" }]; currentIndex: 1 } }
    Component { id: topAppBarSample; MeoTopAppBar { width: 460 * MeoTheme.globalScale; title: "Library"; type: "medium"; actions: [Component { MeoIconButton { icon.name: "search" } }, Component { MeoIconButton { icon.name: "more_vert" } }] } }
    Component { id: bottomAppBarSample; MeoBottomAppBar { width: 460 * MeoTheme.globalScale } }
    Component { id: menuSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open menu"; onClicked: menu.open() } MeoMenu { id: menu; model: [{ "label": "Copy", "icon": "content_copy" }, { "label": "Share", "icon": "share", "isVibrant": true }, { "label": "Delete", "icon": "delete" }]; itemSpacing: MeoTheme.space4 } } }
    Component { id: dataTableSample; MeoDataTable { width: 520 * MeoTheme.globalScale; columns: control.tableColumns; model: control.tableRows; selectable: true; sortProperty: "calories" } }
    Component { id: listItemSample; Column { width: 420 * MeoTheme.globalScale; MeoListItem { width: parent.width; headline: "One-line item"; leadingIcon: "inbox"; badgeText: "3" } MeoListItem { width: parent.width; headline: "Two-line item"; supportingText: "Supporting text"; leadingIcon: "article"; selected: true } } }
    Component { id: listHeaderSample; MeoListHeader { text: "Component group"; type: "emphasized" } }
    Component { id: groupedListSample; MeoGroupedList { width: 420 * MeoTheme.globalScale; title: "Settings"; selectedIndex: 1; model: [{ "label": "Theme", "icon": "palette" }, { "label": "Typography", "icon": "text_fields", "supportingText": "Roboto and Comfortaa" }] } }
    Component { id: badgeSample; Flow { spacing: MeoTheme.space16; MeoBadge { isDot: true } MeoBadge { text: "8" } MeoBadge { text: "120" } } }
    Component { id: avatarSample; Flow { spacing: MeoTheme.space12; MeoAvatar { initials: "ME"; variant: "circle" } MeoAvatar { initials: "UI"; variant: "squircle" } MeoAvatar { initials: "M3"; variant: "hexagon" } } }
    Component { id: dividerSample; Column { width: 360 * MeoTheme.globalScale; spacing: MeoTheme.space8; MeoText { text: "Above"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } MeoDivider {} MeoText { text: "Below"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component { id: skeletonSample; Column { width: 360 * MeoTheme.globalScale; spacing: MeoTheme.space8; MeoSkeleton { width: parent.width; height: MeoTheme.buttonHeightM } MeoSkeleton { width: parent.width * 0.7; height: MeoTheme.buttonHeightXS } } }
    Component { id: cardSample; Flow { spacing: MeoTheme.space12; SurfaceCard { title: "Elevated"; cardType: "elevated" } SurfaceCard { title: "Filled"; cardType: "filled" } SurfaceCard { title: "Outlined"; cardType: "outlined" } } }
    Component { id: dialogSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open dialog"; onClicked: dialog.open() } MeoDialog { id: dialog; title: "Confirm action"; message: "Dialogs keep the user focused."; confirmText: "OK"; cancelText: "Cancel" } } }
    Component { id: fullDialogSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open full dialog"; onClicked: full.open() } MeoFullScreenDialog { id: full; title: "Edit item" } } }
    Component { id: expressiveDialogSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open expressive dialog"; onClicked: dialog.open() } MeoExpressiveDialog { id: dialog; title: "Expressive"; message: "Custom content and shape."; icon: "auto_awesome" } } }
    Component { id: bottomSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open bottom sheet"; onClicked: sheet.open() } MeoBottomSheet { id: sheet; content: Component { MeoText { text: "Bottom sheet content"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: standardSheetSample; Item { width: 420 * MeoTheme.globalScale; height: 160 * MeoTheme.globalScale; MeoStandardBottomSheet { anchors.fill: parent; isOpen: true; content: Component { MeoText { text: "Standard sheet"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: sideSheetSample; Item { width: 420 * MeoTheme.globalScale; height: 160 * MeoTheme.globalScale; MeoSideSheet { anchors.right: parent.right; width: 240 * MeoTheme.globalScale; height: parent.height; isOpen: true; content: Component { MeoText { text: "Details"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: modalSideSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open side sheet"; onClicked: sheet.open() } MeoSideSheetModal { id: sheet; content: Component { MeoText { text: "Modal side sheet"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: actionSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open action sheet"; onClicked: sheet.open() } MeoActionSheet { id: sheet; title: "Share"; model: [{ "label": "Messages", "icon": "chat" }, { "label": "Email", "icon": "mail" }] } } }
    Component { id: bannerSample; MeoBanner { width: 460 * MeoTheme.globalScale; text: "This banner includes an icon and actions."; icon: "info"; confirmText: "Action"; cancelText: "Dismiss" } }
    Component { id: snackbarSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Show snackbar"; onClicked: snackbar.open() } MeoSnackbar { id: snackbar; message: "Saved"; actionText: "Undo" } } }
    Component { id: tooltipSample; Item { width: 220 * MeoTheme.globalScale; height: MeoTheme.buttonHeightM; MeoButton { anchors.centerIn: parent; text: "Hover target"; ToolTip.text: "Plain tooltip"; ToolTip.visible: hovered } } }
    Component { id: richTooltipSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open rich tooltip"; onClicked: tip.open() } MeoRichTooltip { id: tip; title: "Rich tooltip"; text: "Useful supporting detail."; icon: "tips_and_updates" } } }
    Component { id: progressSample; Column { width: 420 * MeoTheme.globalScale; spacing: MeoTheme.space12; MeoProgressBar { width: parent.width; value: 0.42 } MeoProgressBar { width: parent.width; indeterminate: true; vibrant: true } MeoProgressBar { type: "linear"; wavy: true; value: 0.72; isThick: true; width: parent.width } MeoProgressBar { type: "circular"; value: 0.62 } } }
    Component { id: loadingSample; Flow { spacing: MeoTheme.space16; MeoLoadingIndicator { size: "s" } MeoLoadingIndicator { size: "m"; vibrant: true } MeoLoadingIndicator { size: "l"; withContainer: true } } }
    Component { id: pullRefreshSample; Rectangle { width: 360 * MeoTheme.globalScale; height: 120 * MeoTheme.globalScale; radius: MeoTheme.shapeMedium; color: MeoTheme.surfaceContainerLow; MeoText { anchors.centerIn: parent; text: "Pull refresh wraps scroll content"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component { id: emptyStateSample; MeoEmptyState { width: 420 * MeoTheme.globalScale; icon: "inbox"; title: "No messages"; description: "Empty states explain what happened."; actionText: "Refresh" } }
    Component { id: searchBarSample; MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: "Search components" } }
    Component { id: dockedSearchSample; MeoDockedSearchBar { width: 460 * MeoTheme.globalScale; placeholder: "Docked search" } }
    Component { id: searchAppBarSample; MeoSearchAppBar { width: 460 * MeoTheme.globalScale; placeholder: "Searchable page" } }
    Component { id: searchViewSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open search view"; onClicked: view.open() } MeoSearchView { id: view; placeholder: "Search anything"; suggestions: [{ "label": "MeoTheme", "isHistory": true }, { "label": "MeoButton" }] } } }
    Component { id: searchSuggestionsSample; MeoSearchSuggestions { width: 420 * MeoTheme.globalScale; highlightText: "meo"; model: [{ "label": "MeoTheme tokens", "icon": "palette" }, { "label": "MeoButton usage", "icon": "smart_button" }] } }
    Component { id: searchHeaderSample; MeoSearchHeader { width: 520 * MeoTheme.globalScale; title: "Library"; placeholder: "Search"; actions: [Component { MeoIconButton { icon.name: "help" } }] } }
    Component { id: searchFilterSample; MeoSearchFilterBar { width: 520 * MeoTheme.globalScale; placeholder: "Search issues"; filterModel: control.chipItems; selectedFilterIndices: [0, 2] } }
    Component { id: carouselSample; MeoCarousel { width: 520 * MeoTheme.globalScale; itemHeight: 160 * MeoTheme.globalScale; type: "multi-browse"; model: [{ "title": "Color", "icon": "palette" }, { "title": "Type", "icon": "text_fields" }, { "title": "Motion", "icon": "animation" }]; delegate: Component { Rectangle { property var modelData: ({ "title": "", "icon": "" }); width: 180 * MeoTheme.globalScale; height: 140 * MeoTheme.globalScale; radius: MeoTheme.shapeLarge; color: MeoTheme.primaryContainer; Column { anchors.centerIn: parent; spacing: MeoTheme.space8; MeoIcon { anchors.horizontalCenter: parent.horizontalCenter; icon: modelData.icon; color: MeoTheme.contentOnPrimaryContainer } MeoText { text: modelData.title; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnPrimaryContainer } } } } } }
    Component { id: pageIndicatorSample; MeoPageIndicator { count: 5; currentIndex: 2 } }
    Component { id: mediaSample; MeoMediaController { width: 420 * MeoTheme.globalScale; title: "Soul Curve"; artist: "MeoUI Sessions"; isPlaying: true } }
    Component { id: toolbarSample; MeoToolbar { width: 460 * MeoTheme.globalScale; title: "Toolbar"; actions: [Component { MeoIconButton { icon.name: "search" } }, Component { MeoIconButton { icon.name: "more_vert" } }] } }
    Component { id: dockedToolbarSample; MeoDockedToolbar { width: 420 * MeoTheme.globalScale; actions: [Component { MeoIconButton { icon.name: "format_bold" } }, Component { MeoIconButton { icon.name: "format_italic" } }] } }
    Component { id: floatingToolbarSample; MeoFloatingToolbar { actions: [Component { MeoIconButton { icon.name: "content_cut" } }, Component { MeoIconButton { icon.name: "content_copy" } }, Component { MeoIconButton { icon.name: "content_paste" } }] } }
    Component { id: accountHeaderSample; MeoAccountHeader { width: 420 * MeoTheme.globalScale; name: "Meo User"; email: "hello@meoarch.dev" } }
    Component {
        id: swipeToDismissSample
        MeoSwipeToDismiss {
            width: 420 * MeoTheme.globalScale
            content: Component {
                MeoListItem {
                    width: parent.width
                    headline: "Swipe this row"
                    supportingText: "Archive left, delete right"
                    leadingIcon: "mail"
                }
            }
            leftAction: Component {
                MeoIcon {
                    icon: "archive"
                    color: MeoTheme.contentOnPrimary
                }
            }
            rightAction: Component {
                MeoIcon {
                    icon: "delete"
                    color: MeoTheme.contentOnError
                }
            }
        }
    }
    Component { id: chipSample; Flow { spacing: MeoTheme.space8; MeoChip { label: "Generic"; icon: "bolt" } MeoChip { label: "Selected"; selected: true } MeoChip { label: "Closable"; closable: true } MeoChip { label: "XL"; size: "xl"; selected: true } } }
    Component { id: assistChipSample; Flow { spacing: MeoTheme.space8; MeoAssistChip { label: "Directions"; icon: "directions" } MeoAssistChip { label: "Elevated"; icon: "star"; elevated: true } MeoAssistChip { label: "Avatar"; avatarSource: ""; icon: "person" } } }
    Component { id: filterChipSample; Flow { spacing: MeoTheme.space8; MeoFilterChip { label: "All"; selected: true } MeoFilterChip { label: "Design"; leadingIcon: "palette" } MeoFilterChip { label: "Code"; leadingIcon: "code"; enabled: false } } }
    Component { id: inputChipSample; Flow { spacing: MeoTheme.space8; MeoInputChip { label: "Avery"; leadingIcon: "person"; selected: true } MeoInputChip { label: "Review"; leadingIcon: "task_alt" } } }
    Component { id: suggestionChipSample; Flow { spacing: MeoTheme.space8; MeoSuggestionChip { label: "Material" } MeoSuggestionChip { label: "Expressive" } MeoSuggestionChip { label: "QML"; enabled: false } } }
    Component { id: pageLayoutSample; Rectangle { width: 420 * MeoTheme.globalScale; height: 170 * MeoTheme.globalScale; radius: MeoTheme.shapeLarge; color: MeoTheme.surfaceContainerLow; Column { anchors.fill: parent; anchors.margins: MeoTheme.space16; spacing: MeoTheme.space8; MeoText { text: "Page title"; typeRole: "title"; typeSize: "medium"; color: MeoTheme.contentOnSurface } MeoText { text: "Max width, padding and section spacing."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; wrapMode: Text.WordWrap; width: parent.width } } } }
    Component { id: scaffoldSample; Rectangle { width: 420 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; radius: MeoTheme.shapeLarge; color: MeoTheme.surfaceContainer; MeoText { anchors.centerIn: parent; text: "Top bar + content + bottom bar + FAB slots"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component { id: appLayoutSample; Rectangle { width: 420 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; radius: MeoTheme.shapeLarge; color: MeoTheme.surfaceContainerLow; Row { anchors.fill: parent; Rectangle { width: 90 * MeoTheme.globalScale; height: parent.height; color: MeoTheme.secondaryContainer; radius: MeoTheme.shapeLarge } MeoText { anchors.verticalCenter: parent.verticalCenter; text: "Drawer / rail / bottom navigation shell"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant; width: 260 * MeoTheme.globalScale; wrapMode: Text.WordWrap } } } }
    Component { id: dashboardSample; MeoDashboardLayout { width: 520 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; columns: 3; model: [{ "title": "Tokens" }, { "title": "Controls" }, { "title": "Patterns" }]; delegate: Component { Rectangle { property var modelData: ({ "title": "" }); radius: MeoTheme.shapeMedium; color: MeoTheme.surfaceContainerLow; MeoText { anchors.centerIn: parent; text: modelData.title; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: feedSample; MeoFeedLayout { width: 420 * MeoTheme.globalScale; height: 190 * MeoTheme.globalScale; model: [{ "title": "Release note" }, { "title": "Component update" }]; delegate: Component { MeoListItem { property var modelData: ({ "title": "" }); width: parent.width; headline: modelData.title; leadingIcon: "article" } } } }
    Component {
        id: listDetailSample
        MeoListDetailLayout {
            width: 520 * MeoTheme.globalScale
            height: 190 * MeoTheme.globalScale
            showDetail: true
            listComponent: Component {
                MeoGroupedList {
                    model: [{ "label": "Inbox" }, { "label": "Archive" }]
                    selectedIndex: 0
                }
            }
            detailComponent: Component {
                Rectangle {
                    color: MeoTheme.surfaceContainerLow
                    radius: MeoTheme.shapeLarge
                    MeoText {
                        anchors.centerIn: parent
                        text: "Detail pane"
                        typeRole: "title"
                        typeSize: "small"
                        color: MeoTheme.contentOnSurface
                    }
                }
            }
        }
    }
    Component { id: settingsSample; MeoSettingsLayout { width: 420 * MeoTheme.globalScale; height: 220 * MeoTheme.globalScale; title: "Settings"; model: [{ "sectionTitle": "Appearance", "items": [{ "title": "Dark theme", "subtitle": "Use dark colors", "icon": "dark_mode", "type": "switch", "checked": true }] }] } }
    Component { id: shapeSample; Flow { spacing: MeoTheme.space16; Repeater { model: ["squircle", "hexagon", "diamond", "pentagon", "octagon"]; delegate: Column { required property string modelData; spacing: MeoTheme.space4; MeoShape { width: 72 * MeoTheme.globalScale; height: 72 * MeoTheme.globalScale; type: modelData; color: MeoTheme.primaryContainer; radius: MeoTheme.shapeLarge } MeoText { anchors.horizontalCenter: parent.horizontalCenter; text: modelData; typeRole: "label"; typeSize: "small"; color: MeoTheme.contentOnSurfaceVariant } } } } }
    Component { id: fallbackSample; MeoText { text: "Sample registered in catalog"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } }

    component TokenSwatch: Rectangle {
        property string label: ""
        property color swatchColor: MeoTheme.primary
        property color contentColor: MeoTheme.contentOnPrimary
        width: 150 * MeoTheme.globalScale
        height: 72 * MeoTheme.globalScale
        radius: MeoTheme.shapeMedium
        color: swatchColor
        MeoText { anchors.centerIn: parent; text: parent.label; typeRole: "label"; typeSize: "big"; color: parent.contentColor }
    }

    component SurfaceCard: MeoCard {
        id: surfaceCard
        property string title: ""
        property string cardType: "elevated"
        width: 150 * MeoTheme.globalScale
        height: 92 * MeoTheme.globalScale
        type: cardType
        interactive: true
        MeoText { anchors.centerIn: parent; text: surfaceCard.title; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurface }
    }
}
