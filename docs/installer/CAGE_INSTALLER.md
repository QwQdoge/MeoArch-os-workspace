# Cage Installer Runtime

This document maps the MeoArch installer specification to the current live ISO
runtime. For the product flow and UX rules, see `INSTALLER_SPEC.md`.

## Runtime Summary

The installer runs as a single fullscreen Qt Quick/QML application inside Cage:

```text
systemd
  -> meoarch-installer.service
  -> /usr/local/bin/meoarch-installer-kiosk
  -> cage
  -> /usr/local/bin/meoarch-installer
  -> /opt/meoarch-installer/bin/meoarch-installer-app
  -> /opt/meoarch-installer/qml/Main.qml
```

The UI source lives outside the archiso profile in `installer/`. The build sync
step copies the QML files and shared `assets/` into the live ISO runtime tree.

## Live ISO Files

| Purpose | Path |
| --- | --- |
| Development source | `installer/` |
| Runtime application | `meoarch-os/airootfs/opt/meoarch-installer/qml/Main.qml` |
| Runtime assets | `meoarch-os/airootfs/opt/meoarch-installer/assets/` |
| Application launcher | `meoarch-os/airootfs/usr/local/bin/meoarch-installer` |
| Cage launcher | `meoarch-os/airootfs/usr/local/bin/meoarch-installer-kiosk` |
| systemd service | `meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service` |

`scripts/build.sh` runs `scripts/sync-installer-to-airootfs.sh` before calling
`mkarchiso`, so changes made to the standalone installer source are copied into
the ISO profile automatically.

## Required ISO Packages

The live ISO package list must include:

```text
archinstall
cage
qt6-base
qt6-declarative
qt6-wayland
```

`archinstall` is reached only through the native controller's validated,
explicitly enabled production path.

## Startup Flags

The launcher defaults to a non-destructive mode:

```sh
meoarch-installer
```

Capabilities are opt-in; the ISO kiosk launcher owns the production combination:

| Flag | Effect |
| --- | --- |
| `--production` | Marks the ISO-controlled production launch. |
| `--enable-real-install` | Enables the guarded Archinstall adapter only with `--production`. |
| `--enable-system-actions` | Enables restart and shutdown only with `--production`. |
| `--repair` | Opens Quick Repair in Live mode. |
| `--` | Forwards all following arguments to the native installer host. |

The launcher does not fall back to a raw QML runner: that process cannot supply
the required controller or production capability boundary.

## Service Behavior

The service starts on the live system through `graphical.target`.

Important properties:

- Runs as root in the live ISO
- Uses `/dev/tty1`
- Starts Cage directly
- Restarts on failure
- Exports `QT_QPA_PLATFORM=wayland`
- Exports `XKB_DEFAULT_LAYOUT=us`

The service is designed for a kiosk installer environment, not a general desktop
session.

## Current UI Mapping

The QML shell contains twelve guided pages from Welcome through Finish,
including language, keyboard, network, privacy, disk, account, software,
channel, review, and installation states. The shared background, centered card,
top actions, footer navigation, and centered power dialog are defined in
`installer/qml/PageFrame.qml`.


### In-Cage diagnostic console

The Live installer is a single Cage kiosk session, not a KDE Plasma desktop.
Launching Konsole, xterm, a browser, or another normal desktop window is not a
reliable diagnostic path because Cage is intentionally hosting the installer as
its single application.

The terminal action in the installer therefore opens an embedded command
console inside `PageFrame.qml`. It accepts normal shell commands such as
`ip route`, `nmcli device status`, `getent ahosts HOST`, and `curl -v URL`
and displays their combined output without leaving the installer.

The root-owned installer does not expose a root shell. Diagnostic commands are
started through `setpriv` as the unprivileged `live` user with
`no_new_privs` and cleared supplementary groups. This console is for
diagnostics only; privileged installation and power actions remain on their
separate reviewed controller paths.

## Safety Contract

The default development launch remains non-destructive. Real installation and
system power actions require the separate production capability flags supplied
by the ISO kiosk launcher.

Allowed:

- Display UI
- Collect choices
- Generate and validate an installation plan
- Write temporary logs under `/tmp`
- Run the non-destructive Archinstall preflight
- Report disabled system actions without executing them

Forbidden:

- Partition disks
- Format filesystems
- Mount target disks
- Run a real `archinstall` installation
- Run `pacstrap`
- Run `grub-install`
- Create target users
- Modify firmware boot entries
- Execute shutdown, reboot, or suspend by default

## Manual Test Checklist

Before connecting real installation behavior, test the default disabled mode:

- The live ISO boots to the installer service.
- Cage starts successfully.
- The QML window fills the display.
- The installer can navigate all twelve pages.
- The Material power dialog opens and requires a hold confirmation.
- Restart and Shut down show a disabled message without production capability.
- Closing the installer exits Cage cleanly.
- A service failure is logged to the journal.
- No disk state changes occur.

Then test explicit opt-in modes:

```sh
meoarch-installer --production --enable-system-actions
meoarch-installer --production --enable-real-install
```

Expected results:

- `--enable-system-actions` allows the controller to request restart or shutdown.
- `--enable-real-install` allows a confirmed, ready plan to enter the adapter.
- Without `--production`, both capability flags remain disabled.
