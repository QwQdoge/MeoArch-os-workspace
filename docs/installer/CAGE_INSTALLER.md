# Cage Installer Runtime

This document maps the MeoArch installer specification to the current live ISO
runtime. For the product flow and UX rules, see `INSTALLER_SPEC.md`.

## Runtime Summary

The installer runs as a single fullscreen GTK application inside Cage:

```text
systemd
  -> meoarch-installer.service
  -> /usr/local/bin/meoarch-installer-kiosk
  -> cage
  -> /usr/local/bin/meoarch-installer
  -> /opt/meoarch-installer/meoarch_installer.py
```

The current implementation is intentionally non-destructive. It can display the
installer shell and write a preview file:

```text
/tmp/meoarch-archinstall-preview.json
```

It does not partition disks, format filesystems, mount target disks, or run
`archinstall`.

## Live ISO Files

| Purpose | Path |
| --- | --- |
| Development source | `scripts/installer/meoarch_installer.py` |
| Runtime application | `MeoArch os/airootfs/opt/meoarch-installer/meoarch_installer.py` |
| Application launcher | `MeoArch os/airootfs/usr/local/bin/meoarch-installer` |
| Cage launcher | `MeoArch os/airootfs/usr/local/bin/meoarch-installer-kiosk` |
| systemd service | `MeoArch os/airootfs/etc/systemd/system/meoarch-installer.service` |
| service enable link | `MeoArch os/airootfs/etc/systemd/system/multi-user.target.wants/meoarch-installer.service` |

`scripts/build.sh` runs `scripts/sync-installer-to-airootfs.sh` before calling
`mkarchiso`, so changes made to the development source are copied into the ISO
profile automatically.

## Required ISO Packages

The live ISO package list must include:

```text
archinstall
cage
gtk4
python-gobject
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
- Exports `GDK_BACKEND=wayland`
- Exports `XKB_DEFAULT_LAYOUT=us`

The service is designed for a kiosk installer environment, not a general desktop
session.

## Current UI Mapping

The current framework provides a lightweight shell for the final flow:

| Current page | Final spec page | Status |
| --- | --- | --- |
| Welcome | Welcome | Present as framework page |
| Disk | Disk Selection | Placeholder |
| User | User Account | Placeholder |
| Profile | Privacy, desktop, and package choices | Placeholder |
| Review | Summary | Preview JSON only |
| Install | Installing | Disabled runner; writes preview only |

The final specification requires additional pages:

- Language & Region
- Keyboard Layout
- Network
- Privacy & Security
- Finish

These should be added before any real installation backend is connected.

## Data Flow

Current framework:

```text
GTK page state
  -> static preview object
  -> /tmp/meoarch-archinstall-preview.json
```

Target flow:

```text
GTK page state
  -> validated installer model
  -> archinstall config JSON
  -> final confirmation
  -> archinstall execution backend
  -> progress and logs
```

The final confirmation page must exist before the execution backend is enabled.

## Safety Contract

The current framework must remain non-destructive.

Allowed:

- Display UI
- Collect choices
- Generate preview JSON
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

## Implementation Roadmap

1. Add the missing UX pages from `INSTALLER_SPEC.md`.
2. Replace placeholders with simple validated controls.
3. Add hardware, disk, network, and locale detection as structured backend data.
4. Generate a complete `archinstall` config preview.
5. Add the Summary page as a hard final checkpoint.
6. Add the Installing page with progress and collapsed logs.
7. Enable real backend execution only after validation and confirmation are in place.

## Manual Test Checklist

Before connecting real installation behavior:

- The live ISO boots to the installer service.
- Cage starts successfully.
- The GTK window fills the display.
- The installer can navigate all pages.
- The preview file is written to `/tmp/meoarch-archinstall-preview.json`.
- Closing the installer exits Cage cleanly.
- A service failure is logged to the journal.
- No disk state changes occur.
