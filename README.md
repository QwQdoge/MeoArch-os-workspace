# MeoArch OS Workspace

MeoArch OS Workspace is the main repository for assembling the MeoArch live ISO.
It contains the existing archiso profile, installer framework, system assets,
themes, build scripts, and project documentation.

This repository is the ISO integration point. Reusable components can later move
to dedicated repositories, but this workspace should remain the place where the
final live image is assembled.

## Current Status

- The existing archiso profile is kept at `meoarch-os/`.
- A compiled Qt 6/C++ host and eleven-step M3 Expressive Qt Quick installer are present.
- MeoUI is a versioned shared QML module; the installer does not embed a private static copy.
- Meo Desktop provides KDE Plasma look-and-feel, shelf defaults, packaging, and safe apply/reset tooling.
- Optional software profiles are recorded as confirmation-required OmniStore provisioning intent.
- Runtime locale, ISO 3166-1 country, IANA time-zone, and XKB catalogs are available.
- Archinstall and KDE configuration adapters are implemented behind explicit safety gates.
- The installer detects PCI display adapters and adds the matching Arch driver packages to the generated Archinstall configuration.
- The default installer mode is non-destructive and simulates progress.
- Installer documentation is available in English and Simplified Chinese.

## Repository Layout

```text
MeoArch_os-workspace/
├── meoarch-os/          # Existing archiso profile; keep this directory name
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
├── themes/              # Theme configuration & single source of truth reference
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
meoarch-os/airootfs/opt/meoarch-installer/
meoarch-os/airootfs/usr/local/bin/
meoarch-os/airootfs/etc/systemd/system/
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
The build installs `libmeoui.so.0` and its QML plugin into the image from the
same `themes/MeoUI` source used by the installer build.

## Meo Desktop and OmniStore

The installed system uses Archinstall's KDE Plasma profile, then applies the
Meo Desktop look-and-feel, shelf layout, wallpaper, and global defaults to the
mounted target. The desktop intentionally reuses KDE's NetworkManager, BlueZ,
PipeWire, PowerDevil, notification, overview, and session actions.

The software page does not silently install optional apps. It writes an
allowlisted `omnistore-provisioning.json` with the selected workflow profiles
and `requiresUserConfirmation: true`. The target receives that file under
`/var/lib/omnistore/`. A signed or repository-resolvable OmniStore package is
still required before first-login execution can be enabled.

## Graphics Driver Detection

Pacman is only a package transaction tool: it does not probe PCI hardware or
choose a graphics driver.  Before it generates the Archinstall configuration,
MeoArch reads the Live ISO PCI display devices and records
`generated/hardware.json` alongside the generated configuration.  The detected
vendor packages are added to `user_configuration.json` and are installed by
Archinstall during the normal package phase:

- AMD: Mesa, Radeon Vulkan, and VA-API Mesa support
- Intel: Mesa, Intel Vulkan, and VA-API Mesa support
- NVIDIA: `nvidia-open` and `nvidia-utils`
- Unknown/no detectable adapter: a safe Mesa/Vulkan fallback

Hybrid systems receive both applicable sets.  The detector never downloads
packages on its own and never enables a legacy third-party NVIDIA driver; those
remain explicit post-install choices.

- `installer/backend/hardware.py` contains the vendor-ID mapping and is covered
  by unit tests.
- `installer/backend/generate-config.py` writes the audited plan to
  `/tmp/meoarch-installer/generated/hardware.json` in the Live ISO.

## Development Notes

- Keep `meoarch-os/` as the archiso profile path. Do not rename it unless the
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
