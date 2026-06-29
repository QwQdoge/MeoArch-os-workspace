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
| Runtime application | `MeoArch os/airootfs/opt/meoarch-installer/qml/Main.qml` |
| Runtime assets | `MeoArch os/airootfs/opt/meoarch-installer/assets/` |
| Application launcher | `MeoArch os/airootfs/usr/local/bin/meoarch-installer` |
| Cage launcher | `MeoArch os/airootfs/usr/local/bin/meoarch-installer-kiosk` |
| systemd service | `MeoArch os/airootfs/etc/systemd/system/meoarch-installer.service` |

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

`archinstall` is present for the future backend. The current framework does not
execute it.

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

Forbidden:

- Partition disks
- Format filesystems
- Mount target disks
- Run `archinstall`
- Run `pacstrap`
- Run `grub-install`
- Create target users
- Modify firmware boot entries

## Manual Test Checklist

Before connecting real installation behavior:

- The live ISO boots to the installer service.
- Cage starts successfully.
- The QML window fills the display.
- The installer can navigate all ten pages.
- Closing the installer exits Cage cleanly.
- A service failure is logged to the journal.
- No disk state changes occur.
