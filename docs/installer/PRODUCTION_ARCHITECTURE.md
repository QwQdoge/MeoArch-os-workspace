# Production installer architecture

This document records the current production architecture. The product/runtime
contract in `LIVE_DESKTOP.md` is authoritative when older implementation notes
conflict with this file.

## Execution modes

The Installer has three intentionally distinct launch contexts:

1. **Default Plasma Live** — the normal product path. Plasma Wayland/KWin starts
   first, then the full-screen Installer opens as a desktop application. Closing
   or crashing the application must not tear down Plasma.
2. **Cage fallback/kiosk** — selected explicitly with
   `meoarch.session=cage`. `meoarch-installer-kiosk` supplies the production
   capability flags and Cage hosts the Installer as its single application.
3. **Development/preview** — `meoarch-installer` without production capability
   remains non-destructive; `--preview` selects `PreviewController` for visual
   regression/screenshot work and is rejected with `--production`.

The default Live graphical environment is therefore **not Cage**. Cage remains a
maintained recovery/kiosk path. See `CAGE_INSTALLER.md` for that runtime only.

The current Plasma path still launches the privileged Installer through the
narrow Live-only authorization helper described in `LIVE_DESKTOP.md`. This is a
transitional security boundary, not the final ideal architecture: the stronger
target is an unprivileged UI plus a separate root installation backend with
narrow IPC and process lifetime independent from the window.

## Live runtime boundary

The default startup path is:

```text
GRUB/Syslinux
  -> graphical.target
  -> plasmalogin
  -> live PAM/logind session
  -> Plasma Wayland / KWin
  -> Live autostart
  -> meoarch-live-app.service
  -> authorized Installer
```

`meoarch.mode=install|repair|tty` selects purpose.
`meoarch.session=plasma|cage` selects the graphical runtime and defaults to
Plasma when omitted.

Only the selected compositor may start. Plasma Live, Cage fallback, and the
installed target are separate environments and must not share autologin or
Live-only authorization residue.

## UI and shared runtime boundaries

`installer/qml/` owns MeoArch branding and wizard business flow. It imports
MeoUI for visual primitives and the existing typed Meo.System runtime where an
authoritative adapter already exists. The Installer must not grow a second
Wi-Fi, audio, display, or hardware authority merely for convenience.

Runtime checks stay split by ownership:

- **Live ISO** owns installation-time identity, hardware/storage eligibility,
  network/repository reachability, and installer preflight.
- **Installed Meo** owns post-install connectivity, Meo Account, fingerprint,
  normal Settings, updates, and recovery.
- Meo Account authentication is not offered by the ephemeral Live ISO.
- The Installer creates the local Unix account; Meo Account is a separate
  optional cloud identity connected after installation.

## Terminal and diagnostics

The explicit `meoarch.mode=tty` path selects a terminal-only recovery mode. The
current ISO boot profile is BIOS Syslinux + UEFI GRUB; GRUB loopback support may
also expose the terminal entry. Do not describe systemd-boot as the current
Live UEFI boot path.

In the default Plasma Live session, Konsole and Quick Repair are ordinary
unprivileged desktop applications and remain usable independently of Installer
lifetime. In Cage fallback, the embedded unprivileged diagnostic console is the
reliable command surface because Cage intentionally hosts a single graphical
application.

## Installation plan and secrets

`InstallerController` is the single source of non-secret installation state.
The generated plan is allowed to enter the destructive adapter only after the
required identity, validation, Summary confirmation marker, and preflight state
are present.

The native controller persists only non-secret selections to the installer state
directory. Account password hashing is handled separately; the resulting hash
is written to a temporary mode-0600 credential artifact for configuration
generation and removed on every supported exit path. Plaintext account, Wi-Fi,
and future disk-encryption passwords must never enter selections, summaries, or
diagnostics.

When the user explicitly enables **Remember this network after installation**,
the controller may hand off exactly one supported, already-active
NetworkManager profile through a root-only temporary file. Unsupported
enterprise/VPN/wallet-backed profiles are refused rather than partially copied.

The ready-plan sequence is conceptually:

