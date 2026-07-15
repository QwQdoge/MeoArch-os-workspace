# MeoUI Design Specification

This document is the source of truth for MeoUI visual language, tokens, component usage, and review rules. MeoUI follows Material Design 3 principles with Meo-specific semantic aliases so application code reads like design intent instead of raw numbers.

## Core Rule

Use semantic tokens and MeoUI components first.

Do not write raw visual values in pages unless the value is local layout data that cannot be represented by an existing token. Typography, motion, state opacity, button height, shape, color, and spacing must come from `MeoTheme` or a MeoUI component.

Good:

```qml
MeoText {
    text: "Storage"
    typeRole: "title"
    typeSize: "big"
}

MeoButton {
    text: "Continue"
    type: "filled"
    size: "m"
}
```

Avoid:

```qml
Text {
    text: "Storage"
    font.pixelSize: 28 * MeoTheme.globalScale
}

NumberAnimation {
    duration: 150
}
```

## Token System

All tokens live in `MeoTheme.qml`.

### Scale

| Token | Meaning |
| --- | --- |
| `globalScale` | Global multiplier for high-DPI and density adjustments. |

Every fixed visual dimension in a component should be multiplied by `globalScale` or use a token that already includes it.

### Adaptive Windows

MeoUI follows the Windows effective-pixel window classes so layouts change according to the space available to the application, not the physical display resolution.

| Size class | Effective width | Primary navigation | Page margin |
| --- | --- | --- | --- |
| Small | 0-640 | Bottom navigation or modal drawer | 12 |
| Medium | 641-1007 | 80 px navigation rail | 24 |
| Large | 1008+ | 280 px expanded navigation drawer | 32 |

Use `MeoWindowMetrics` inside reusable views. It provides `sizeClass`, `small`, `medium`, `large`, `pageMargin`, `paneWidth`, `maximumContentWidth`, `navigationMode`, `supportsTwoPane`, and `preferredColumns`. Do not duplicate 640/1008 breakpoint expressions in pages.

Layouts must remain usable at 360x480. A width change may alter navigation, column count, pane visibility, control arrangement, and margins, but must not discard view or form state. Prefer fluid sizing inside a size class and discrete adaptive changes only at a breakpoint.

