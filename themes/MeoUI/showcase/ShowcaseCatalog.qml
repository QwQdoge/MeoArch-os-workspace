import QtQuick

QtObject {
    id: catalog

    readonly property var categories: [
        {
            "id": "foundations",
            "label": "Foundations",
            "icon": "palette",
            "subtitle": "Theme tokens, colors, typography, shape, motion, state layers, icons, and font resources.",
            "components": [
                component("MeoTheme", "MeoTheme.qml", "Color roles, type scale, motion, spacing, shape, state, and density tokens.", "theme, colors, typography, motion, shape, scale", "Color roles, type tokens, motion tokens, shape tokens, spacing tokens", "globalScale, isDarkMode, isExpressive, typefacePlain, typefaceBrand", "Use semantic tokens from MeoTheme instead of raw values."),
                component("MeoWindowMetrics", "MeoWindowMetrics.qml", "Windows-style effective-pixel breakpoints and adaptive page metrics.", "small, medium, large, navigation mode, columns", "Small ≤640, Medium 641–1007, Large ≥1008", "availableWidth, availableHeight, sizeClass, pageMargin, preferredColumns", "MeoWindowMetrics { availableWidth: page.width; availableHeight: page.height }"),
                component("MeoText", "components/MeoText.qml", "Semantic text wrapper for display, title, body, and label roles.", "title, body, label, emphasized, fallback fonts", "Role variants, sizes, emphasized variants, Chinese fallback", "text, typeRole, typeSize, emphasized, color", "MeoText { text: \"Page title\"; typeRole: \"title\"; typeSize: \"big\" }"),
                component("MeoIcon", "components/MeoIcon.qml", "Material Symbols icon renderer used across controls.", "icon, size, color, symbol font", "Icon names, color roles, size tokens", "icon, size, color", "MeoIcon { icon: \"palette\"; color: MeoTheme.primary }"),
                component("MeoStateLayer", "components/MeoStateLayer.qml", "Shared hover, focus, pressed, dragged, and ripple state layer.", "hovered, focused, pressed, dragged, ripple", "Normal, hovered, focused, pressed, dragged", "hovered, focused, pressed, dragged, color, radius", "Use inside interactive surfaces instead of hand-built hover fills.")
            ]
        },
        {
            "id": "actions",
            "label": "Actions",
            "icon": "smart_button",
            "subtitle": "Buttons, icon buttons, FABs, grouped actions, split actions, and segmented controls.",
            "components": [
                component("MeoButton", "components/MeoButton.qml", "Primary action button with MD3 types, sizes, loading, selected, vibrant, and expressive states.", "filled, tonal, outlined, elevated, text, loading, selected", "Normal, disabled, icon, loading, selected, focused, xs/s/m/l/xl", "text, type, size, shape, loading, loadingWithContainer, selected, vibrant", "MeoButton { text: \"Save\"; type: \"filled\"; size: \"m\" }"),
                component("MeoIconButton", "components/MeoIconButton.qml", "Icon-only action with standard, filled, tonal, outlined, selected, badge, and size variants.", "standard, filled, tonal, outlined, selected, badge", "Normal, selected, disabled, badge, xs/s/m/l/xl", "icon.name, type, size, selected, selectedIcon, badgeText, badgeDot", "MeoIconButton { icon.name: \"favorite\"; type: \"filled\" }"),
                component("MeoIconToggleButton", "components/MeoIconToggleButton.qml", "Icon toggle action with standard, filled, tonal, and outlined types.", "standard, filled, tonal, outlined", "Normal, checked, disabled, badge, xs/s/m/l/xl", "icon.name, type, size, checked, checkedIcon, badgeText, badgeDot", "MeoIconToggleButton { icon.name: \"favorite_border\"; checkedIcon: \"favorite\"; type: \"standard\" }"),
                component("MeoFAB", "components/MeoFAB.qml", "Floating action button for prominent primary actions.", "small, regular, large, extended, collapsed", "Small, regular, large, extended, collapsed", "type, collapsed, icon.name, text", "MeoFAB { type: \"large\"; icon.name: \"add\" }"),
                component("MeoFABMenu", "components/MeoFABMenu.qml", "Speed-dial style floating action menu.", "menu actions, expanded state", "Closed, opened, action list", "model, icon, expanded", "Use for multiple related primary actions."),
                component("MeoSplitButton", "components/MeoSplitButton.qml", "Combined primary action and dropdown affordance.", "primary action, menu action, sizes", "Default, emphasized, menu open-ready", "text, icon, size, type", "MeoSplitButton { text: \"Create\" }"),
                component("MeoButtonGroup", "components/MeoButtonGroup.qml", "Connected button group with single selection.", "filled, tonal, outlined, elevated", "Selected item, disabled-ready, sizes", "model, type, size, currentIndex", "MeoButtonGroup { model: [\"Day\", \"Week\", \"Month\"] }"),
                component("MeoSegmentedButtons", "components/MeoSegmentedButtons.qml", "Segmented selection control with single and multi-select modes.", "single, multi, icons, sizes", "Selected, multi-selected, disabled-ready, xs/s/m/l/xl", "model, currentIndex, multiSelect, selectedIndices, size", "MeoSegmentedButtons { model: [\"List\", \"Grid\"] }")
            ]
        },
        {
            "id": "text-input",
            "label": "Text Input",
            "icon": "edit",
            "subtitle": "Text fields, text areas, dropdowns, date inputs, time inputs, and picker widgets.",
            "components": [
                component("MeoTextField", "components/MeoTextField.qml", "Filled and outlined single-line input with icons, helper text, error, clear, prefix, suffix, and counter.", "filled, outlined, icons, helper, error", "Normal, focused-ready, error, disabled, password-style, counter, xs/s/m/l/xl", "type, size, label, placeholder, helperText, isError, errorText, leadingIcon, trailingIcon, prefixText, suffixText, showCounter", "MeoTextField { label: \"Email\"; type: \"outlined\"; leadingIcon: \"mail\" }"),
                component("MeoTextArea", "components/MeoTextArea.qml", "Multiline filled or outlined text input.", "filled, outlined, helper, error, counter", "Normal, error, disabled-ready, counter", "type, label, placeholder, helperText, isError, errorText, maxLength, showCounter", "MeoTextArea { label: \"Description\"; type: \"outlined\" }"),
                component("MeoExposedDropdown", "components/MeoExposedDropdown.qml", "Text-field based menu selector.", "menu, selection, disabled", "Default, disabled, menu-ready", "label, model, currentIndex, enabled", "MeoExposedDropdown { label: \"Environment\"; model: [\"Dev\", \"Prod\"] }"),
                component("MeoChipDropdown", "components/MeoChipDropdown.qml", "MD3 Expressive multi-select exposed dropdown component with removable chips.", "filled, outlined, sizes, responsive wrapping", "Normal, focused, error, disabled, xs/s/m/l/xl", "type, size, label, placeholder, helperText, isError, errorText, model, selectedIndices, showCounter", "MeoChipDropdown { label: \"Categories\"; model: [\"A\", \"B\", \"C\"]; selectedIndices: [0] }"),
                component("MeoDateInput", "components/MeoDateInput.qml", "Compact date input field.", "date value, clear, accepted", "Filled value, empty-ready, clear-ready", "value, format, allowEmpty, hasValue", "MeoDateInput { format: \"yyyy-MM-dd\" }"),
                component("MeoTimeInput", "components/MeoTimeInput.qml", "Compact time input field.", "time entry", "Default, edited-ready", "text, value", "MeoTimeInput {}"),
                component("MeoDatePicker", "widgets/MeoDatePicker.qml", "Calendar date picker widget.", "calendar, selected date, display date", "Current month, selected date", "selectedDate, displayDate", "MeoDatePicker { selectedDate: new Date() }"),
                component("MeoDateRangePicker", "widgets/MeoDateRangePicker.qml", "Calendar range picker for start and end dates.", "start date, end date, range", "No range, range selected", "startDate, endDate, displayDate", "Use when a flow needs a date interval."),
                component("MeoTimePicker", "widgets/MeoTimePicker.qml", "Clock-style time picker widget.", "hours, minutes, am/pm", "Hour select, minute select, AM/PM", "hours, minutes, isPM", "MeoTimePicker { hours: 10; minutes: 30 }")
            ]
        },
        {
            "id": "selection",
            "label": "Selection",
            "icon": "check_box",
            "subtitle": "Checkboxes, radio buttons, switches, sliders, ranges, and selection groups.",
            "components": [
                component("MeoCheckbox", "components/MeoCheckbox.qml", "Checkbox with checked and indeterminate states.", "checked, unchecked, indeterminate", "Unchecked, checked, indeterminate, disabled-ready", "checked, indeterminate, label", "MeoCheckbox { label: \"Receive updates\"; checked: true }"),
                component("MeoRadioButton", "components/MeoRadioButton.qml", "Single-choice radio control.", "selected, unselected", "Unchecked, checked, disabled-ready", "checked, label", "MeoRadioButton { label: \"Option A\"; checked: true }"),
                component("MeoSwitch", "components/MeoSwitch.qml", "Binary switch with optional icons and expressive style.", "on, off, icons, expressive", "Off, on, icon, disabled-ready", "checked, label, icon, uncheckedIcon, isExpressive", "MeoSwitch { label: \"Enabled\"; checked: true }"),
                component("MeoSlider", "components/MeoSlider.qml", "Single-value slider with continuous, discrete, thick, and wavy variants.", "continuous, discrete, thick, wavy, sizes", "Low, mid, high, disabled-ready, xs/s/m/l/xl", "from, to, value, discrete, stepSize, isThick, wavy, size", "MeoSlider { value: 40; wavy: true }"),
                component("MeoRangeSlider", "components/MeoRangeSlider.qml", "Two-thumb range slider.", "range, discrete, sizes", "Low range, wide range, disabled-ready", "from, to, firstValue, secondValue, discrete, stepSize", "MeoRangeSlider { firstValue: 20; secondValue: 80 }"),
                component("MeoSelectionGroup", "components/MeoSelectionGroup.qml", "List-like group for option selection.", "single selection, grouped rows", "Selected row, unselected rows", "model, selectedIndex", "Use for settings-like option groups."),
                component("MeoFilterGroup", "components/MeoFilterGroup.qml", "Filter chip group for one or many filters.", "single, multi, icons", "Selected, unselected, disabled-ready", "model, currentIndex, selectedIndices, multiSelect", "MeoFilterGroup { model: [{ label: \"All\" }, { label: \"Open\" }] }"),
                component("MeoStepper", "components/MeoStepper.qml", "Step progress selector for multi-step flows.", "horizontal, vertical, completed, active", "Completed, active, pending", "model, currentIndex, orientation", "MeoStepper { model: [{ label: \"Account\" }, { label: \"Review\" }]; currentIndex: 1 }")
            ]
        },
        {
            "id": "navigation",
            "label": "Navigation",
            "icon": "explore",
            "subtitle": "Navigation bars, rails, drawers, tabs, breadcrumbs, app bars, and adaptive suites.",
            "components": [
                component("MeoNavigationBar", "widgets/MeoNavigationBar.qml", "Compact bottom navigation for primary destinations.", "bottom destinations, labels, badges", "Selected, badge, compact", "model, currentIndex, labelType, shape", "MeoNavigationBar { model: navItems }"),
                component("MeoNavigationRail", "widgets/MeoNavigationRail.qml", "Medium-width side navigation rail with optional expanded state.", "collapsed, expanded, badges", "Collapsed, expanded, selected, badge", "model, currentIndex, isExpanded, labelType, header, footer", "MeoNavigationRail { model: navItems; currentIndex: 0 }"),
                component("MeoNavigationDrawer", "widgets/MeoNavigationDrawer.qml", "Expanded navigation drawer with optional headers and grouped labels.", "drawer, headers, badges", "Selected, header, badge", "model, currentIndex, title, header, footer", "MeoNavigationDrawer { model: navItems }"),
                component("MeoNavigationDrawerModal", "widgets/MeoNavigationDrawerModal.qml", "Modal drawer for compact navigation.", "modal drawer, scrim, open-close", "Closed, opened, selected", "model, currentIndex, header", "Use with a menu button on compact layouts."),
                component("MeoNavigationDrawerItem", "components/MeoNavigationDrawerItem.qml", "Drawer row item with group mode, supporting text, divider, and badge.", "drawer item, group item, badge", "Selected, unselected, grouped, supporting text", "label, icon, badgeText, selected, mode, supportingText", "MeoNavigationDrawerItem { label: \"Inbox\"; icon: \"inbox\" }"),
                component("MeoNavigationSuite", "patterns/MeoNavigationSuite.qml", "Adaptive navigation that switches bottom bar, rail, and drawer by width.", "compact, medium, expanded", "Bottom bar, rail, drawer", "model, currentIndex, availableWidth, expandedRail", "Use for app-level adaptive navigation."),
                component("MeoBreadcrumbs", "components/MeoBreadcrumbs.qml", "Hierarchical path navigation.", "icons, separators, clickable crumbs", "Root, middle, current", "model, separator", "MeoBreadcrumbs { model: [{ label: \"Home\" }, { label: \"Library\" }] }"),
                component("MeoTabs", "components/MeoTabs.qml", "Primary and secondary tabs with icons and badges.", "primary, secondary, icons, badges", "Selected, unselected, scrollable-ready", "model, currentIndex, type, isScrollable", "MeoTabs { model: [\"Overview\", \"Usage\"] }"),
                component("MeoTopAppBar", "widgets/MeoTopAppBar.qml", "Top app bar with small, center, medium, large, flexible, and contextual modes.", "small, center, medium, large, contextual", "Default, contextual, actions", "type, title, navigationIcon, actions, isContextual, selectionCount", "MeoTopAppBar { title: \"Inbox\"; type: \"small\" }"),
                component("MeoBottomAppBar", "widgets/MeoBottomAppBar.qml", "Bottom app bar for actions and FAB placement.", "actions, fab slot", "Default, with actions", "actions, fab", "Use for mobile bottom actions."),
                component("MeoMenu", "components/MeoMenu.qml", "Popup menu with icon rows, separators, trailing metadata, disabled rows, submenu affordances, and expressive item spacing.", "standard, separator, trailing text, trailing icon, submenu-ready, vibrant", "Closed, open-ready, enabled, disabled, segmented", "model, vibrant, itemSpacing, menuPadding, open(), openAt(), close()", "MeoMenu { model: [{ label: \"Copy\", icon: \"content_copy\", trailingText: \"Ctrl+C\" }] }")
            ]
        },
        {
            "id": "data-display",
            "label": "Data Display",
            "icon": "table_chart",
            "subtitle": "Tables, lists, headers, grouped rows, badges, avatars, dividers, and skeleton states.",
            "components": [
                component("MeoDataTable", "components/MeoDataTable.qml", "Sortable and selectable data table.", "columns, rows, selection, sorting", "Normal, sorted, selected rows, pagination anatomy", "columns, model, selectable, sortProperty, sortAscending", "MeoDataTable { columns: columns; model: rows; selectable: true }"),
                component("MeoListItem", "components/MeoListItem.qml", "Rich list row with icons, supporting text, trailing content, and actions.", "one-line, two-line, actions, badges", "Normal, selected-ready, trailing actions", "text, supportingText, leadingIcon, trailingText, trailingComponent", "MeoListItem { text: \"Inbox\"; supportingText: \"12 unread\" }"),
                component("MeoListHeader", "components/MeoListHeader.qml", "Section label for lists and grouped content.", "standard, emphasized", "Default, emphasized", "text, type", "MeoListHeader { text: \"Today\" }"),
                component("MeoGroupedList", "patterns/MeoGroupedList.qml", "Rounded grouped list pattern for settings and menus.", "groups, dividers, selected rows", "Selected, divided, chevron-ready", "title, subtitle, model, selectedIndex, showDividers", "MeoGroupedList { title: \"Settings\"; model: rows }"),
                component("MeoBadge", "components/MeoBadge.qml", "Dot or count badge.", "dot, count, max count", "Dot, number, overflow", "text, maxCount, isDot, target", "MeoBadge { text: \"12\" }"),
                component("MeoAvatar", "components/MeoAvatar.qml", "Image or initials avatar with expressive shape variants.", "image, initials, circle, squircle, hexagon", "Initials, image fallback, shape variants", "source, initials, size, variant, color, textColor", "MeoAvatar { initials: \"ME\"; variant: \"squircle\" }"),
                component("MeoDivider", "components/MeoDivider.qml", "Horizontal or vertical separator.", "horizontal, vertical", "Horizontal, vertical", "orientation", "MeoDivider { orientation: \"horizontal\" }"),
                component("MeoSkeleton", "components/MeoSkeleton.qml", "Placeholder loading block.", "text, avatar, card-like placeholders", "Loading placeholder", "type, active", "Use while data rows or cards load.")
            ]
        },
        {
            "id": "surfaces",
            "label": "Surfaces",
            "icon": "layers",
            "subtitle": "Cards, dialogs, sheets, action sheets, and temporary surfaces.",
            "components": [
                component("MeoCard", "components/MeoCard.qml", "Container card with elevated, filled, outlined, shape, and interactive variants.", "elevated, filled, outlined, interactive, expressive shapes", "Default, interactive, selected-ready", "type, level, radius, shape, interactive", "MeoCard { type: \"elevated\"; interactive: true }"),
                component("MeoDialog", "components/MeoDialog.qml", "Standard confirmation dialog.", "title, message, actions, icon", "Closed, open-ready, confirm/cancel", "title, message, confirmText, cancelText, icon", "MeoDialog { title: \"Delete item?\" }"),
                component("MeoFullScreenDialog", "components/MeoFullScreenDialog.qml", "Full-screen task dialog.", "full-screen, actions, content slot", "Closed, open-ready", "title, content, actions", "Use for focused editing flows."),
                component("MeoExpressiveDialog", "patterns/MeoExpressiveDialog.qml", "Expressive dialog with custom content slot.", "icon, custom content, actions", "Closed, open-ready, content", "title, message, confirmText, cancelText, icon, content", "MeoExpressiveDialog { title: \"Ready\" }"),
                component("MeoBottomSheet", "widgets/MeoBottomSheet.qml", "Modal bottom sheet.", "modal sheet, content slot", "Closed, open-ready", "content", "Use for compact temporary tasks."),
                component("MeoStandardBottomSheet", "widgets/MeoStandardBottomSheet.qml", "Standard bottom sheet surface.", "standard sheet, drag handle, content", "Closed, open-ready", "content", "Use for persistent or standard sheets."),
                component("MeoSideSheet", "widgets/MeoSideSheet.qml", "Side sheet for supplementary content.", "side panel, content", "Closed, open-ready", "content", "Use for details alongside main content."),
                component("MeoSideSheetModal", "widgets/MeoSideSheetModal.qml", "Modal side sheet with scrim.", "modal side panel, content", "Closed, open-ready", "content", "Use when side content blocks the current task."),
                component("MeoActionSheet", "widgets/MeoActionSheet.qml", "Action sheet for contextual choices.", "actions, icons, destructive-ready", "Closed, open-ready", "model, title", "MeoActionSheet { title: \"Share\"; model: actions }")
            ]
        },
        {
            "id": "feedback",
            "label": "Feedback",
            "icon": "info",
            "subtitle": "Banners, snackbars, tooltips, progress, loading, pull refresh, and empty states.",
            "components": [
                component("MeoBanner", "components/MeoBanner.qml", "Inline message with leading icon and actions.", "info, actions, dismiss", "Default, confirm, cancel", "text, icon, confirmText, cancelText", "MeoBanner { text: \"Network restored\"; icon: \"info\" }"),
                component("MeoSnackbar", "components/MeoSnackbar.qml", "Transient bottom message.", "message, action, timeout", "Closed, open-ready, action", "text, actionText, timeout", "MeoSnackbar { text: \"Saved\" }"),
                component("MeoTooltip", "components/MeoTooltip.qml", "Plain tooltip.", "message, anchor-ready", "Hidden, visible-ready", "text", "MeoTooltip { text: \"Copy\" }"),
                component("MeoRichTooltip", "components/MeoRichTooltip.qml", "Rich tooltip with title and supporting text.", "title, text, actions", "Hidden, visible-ready", "title, text, actionText", "Use for explanatory tooltips."),
                component("MeoProgressBar", "components/MeoProgressBar.qml", "Linear, circular, indeterminate, thick, vibrant, and wavy progress.", "linear, circular, determinate, indeterminate, wavy", "Determinate, indeterminate, with/without track, thick, vibrant", "value, indeterminate, type, isThick, vibrant, wavy, showTrack, activeColor, trackColor", "MeoProgressBar { value: 0.4; type: \"linear\" }"),
                component("MeoLoadingIndicator", "components/MeoLoadingIndicator.qml", "Expressive morphing loading indicator.", "determinate, indeterminate, container, vibrant", "Running, paused, with container, vibrant, xs/s/m/l/xl", "value, indeterminate, running, withContainer, size, vibrant, color", "MeoLoadingIndicator { size: \"m\"; withContainer: true }"),
                component("MeoPullToRefresh", "components/MeoPullToRefresh.qml", "Pull refresh interaction surface.", "pull, refreshing, content slot", "Idle, pull-ready, refreshing", "refreshing, content", "Use around scrollable content."),
                component("MeoEmptyState", "patterns/MeoEmptyState.qml", "Empty state layout with icon, title, description, and action.", "icon, copy, action", "No data, action", "icon, title, description, actionText, customContent", "MeoEmptyState { title: \"No items\"; actionText: \"Create\" }")
            ]
        },
        {
            "id": "search",
            "label": "Search",
            "icon": "search",
            "subtitle": "Search bars, docked search, app bar search, search views, suggestions, and filter headers.",
            "components": [
                component("MeoSearchBar", "widgets/MeoSearchBar.qml", "Standalone rounded search entry.", "inactive, active, leading/trailing icons", "Inactive, active, accepted", "text, placeholder, leadingIcon, trailingIcon, active", "MeoSearchBar { placeholder: \"Search components\" }"),
                component("MeoDockedSearchBar", "widgets/MeoDockedSearchBar.qml", "Docked search field for wider layouts.", "docked, suggestions-ready", "Default, active-ready", "text, placeholder", "MeoDockedSearchBar { placeholder: \"Search\" }"),
                component("MeoSearchAppBar", "widgets/MeoSearchAppBar.qml", "App bar with search affordance.", "app bar, search action", "Default, active-ready", "text, placeholder, active, actions", "Use at the top of searchable screens."),
                component("MeoSearchView", "widgets/MeoSearchView.qml", "Full search view with suggestions.", "modal search, suggestions, history", "Closed, open-ready, suggestions", "placeholder, suggestions", "MeoSearchView { suggestions: suggestions }"),
                component("MeoSearchSuggestions", "widgets/MeoSearchSuggestions.qml", "Suggestion list for search results and history.", "history, icons, highlight", "History, suggestion, highlighted", "model, highlightText", "MeoSearchSuggestions { highlightText: \"meo\" }"),
                component("MeoSearchHeader", "patterns/MeoSearchHeader.qml", "Page header with title, search box, and actions.", "title, search, actions", "Default, accepted, action-ready", "title, placeholder, text, leadingIcon, trailingIcon, actions", "MeoSearchHeader { title: \"Library\"; placeholder: \"Search\" }"),
                component("MeoSearchFilterBar", "patterns/MeoSearchFilterBar.qml", "Combined search and filter chip row.", "search, filters, multi-select", "No filters, selected filters", "text, placeholder, filterModel, selectedFilterIndices, multiSelectFilters", "MeoSearchFilterBar { filterModel: filters }")
            ]
        },
        {
            "id": "content-media",
            "label": "Content & Media",
            "icon": "perm_media",
            "subtitle": "Carousel, page indicators, media controller, toolbars, and account headers.",
            "components": [
                component("MeoCarousel", "components/MeoCarousel.qml", "Scrollable carousel with multi-browse, uncontained, hero, and full-screen strategies.", "multi-browse, uncontained, hero, full-screen", "Default, indicator, auto-scroll-ready", "model, delegate, type, itemWidth, itemHeight, showPageIndicator, autoScroll", "MeoCarousel { model: cards; type: \"hero\" }"),
                component("MeoPageIndicator", "components/MeoPageIndicator.qml", "Dots page indicator.", "dots, active index", "First, middle, last", "count, currentIndex", "MeoPageIndicator { count: 4; currentIndex: 1 }"),
                component("MeoMediaController", "widgets/MeoMediaController.qml", "Media playback control surface.", "play, pause, progress, metadata", "Playing, paused, progress", "title, artist, isPlaying, progress", "MeoMediaController { title: \"Track\"; isPlaying: true }"),
                component("MeoToolbar", "widgets/MeoToolbar.qml", "General toolbar with title and actions.", "regular, compact, actions", "Default, compact", "title, actions, isCompact", "MeoToolbar { title: \"Tools\" }"),
                component("MeoDockedToolbar", "components/MeoDockedToolbar.qml", "Docked toolbar for grouped tools.", "docked tools, actions", "Default, action group", "actions", "Use for editor-like surfaces."),
                component("MeoFloatingToolbar", "components/MeoFloatingToolbar.qml", "Floating toolbar for contextual tools.", "floating, actions", "Default, compact-ready", "actions", "Use near selected content."),
                component("MeoAccountHeader", "widgets/MeoAccountHeader.qml", "Account identity header.", "avatar, name, email", "Default, with avatar", "name, email, avatarSource", "MeoAccountHeader { name: \"Meo User\"; email: \"hello@meo.dev\" }"),
                component("MeoAccountSwitcher", "widgets/MeoAccountSwitcher.qml", "Expressive account switching widget.", "active account, quick switch, menu", "Active, alternative accounts, menu-open", "model, currentIndex", "MeoAccountSwitcher { model: accounts }"),
                component("MeoSwipeToDismiss", "components/MeoSwipeToDismiss.qml", "Swipeable content row with left and right dismiss actions.", "left action, right action, threshold", "Idle, swiping, dismissed", "content, leftAction, rightAction, swipeThreshold, dismissed", "MeoSwipeToDismiss { content: listRow; leftAction: archiveAction; rightAction: deleteAction }")
            ]
        },
        {
            "id": "chips",
            "label": "Chips",
            "icon": "label",
            "subtitle": "Assist, filter, input, suggestion, generic, action, selected, avatar, icon, and closable chips.",
            "components": [
                component("MeoChip", "components/MeoChip.qml", "Generic chip with icon, selection, custom colors, and closable state.", "assist, selected, icon, closable", "Normal, selected, icon, closable, disabled-ready, xs/s/m/l/xl", "type, label, icon, size, selected, closable, selectedContainerColor, contentColor", "MeoChip { label: \"Closable\"; icon: \"bolt\"; closable: true }"),
                component("MeoAssistChip", "components/MeoAssistChip.qml", "Assist chip with icon, avatar, elevated, and expressive sizes.", "icon, avatar, elevated, sizes", "Normal, elevated, avatar, disabled-ready, xs/s/m/l/xl", "label, icon, size, avatarSource, elevated", "MeoAssistChip { label: \"Directions\"; icon: \"directions\" }"),
                component("MeoFilterChip", "components/MeoFilterChip.qml", "Selectable filter chip with optional icon/avatar.", "selected, unselected, icon, avatar", "Unselected, selected, avatar, disabled-ready, xs/s/m/l/xl", "label, leadingIcon, size, selected, avatarSource", "MeoFilterChip { label: \"Design\"; selected: true }"),
                component("MeoInputChip", "components/MeoInputChip.qml", "Input chip for entered entities and removable items.", "selected, avatar, remove", "Normal, selected, avatar, closable-ready", "label, leadingIcon, avatarSource, selected", "MeoInputChip { label: \"Avery\"; leadingIcon: \"person\" }"),
                component("MeoSuggestionChip", "components/MeoSuggestionChip.qml", "Suggestion chip for lightweight prompts.", "suggestion, icon-ready", "Normal, disabled-ready", "label, icon, size", "MeoSuggestionChip { label: \"Material\" }")
            ]
        },
        {
            "id": "layouts",
            "label": "Layouts",
            "icon": "dashboard_customize",
            "subtitle": "Page, scaffold, app, dashboard, feed, list-detail, and settings layouts.",
            "components": [
                component("MeoPageLayout", "patterns/MeoPageLayout.qml", "Standard showcase/page shell with title, subtitle, actions, max width, and spacing.", "compact, medium, expanded", "Compact, medium, expanded", "title, subtitle, topBar, actions, compactWidth, mediumWidth, expandedWidth", "Use as the default page container."),
                component("MeoScaffold", "patterns/MeoScaffold.qml", "Composable app scaffold with top, bottom, navigation, sheet, fab, content, and snackbar slots.", "slots, adaptive, side sheet", "Compact, medium, expanded, side sheet", "topBar, bottomBar, navigationBar, navigationRail, navigationDrawer, sideSheet, fab, content, snackbar", "Use for app screens with multiple layout slots."),
                component("MeoAppLayout", "patterns/MeoAppLayout.qml", "Application shell that adapts between drawer, rail, and bottom navigation.", "compact, rail, drawer", "Compact bottom nav, medium rail, expanded drawer", "navigationModel, pages, currentIndex, compactNavigationLimit, accountHeader, fab", "MeoAppLayout { navigationModel: pages }"),
                component("MeoDashboardLayout", "patterns/MeoDashboardLayout.qml", "Responsive dashboard grid.", "columns, cards, responsive", "Compact, medium, expanded columns", "model, delegate, padding, spacing, columns", "Use for metric dashboards."),
                component("MeoFeedLayout", "patterns/MeoFeedLayout.qml", "Responsive feed/list layout.", "single column, adaptive spacing", "Compact feed, expanded feed", "model, delegate, padding, spacing", "Use for repeatable content feeds."),
                component("MeoListDetailLayout", "patterns/MeoListDetailLayout.qml", "Master-detail layout that adapts by breakpoint.", "list, detail, split", "Compact list/detail, expanded split", "listComponent, detailComponent, showDetail", "Use for inbox/detail or settings/detail flows."),
                component("MeoSettingsLayout", "patterns/MeoSettingsLayout.qml", "Settings page layout.", "sections, settings rows", "Default settings", "title, model, padding", "MeoSettingsLayout { title: \"Settings\" }")
            ]
        },
        {
            "id": "expressive",
            "label": "Expressive",
            "icon": "auto_awesome",
            "subtitle": "Meo-specific expressive shapes, bouncy motion, vibrant surfaces, and large component scales.",
            "components": [
                component("MeoShape", "components/MeoShape.qml", "Expressive shape primitive used by cards, rails, indicators, and avatars.", "squircle, hexagon, diamond, pentagon, octagon", "Shape variants, selected indicators, visual primitives", "type, radius, color", "MeoShape { type: \"squircle\"; color: MeoTheme.primaryContainer }"),
                component("Expressive buttons", "components/MeoButton.qml", "Button scale, bouncy press, vibrant fill, and emphasized type.", "xs/s/m/l/xl, squircle, hexagon, bouncy, vibrant", "Bouncy, vibrant, emphasized, loading", "size, shape, bouncy, vibrant, isEmphasized", "MeoButton { text: \"Create\"; size: \"xl\"; vibrant: true; shape: \"squircle\" }"),
                component("Expressive list items", "components/MeoListItem.qml", "Segmented list items with adaptive rounding and vibrant selection.", "segmented, roundingStrategy, vibrant, emphasized", "Selected, vibrant, top/middle/bottom rounding", "roundingStrategy, isSegmented, vibrant, isEmphasized", "MeoListItem { headline: \"Item\"; isSegmented: true; roundingStrategy: \"top\" }"),
                component("Expressive chips", "components/MeoChip.qml", "Chip size scale, selected container, icon and close affordance.", "xs/s/m/l/xl, selected, closable", "Sizes, selected, closable", "size, selected, closable, isEmphasized", "MeoChip { label: \"Expressive\"; size: \"xl\" }"),
                component("Expressive progress", "components/MeoProgressBar.qml", "Wavy, thick, vibrant, and containerized feedback.", "wavy, thick, vibrant, loading container", "Linear, circular, wavy, loading", "wavy, isThick, vibrant, withContainer", "MeoProgressBar { wavy: true; value: 0.6 }"),
                component("Expressive navigation", "widgets/MeoNavigationRail.qml", "Expanded rail and animated selected indicators.", "rail, drawer, shape indicator", "Collapsed, expanded, selected", "isExpanded, shape, currentIndex", "MeoNavigationRail { isExpanded: true }")
            ]
        }
    ]

    function component(name, source, summary, variants, states, api, usage) {
        return {
            "name": name,
            "source": source,
            "summary": summary,
            "variants": variants,
            "states": states,
            "api": api,
            "usage": usage
        }
    }

    function categoryById(id) {
        for (var i = 0; i < categories.length; ++i) {
            if (categories[i].id === id)
                return categories[i]
        }
        return categories[0]
    }
}
