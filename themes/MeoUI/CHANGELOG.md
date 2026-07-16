# Changelog

## 0.3.1 - 2026-07-16

- Reduced idle rendering cost across cards, dialogs, menus, tooltips, avatars, floating toolbars, persistent sheets, carousels, and virtualized delegates.
- Paused canvas-heavy loading, skeleton, pull-to-refresh, progress, and wavy-slider motion whenever there is no drawable or active interactive surface.
- Removed the carousel's transparent per-item mask layer, which allocated an offscreen effect without clipping the delegate.
- Preserved the MD3 interaction and reduced-motion behavior while avoiding hidden popup shadows and unnecessary surface-tint masks.
- Refined FAB, Button Group, Segmented Buttons, Split Button, and Bottom App Bar grouping from the prior motion release.
- Rebuilt the MeoUI Showcase and MeoArch Installer for Windows, and synchronized the shared runtime for the ISO installer.

## 0.3.0 - 2026-07-15

- Added Windows-style small, medium, and large window size classes at 640 and 1008 effective pixels.
- Added `MeoWindowMetrics` for adaptive margins, navigation mode, pane widths, content widths, two-pane support, and responsive column counts.
- Refactored app, page, dashboard, feed, list-detail, settings, scaffold, navigation, search, and side-sheet layouts for 360-1440 px windows.
- Added compact bottom navigation, medium navigation rail, and expanded large-window navigation drawer behavior.
- Standardized high-frequency control motion on 83/167/250 ms WinUI-compatible timing and directional enter/exit curves.
- Added shared `MeoMotionPopup` and `MeoMotionSurface` primitives with reduced-motion support.
- Improved state layers, shape transitions, loading indicators, progress, dialogs, menus, tabs, fields, selection controls, and surface feedback.
- Replaced eager page creation in `MeoAppLayout` with a lazy loader to reduce startup work and prevent offscreen flicker.
- Made the Showcase resizable down to 360x480 and added deterministic screenshot capture for visual regression checks.
- Synchronized the optimized MeoUI runtime into the MeoArch ISO installer and verified all ten installer pages.

## 0.2.0 - 2026-07-03

- Added bundled Comfortaa and Roboto fonts for the MeoUI QML module.
- Updated typography tokens so brand/page titles use Comfortaa and UI/body text uses Roboto.
- Added `MeoText` semantic typography support and connected page layouts to title/body tokens.
- Refined app layout width, page padding, top app bar surface, and drawer sizing.
- Expanded Showcase coverage for Theme, Buttons, Inputs, Data Table, Components Lab, Widgets Lab, and Layouts Lab.
- Added `DESIGN_SPEC.md` and a static MeoUI spec site with component placeholders.
- Rebuilt and verified the Windows Showcase demo.
