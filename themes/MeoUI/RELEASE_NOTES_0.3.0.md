# MeoUI 0.3.0

MeoUI 0.3.0 is the adaptive-window and motion-quality release. It brings Windows-style responsive behavior to the MD3 Expressive component library, centralizes animation primitives in MeoUI, and ships the same runtime used by the MeoArch installer.

## Highlights

- Windows effective-pixel window classes: small through 640 px, medium from 641-1007 px, and large from 1008 px.
- New `MeoWindowMetrics` API for navigation mode, margins, pane widths, content constraints, two-pane views, and adaptive columns.
- Bottom navigation on small windows, navigation rail on medium windows, and expanded navigation drawer on large windows.
- Verified 360x480 minimum window support without clipped page content.
- Shared 83/167/250 ms control timing, directional enter/exit curves, and reduced-motion support.
- Shared popup and surface motion primitives used by dialogs, menus, sheets, and installer surfaces.
- Improved ripple/state feedback, shape morphing, progress/loading behavior, selection transitions, elevation, and popup choreography.
- Lazy page loading in `MeoAppLayout` to reduce startup work and eliminate hidden-page rendering flicker.
- Resizable Showcase with native deterministic screenshot capture for breakpoint regression testing.
- Updated MeoArch ISO runtime and verified all ten installer screens against the shared MeoUI package.

## Validation

- Windows MinGW Release QML AOT build: passed.
- MeoArch installer + MeoUI combined Release build: passed.
- Linux Qt Showcase build and native screenshot capture: passed.
- Visual checks: 360, 480, 640, 641, 800, 960, 1007, 1008, 1280, and 1440 px widths.
- Ten installer page screenshots: passed.
- Installer configuration and secret-handling tests: 4/4 passed.
- `git diff --check`: passed.

## Assets

- `meo-ui-showcase-windows-x64-0.3.0.zip`
  - Standalone Windows Showcase with the Qt runtime.
- `meo-ui-showcase-linux-x64-source-0.3.0.tar.gz`
  - Linux source package with `run-showcase-linux.sh`; requires Qt 6 and CMake.
- `meo-ui-runtime-0.3.0.tar.gz`
  - QML runtime module, bundled fonts, and Linux/Windows installer helpers.
