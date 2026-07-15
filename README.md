# MeoArch OS Workspace

MeoArch OS Workspace is the main repository for assembling the MeoArch live ISO.
It contains the existing archiso profile, installer framework, system assets,
themes, build scripts, and project documentation.

This repository is the ISO integration point. Reusable components can later move
to dedicated repositories, but this workspace should remain the place where the
final live image is assembled.

## Current Status

- The existing archiso profile is kept at `MeoArch os/`.
- A compiled Qt 6/C++ host and ten-step MD3 Qt Quick installer are present.
- Runtime locale, ISO 3166-1 country, IANA time-zone, and XKB catalogs are available.
- Archinstall and KDE configuration adapters are implemented behind explicit safety gates.
- The default installer mode is non-destructive and simulates progress.
- Installer documentation is available in English and Simplified Chinese.

## Repository Layout

```text
MeoArch_os-workspace/
├── MeoArch os/          # Existing archiso profile; keep this directory name
│   ├── profiledef.sh
│   ├── packages.x86_64
│   ├── pacman.conf
│   ├── efiboot/
│   ├── grub/
│   ├── syslinux/
│   └── airootfs/
├── configs/             # System configuration staged outside airootfs
│   ├── systemd/
│   ├── pacman/
│   ├── zsh/
│   └── network/
├── themes/              # UI, GTK, Qt, GRUB, SDDM, and related themes
│   └── MeoUI/
├── installer/           # Standalone Cage installer source
│   ├── bin/
│   └── qml/
├── scripts/             # Build, installer, and sync entrypoints
│   ├── build.sh
│   ├── install.sh
│   ├── firstboot.sh
│   ├── postinstall.sh
│   ├── run-installer-kiosk.sh
│   └── sync-installer-to-airootfs.sh
├── assets/              # Wallpapers, icons, logos, and fonts
│   ├── wallpapers/
│   ├── icons/
│   └── fonts/
├── docs/
│   └── installer/
└── README.md
```

`build/` and `.vscode/` may exist locally during development. They are not part
of the source layout.

## Installer Documentation

Start here if you are reviewing or implementing the installer:

- English product specification:
  `docs/installer/INSTALLER_SPEC.md`
- English Cage runtime mapping:
  `docs/installer/CAGE_INSTALLER.md`
- Simplified Chinese product specification:
  `docs/installer/INSTALLER_SPEC.zh_cn.md`
- Simplified Chinese Cage runtime mapping:
  `docs/installer/CAGE_INSTALLER.zh_cn.md`

The product specification describes the user flow, page requirements, safety
rules, and future backend boundaries. The Cage runtime document explains how the
current framework starts inside the live ISO.

## Graphical Installer Framework

The current installer starts as:

```text
systemd
  -> meoarch-installer.service
  -> meoarch-installer-kiosk
  -> cage
  -> meoarch-installer
  -> meoarch-installer-app
  -> QML installer UI
```

Runtime files are staged under:

```text
installer/
MeoArch os/airootfs/opt/meoarch-installer/
MeoArch os/airootfs/usr/local/bin/
MeoArch os/airootfs/etc/systemd/system/
```

The framework is intentionally safe. It can write preview artifacts under:

```text
/tmp/meoarch-installer/
```

It will not call Archinstall unless real-install mode is enabled, Summary is
confirmed, disk geometry is present, and the separate credentials artifact is ready.

## Building The ISO

Builds should be run on Arch Linux with `archiso` installed:

```sh
./scripts/build.sh
```

The build script synchronizes the installer source into `airootfs` before
calling `mkarchiso`. A development machine without Qt 6 headers can still build
the ISO: the optional C++ host is skipped and the live image runs the same QML
views with `qml6`. The live image itself always installs `qt6-base`,
`qt6-declarative`, `qt6-svg`, and `qt6-wayland` from the Arch repositories.

## Development Notes

- Keep `MeoArch os/` as the archiso profile path. Do not rename it unless the
  project intentionally migrates the profile directory.
- Edit installer source in `installer/`.
- Use `scripts/sync-installer-to-airootfs.sh` to copy installer changes into the
  ISO profile without running a full build.
- Keep generated files, build output, ISO images, and local IDE state out of git.

## Split Repository Rule

Only split code or assets into another repository when they can be reused
independently from this ISO workspace.

Likely future split candidates:

- `MeoUI` from `themes/MeoUI`
- logos and fonts from `assets/`
- installer documentation from `docs/installer`
- installer source once it becomes a standalone application
- package definitions once they are reused outside this ISO

The main workspace should stay focused on assembling the live ISO.
