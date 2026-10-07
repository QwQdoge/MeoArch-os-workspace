# MeoArch unfinished work

This file consolidates product work that was previously scattered across repository docs and older planning notes. It deliberately separates **product/code gaps**, **documentation conflicts**, **validation**, and **deployment/release** so a missing test is not mistaken for a missing feature and a roadmap checkbox is not mistaken for runtime truth.

The cross-system product contract is `docs/design.md`.

## P0 — product paths that are still incomplete

### Meo Settings real writers and transactions

- Replace preview-only/session-only configuration paths with validated real writers where the owning backend exists.
- Lock-screen user configuration needs a real per-user writer with schema validation, atomic persistence and rollback.
- Login-screen configuration needs a privileged, narrow transaction service that snapshots, validates and rolls back without editing PAM directly.
- Keep the transaction sequence consistent: `Inspect -> Validate -> Plan -> Preview -> Authorize -> Snapshot -> Apply -> Validate -> Commit / Rollback`.
- Continue converting normal KCM handoffs into native Meo Settings pages; KDE System Settings remains the advanced fallback.
- Do not claim an area complete until the page changes the real authoritative system state and reads it back successfully.

### Shared Meo system service/API

Create or finish a typed shared system layer so Shell, Settings, Widgets, Lock Screen, Performance Manager and AI Router stop growing duplicate runtime adapters.

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

Keep model output untrusted, capability typed, caller-bound and policy checked. Privileged package/repair/configuration operations remain in their owning services.

### Installer process lifetime and Live separation

- Plasma Wayland Live is the normal path; Cage remains fallback/kiosk.
- The Live desktop must survive Installer close/crash.
- Installation work must continue through a trusted backend and must not be killed merely because the GUI window exits.
- GUI and CLI must share `InstallConfig -> InstallPlan -> runner`.
- Keep Live environment state separate from target-system state.
- Finish the repeatable install -> reboot -> first-login VM path before treating installer work as release-ready.

### Input methods

- Implement the native Meo Settings Fcitx5 page far enough that normal users do not need `kcm_fcitx5` for ordinary setup.
- Support Meo-managed, self-managed and custom framework modes.
- Contextually install missing engines through the shared package transaction authority, never `pacman` from QML.
- Preserve user dictionaries/configuration when switching management mode.

## P1 — documentation conflicts to normalize

### Lock-screen runtime

Current merged/runtime direction is standalone Meo Session Lock (resident Quickshell + Wayland session-lock + PAM). Older KScreenLocker Look-and-Feel-only wording must be updated or clearly marked historical.

### Lock-screen privacy default

Canonical default: notification **count only**. App names, full content, album artwork and precise location are opt-in. Update older `full-content` defaults to match.

### Installer Live mode

Update older Cage-only specs so they distinguish:

- normal Plasma Wayland Live desktop;
- full-screen Installer application on top;
- optional Cage fallback/kiosk mode.

### Settings fallback wording

Older documents that present KCM handoff as the normal Settings flow should be updated. Native Meo workflow is the target; KCM is advanced compatibility fallback.

### Package/catalog truth

Reduce duplicated hard-coded application/component lists. Installer, OmniStore and release tooling should consume one versioned/release-pinned canonical catalogue.

## P1 — package/release architecture still to finish

- Canonical package/application catalog with `kind`, `visibility`, `required`, `removable`, install source and Store exposure metadata.
- Stable/Beta channel handling remains pacman-authoritative.
- Formal user installation must use signed repository packages, not clone/build from GitHub.
- Keep shell/runtime components hidden as system components rather than ordinary Store apps.
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

- real Plasma/Wayland session behavior;
- lock/unlock success/failure, suspend/resume, DPMS and multi-monitor;
- Login Manager authentication/session-start behavior;
- real package transaction and channel changes;
- full installer disk operation, reboot and first login;
- real NetworkManager/BlueZ/PipeWire/KScreen interaction;
- accessibility, keyboard-only and screen-reader checks;
- hardware-specific power/HDR/VRR/fingerprint behavior;
- ISO boot and repeated VM installation reliability.

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
10. docs no longer describe an obsolete competing architecture as current.
