# MeoArch Installer implementation

The preferred runtime is a compiled Qt 6 host that loads the QML view layer and
exposes `InstallerController` as the single source of non-secret installation
state. If the build machine has no Qt development libraries, the ISO build skips
that optional host and starts the QML layer with `qml6` instead. The default mode
is a simulated installation and cannot modify a disk.

## Runtime flow

1. `meoarch-installer` prefers `/opt/meoarch-installer/bin/meoarch-installer-app`
   when all of its shared libraries resolve, otherwise it falls back to `qml6`.
2. The host loads `/opt/meoarch-installer/qml/Main.qml` and builds runtime catalogs.
3. QML writes non-secret choices through `InstallerController`.
4. `generate-config.py` maps schema version 1 state to Archinstall configuration,
   credentials, and KDE `plasma-localerc` artifacts.
5. `run-archinstall.sh` requires both the Summary marker and a manifest whose
   `realInstallReady` value is true.

The real path additionally requires `--enable-real-install`; power actions require
`--enable-system-actions`. Missing disk geometry or a missing yescrypt user hash
keeps the generated manifest in preview state.

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

## Development checks

```sh
cmake -S installer -B build/installer-host -G Ninja
cmake --build build/installer-host
qmllint -I installer/qml installer/qml/Main.qml installer/qml/pages/*.qml
python -m unittest discover -s installer/tests -v
```

For a non-destructive render, pass `--page=N` and `--screenshot=/path/page.png`.