```text
collect non-secret selections
  -> validate
  -> generate target/config artifacts
  -> run non-destructive Archinstall preflight
  -> produce ready manifest
  -> explicit destructive confirmation
  -> run guarded adapter
```

Dry-run/preview and real execution remain separate capability paths.

## Process lifetime and failure boundary

Window close, Alt+F4, page exit, restart, and shutdown share the running-install
guard. This protects the normal UI path from destroying its current QProcess.
It does **not** prove that installation survives SIGKILL, OOM, compositor loss,
or power failure.

A future root backend/service with narrow IPC is required before the project may
claim destructive installation is independent of Installer GUI lifetime.
Until then, runtime validation must test both ordinary guarded exits and hard
failure behavior explicitly.

## Disk safety

Production disk enumeration is normalized into structured data and records
stable `/dev/disk/by-id` identity where available, together with model, serial,
WWN, transport, capacity, mount/removable state, and running-media protection.
Preview disks must never be inserted in production mode.

Current supported destructive plans are full-disk plans:

- automatic GPT + 1 GiB EFI system partition + Btrfs or ext4 root;
- custom full-disk layout using the same validated schema, with adjustable root
  and a separate `/home` while enforcing minimum sizes.

Both erase the selected target disk. Reuse/resizing of existing partitions and
dual-boot partition editing are not currently supported.

Disk encryption remains unavailable in the current production generator. Do not
show it as working until the passphrase lifecycle, Archinstall mapping, cleanup,
recovery, and UEFI VM path are implemented and accepted together.

Swap choices are real where supported: zram, an idempotent target swap file, or
none.

## Target customizations and login manager

The installed target uses the Meo Plasma Login Manager / `plasmalogin` path.
Generated target customization currently accepts only the
`meo-plasma-login-manager` login-manager value and enables
`plasmalogin.service`.

Automatic login is currently rejected by the target customization backend. Do
not document SDDM Plasma autologin as the supported current implementation.

Target customization also owns the supported Meo Desktop payload, MeoUI and
Meo.System runtime, Quick Repair, Welcome first-run entry, locale state,
NetworkManager handoff, selected guest integration, firewall state, swap mode,
GRUB theme/config generation, Plymouth integration, and required service
activation.

The installed-target GRUB configuration and Live ISO bootloader are separate
concerns:

- Live ISO: BIOS Syslinux + UEFI GRUB.
- Installed target: GRUB according to the validated installation plan.

No Live-only autologin, authorization helper, Cage service state, or other Live
capability marker may remain in the installed target.

## Software/package boundary

Software selections resolve versioned catalogue IDs, not arbitrary shell
commands. Arch packages come from configured signed repositories and Meo
components from the selected signed Meo repository/channel.

Installer package selection must converge with OmniStore/meo-repo catalogue
truth rather than maintaining an unrelated hard-coded product list.
Contextual package changes after installation belong to the shared package
transaction/OmniStore architecture, not to the Installer.

## Translation

Installer strings use Qt translation facilities. English is the fallback and
Simplified Chinese is a reviewed packaged language. Runtime locale, region,
time-zone, and keyboard catalogues are generated from maintained system data
rather than a tiny hand-written list where practical.

## Validation boundary

Source tests can prove schema, secret-exclusion, planning, QML/native build, and
security invariants. They do not prove the Live session or destructive install.

Release evidence must remain layered:

```text
source/static
  < component/package build
  < ISO inspection
  < Live ISO boot
  < destructive VM install
  < reboot + first login
  < failure/recovery repetition
  < representative real hardware
```

At minimum, the current candidate still needs explicit evidence for:

- default Plasma Live startup and full-screen Installer;
- Installer close/crash leaving Plasma/KWin and diagnostics usable;
- Cage Install/Repair fallback with no compositor race;
- BIOS Syslinux and UEFI GRUB Live boot paths;
- destructive disk plan in a disposable VM;
- reboot into the installed target and first login through plasmalogin;
- absence of Live-only residue in the target;
- installation failure/recovery behavior;
- repeated runs rather than one successful screenshot.

Never use a host disk for destructive acceptance testing, and never upgrade an
unrun stage to PASS because an earlier source/build stage succeeded.