Reference: [Windows responsive design](https://learn.microsoft.com/windows/apps/design/layout/responsive-design) and [screen sizes and breakpoints](https://learn.microsoft.com/windows/apps/design/layout/screen-sizes-and-breakpoints-for-responsive-design).

### Color Roles

Use color roles by purpose, not by color name.

| Role | Use |
| --- | --- |
| `primary` | Main action, selected indicator, active brand accent. |
| `contentOnPrimary` | Text/icon on `primary`. |
| `primaryContainer` | Tonal selected surfaces and soft primary emphasis. |
| `contentOnPrimaryContainer` | Text/icon on `primaryContainer`. |
| `secondary` | Secondary accents. |
| `contentOnSecondary` | Text/icon on `secondary`. |
| `secondaryContainer` | Tonal secondary backgrounds. |
| `contentOnSecondaryContainer` | Text/icon on `secondaryContainer`. |
| `tertiary` | Tertiary accents and decorative-but-semantic emphasis. |
| `contentOnTertiary` | Text/icon on `tertiary`. |
| `tertiaryContainer` | Tonal tertiary backgrounds. |
| `contentOnTertiaryContainer` | Text/icon on `tertiaryContainer`. |
| `error` | Destructive or invalid state. |
| `contentOnError` | Text/icon on `error`. |
| `errorContainer` | Error background surface. |
| `contentOnErrorContainer` | Text/icon on `errorContainer`. |
| `background` | App background. |
| `contentOnBackground` | Content on app background. |
| `surface` | Default component/page surface. |
| `contentOnSurface` | Primary text/icon on surface. |
| `surfaceVariant` | Variant surface. |
| `contentOnSurfaceVariant` | Secondary text/icon on surface. |
| `outline` | Borders and dividers. |
| `outlineVariant` | Softer borders and dividers. |

Surface container tokens:

| Token | Use |
| --- | --- |
| `surfaceContainerLowest` | Lowest emphasis raised surface. |
| `surfaceContainerLow` | Low emphasis container. |
| `surfaceContainer` | Default container. |
| `surfaceContainerHigh` | High emphasis container. |
| `surfaceContainerHighest` | Highest emphasis container. |

### Typography

Font families:

| Use | Font |
| --- | --- |
| Brand name / logo | `Comfortaa` Bold, 18-20 |
| Page title | `Comfortaa` Bold, 34-42 |
| Section title | `Roboto` Bold, 24-28 |
| Component label | `Roboto` Medium, 15-16 |
| Body / UI / navigation / table | `Roboto` Regular or Medium, 14-16 |
| Button text | `Roboto` Medium, 14-15 |
| Placeholder / helper text | `Roboto` Regular |
| Chinese UI fallback | `Noto Sans SC`, `Microsoft YaHei`, `Source Han Sans SC` |

Comfortaa is only for English brand names, logo text, page titles, and rare display headings. Do not use Comfortaa for mixed body copy or Chinese UI text.

Base Material 3 type-scale tokens are available:

| Token | Size / line height | Weight |
| --- | --- | --- |
| `displayLarge` | 57 / 64 | Normal |
| `displayMedium` | 45 / 52 | Normal |
| `displaySmall` | 36 / 44 | Normal |
| `headlineLarge` | 32 / 40 | Normal |
| `headlineMedium` | 28 / 36 | Normal |
| `headlineSmall` | 24 / 32 | Normal |
| `titleLarge` | 22 / 28 | Normal |
| `titleMedium` | 16 / 24 | Medium |
| `titleSmall` | 14 / 20 | Medium |
| `bodyLarge` | 16 / 24 | Normal |
| `bodyMedium` | 14 / 20 | Normal |
| `bodySmall` | 12 / 16 | Normal |
| `labelLarge` | 14 / 20 | Medium |
| `labelMedium` | 12 / 16 | Medium |
| `labelSmall` | 11 / 16 | Medium |

Emphasized variants exist for every base token, for example `headlineMediumEmphasized`, `bodyLargeEmphasized`, and `labelSmallEmphasized`.

Application and page code must prefer semantic Meo tokens:

| Semantic token | Maps to | Use |
| --- | --- | --- |
| `titleBig` | Comfortaa Bold 40 / 48 | Page titles. |
| `titleMediumUi` | Roboto Bold 26 / 34 | Section titles. |
| `titleSmallUi` | Roboto Bold 16 / 24 | Card titles and compact headings. |
| `bodyBig` | Roboto Regular 18 / 28 | Page subtitles and primary body text. |
| `bodyMediumUi` | Roboto Regular 15 / 22 | Default body text. |
| `bodySmallUi` | Roboto Regular 14 / 20 | Dense helper text and table text. |
| `labelBig` | Roboto Medium 15 / 20 | Buttons and prominent labels. |
| `labelMediumUi` | Roboto Medium 14 / 20 | Compact labels. |
| `labelSmallUi` | Roboto Medium 12 / 16 | Captions and tiny labels. |

Use `MeoTheme.typeToken(role, size, emphasized)` when building a component that needs to choose typography dynamically.

Accepted values:

| Parameter | Values |
| --- | --- |
| `role` | `"title"`, `"body"`, `"label"` |
| `size` | `"big"`, `"large"`, `"medium"`, `"small"` |
| `emphasized` | `true`, `false` |

### Motion

Base Material 3 duration tokens:

| Token | Value |
| --- | --- |
| `motionDurationShort1` | 50 |
| `motionDurationShort2` | 100 |
| `motionDurationShort3` | 150 |
| `motionDurationShort4` | 200 |
| `motionDurationMedium1` | 250 |
| `motionDurationMedium2` | 300 |
| `motionDurationMedium3` | 350 |
| `motionDurationMedium4` | 400 |
| `motionDurationLong1` | 450 |
| `motionDurationLong2` | 500 |
| `motionDurationLong3` | 550 |
| `motionDurationLong4` | 600 |
| `motionDurationExtraLong1` | 700 |
| `motionDurationExtraLong2` | 800 |
| `motionDurationExtraLong3` | 900 |
| `motionDurationExtraLong4` | 1000 |

Semantic motion tokens:

| Token | Maps to | Use |
| --- | --- | --- |
| `motionDurationInstant` | `short1` | Near-instant feedback. |
| `motionDurationFast` | `short3` | Hover, color, icon, opacity, press scale. |
| `motionDurationMedium` | `medium2` | Button selection, indicator movement, loading scale. |
| `motionDurationSlow` | `long1` | Larger surface or page-level transitions. |
| `motionDurationRippleExpand` | `medium4` | Circular ripple expansion. |
| `motionDurationRippleFade` | `medium2` | Ripple fade-out. |

Windows-compatible control timing:

| Token | Value | Use |
| --- | --- | --- |
| `motionDurationControlFaster` | 83 | Tiny press/icon feedback. |
| `motionDurationControlFast` | 167 | Exit, fade, hover, and color feedback. |
| `motionDurationControlNormal` | 250 | Enter, selection indicator, pane, and page transitions. |

Use `motionEasingEnter` for elements arriving or expanding and `motionEasingExit` for elements leaving or collapsing. `reduceMotion` must collapse nonessential durations to zero while preserving the final state. Popups use `MeoMotionPopup`; elevated/appearing surfaces use `MeoMotionSurface`. Components may add motion, but application pages must not reimplement these primitives.

Reference: [Windows timing and easing](https://learn.microsoft.com/windows/apps/design/motion/timing-and-easing).

Easing tokens:

| Token | Use |
| --- | --- |
| `motionEasingStandard` | Most property changes. |
| `motionEasingStandardAccelerate` | Elements leaving or collapsing. |
| `motionEasingStandardDecelerate` | Elements entering or expanding. |
| `motionEasingEmphasized` | Important shape/scale transitions. |
| `motionEasingEmphasizedAccelerate` | Selected state exit. |
| `motionEasingEmphasizedDecelerate` | Selected state enter and ripple. |
| `motionEasingSoul` | Compatibility alias for expressive components. |

### State Layer

State opacity tokens:

| Token | Value | Use |
| --- | --- | --- |
| `stateOpacityHover` | 0.08 | Hover state layer. |
| `stateOpacityFocus` | 0.10 | Keyboard focus state layer. |
| `stateOpacityPressed` | 0.10 | Pressed/ripple state layer. |
| `stateOpacityDragged` | 0.16 | Dragged state layer. |

Use `MeoStateLayer` for interactive surfaces. Do not hand-roll hover rectangles in buttons, list items, tabs, chips, or selectable cards.

### Shape

| Token | Value |
| --- | --- |
| `shapeNone` | 0 |
| `shapeExtraSmall` | 4 |
| `shapeSmall` | 8 |
| `shapeMedium` | 12 |
| `shapeLarge` | 16 |
| `shapeLargeIncreased` | 20 |
| `shapeExtraLarge` | 28 |
| `shapeExtraLargeIncreased` | 32 |
| `expressiveShapeCornerRadius` | 32 |
| `shapeExtraExtraLarge` | 48 |
| `shapeFull` | 1000 |
| `shapeSquareRadius` | 4 |

Use `shapeFull` for pills and fully rounded controls. Use `shapeLarge` or `shapeExtraLarge` for surfaces. Avoid inventing new corner sizes.

### Spacing

| Token | Value |
| --- | --- |
| `space2` | 2 |
| `space4` | 4 |
| `space8` | 8 |
| `space12` | 12 |
| `space16` | 16 |
| `space24` | 24 |
| `space32` | 32 |
| `space40` | 40 |
| `space48` | 48 |

Legacy aliases:

| Token | Value |
| --- | --- |
| `compactPadding` | 8 |
| `standardPadding` | 16 |
| `largePadding` | 24 |

### Button Heights

| Token | Value | Size |
| --- | --- | --- |
| `buttonHeightXS` | 32 | `xs` |
| `buttonHeightS` | 40 | `s` |
| `buttonHeightM` | 48 | `m` |
| `buttonHeightL` | 56 | `l` |
| `buttonHeightXL` | 72 | `xl` |

## Component APIs

### MeoText

Use for all page and component text unless a Qt control requires direct `font` binding.

| Property | Type | Values / default |
| --- | --- | --- |
| `typeRole` | string | `"body"` default, `"title"`, `"body"`, `"label"` |
| `typeSize` | string | `"medium"` default, `"big"`, `"large"`, `"medium"`, `"small"` |
| `emphasized` | bool | `false` default |
| `fontFamilyOverride` | string | Optional escape hatch for special cases |

Example:

```qml
MeoText {
    text: "Network"
    typeRole: "title"
    typeSize: "big"
    emphasized: true
    color: MeoTheme.contentOnSurface
}
```

### MeoButton

Use for commands. It includes MD3 state layer, circular ripple, hover animation, loading state, and selected/check icon support.

| Property | Type | Values / default |
| --- | --- | --- |
| `type` | string | `"filled"` default, `"tonal"`, `"outlined"`, `"elevated"`, `"text"` |
| `size` | string | `"m"` default, `"xs"`, `"s"`, `"m"`, `"l"`, `"xl"` |
| `shape` | string | `"round"` default, `"square"` |
| `isEmphasized` | bool | `false` default |
| `loading` | bool | `false` default |
| `selected` | bool | `false` default |
| `bouncy` | bool | `MeoTheme.isExpressive && MeoTheme.isBouncy` |
| `checkable` | bool | Qt `Button` property, default `false` |
| `checked` | bool | Qt `Button` property, default `false` |
| `text` | string | Button label |
| `icon.name` | string | Material symbol name |

Usage:

```qml
MeoButton {
    text: "Install"
    icon.name: "download"
    type: "filled"
    size: "m"
}
```

Rules:

- Primary route or final confirmation: `type: "filled"`.
- Secondary action: `type: "tonal"` or `type: "outlined"`.
- Low emphasis inline action: `type: "text"`.
- Use `loading: true` instead of replacing content manually.
- Use `checked` or `selected` for toggle-like buttons; do not create separate selected backgrounds in page code.

### MeoSegmentedButtons

Use for mutually exclusive or multi-select mode choices.

| Property | Type | Values / default |
| --- | --- | --- |
| `model` | var | `["option1", "option2", "option3"]` or objects with `label`, `icon` |
| `currentIndex` | int | `0` |
| `multiSelect` | bool | `false` |
| `selectedIndices` | var | `[]` |
| `size` | string | `"m"`, accepts `"xs"`, `"s"`, `"m"`, `"l"`, `"xl"` |
| `selected(index, data)` | signal | Emits on user selection |

Usage:

```qml
MeoSegmentedButtons {
    model: [
        { label: "Day", icon: "wb_sunny" },
        { label: "Night", icon: "dark_mode" }
    ]
    currentIndex: 0
}
```

Rules:

- Use for mode switching, filters, and formatting options.
- Use icons when the option is visually familiar.
- Selection animation must use theme motion tokens through the component.

### MeoButtonGroup

Use for compact grouped actions.

| Property | Type | Values / default |
| --- | --- | --- |
| `model` | var | List of `{ label, icon, action }` |
| `type` | string | `"tonal"` default, `"filled"`, `"tonal"`, `"outlined"`, `"elevated"` |
| `sizeVariant` | string | `"medium"` default, `"small"`, `"medium"`, `"large"` |
| `currentIndex` | int | `0` |

Usage:

```qml
MeoButtonGroup {
    model: [
        { label: "Cut", icon: "content_cut" },
        { label: "Copy", icon: "content_copy" },
        { label: "Paste", icon: "content_paste" }
    ]
}
```

### MeoStateLayer

Use inside custom interactive surfaces only. Standard components already include it.

| Property | Type | Values / default |
| --- | --- | --- |
| `pressed` | bool | `false` |
| `hovered` | bool | `false` |
| `focused` | bool | `false` |
| `dragged` | bool | `false` |
| `color` | color | `"#000000"` |
| `radius` | real | `0` |
| `pressX` | real | pointer X or center |
| `pressY` | real | pointer Y or center |

Behavior:

- Hover opacity uses `stateOpacityHover`.
- Focus opacity uses `stateOpacityFocus`.
- Pressed opacity uses `stateOpacityPressed`.
- Click triggers a circular ripple from `pressX`, `pressY`.
- Ripple is clipped to the parent shape.

### MeoPageLayout

Use as the default page shell for app pages.

| Property | Type | Values / default |
| --- | --- | --- |
| `title` | string | Page title |
| `subtitle` | string | Page subtitle |
| `topBar` | Component | Optional custom top bar |
| `actions` | list<Component> | Optional page actions |
| `compactWidth` | real | `680 * globalScale` |
| `mediumWidth` | real | `840 * globalScale` |
| `expandedWidth` | real | `1120 * globalScale` |
| `padding` | real | `24 * globalScale` |
| `sectionSpacing` | real | `24 * globalScale` |
| `content` | default property | Page body |

Usage:

```qml
MeoPageLayout {
    title: "Settings"
    subtitle: "Manage system preferences."

    actions: [
        Component { MeoButton { text: "Save"; type: "filled" } }
    ]

    MeoCard {
        type: "filled"
        // content
    }
}
```

## Component Catalog

### Atomic Components

| Component | Use |
| --- | --- |
| `MeoText` | Semantic typography. |
| `MeoIcon` | Material Symbols icon rendering. |
| `MeoButton` | Standard command buttons. |
| `MeoIconButton` | Icon-only actions. |
| `MeoFAB` | Floating action button. |
| `MeoFABMenu` | FAB with action menu. |
| `MeoSplitButton` | Primary action plus menu/secondary action. |
| `MeoButtonGroup` | Compact grouped actions. |
| `MeoSegmentedButtons` | Mode/filter selection. |
| `MeoStateLayer` | Hover/focus/press/ripple layer for custom surfaces. |
| `MeoCard` | Surface container for grouped content. |
| `MeoDivider` | Visual separator. |
| `MeoBadge` | Small count/status marker. |
| `MeoAvatar` | User/object avatar. |
| `MeoSkeleton` | Loading placeholder. |
| `MeoShape` | Expressive shape primitive. |

### Inputs And Selection

| Component | Use |
| --- | --- |
| `MeoTextField` | Single-line text input. |
| `MeoTextArea` | Multi-line text input. |
| `MeoDateInput` | Date entry field. |
| `MeoTimeInput` | Time entry field. |
| `MeoExposedDropdown` | Field with dropdown choices. |
| `MeoCheckbox` | Multi-select boolean option. |
| `MeoRadioButton` | Single-choice option. |
| `MeoSwitch` | Immediate on/off setting. |
| `MeoSlider` | Single numeric value. |
| `MeoRangeSlider` | Min/max numeric range. |
| `MeoSelectionGroup` | Grouped checkbox/radio list. |
| `MeoStepper` | Step progress and navigation. |

### Chips

| Component | Use |
| --- | --- |
| `MeoChip` | Generic chip with optional close. |
| `MeoAssistChip` | Action suggestion chip. |
| `MeoFilterChip` | Filter toggle chip. |
| `MeoFilterGroup` | Filter chip group. |
| `MeoInputChip` | User-entered/entity chip. |
| `MeoSuggestionChip` | Lightweight suggestion. |

### Navigation

| Component | Use |
| --- | --- |
| `MeoTabs` | Same-level content switching. |
| `MeoBreadcrumbs` | Hierarchical path. |
| `MeoNavigationDrawerItem` | Drawer row item. |
| `MeoPageIndicator` | Page/carousel position. |
| `MeoMenu` | Action menu. |

### Feedback And Overlays

| Component | Use |
| --- | --- |
| `MeoBanner` | Persistent contextual message. |
| `MeoDialog` | Focused decision dialog. |
| `MeoFullScreenDialog` | Full-screen editing/creation flow. |
| `MeoRichTooltip` | Tooltip with rich content/actions. |
| `MeoTooltip` | Simple hover/help tooltip. |
| `MeoSnackbar` | Temporary feedback. |
| `MeoProgressBar` | Linear or circular progress. |
| `MeoPullToRefresh` | Pull refresh indicator. |
| `MeoSwipeToDismiss` | Swipe action/dismiss pattern. |

### Data And Display

| Component | Use |
| --- | --- |
| `MeoDataTable` | Structured tabular data. |
| `MeoListItem` | Single list row. |
| `MeoListHeader` | List section label. |
| `MeoCarousel` | Scrollable visual item set. |
| `MeoDockedToolbar` | Full-width tool surface. |
| `MeoFloatingToolbar` | Floating contextual tool surface. |

### Widgets

| Component | Use |
| --- | --- |
| `MeoAccountHeader` | Account identity header. |
| `MeoActionSheet` | Mobile-style action list surface. |
| `MeoBottomAppBar` | Bottom app bar. |
| `MeoBottomSheet` | Modal bottom sheet. |
| `MeoStandardBottomSheet` | Persistent/standard bottom sheet. |
| `MeoSideSheet` | Side sheet. |
| `MeoSideSheetModal` | Modal side sheet. |
| `MeoDatePicker` | Date picker. |
| `MeoDateRangePicker` | Date range picker. |
| `MeoTimePicker` | Time picker. |
| `MeoMediaController` | Playback control surface. |
| `MeoNavigationBar` | Bottom navigation. |
| `MeoNavigationDrawer` | Permanent drawer. |
| `MeoNavigationDrawerModal` | Modal drawer. |
| `MeoNavigationRail` | Rail navigation. |
| `MeoToolbar` | Generic toolbar. |
| `MeoTopAppBar` | Top app bar. |
| `MeoSearchBar` | Search entry. |
| `MeoDockedSearchBar` | Docked search entry. |
| `MeoSearchAppBar` | App bar with search. |
| `MeoSearchSuggestions` | Suggestions list. |
| `MeoSearchView` | Full search surface. |

### Patterns

| Component | Use |
| --- | --- |
| `MeoPageLayout` | Default page scaffold. |
| `MeoAppLayout` | App-level frame. |
| `MeoScaffold` | General layout scaffold. |
| `MeoDashboardLayout` | Dashboard grid. |
| `MeoFeedLayout` | Responsive feed. |
| `MeoGroupedList` | Grouped list pattern. |
| `MeoListDetailLayout` | Master-detail layout. |
| `MeoNavigationSuite` | Adaptive navigation shell. |
| `MeoSettingsLayout` | Settings page pattern. |
| `MeoSearchFilterBar` | Search filters. |
| `MeoSearchHeader` | Search page header. |
| `MeoEmptyState` | Empty state. |
| `MeoExpressiveDialog` | Expressive dialog pattern. |

## Usage Rules

### Typography Rules

- Use `MeoText` in pages, showcase files, cards, dialogs, sheets, and layout patterns.
- Use `typeRole: "title"; typeSize: "big"` for page titles.
- Use `typeRole: "title"; typeSize: "medium"` for section titles.
- Use `typeRole: "title"; typeSize: "small"; emphasized: true` for card titles.
- Use `typeRole: "body"; typeSize: "big"` for page subtitles.
- Use `typeRole: "body"; typeSize: "medium"` for normal descriptions.
- Use `typeRole: "label"` for labels, counters, compact status text, and metadata.
- Do not set `font.pixelSize` directly in page code.
- Do not use negative letter spacing in new semantic tokens.

### Motion Rules

- Use `motionDurationFast` for hover, color, opacity, icon swap, small press scale.
- Use `motionDurationMedium` for selected state, indicator movement, and loading scale.
- Use `motionDurationSlow` only for larger surfaces and page-level changes.
- Use `motionDurationRippleExpand` and `motionDurationRippleFade` for ripple behavior.
- Do not write `duration: 150`, `duration: 200`, or other raw durations in component/page code.
- Match easing to intent: standard for normal changes, emphasized for selected/ripple/shape changes.

### Button Rules

- Every button must use `MeoButton`, `MeoIconButton`, `MeoFAB`, `MeoSegmentedButtons`, or `MeoButtonGroup`.
- Button hover must come from `MeoStateLayer`.
- Button click feedback must include circular ripple unless the button is disabled.
- Button selected/toggle motion must use `motionFast` and `motionMedium`.
- Button text must use button font tokens internally; pages must not override it with raw `font.pixelSize`.

### Layout Rules

- New app pages should start with `MeoPageLayout`.
- Keep page padding and section spacing token-based.
- Use `MeoCard` only for actual grouped surfaces or repeated items.
- Do not nest cards inside cards unless the inner card is a real repeated item.
- Use layout width constraints like `compactWidth`, `mediumWidth`, and `expandedWidth` instead of arbitrary page widths.

### Color Rules

- Use content pair colors: if background is `primary`, text is `contentOnPrimary`.
- Never use hard-coded text color on theme surfaces unless it is an external brand asset.
- Use `error` only for destructive, invalid, or failure states.
- Use `surfaceContainer*` for neutral UI surfaces instead of custom grays.

### State Rules

- Hover: `stateOpacityHover`.
- Focus: `stateOpacityFocus`.
- Press: `stateOpacityPressed`.
- Drag: `stateOpacityDragged`.
- Interactive custom surfaces must include `MeoStateLayer`.
- State layers must be clipped to the same radius as the host surface.

### Showcase Coverage Rules

- Buttons must show normal, disabled, icon, loading, selected, and focus-ready states.
- Inputs must show filled/outlined, helper, error, disabled, icon, password, and multiline states.
- Data tables must include toolbar actions, sorting indicators, selection, status chips, and pagination.
- Chips must be grouped by Assist, Filter, Input, Suggestion, and Action.
- Navigation demos must show bottom navigation, rail, and drawer previews.
- Layouts Lab must include Row, Column, Grid, Flow, Stack, Split view, breakpoint concepts, and common page compositions.

## Review Checklist

Before merging a MeoUI change:

- Search for raw typography in touched QML:

```powershell
rg -n "font\\.pixelSize:\\s*[0-9]|font\\.pointSize:\\s*[0-9]" themes\\MeoUI
```

- Search for raw motion duration in touched QML:

```powershell
rg -n "duration:\\s*[0-9]" themes\\MeoUI
```

- Confirm page titles use `MeoText` or `MeoPageLayout`.
- Confirm buttons use Meo button components.
- Confirm custom interactive surfaces use `MeoStateLayer`.
- Confirm color pairs use `contentOn*` roles.
- Confirm component additions are registered in `CMakeLists.txt`.
- Confirm segmented lists use `roundingStrategy` for cohesive grouping.
- Run `git diff --check`.
- Build or lint with Qt tools when available.

## Change Policy

Changing a token is a design-system change. Treat it as broad-impact work:

- Update this spec in the same change.
- Check showcase pages visually.
- Prefer adding semantic aliases over changing MD3 base tokens.
- Do not remove existing tokens without a compatibility plan.
- Keep component APIs small and semantic; do not expose raw animation or font-size knobs unless they are genuinely needed.
