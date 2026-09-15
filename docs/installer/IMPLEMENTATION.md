# MeoArch Installer implementation

The runtime is a compiled Qt 6 host that loads the QML view layer and
exposes `InstallerController` as the single source of non-secret installation
state. The launcher fails closed when that host or one of its libraries is
missing; a raw `qml6` process cannot provide the controller contract. The
default mode is a simulated installation and cannot modify a disk.

## Runtime flow

1. `meoarch-installer` validates and starts
   `/opt/meoarch-installer/bin/meoarch-installer-app`; missing host dependencies
   stop startup and let the Live boot-status failure path report the problem.
2. The host loads `/opt/meoarch-installer/qml/Main.qml` and builds runtime catalogs.
3. QML writes non-secret choices through `InstallerController`.
4. `generate-config.py` maps schema version 1 state to Archinstall configuration,
   credentials, and KDE `plasma-localerc` artifacts.
5. `run-archinstall.sh` requires both the Summary marker and a manifest whose
   `realInstallReady` value is true.

The real path additionally requires `--enable-real-install`; power actions require
`--enable-system-actions`. Missing disk geometry or a missing yescrypt user hash
keeps the generated manifest in preview state.

## Visual reference boundary

The startup surface and power dialog independently implement the compact,
morphing-session principles visible in Caelestia Shell: large rounded actions,
semantic focus, keyboard navigation, and state-driven motion. No Quickshell,
Caelestia service, IPC, or GPL source is copied into the installer. The result
uses MeoUI controls and the existing `InstallerController` capability boundary.
The shared `MeoMotionPopup` separately records its small MIT-licensed DMS
reference in the MeoUI source.

## Runtime catalogs

- UI languages: exactly 11 packaged entries.
- System locales: UTF-8 entries parsed from `/usr/share/i18n/SUPPORTED`.
- Countries and regions: ISO 3166-1 from `iso-codes`.
- Time zones: canonical entries from `zone1970.tab`, with `zone.tab` fallback, plus UTC.
- Keyboard layouts: XKB layouts from `evdev.lst`.

Counts are calculated at runtime. The UI selectors display filtered result counts,
virtualize delegates with `ListView`, and retain the current selection while searching.

## State boundary

`selections.json` contains only non-secret schema version 1 state. Account password,
Wi-Fi secret, and disk passphrase stay in memory. The credential artifact is a separate
0600 file and is never produced from `selections.json`.

The optional single-profile NetworkManager handoff is the sole exception to
“keep Wi-Fi secrets in memory”: it is an existing NetworkManager connection
file, copied only after explicit user consent to a root-only temporary file and
then into the installed system. It is not serialized into selections, plans,
summaries, or logs, and it is removed on all installer exits.

## Development checks

```sh
cmake -S installer -B build/installer-host -G Ninja
cmake --build build/installer-host
qmllint -I installer/qml installer/qml/Main.qml installer/qml/pages/*.qml
python -m unittest discover -s installer/tests -v
```

For a non-destructive render, pass `--page=N` and `--screenshot=/path/page.png`.
