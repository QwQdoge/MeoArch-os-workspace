import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import MeoUI

Item {
    id: control

    property var componentData: ({})

    implicitWidth: sampleLoader.implicitWidth
    implicitHeight: sampleLoader.implicitHeight
    width: parent ? Math.min(implicitWidth, parent.width) : implicitWidth
    clip: width < implicitWidth

    WheelHandler {
        enabled: control.width < control.implicitWidth
        acceptedDevices: PointerDevice.Mouse | PointerDevice.TouchPad
        onWheel: event => {
            const next = sampleLoader.x + event.angleDelta.y
            sampleLoader.x = Math.max(control.width - sampleLoader.implicitWidth, Math.min(0, next))
        }
    }

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
    readonly property var carouselItems: [
        { "title": "Color", "icon": "palette" },
        { "title": "Type", "icon": "text_fields" },
        { "title": "Motion", "icon": "animation" },
        { "title": "Shape", "icon": "category" },
        { "title": "Layout", "icon": "view_quilt" }
    ]

    Loader {
        id: sampleLoader
        sourceComponent: sampleFor(control.componentData.name || "")
        Behavior on x { NumberAnimation { duration: MeoTheme.motionDurationState; easing.bezierCurve: MeoTheme.motionEasingStandardDecelerate } }
    }

    function sampleFor(name) {
        if (name === "MeoTheme") return foundationsSample
        if (name === "MeoWindowMetrics") return windowMetricsSample
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
    Component { id: windowMetricsSample; Row { spacing: MeoTheme.space8; Repeater { model: [{"label":"Small","width":640},{"label":"Medium","width":800},{"label":"Large","width":1200}]; delegate: MeoChip { required property var modelData; label: modelData.label + " · " + modelData.width; selected: modelData.width === 800 } } } }
    Component { id: textSample; Column { spacing: MeoTheme.space4; MeoText { text: "Display title"; typeRole: "title"; typeSize: "big"; emphasized: true; color: MeoTheme.contentOnSurface } MeoText { text: "Roboto body text with semantic type tokens."; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component { id: iconSample; Flow { spacing: MeoTheme.space12; Repeater { model: ["palette", "smart_button", "edit", "search", "auto_awesome"]; delegate: MeoIcon { required property string modelData; icon: modelData; color: MeoTheme.primary; size: 32 } } } }
    Component { id: stateLayerSample; Rectangle { width: 180 * MeoTheme.globalScale; height: MeoTheme.buttonHeightM; radius: MeoTheme.shapeMedium; color: MeoTheme.surfaceContainer; MeoStateLayer { anchors.fill: parent; radius: parent.radius; hovered: true; focused: true; color: MeoTheme.primary } MeoText { anchors.centerIn: parent; text: "Hover + focus"; typeRole: "label"; typeSize: "big"; color: MeoTheme.contentOnSurface } } }
    Component {
        id: buttonSample
        GridLayout {
            columns: 5
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space12

            SampleLabel { label: "Type" }
            SampleLabel { label: "Text" }
            SampleLabel { label: "With icon" }
            SampleLabel { label: "Disabled" }
            SampleLabel { label: "Loading" }

            SampleLabel { label: "Filled" }
            MeoButton { text: "Filled"; type: "filled" }
            MeoButton { text: "Icon"; type: "filled"; icon.name: "add" }
            MeoButton { text: "Filled"; type: "filled"; enabled: false }
            MeoButton { text: "Loading"; type: "filled"; loading: true; loadingWithContainer: true }

            SampleLabel { label: "Tonal" }
            MeoButton { text: "Tonal"; type: "tonal" }
            MeoButton { text: "Icon"; type: "tonal"; icon.name: "star" }
            MeoButton { text: "Tonal"; type: "tonal"; enabled: false }
            MeoButton { text: "Loading"; type: "tonal"; loading: true }

            SampleLabel { label: "Outlined" }
            MeoButton { text: "Outlined"; type: "outlined" }
            MeoButton { text: "Icon"; type: "outlined"; icon.name: "add" }
            MeoButton { text: "Outlined"; type: "outlined"; enabled: false }
            MeoButton { text: "Loading"; type: "outlined"; loading: true }

            SampleLabel { label: "Elevated" }
            MeoButton { text: "Elevated"; type: "elevated" }
            MeoButton { text: "Icon"; type: "elevated"; icon.name: "add" }
            MeoButton { text: "Elevated"; type: "elevated"; enabled: false }
            MeoButton { text: "Loading"; type: "elevated"; loading: true }

            SampleLabel { label: "Text" }
            MeoButton { text: "Text"; type: "text" }
            MeoButton { text: "Icon"; type: "text"; icon.name: "add" }
            MeoButton { text: "Text"; type: "text"; enabled: false }
            MeoButton { text: "Loading"; type: "text"; loading: true }
        }
    }

    Component {
        id: iconButtonSample
        GridLayout {
            columns: 4
            rowSpacing: MeoTheme.space16
            columnSpacing: MeoTheme.space24

            IconButtonColumn { label: "Standard"; buttonType: "standard"; buttonIcon: "settings" }
            IconButtonColumn { label: "Filled"; buttonType: "filled"; buttonIcon: "favorite"; selected: true }
            IconButtonColumn { label: "Tonal"; buttonType: "tonal"; buttonIcon: "bookmark"; badgeDot: true }
            IconButtonColumn { label: "Outlined"; buttonType: "outlined"; buttonIcon: "share" }
            IconButtonColumn { label: "Disabled"; buttonType: "standard"; buttonIcon: "settings"; enabledState: false }
            IconButtonColumn { label: "Disabled"; buttonType: "filled"; buttonIcon: "favorite"; enabledState: false }
            IconButtonColumn { label: "Disabled"; buttonType: "tonal"; buttonIcon: "bookmark"; enabledState: false }
            IconButtonColumn { label: "Disabled"; buttonType: "outlined"; buttonIcon: "share"; enabledState: false }
        }
    }

    Component {
        id: fabSample
        Flow {
            spacing: MeoTheme.space24
            FabColumn { label: "Small"; fabType: "small"; fabIcon: "edit" }
            FabColumn { label: "Regular"; fabType: "regular"; fabIcon: "add" }
            FabColumn { label: "Large"; fabType: "large"; fabIcon: "palette" }
            FabColumn { label: "Extended"; fabType: "extended"; fabIcon: "send"; fabText: "Send" }
        }
    }
    Component { id: fabMenuSample; Item { width: 220 * MeoTheme.globalScale; height: 96 * MeoTheme.globalScale; MeoFABMenu { anchors.centerIn: parent; model: control.chipItems } } }
    Component { id: splitButtonSample; MeoSplitButton { text: "Create"; icon: "add"; menuModel: control.chipItems } }
    Component { id: buttonGroupSample; MeoButtonGroup { model: [{ "label": "Day" }, { "label": "Week" }, { "label": "Month" }]; currentIndex: 1 } }
    Component { id: segmentedSample; MeoSegmentedButtons { width: 420 * MeoTheme.globalScale; model: [{ "label": "List", "icon": "view_list" }, { "label": "Grid", "icon": "grid_view" }, { "label": "Map", "icon": "map" }]; currentIndex: 1 } }
    Component {
        id: textFieldSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space16
            columnSpacing: MeoTheme.space16

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: "Filled"
                placeholder: "Filled input"
                helperText: "Supporting text"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: "Outlined"
                placeholder: "Outlined input"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: "Search"
                leadingIcon: "search"
                trailingIcon: "close"
                showClearButton: true
                text: "Material"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: "Password"
                placeholder: "Enter password"
                trailingIcon: "visibility"
                echoMode: TextInput.Password
                text: "secret"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: "Error"
                text: "bad input"
                isError: true
                errorText: "Invalid input"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: "Counter"
                text: "Short note"
                maxLength: 24
                showCounter: true
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "filled"
                label: "Prefix / suffix"
                prefixText: "$"
                suffixText: "USD"
                text: "128"
            }

            MeoTextField {
                width: 280 * MeoTheme.globalScale
                type: "outlined"
                label: "Disabled"
                text: "Disabled"
                enabled: false
            }
        }
    }
    Component { id: textAreaSample; MeoTextArea { width: 420 * MeoTheme.globalScale; height: 150 * MeoTheme.globalScale; label: "Description"; type: "outlined"; placeholder: "Enter multiline text"; helperText: "Supporting text"; maxLength: 200; showCounter: true } }
    Component { id: dropdownSample; Flow { spacing: MeoTheme.space12; MeoExposedDropdown { width: 240 * MeoTheme.globalScale; label: "Environment"; model: ["Development", "Staging", "Production"] } MeoExposedDropdown { width: 220 * MeoTheme.globalScale; label: "Disabled"; model: ["Unavailable"]; enabled: false } } }
    Component { id: dateInputSample; MeoDateInput { width: 220 * MeoTheme.globalScale } }
    Component { id: timeInputSample; MeoTimeInput { width: 220 * MeoTheme.globalScale } }
    Component {
        id: datePickerSample
        Column {
            spacing: MeoTheme.space8

            MeoText {
                text: "Selected: 2026-07-04"
                typeRole: "label"
                typeSize: "medium"
                color: MeoTheme.contentOnSurfaceVariant
            }

            MeoDatePicker {
                selectedDate: new Date(2026, 6, 4)
            }
        }
    }
    Component { id: dateRangeSample; MeoDateRangePicker { startDate: new Date(2026, 6, 1); endDate: new Date(2026, 6, 12) } }
    Component {
        id: timePickerSample
        Column {
            spacing: MeoTheme.space8

            MeoText {
                text: "Selected: 10:30"
                typeRole: "label"
                typeSize: "medium"
                color: MeoTheme.contentOnSurfaceVariant
            }

            MeoTimePicker {
                hours: 10
                minutes: 30
            }
        }
    }
    Component {
        id: checkboxSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space24

            MeoCheckbox { label: "Checked"; checked: true }
            MeoCheckbox { label: "Unchecked" }
            MeoCheckbox { label: "Indeterminate"; indeterminate: true }
            MeoCheckbox { label: "Disabled"; checked: true; enabled: false }
        }
    }
    Component {
        id: radioSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space24

            MeoRadioButton { label: "Selected"; checked: true }
            MeoRadioButton { label: "Unselected" }
            MeoRadioButton { label: "Disabled selected"; checked: true; enabled: false }
            MeoRadioButton { label: "Disabled"; enabled: false }
        }
    }
    Component {
        id: switchSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space24

            MeoSwitch { label: "On"; checked: true; icon: "check" }
            MeoSwitch { label: "Off"; uncheckedIcon: "close" }
            MeoSwitch { label: "Disabled on"; checked: true; icon: "check"; enabled: false }
            MeoSwitch { label: "Disabled off"; uncheckedIcon: "close"; enabled: false }
        }
    }
    Component {
        id: sliderSample
        GridLayout {
            columns: 2
            rowSpacing: MeoTheme.space12
            columnSpacing: MeoTheme.space16

            SampleLabel { label: "Continuous" }
            MeoSlider { width: 360 * MeoTheme.globalScale; value: 35 }

            SampleLabel { label: "Discrete ticks" }
            MeoSlider { width: 360 * MeoTheme.globalScale; value: 40; discrete: true; stepSize: 20; size: "xs" }

            SampleLabel { label: "Expressive thick" }
            MeoSlider { width: 360 * MeoTheme.globalScale; value: 65; isThick: true; size: "l" }

            SampleLabel { label: "Wavy" }
            MeoSlider { width: 360 * MeoTheme.globalScale; value: 70; discrete: true; wavy: true; isThick: true }

            SampleLabel { label: "Disabled" }
            MeoSlider { width: 360 * MeoTheme.globalScale; value: 30; enabled: false }
        }
    }
    Component { id: rangeSliderSample; MeoRangeSlider { width: 360 * MeoTheme.globalScale; firstValue: 24; secondValue: 78 } }
    Component { id: selectionGroupSample; MeoSelectionGroup { width: 360 * MeoTheme.globalScale; type: "checkbox"; showSelectAll: true; model: [{ "label": "Design", "checked": true }, { "label": "Code", "checked": false }] } }
    Component { id: filterGroupSample; MeoFilterGroup { width: 420 * MeoTheme.globalScale; model: control.chipItems; currentIndex: 0 } }
    Component { id: stepperSample; Flow { spacing: MeoTheme.space16; MeoStepper { width: 420 * MeoTheme.globalScale; model: [{ "label": "Account" }, { "label": "Profile" }, { "label": "Review" }]; currentIndex: 1 } MeoStepper { height: 220 * MeoTheme.globalScale; orientation: "vertical"; model: [{ "label": "Draft" }, { "label": "Check" }, { "label": "Publish" }]; currentIndex: 2 } } }
    Component { id: navigationBarSample; MeoNavigationBar { width: 420 * MeoTheme.globalScale; model: control.navItems; currentIndex: 1 } }
    Component {
        id: navigationRailSample
        Flow {
            spacing: MeoTheme.space24

            MeoNavigationRail {
                height: 340 * MeoTheme.globalScale
                model: control.navItems
                currentIndex: 1
                labelType: "selected"
                header: Component {
                    Column {
                        spacing: MeoTheme.space12
                        MeoIconButton { anchors.horizontalCenter: parent.horizontalCenter; icon.name: "menu"; type: "standard" }
                        MeoFAB { anchors.horizontalCenter: parent.horizontalCenter; type: "small"; icon.name: "edit" }
                    }
                }
                footer: Component {
                    MeoIconButton { icon.name: "settings"; type: "tonal" }
                }
            }

            MeoNavigationRail {
                height: 340 * MeoTheme.globalScale
                model: control.navItems
                currentIndex: 1
                isExpanded: true
                header: Component {
                    Row {
                        spacing: MeoTheme.space8
                        MeoIconButton { icon.name: "menu"; type: "standard" }
                        MeoButton { text: "Compose"; type: "filled"; icon.name: "edit" }
                    }
                }
            }
        }
    }
    Component { id: navigationDrawerSample; MeoNavigationDrawer { width: 260 * MeoTheme.globalScale; height: 260 * MeoTheme.globalScale; model: control.navItems; currentIndex: 0; title: "MeoUI" } }
    Component { id: modalDrawerSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open modal drawer"; onClicked: drawer.open() } MeoNavigationDrawerModal { id: drawer; model: control.navItems } } }
    Component { id: drawerItemSample; Column { width: 360 * MeoTheme.globalScale; spacing: MeoTheme.space4; MeoNavigationDrawerItem { width: parent.width; label: "Inbox"; icon: "inbox"; selected: true; badgeText: "8" } MeoNavigationDrawerItem { width: parent.width; label: "Archive"; icon: "archive"; supportingText: "Grouped row"; mode: "group" } } }
    Component { id: navigationSuiteSample; MeoNavigationSuite { width: 520 * MeoTheme.globalScale; height: 180 * MeoTheme.globalScale; model: control.navItems; currentIndex: 0; availableWidth: width } }
    Component { id: breadcrumbsSample; MeoBreadcrumbs { model: [{ "label": "Home", "icon": "home" }, { "label": "Library" }, { "label": "Component" }] } }
    Component {
        id: tabsSample
        Column {
            width: 460 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            SampleLabel { label: "Primary tabs with icons" }
            MeoTabs {
                width: parent.width
                type: "primary"
                model: [{ "label": "Video", "icon": "videocam" }, { "label": "Photos", "icon": "photo", "badgeDot": true }, { "label": "Audio", "icon": "audiotrack" }]
                currentIndex: 1
            }

            SampleLabel { label: "Primary tabs text only" }
            MeoTabs {
                width: parent.width
                type: "primary"
                model: ["Overview", "Specs", "Reviews"]
                currentIndex: 0
            }

            SampleLabel { label: "Secondary tabs" }
            MeoTabs {
                width: parent.width
                type: "secondary"
                model: ["Explore", "Flights", "Trips"]
                currentIndex: 2
            }
        }
    }
    Component {
        id: topAppBarSample
        Column {
            width: 500 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            MeoTopAppBar {
                width: parent.width
                title: "Library"
                type: "medium"
                navigationIcon: Component { MeoIconButton { icon.name: "arrow_back"; type: "standard" } }
                actions: [Component { MeoIconButton { icon.name: "search" } }, Component { MeoIconButton { icon.name: "favorite" } }, Component { MeoIconButton { icon.name: "more_vert" } }]
            }

            MeoTopAppBar {
                width: parent.width
                title: "3"
                type: "small"
                isContextual: true
                selectionCount: 3
                navigationIcon: Component { MeoIconButton { icon.name: "close"; type: "standard" } }
                actions: [Component { MeoIconButton { icon.name: "delete" } }, Component { MeoIconButton { icon.name: "archive" } }]
            }
        }
    }
    Component {
        id: bottomAppBarSample
        MeoBottomAppBar {
            width: 500 * MeoTheme.globalScale
            navigationIcons: ["check_box", "edit", "search", "more_vert"]
            fab: Component { MeoFAB { type: "regular"; icon.name: "add" } }
        }
    }
    Component {
        id: menuSample
        Column {
            spacing: MeoTheme.space8

            MeoButton {
                id: menuButton
                text: "Open menu"
                type: "filled"
                onClicked: menu.openAt(menuButton, 0, height)
            }

            MeoMenu {
                id: menu
                itemSpacing: MeoTheme.space4
                model: [
                    { "label": "Copy", "icon": "content_copy", "trailingText": "Ctrl+C" },
                    { "label": "Share", "icon": "share", "isVibrant": true },
                    { "label": "More tools", "icon": "folder", "subItems": [{ "label": "Inspect" }, { "label": "Format" }] },
                    { "type": "separator" },
                    { "label": "Paste", "icon": "content_paste", "trailingText": "Ctrl+V", "enabled": false },
                    { "label": "Delete", "icon": "delete", "trailingIcon": "keyboard_return" }
                ]
            }
        }
    }
    Component { id: dataTableSample; MeoDataTable { width: 520 * MeoTheme.globalScale; columns: control.tableColumns; model: control.tableRows; selectable: true; sortProperty: "calories" } }
    Component { id: listItemSample; Column { width: 420 * MeoTheme.globalScale; MeoListItem { width: parent.width; headline: "One-line item"; leadingIcon: "inbox"; badgeText: "3" } MeoListItem { width: parent.width; headline: "Two-line item"; supportingText: "Supporting text"; leadingIcon: "article"; selected: true } } }
    Component { id: listHeaderSample; MeoListHeader { text: "Component group"; type: "emphasized" } }
    Component { id: groupedListSample; MeoGroupedList { width: 420 * MeoTheme.globalScale; title: "Settings"; selectedIndex: 1; model: [{ "label": "Theme", "icon": "palette" }, { "label": "Typography", "icon": "text_fields", "supportingText": "Roboto and Comfortaa" }] } }
    Component { id: badgeSample; Flow { spacing: MeoTheme.space16; MeoBadge { isDot: true } MeoBadge { text: "8" } MeoBadge { text: "120" } } }
    Component { id: avatarSample; Flow { spacing: MeoTheme.space12; MeoAvatar { initials: "ME"; variant: "circle" } MeoAvatar { initials: "UI"; variant: "squircle" } MeoAvatar { initials: "M3"; variant: "hexagon" } } }
    Component { id: dividerSample; Column { width: 360 * MeoTheme.globalScale; spacing: MeoTheme.space8; MeoText { text: "Above"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } MeoDivider {} MeoText { text: "Below"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component { id: skeletonSample; Column { width: 360 * MeoTheme.globalScale; spacing: MeoTheme.space8; MeoSkeleton { width: parent.width; height: MeoTheme.buttonHeightM } MeoSkeleton { width: parent.width * 0.7; height: MeoTheme.buttonHeightXS } } }
    Component {
        id: cardSample
        Flow {
            spacing: MeoTheme.space24
            SurfaceCard { title: "Elevated"; cardType: "elevated" }
            SurfaceCard { title: "Filled"; cardType: "filled" }
            SurfaceCard { title: "Outlined"; cardType: "outlined" }
        }
    }

    Component {
        id: dialogSample
        Column {
            spacing: MeoTheme.space12

            Flow {
                spacing: MeoTheme.space8

                MeoButton {
                    text: "Basic dialog"
                    onClicked: basicDialog.open()
                }

                MeoButton {
                    text: "Dialog with icon"
                    type: "tonal"
                    onClicked: iconDialog.open()
                }

                MeoButton {
                    text: "Single select"
                    type: "outlined"
                    onClicked: singleSelectDialog.open()
                }

                MeoButton {
                    text: "Multi select"
                    type: "outlined"
                    onClicked: multiSelectDialog.open()
                }
            }

            MeoDialog {
                id: basicDialog
                title: "Basic dialog"
                message: "This dialog asks for a focused decision."
                confirmText: "Accept"
                cancelText: "Cancel"
            }

            MeoDialog {
                id: iconDialog
                icon: "info"
                title: "Dialog with icon"
                message: "A hero icon reinforces the message."
                confirmText: "Confirm"
                cancelText: "Dismiss"
            }

            MeoExpressiveDialog {
                id: singleSelectDialog
                title: "Choose density"
                message: "Selection dialogs keep choices in one focused surface."
                confirmText: "Apply"
                cancelText: "Cancel"
                content: Component {
                    Column {
                        spacing: MeoTheme.space8
                        MeoRadioButton { label: "Comfortable"; checked: true }
                        MeoRadioButton { label: "Compact" }
                        MeoRadioButton { label: "Expanded" }
                    }
                }
            }

            MeoExpressiveDialog {
                id: multiSelectDialog
                title: "Visible columns"
                message: "Use checkboxes when multiple items can stay selected."
                confirmText: "Save"
                cancelText: "Cancel"
                content: Component {
                    Column {
                        spacing: MeoTheme.space8
                        MeoCheckbox { label: "Name"; checked: true }
                        MeoCheckbox { label: "Status"; checked: true }
                        MeoCheckbox { label: "Owner" }
                    }
                }
            }
        }
    }
    Component { id: fullDialogSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open full dialog"; onClicked: full.open() } MeoFullScreenDialog { id: full; title: "Edit item" } } }
    Component { id: expressiveDialogSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open expressive dialog"; onClicked: dialog.open() } MeoExpressiveDialog { id: dialog; title: "Expressive"; message: "Custom content and shape."; icon: "auto_awesome" } } }
    Component { id: bottomSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open bottom sheet"; onClicked: sheet.open() } MeoBottomSheet { id: sheet; content: Component { MeoText { text: "Bottom sheet content"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: standardSheetSample; Item { width: 420 * MeoTheme.globalScale; height: 160 * MeoTheme.globalScale; MeoStandardBottomSheet { anchors.fill: parent; isOpen: true; content: Component { MeoText { text: "Standard sheet"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: sideSheetSample; Item { width: 420 * MeoTheme.globalScale; height: 160 * MeoTheme.globalScale; MeoSideSheet { anchors.right: parent.right; width: 240 * MeoTheme.globalScale; height: parent.height; isOpen: true; content: Component { MeoText { text: "Details"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: modalSideSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open side sheet"; onClicked: sheet.open() } MeoSideSheetModal { id: sheet; content: Component { MeoText { text: "Modal side sheet"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurface } } } } }
    Component { id: actionSheetSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open action sheet"; onClicked: sheet.open() } MeoActionSheet { id: sheet; title: "Share"; model: [{ "label": "Messages", "icon": "chat" }, { "label": "Email", "icon": "mail" }] } } }
    Component { id: bannerSample; MeoBanner { width: 460 * MeoTheme.globalScale; text: "This banner includes an icon and actions."; icon: "info"; confirmText: "Action"; cancelText: "Dismiss" } }
    Component {
        id: snackbarSample
        Column {
            spacing: MeoTheme.space8

            Flow {
                spacing: MeoTheme.space8

                MeoButton {
                    text: "Show snackbar"
                    type: "filled"
                    onClicked: {
                        snackbar.message = "Message sent"
                        snackbar.actionText = ""
                        snackbar.open()
                    }
                }

                MeoButton {
                    text: "With action"
                    type: "outlined"
                    onClicked: {
                        snackbar.message = "Photo deleted"
                        snackbar.actionText = "Undo"
                        snackbar.open()
                    }
                }
            }

            MeoSnackbar {
                id: snackbar
                message: "Saved"
                actionText: "Undo"
            }
        }
    }

    Component {
        id: tooltipSample
        Item {
            width: 260 * MeoTheme.globalScale
            height: MeoTheme.buttonHeightL

            MeoButton {
                id: hoverButton
                anchors.centerIn: parent
                text: "Hover target"
                type: "outlined"
            }

            MouseArea {
                anchors.fill: hoverButton
                hoverEnabled: true
                acceptedButtons: Qt.NoButton
                onEntered: tip.open()
                onExited: tip.close()
            }

            MeoTooltip {
                id: tip
                text: "Tooltip on hover"
                x: hoverButton.x + hoverButton.width / 2 - width / 2
                y: hoverButton.y - height - MeoTheme.space8
            }
        }
    }
    Component { id: richTooltipSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open rich tooltip"; onClicked: tip.open() } MeoRichTooltip { id: tip; title: "Rich tooltip"; text: "Useful supporting detail."; icon: "tips_and_updates" } } }
    Component {
        id: progressSample
        Column {
            width: 460 * MeoTheme.globalScale
            spacing: MeoTheme.space12

            SampleLabel { label: "Determinate linear" }
            MeoProgressBar { width: parent.width; value: 0.42 }

            SampleLabel { label: "Indeterminate linear" }
            MeoProgressBar { width: parent.width; indeterminate: true; vibrant: true }

            SampleLabel { label: "Wavy progress" }
            MeoProgressBar { width: parent.width; type: "linear"; wavy: true; value: 0.72; isThick: true }

            Flow {
                spacing: MeoTheme.space24
                MeoProgressBar { type: "circular"; value: 0.62 }
                MeoProgressBar { type: "circular"; indeterminate: true; vibrant: true }
            }
        }
    }

    Component {
        id: loadingSample
        Flow {
            spacing: MeoTheme.space16
            MeoLoadingIndicator { size: "s"; running: true }
            MeoLoadingIndicator { size: "m"; running: true; vibrant: true }
            MeoLoadingIndicator { size: "l"; running: true; withContainer: true }
            MeoButton {
                text: "Loading..."
                type: "outlined"
                loading: true
            }
        }
    }
    Component { id: pullRefreshSample; Rectangle { width: 360 * MeoTheme.globalScale; height: 120 * MeoTheme.globalScale; radius: MeoTheme.shapeMedium; color: MeoTheme.surfaceContainerLow; MeoText { anchors.centerIn: parent; text: "Pull refresh wraps scroll content"; typeRole: "body"; typeSize: "medium"; color: MeoTheme.contentOnSurfaceVariant } } }
    Component { id: emptyStateSample; MeoEmptyState { width: 420 * MeoTheme.globalScale; icon: "inbox"; title: "No messages"; description: "Empty states explain what happened."; actionText: "Refresh" } }
    Component { id: searchBarSample; MeoSearchBar { width: 420 * MeoTheme.globalScale; placeholder: "Search components" } }
    Component { id: dockedSearchSample; MeoDockedSearchBar { width: 460 * MeoTheme.globalScale; placeholder: "Docked search" } }
    Component { id: searchAppBarSample; MeoSearchAppBar { width: 460 * MeoTheme.globalScale; placeholder: "Searchable page" } }
    Component { id: searchViewSample; Column { spacing: MeoTheme.space8; MeoButton { text: "Open search view"; onClicked: view.open() } MeoSearchView { id: view; placeholder: "Search anything"; suggestions: [{ "label": "MeoTheme", "isHistory": true }, { "label": "MeoButton" }] } } }
    Component { id: searchSuggestionsSample; MeoSearchSuggestions { width: 420 * MeoTheme.globalScale; highlightText: "meo"; model: [{ "label": "MeoTheme tokens", "icon": "palette" }, { "label": "MeoButton usage", "icon": "smart_button" }] } }
    Component { id: searchHeaderSample; MeoSearchHeader { width: 520 * MeoTheme.globalScale; title: "Library"; placeholder: "Search"; actions: [Component { MeoIconButton { icon.name: "help" } }] } }
    Component { id: searchFilterSample; MeoSearchFilterBar { width: 520 * MeoTheme.globalScale; placeholder: "Search issues"; filterModel: control.chipItems; selectedFilterIndices: [0, 2] } }
    Component {
        id: carouselSample
        Column {
            width: 560 * MeoTheme.globalScale
            spacing: MeoTheme.space16

            SampleLabel { label: "Multi-browse" }
            MeoCarousel {
                width: parent.width
                itemHeight: 140 * MeoTheme.globalScale
                type: "multi-browse"
                model: control.carouselItems
                delegate: Component { CarouselTile {} }
            }

            SampleLabel { label: "Hero" }
            MeoCarousel {
                width: parent.width
                itemHeight: 170 * MeoTheme.globalScale
                type: "hero"
                model: control.carouselItems
                delegate: Component { CarouselTile { tileType: "hero" } }
            }

            SampleLabel { label: "Uncontained" }
            MeoCarousel {
                width: parent.width
                itemHeight: 120 * MeoTheme.globalScale
                type: "uncontained"
                showPageIndicator: false
                model: control.carouselItems
                delegate: Component { CarouselTile { tileType: "outlined" } }
            }
        }
    }
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
        width: 200 * MeoTheme.globalScale
        height: 200 * MeoTheme.globalScale
        type: cardType
        interactive: true

        MeoIconButton {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: MeoTheme.space8
            icon.name: "more_vert"
            type: "standard"
        }

        MeoText {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: MeoTheme.space16
            text: surfaceCard.title
            typeRole: "title"
            typeSize: "small"
            emphasized: true
            color: MeoTheme.contentOnSurface
        }
    }

    component SampleLabel: MeoText {
        property string label: ""
        text: label
        typeRole: "label"
        typeSize: "medium"
        color: MeoTheme.contentOnSurfaceVariant
        Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
    }

    component IconButtonColumn: Column {
        property string label: ""
        property string buttonType: "standard"
        property string buttonIcon: "settings"
        property bool selected: false
        property bool badgeDot: false
        property bool enabledState: true

        spacing: MeoTheme.space8
        Layout.alignment: Qt.AlignHCenter

        MeoIconButton {
            anchors.horizontalCenter: parent.horizontalCenter
            type: parent.buttonType
            icon.name: parent.buttonIcon
            selected: parent.selected
            badgeDot: parent.badgeDot
            enabled: parent.enabledState
        }

        SampleLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            label: parent.label
            opacity: parent.enabledState ? 1.0 : 0.62
        }
    }

    component FabColumn: Column {
        property string label: ""
        property string fabType: "regular"
        property string fabIcon: "add"
        property string fabText: ""

        spacing: MeoTheme.space8

        MeoFAB {
            anchors.horizontalCenter: parent.horizontalCenter
            type: parent.fabType
            icon.name: parent.fabIcon
            text: parent.fabText
        }

        SampleLabel {
            anchors.horizontalCenter: parent.horizontalCenter
            label: parent.label
        }
    }

    component CarouselTile: Rectangle {
        id: carouselTile
        property var modelData: ({ "title": "", "icon": "" })
        property string tileType: "filled"

        radius: MeoTheme.shapeLarge
        color: carouselTile.tileType === "outlined" ? MeoTheme.surface : (carouselTile.tileType === "hero" ? MeoTheme.tertiaryContainer : MeoTheme.primaryContainer)
        border.color: carouselTile.tileType === "outlined" ? MeoTheme.outlineVariant : "transparent"
        border.width: carouselTile.tileType === "outlined" ? 1 * MeoTheme.globalScale : 0

        Column {
            anchors.centerIn: parent
            spacing: MeoTheme.space8

            MeoIcon {
                anchors.horizontalCenter: parent.horizontalCenter
                icon: carouselTile.modelData.icon
                size: carouselTile.tileType === "hero" ? 32 : 24
                color: carouselTile.tileType === "outlined" ? MeoTheme.primary : (carouselTile.tileType === "hero" ? MeoTheme.contentOnTertiaryContainer : MeoTheme.contentOnPrimaryContainer)
            }

            MeoText {
                text: carouselTile.modelData.title
                typeRole: "label"
                typeSize: "big"
                color: carouselTile.tileType === "outlined" ? MeoTheme.contentOnSurface : (carouselTile.tileType === "hero" ? MeoTheme.contentOnTertiaryContainer : MeoTheme.contentOnPrimaryContainer)
            }
        }
    }
}
