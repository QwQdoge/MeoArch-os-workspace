# MeoUI 0.3.1

MeoUI 0.3.1 is the performance refinement release for the adaptive MD3
runtime shared by the Showcase and the MeoArch Installer.

## Highlights

- Suspends canvas-intensive loading, skeleton, pull-to-refresh, progress, and
  wavy-slider animation when there is nothing to draw or interact with.
- Removes inert offscreen layers from hidden popup surfaces and carousel items.
- Limits expensive elevation, masking, and tint work to visible surfaces that
  actually require it.
- Keeps the expressive MD3 transitions, hover/press feedback, morphing,
  reduced-motion behavior, and responsive layouts introduced in 0.3.0.
- Includes the refined FAB, connected action/selection groups, split button,
  and Bottom App Bar presentation in the shared installer runtime.

## Validation

- Windows MinGW Release build: Showcase passed.
- Windows MinGW Release build: MeoArch Installer passed.
- Showcase screenshot capture: passed without QML warnings.
- Linux Qt installer build and catalog check: passed.
- `git diff --check`: passed.

## Assets

- `meo-ui-showcase-windows-x64-0.3.1.zip`
  - Runnable Showcase with the Qt runtime.
- `meoarch-installer-windows-x64-0.3.1.zip`
  - Runnable Installer preview with the Qt runtime and its shared MeoUI module.
