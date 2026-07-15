# MeoUI Showcase Reference Alignment

Reference checked: `sudoevolve/material-components-qml` at `3e04769` (`2026-06-03`).

This file records design/API coverage ideas observed from the reference project. It is not a source-copy log; MeoUI keeps its own `MeoTheme`, `MeoText`, component APIs, names, and implementation.

## Differences Found

- The reference demo shows controls in compact matrices instead of isolated examples, especially buttons, icon buttons, FABs, sliders, and menus.
- Menu items cover more anatomy: leading icon, trailing shortcut text, trailing icon, separator rows, disabled rows, and submenu affordance.
- Slider demos separate continuous, discrete ticks, labeled behavior, range behavior, and disabled state.
- Button demos show a type-by-state grid: text-only, icon, disabled, and loading/interactive equivalents.
- Navigation examples are kept as distinct bottom bar, rail, drawer, and app shell demonstrations.
- Navigation rail examples include a header area with menu/FAB affordances and an expanded rail mode, not only a static list.
- The reference demonstrates contextual top bars for selected content, plus bottom app bars with navigation icons and a FAB slot.
- Selection controls are shown with selected, unselected, indeterminate, and disabled states.
- Reference checkbox and radio controls use `text` for labels and disable their hit area when the component is disabled.
- Reference slider exposes `snapMode`, `tickMarksEnabled`, `valueLabelEnabled`, plus `pressed` and `hovered` state accessors.
- Dialog coverage includes basic, icon, single-selection, and multi-selection trigger patterns.
- Reference component APIs use `filledTonal`, `standard` FAB, and dialog button visibility flags in several demos; MeoUI historically used `tonal`, `regular`, and always-visible dialog actions.
- Reference text fields expose `supportingText`, `error`, `isPassword`, `passwordVisible`, and `trailingIconClicked`; MeoUI historically used `helperText`, `isError`, and a passive trailing icon.
- Reference tabs use `{ text, icon }` item data and 72dp primary tabs when icons are present.
- Reference tabs animate indicator edges independently, which gives the active tab indicator a stronger directional transition than a simple x/width animation.
- Reference data tables expose `rowData`, `showCheckBoxes`, `showDividers`, `hoverEffect`, selection state properties, and column `role`; MeoUI historically used `model`, `selectable`, and column `property`.
- Reference switches expose `text` and `showIcon`, and disabled switches do not receive click input.
- Reference linear progress uses two staggered indeterminate bars instead of one moving segment.
- Reference loading indicator uses a rotating lobed morph sequence rather than a circle/squircle/star loop.
- Several reference controls consistently use theme typography, state-layer opacity, and motion values instead of local text/duration constants.
- The reference repository includes extra non-core demos such as charts, desktop widgets, scaffold templates, and color picker. MeoUI does not currently expose matching public components for all of those, so they are not added as fake showcase replicas.

## Changes Applied In MeoUI

- `MeoMenu` now accepts richer item models: `label`/`text`, `icon`, `trailingText`, `trailingIcon`, `type: "separator"`, `enabled`, `subItems`, and `isVibrant`.
- `MeoMenu.openAt(anchor, offsetX, offsetY)` was added for anchor-relative menu opening.
- Actions showcase now presents `MeoButton` as a type-by-state matrix.
- Actions showcase now presents `MeoIconButton` as type and disabled-state columns.
- FAB showcase now labels small, regular, large, and extended variants.
- Text Input showcase now presents text fields as a filled/outlined matrix with search, password, error, counter, prefix/suffix, and disabled examples.
- Selection showcase now separates slider rows for continuous, discrete ticks, expressive thick, wavy, and disabled states.
- Navigation/Menu showcase now shows separator, disabled, trailing shortcut, trailing icon, and submenu-ready examples.
- Navigation showcase now separates primary icon tabs, primary text-only tabs, and secondary tabs.
- Navigation showcase now includes collapsed and expanded navigation rail examples with header actions and a footer/settings affordance.
- App bar showcase now includes standard top app bar actions, contextual selection mode, and a bottom app bar with navigation icons plus FAB.
- Selection showcase now covers checkbox, radio, and switch disabled states alongside selected/unselected states.
- Feedback showcase now separates determinate, indeterminate, wavy, circular, and loading-in-button examples.
- Content & Media showcase now separates carousel strategies: multi-browse, hero, and uncontained.
- Dialog showcase now mirrors the trigger-button pattern: basic dialog, icon dialog, single select, and multi select are shown as separate launch actions.
- Picker showcase now pairs selected-value summary text with date and time picker previews.
- Snackbar showcase now separates plain message and action snackbar triggers.
- Tooltip showcase now uses the MeoUI tooltip component with a hover target instead of a passive static label.
- Card showcase now uses larger elevated, filled, and outlined card examples with trailing action affordances.
- `MeoDialog` and `MeoExpressiveDialog` now route enter/exit animation durations through `MeoTheme` motion tokens instead of local raw duration values.
- `MeoButton` and `MeoIconButton` now accept `filledTonal` as an alias for MeoUI's existing `tonal` variant, so reference-style examples can be expressed without changing public MeoUI naming.
- `MeoFAB` now accepts `standard` as an alias for MeoUI's existing `regular` FAB variant.
- `MeoDialog` now supports `showAcceptButton` and `showRejectButton`, matching the reference demo behavior for icon/informational dialogs while preserving the existing confirm/cancel API.
- `MeoSnackbar`, `MeoTooltip`, and `MeoCard` now route showcase-critical typography/motion values through `MeoTheme` tokens instead of local raw values.
- `MeoChip` now has disabled opacity, focused state-layer wiring, and pressed expressive scale behavior for closer MD3E state treatment.
- `MeoTextField` now supports reference-style `supportingText`, `error`, password visibility toggling, and `trailingIconClicked` while preserving the existing helper/error API.
- `MeoTabs` now accepts `text` as a model label field, uses the MD3 72dp height for primary tabs with icons, and drives the active indicator from animated left/right edges.
- `MeoDataTable` now accepts reference-style `rowData`, `showCheckBoxes`, `showDividers`, `hoverEffect`, and column `role`.
- `MeoDataTable` now exposes `selectedIndices`, `allSelected`, `isIndeterminate`, `toggleAll()`, and `toggleRow()` while keeping `selected` row data compatible.
- `MeoSwitch` now accepts reference-style `text`/`showIcon`, routes motion through tokens, and prevents disabled switches from toggling.
- `MeoProgressBar` now uses two staggered indeterminate bars while preserving MeoUI thick, vibrant, and wavy variants.
- `MeoLoadingIndicator` now uses a MeoUI-owned multi-lobe morph sequence with independent rotation and morph timing.
- `MeoCheckbox` and `MeoRadioButton` now support reference-style `text`, use token typography/motion, and prevent disabled controls from toggling.
- `MeoSlider` now supports `snapMode`, `tickMarksEnabled`, `valueLabelEnabled`, and exposes `pressed`/`hovered` while preserving MeoUI expressive sizes and the separate `MeoRangeSlider` component.

## Still Different By Intent

- No color picker parity yet, per request.
- No chart/widget parity yet because MeoUI does not currently define chart or desktop-widget public components.
- MeoUI keeps MD3 Expressive-specific variants such as vibrant, wavy, bouncy, shape scales, and loading containers instead of matching the reference API names one-for-one.
