# MeoArch unfinished work

This file consolidates product work that was previously scattered across repository docs and older planning notes. It deliberately separates **product/code gaps**, **documentation conflicts**, **validation**, and **deployment/release** so a missing test is not mistaken for a missing feature and a roadmap checkbox is not mistaken for runtime truth.

The cross-system product contract is `docs/design.md`.

> **2026-10-08 status:** workspace-level lock/session-entry wording, lock-screen privacy defaults, current Live-session direction, and current ISO boot-mode wording have been reconciled. `docs/production-readiness-matrix.md` now records BIOS Syslinux + UEFI GRUB and treats Plasma Wayland as the normal Live UX with Cage as fallback. Repository-local stale documents may still need the same normalization.

## P0 — product paths that are still incomplete

### Meo Settings session-entry writers and transactions

The Plasma/Meo Desktop lock-screen presentation writer is already implemented and tested in Meo Settings. `LockScreenPresentationBackend` validates and persists the allowlisted Meo KScreenLocker Look-and-Feel keys in `kscreenlockerrc`, and the Meo lock-screen `config.xml` consumes the same keys. Do not reimplement or remove this working path as if it were preview-only.

The first `org.meo.SystemTransaction1` foundation also exists in the workspace. Its current v0.1 contract is deliberately read-only: `Inspect` validates/plans the `session-entry.login.v1` configuration request and rejects mutation. D-Bus introspection and CI coverage exist for this foundation. This is **not** the privileged writer yet.

Remaining work:

- add the first narrow mutating Login Manager configuration transaction only when caller-aware Polkit authorization, snapshot, bounded apply, post-write readback/validation and rollback exist together;
- keep the first mutation limited to a closed typed `session-entry.login.v1` contract rather than turning the service into an arbitrary config-file writer;
- the richer secure-widget/layout editor still needs a validated persistent writer before preview layout state can be described as applied system state;
- per-output presentation/layout and future schema-backed session-entry fields need real adapters before they are marked implemented;
- if the standalone Quickshell Meo Session Lock is exposed as a configurable supported session, add a separate maintained adapter for that runtime rather than blindly writing both lock backends;
- keep the target transaction sequence consistent for sensitive or multi-step writes: `Inspect -> Validate -> Plan -> Preview -> Authorize -> Snapshot -> Apply -> Validate -> Commit / Rollback`;
- continue converting normal KCM handoffs into native Meo Settings pages; KDE System Settings remains the advanced fallback;
- do not claim an area complete until the page changes the real authoritative state and reads it back successfully.

### Shared Meo system service/API

Create or finish a typed shared system-state layer so Shell, Settings, Widgets, Lock Screen, Performance Manager and AI Router stop growing duplicate runtime adapters.

Do not confuse this with `org.meo.SystemTransaction1`: the transaction service is a narrow privileged configuration boundary, while the shared state/service layer is the reusable typed authority for normal runtime state and controls.

Priority authorities:

- NetworkManager;
- BlueZ;
- PipeWire/PulseAudio-compatible audio;
- KScreen/KWin;
- Power/battery/brightness;
- media/MPRIS;
- notifications;
- hardware/runtime information;
- CPU/GPU/RAM/process/temperature/network telemetry.

No first-party QML surface should depend on arbitrary shell parsing for these paths.

### Performance Manager

- Finish the dedicated first-party performance manager UI using MeoUI.
- Use one shared telemetry authority for the full app, quick-settings summary, widgets and AI read-only queries.
- Cover CPU, GPU, RAM, processes, temperatures, uptime, battery and network where available.
- Expose capability/unavailable states instead of fake or hard-coded values.
- Keep the package/app identity aligned with the software catalogue (`Meo System Monitor` / monitor service) rather than creating multiple overlapping performance products.

### Widget platform

- Finish the Add Widgets entry and searchable catalogue.
- Add a real Settings/user-management entry; a source-ready style patch alone is not complete.
- Verify desktop placement, move, resize, configuration, persistence and multi-display behavior.
- Keep secure lock-screen widgets in a separate reviewed registry; never move a live desktop applet directly into the security surface.

### System AI Router

Current typed capabilities are only the beginning. Continue the application capability registry rather than adding ad-hoc model commands.

Next practical capabilities should be added only when the owning component exposes a maintained typed API. Priority families:

- Settings deep links and safe setting reads;
- Bluetooth/network page routing and read-only status;
- desktop audio controls;
- application launch/open;
- file search through an owning file/search service;
- read-only performance/system summaries;
- app-owned actions registered by first-party applications.

Keep model output untrusted, capability typed, caller-bound and policy checked. Privileged package/repair/configuration operations remain in their owning services. The AI Router must not call the system transaction service as a generic root escape hatch.

### Installer process lifetime and Live separation

- Plasma Wayland Live is the normal path; Cage remains fallback/kiosk.
- The Live desktop must survive Installer close/crash.
- Installation work must continue through a trusted backend and must not be killed merely because the GUI window exits.
- GUI and CLI must share `InstallConfig -> InstallPlan -> runner`.
- Keep Live environment state separate from target-system state.
- Finish the repeatable install -> reboot -> first-login VM path before treating installer work as release-ready.
- Current ISO boot contract is BIOS Syslinux + UEFI GRUB; do not restore obsolete systemd-boot readiness claims unless the profile actually changes again.

### Input methods

- Implement the native Meo Settings Fcitx5 page far enough that normal users do not need `kcm_fcitx5` for ordinary setup.
- Support Meo-managed, self-managed and custom framework modes.
- Contextually install missing engines through the shared package transaction authority, never `pacman` from QML.
- Preserve user dictionaries/configuration when switching management mode.

