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

`archinstall` is present for the future backend. The launcher does not run any
installer backend unless an explicit test flag is passed.

## Startup Flags

The launcher defaults to a non-destructive mode:

```sh
meoarch-installer
```

Optional flags are opt-in and intended for testing only:

| Flag | Effect |
| --- | --- |
| `--enable-archinstall-preflight` | Runs the background `archinstall --dry-run` preflight helper. |
| `--enable-system-actions` | Lets the QML power menu emit system-action requests for bridge testing. |
| `--` | Forwards all following arguments directly to the QML runtime. |

Even with `--enable-system-actions`, the current QML app only emits/logs action
requests. No native shutdown, reboot, suspend, or installer bridge is connected
yet.

## Service Behavior

The service starts on the live system through `multi-user.target`.

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

The QML shell currently contains ten pages:

| QML page | Final spec page | Status |
| --- | --- | --- |
| `WelcomePage.qml` | Welcome | Visual first page |
| `LanguageRegionPage.qml` | Language & Region | Placeholder |
| `KeyboardLayoutPage.qml` | Keyboard Layout | Placeholder |
| `NetworkPage.qml` | Network | Placeholder |
| `PrivacySecurityPage.qml` | Privacy & Security | Placeholder |
| `DiskSelectionPage.qml` | Disk Selection | Placeholder |
| `UserAccountPage.qml` | User Account | Placeholder |
| `SummaryPage.qml` | Summary | Placeholder |
| `InstallingPage.qml` | Installing | Placeholder |
| `FinishPage.qml` | Finish | Placeholder |

The shared background, centered card, brand pill, top action buttons, and right
power menu are defined in `installer/qml/PageFrame.qml`.

## Safety Contract

The current framework must remain non-destructive.

Allowed:

- Display UI
- Collect choices
- Generate future preview data
- Write temporary logs under `/tmp`
- Run `archinstall --dry-run` only when `--enable-archinstall-preflight` is set
- Emit QML system-action requests only when `--enable-system-actions` is set

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
- The installer can navigate all ten pages.
- The power menu opens.
- Power off, Restart, and Sleep show a disabled message.
- Test no-op shows a no-op message and never emits a real system action.
- Closing the installer exits Cage cleanly.
- A service failure is logged to the journal.
- No disk state changes occur.

Then test explicit opt-in modes:

```sh
meoarch-installer --enable-system-actions
meoarch-installer --enable-archinstall-preflight
meoarch-installer --enable-system-actions --enable-archinstall-preflight
```

Expected results:

- `--enable-system-actions` allows the QML shell to emit/log action requests.
- `--enable-archinstall-preflight` runs only the dry-run preflight helper.
- Running without these flags remains the normal ISO behavior.
