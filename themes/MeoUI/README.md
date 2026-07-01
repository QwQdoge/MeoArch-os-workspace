# MeoUI

MeoUI is the Material Design 3 / MD3 Expressive QML component library used by the MeoArch workspace. The `MeoShowcaseDemo` target launches a finished showcase with token, component, widget, pattern, and layout pages.

## Requirements

- Qt 6 with `Core`, `Gui`, `Qml`, `Quick`, and `QuickControls2`
- CMake 3.16 or newer
- A C++17 compiler

Use an out-of-source build. The helper scripts below place generated files under `out/build/showcase` so source QML stays clean.

## Windows

From this directory:

```powershell
.\tools\build-showcase.ps1 -Config Release -Run
```

If Qt is not on `PATH`, pass the Qt prefix:

```powershell
.\tools\build-showcase.ps1 -QtPrefixPath "C:\Qt\6.7.3\msvc2019_64" -Config Release -Run
```

## Linux

From this directory:

```bash
./tools/build-showcase.sh --config Release --run
```

If Qt is installed in a custom prefix:

```bash
./tools/build-showcase.sh --qt-prefix "$HOME/Qt/6.7.3/gcc_64" --config Release --run
```

## Runtime Install

The release runtime package includes `install-runtime.sh`. On Linux it installs
the QML module to `/opt/meo-ui/qml/Meo/UI/`, installs bundled fonts under
`/usr/local/share/fonts/meo-ui`, writes `/opt/meo-ui/VERSION`, and creates the
compatibility import path `/opt/meo-ui/qml/MeoUI` for existing `import MeoUI`
applications.

```bash
tar -xzf meo-ui-runtime-0.1.0.tar.gz
cd meo-ui-runtime-0.1.0
./install-runtime.sh
```

The installer checks the platform and any existing installed version before it
overwrites, upgrades, or downgrades.

## Manual CMake

```bash
cmake -S . -B out/build/showcase -DCMAKE_BUILD_TYPE=Release
cmake --build out/build/showcase --target MeoShowcaseDemo
cmake --install out/build/showcase --prefix out/install/showcase
```

On multi-config generators such as Visual Studio, add `--config Release` to the build and install commands.

## Showcase Coverage

The showcase entry point is `showcase/MeoShowcase.qml`. It includes pages for theme tokens, buttons, inputs, navigation, selection, display, feedback, patterns, data tables, expressive controls, component lab, widget lab, and layout lab.