## P1 — documentation conflicts to normalize

The workspace-level contracts are now aligned on the items below. Continue scanning repository-local docs, old roadmaps and acceptance notes for stale wording rather than reintroducing the old architecture.

### Lock-screen runtime

Canonical wording:

- **Meo Desktop / Plasma Wayland** uses Plasma 6 + KWin and the Meo KScreenLocker Look-and-Feel path. Its presentation settings writer is real and already persists the corresponding `kscreenlockerrc` keys.
- **Hyprland/UWSM-style sessions** may use the standalone resident Meo Session Lock based on Quickshell + Wayland session-lock + PAM.

Repository docs must say which session/runtime they describe. KScreenLocker documents are not automatically obsolete merely because the standalone lock also exists, and standalone-lock documents must not claim to be the only lock implementation for every MeoArch session.

### Lock-screen privacy default

Canonical default: notification **count only**. App names and full content are opt-in. Album artwork and precise weather location are controlled independently and are not permission to reveal notification content. Update older `full-content`, generic `show content`, or otherwise more permissive defaults to match.

### Installer Live mode

Canonical wording:

- normal Plasma Wayland Live desktop;
- full-screen Installer application on top;
- optional Cage fallback/kiosk mode.

Older Cage-only specs still need repository-local cleanup when found.

### ISO boot mode

Canonical current profile: `bios.syslinux` + `uefi.grub` from `meoarch-os/profiledef.sh`.

Remove stale current-readiness claims that describe systemd-boot as the active UEFI path. Historical systemd-boot notes may remain only when clearly marked historical.

### Settings fallback wording

Older documents that present KCM handoff as the normal Settings flow should be updated. Native Meo workflow is the target; KCM is advanced compatibility fallback.

### Package/catalog truth

Reduce duplicated hard-coded application/component lists. Installer, OmniStore and release tooling should consume one versioned/release-pinned canonical catalogue.

## P1 — package/release architecture still to finish

- Canonical package/application catalog with `kind`, `visibility`, `required`, `removable`, install source and Store exposure metadata.
- Stable/Beta channel handling remains pacman-authoritative.
- Formal user installation must use signed repository packages, not clone/build from GitHub.
- Keep shell/runtime components hidden as system components rather than ordinary Store apps.
- Keep the formal first-party software catalogue aligned with current product names: Meo Settings, OmniStore, Meo System Monitor, MeoArch Quick Repair, Meo Icon Studio, Meo Widgets and Meo Appearance; Meo Welcome remains a first-run flow rather than a competing standalone settings product.
- Add deterministic/reproducible release metadata where practical (pinned recipe commit/hash and consistent build epoch).
- Keep repository signing/key management, R2/distribution and production OAuth/Worker/Supabase deployment as separate release/deployment work; docs alone do not authorize production publication.

## P2 — application/chrome/design completion

### MeoStyle v2

Continue from the existing canonical MeoUI token/runtime contract. Remaining work includes full control coverage, tables/trees/lists, tabs, scrollbars, motion and QQC2/Kirigami compatibility while preserving upstream behavior, keyboard navigation, RTL and accessibility.

### KDE application chrome

Dolphin remains the first practical pilot for a small distro patch to align top bar/toolbar/address bar/Places spacing and action layout without breaking KIO, views, tabs, split view, drag/drop or shortcuts.

Do not assume every KDE app needs a full fork. Evaluate Ark/Okular/Kate/Konsole only after the pilot proves the patching model.

### MeoUI

Prefer consistency work over adding components for its own sake:

- canonical dimensions/padding/state behavior;
- shared responsive navigation;
- dynamic-color parity;
- motion/reduced-motion consistency;
- accessibility and localization;
- stable component contracts and visual regression coverage.

## Validation backlog — not automatically code gaps

The following require runtime evidence and should not be marked complete from static/source tests alone:

- real Plasma/Wayland Live-session behavior;
- Installer close/crash while the Live desktop remains usable;
- KScreenLocker lock/unlock success/failure, suspend/resume, DPMS and multi-monitor in Meo Desktop;
- standalone session-lock behavior only in sessions that actually ship/use that runtime;
- Login Manager authentication/session-start behavior;
- real package transaction and channel changes;
- full installer disk operation, reboot and first login;
- real NetworkManager/BlueZ/PipeWire/KScreen interaction;
- accessibility, keyboard-only and screen-reader checks;
- hardware-specific power/HDR/VRR/fingerprint behavior;
- BIOS Syslinux boot where supported;
- UEFI GRUB boot on OVMF and representative hardware;
- repeated VM installation reliability.

## Deployment backlog — separate from product implementation

These require explicit deployment/release work and credentials; they are not solved by updating docs or merging source:

- production OAuth configuration;
- Supabase/Worker/R2 production deployment where used;
- signing/trust-root publication;
- release-channel promotion;
- official mirror/distribution configuration;
- production secrets/keys and operational ownership.

## Definition of done

For an ordinary user-facing capability, "done" means all of the following where applicable:

1. the user can reach it through the intended Meo surface;
2. the UI is MeoUI/Meo design-system compliant;
3. it reads the real authoritative state;
4. it changes that state through the maintained typed backend;
5. busy/error/unavailable states are real;
6. privileged/destructive actions use the required policy/authorization boundary;
7. changes are validated and recoverable where failure could leave bad state;
8. the result is read back or otherwise verified;
9. runtime evidence exists for the relevant environment;
10. docs no longer describe another session/runtime's implementation as if it were the only current architecture;
11. release/readiness tables record the strongest evidence actually observed instead of copying historical `Yes` values forward.
