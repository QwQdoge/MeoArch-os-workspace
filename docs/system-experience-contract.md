# MeoArch system experience contract

## Purpose

MeoArch is split across several repositories, but the user must experience one coherent system.

This contract defines the cross-repository ownership required for normal installation, first boot, settings, software installation, input methods, appearance, lock screen/session entry, updates, recovery, and common desktop hardware. It does not replace the detailed contracts in each owning repository.

A feature is not complete merely because one repository has a UI or helper. A user-facing capability is complete only when its full path is owned:

```text
user intent
  -> Meo UI surface
  -> typed system/package capability
  -> authoritative backend
  -> progress/error state
  -> verification
  -> refreshed UI state
```

Do not solve cross-repository gaps with duplicated state, arbitrary shell commands, or repeated handoffs to unrelated KDE utilities.

---

## Repository ownership

### MeoArch-os-workspace

Owns:

- Live ISO;
- Installer UI/backend;
- target install selections and package resolution;
- target customization/handoff files;
- first-boot installation markers;
- Quick Repair and Live recovery entry points;
- release/VM/installed-system acceptance.

The Installer may select what must exist on the target, but should not become the long-term settings authority.

### meo-kde

Owns KDE/Plasma/KWin/Qt-native integration and Meo.System-style adapters, including:

- desktop/session integration;
- theme/application-style integration;
- wallpaper/dynamic-color bridge;
- input-method framework integration;
- lock-screen presentation/session-lock integration;
- display/audio/network/power/session adapters that belong to the desktop layer;
- typed APIs used by Meo Settings and Meo AI.

It should expose maintained typed capabilities instead of forcing consumers to edit KDE configuration files or invoke shell helpers directly when a reusable system API is needed.

### MeoSettings

Owns the normal day-to-day settings UI and workflow.

Its maintained coverage contract is `docs/SETTINGS_COVERAGE.md` in the MeoSettings repository. KDE System Settings is a compatibility/advanced escape hatch, not the default workflow.

### MeoUI

Owns reusable UI primitives, design tokens, motion and application-level visual contracts. It does not own system state, authentication, session locking or package transactions.

### OmniStore

Owns software catalog/source logic and package mutations after installation.

Meo Settings may embed contextual install/remove flows, but the package plan, trust, authentication, mutation, progress and result verification must come from a shared OmniStore/package transaction contract rather than a second package manager in Settings.

### meo-repo

Owns Meo package recipes, signed repository metadata, meta packages and versioned product dependency contracts.

It should provide package-level groupings/capability metadata where MeoArch needs an optional system feature to be consistently resolvable by Installer, Settings and OmniStore.

### MeoArch-account

Owns Meo account/authentication and provider/inference grants. It must not become a generic OS privilege, local-session unlock authority or package-install authority.

### meo-login-manager

Owns the supported login-manager implementation. Login/password entry should remain minimal and security-focused; session input-method frameworks are not implicitly injected into the credential field.

The login manager and lock screen may share MeoUI visual language and carefully reviewed authentication integration, but they must not share transient credential state or pretend to be the same security boundary.

---

# Required cross-repository flows

## 1. Installer -> installed desktop -> first login

The supported flow is:

```text
Live ISO
  -> Installer selections
  -> deterministic install/package plan
  -> install target
  -> target customizations
  -> first boot/login
  -> Welcome for unfinished personal setup
  -> Meo Settings for ongoing configuration
```

Installer should own choices that materially affect the installed target and are difficult to make safely after destructive installation has begun:

- locale/time zone;
- physical keyboard layout;
- network needed for installation;
- disk/filesystem/security choices;
- target local user;
- base/recommended/custom product profile;
- update channel;
- optional input-method framework/initial engines;
- target hardware-driver plan.

Personalization that is safe to change later should normally live in Meo Settings/Welcome rather than expanding the destructive installer indefinitely, for example wallpaper, detailed theme tuning, default applications, Meo Account sign-in, notification preferences and most accessibility preferences.

The Installer must record enough non-secret first-boot state to let Welcome identify unfinished setup without inventing a second configuration database.

---

## 2. Input methods

### Current product direction

MeoArch should offer Fcitx 5 as the recommended managed Wayland input-method framework while allowing the user to choose keyboard-layout-only/self-managed/custom input-method ownership.

Physical keyboard layout and text input method are different settings and must not be represented as one selection.

### Installer responsibility

Add a target input-method selection adjacent to locale/keyboard setup or as a dedicated step.

At minimum support:

- `Keyboard layouts only / no managed IME`;
- `Meo-managed Fcitx 5`;
- initial engine/language selection when the selected engine is available from trusted configured repositories.

The Installer should resolve the selected capability to target packages through versioned package metadata. It must not hard-code one unmaintained list in QML.

The selected target plan should be visible in Summary before installation.

### meo-repo responsibility

Provide a stable package/capability grouping for the supported Fcitx integration instead of making `meo-desktop` permanently depend on an input-method framework.

A suitable model is an optional Meo Fcitx integration/meta package plus versioned engine capability metadata. Language-engine packages may continue to come from signed Arch/Meo repositories; wrapper packages are not required when upstream packages already provide the real implementation.

### meo-kde responsibility

The existing input-method theming contract remains presentation-only. Add a separate management/integration boundary for:

- detecting supported frameworks;
- session/KWin integration state;
- Fcitx 5 availability/running state;
- active engine inventory through maintained Fcitx interfaces;
- reload/restart where safe;
- Meo theme synchronization;
- diagnostics for Wayland/Qt/GTK integration.

Do not give Meo Settings arbitrary process or shell authority.

### Meo Settings responsibility

Provide the normal input-method page defined by its coverage contract: enable/disable managed mode, add/remove/reorder engines, shortcut, integration status, diagnostics and contextual package installation.

### Login-manager boundary

Do not automatically run a general session IME inside the login/password field. The login manager may offer safe keyboard-layout selection. Full IME support at credential entry requires a separate explicit security review.

### Repair responsibility

Quick Repair should eventually gain an `input-method` diagnostic category covering common bounded faults such as missing framework packages, framework not running, KWin integration mismatch, missing toolkit bridge, or selected engine unavailable. Repair must use typed fixes/package handoffs rather than arbitrary commands.

---

## 3. Contextual package transactions

Meo Settings needs to install optional capabilities such as input engines, language support, helpers, themes/components and potentially drivers without opening a terminal or KDE package tool.

The long-term flow is:

```text
Meo Settings owning page
  -> request capability/package plan
  -> OmniStore/package transaction service
  -> trusted source + dependency resolution
  -> user confirmation/authentication
  -> apply transaction
  -> progress/result
  -> verify installed capability
  -> refresh owning Settings page
```

Required package-service properties:

- typed package/resource IDs, never arbitrary command strings;
- source identity and trust visible to the caller;
- dependency and size plan when available;
- canonical plan/hash before privileged apply where practical;
- Polkit/authentication owned by the privileged transaction boundary;
- progress and cancellation semantics;
- one active native package transaction at a time;
- signature/repository policy preserved;
- structured failure result;
- post-transaction verification.

Meo Settings must not run `sudo`, `pkexec pacman`, `pacman -S`, or parse terminal output as its package authority.

The existing unified update path remains owned by OmniStore. Contextual one-off installs/removals should reuse the same trust and transaction architecture rather than becoming a separate updater.

---

## 4. Appearance, wallpaper and Meo visual state

Normal appearance configuration must stay inside Meo Settings.

The presentation is MeoUI, while meo-kde owns the reusable KDE/Plasma/KWin integration required to apply:

- supported light/dark/system mode;
- dynamic-color source;
- MeoStyle;
- Meo desktop/fallback theme;
- icons/application icon treatment;
- window decoration;
- supported cursor defaults;
- wallpaper and per-display wallpaper state;
- supported shell visual profile.

Where several layers form one supported Meo preset, expose one typed/apply transaction with verification and partial-failure reporting rather than making Settings invoke a series of unrelated scripts.

Wallpaper must use the real desktop wallpaper authority and dynamic-color refresh must follow the confirmed wallpaper change.

---

## 5. First boot / Welcome

Welcome is not a second Settings implementation.

It should:

- read whether first-boot setup is complete;
- show unresolved high-value setup items;
- deep-link to or reuse Meo Settings workflows;
- support Appearance/wallpaper, network, Bluetooth, input method, display/power, account, privacy/update/recovery and default-app setup where useful;
- disappear from automatic startup after completion while remaining manually launchable if desired.

Installer selections already applied to the target should appear as current state, not be asked again without reason.

---

## 6. Lock screen and session entry

The lock screen is a security surface, not merely a themed desktop page.

The supported architecture must have exactly one authoritative normal session-lock path. Meo must not allow Plasma/KScreenLocker, a Meo lock process and an emergency locker to race as independent normal lock owners. A fallback may exist only as a bounded fail-safe when the primary Meo locker cannot acquire or provide a secure lock.

### Current direction

The current meo-kde lock path uses a resident, lock-only Quickshell process with source watching disabled. It keeps the service graph needed by the lock surface and idle/suspend locking resident so the normal lock request does not need to start a renderer after the user requests a lock. The launcher keeps lock configuration isolated from the user's ordinary shell configuration, and the lock command has an emergency fallback path if the primary process is unavailable.

This is a useful foundation, but source/package presence alone is not proof of production lock security. Installed-session acceptance must prove the session is actually protected across lock, suspend/resume, crashes and multiple displays.

### meo-kde responsibility

meo-kde owns the installed-session lock presentation and desktop integration, including:

- the primary session-lock process and invocation path;
- secure lock acquisition through the maintained Wayland/session-lock authority;
- idle lock and lock-before-suspend coordination;
- multi-monitor lock surfaces and hotplug behavior while locked;
- lock/unlock transition presentation without exposing a desktop frame;
- Meo wallpaper/dynamic-color presentation on the lock surface;
- battery, network and other read-only status adapters shown while locked;
- lock-safe media controls when enabled;
- emergency fallback behavior if the primary lock surface fails;
- post-crash/restart behavior that fails closed rather than turning the lock action into a no-op.

The lock screen must never own or persist a plaintext password/PIN. It presents authentication prompts and consumes the result of the maintained authentication authority.

### Authentication boundary

Local session unlock remains owned by the supported PAM/session authentication stack. Password, fingerprint and any future local authentication methods must enter through reviewed authentication interfaces.

Required rules:

- password verification is never reimplemented in QML;
- credentials are not logged, persisted, sent to Meo Account, exposed to AI or copied into general app state;
- fingerprint may supplement unlock only through the maintained PAM/authentication flow;
- password fallback remains available when biometrics fail or are unavailable;
- repeated failed authentication must preserve the upstream security/rate-limit behavior;
- account/cloud authentication is not a substitute for local session unlock.

### Lock-screen information and privacy

The lock screen may expose useful glanceable information, but every data source must have a lock-safe presentation contract.

Supported product targets may include:

- time/date;
- battery/charging state;
- network state without secrets;
- media title/artwork and playback controls;
- notification summary/cards;
- weather;
- calendar/upcoming events;
- user/avatar;
- safe accessibility and session-entry affordances.

Meo Settings must provide privacy controls for sensitive lock-screen data. At minimum support a policy equivalent to:

```text
Notifications on lock screen
  - Show content
  - Hide sensitive content
  - Do not show notifications
```

Calendar/event details, message previews, sender names and media metadata should follow explicit privacy policy rather than being exposed merely because the desktop service can provide them.

Do not expose arbitrary app actions, clipboard contents, file previews, AI conversation content, secrets, package actions or privileged settings while locked.

### Meo Settings responsibility

Normal lock-screen settings should live in Meo Settings rather than a KCM handoff. The native page should eventually cover the supported subset of:

- automatic lock timeout;
- lock on suspend/resume policy where applicable;
- lock-screen wallpaper mode (follow desktop or separate when supported);
- notification visibility/privacy;
- media controls visibility;
- weather/calendar visibility and privacy;
- battery/network status visibility;
- reduced-motion integration;
- fingerprint/unlock-method status through the maintained authentication backend;
- safe power/session-entry preferences exposed by the supported login/session stack.

Advanced upstream settings may remain behind the final KDE compatibility escape hatch until Meo has a maintained implementation.

### Login-manager boundary

The lock screen and `meo-login-manager` should look like one Meo product but remain separate lifecycle/security surfaces.

Shared MeoUI components, tokens, wallpapers and authentication adapters are acceptable. Shared transient password state, unlock-session state or assumptions that login and unlock are interchangeable are not.

User switching from the lock screen should hand off to the supported login/session manager rather than implementing a second login manager inside the lock surface.

### Acceptance requirements

Lock screen acceptance requires installed-session evidence for at least:

- manual lock;
- idle-triggered lock;
- lock before suspend and resume into a locked state;
- correct password unlock;
- incorrect password behavior;
- fingerprint success/failure/password fallback when supported;
- primary locker crash/failure and secure fallback;
- no visible desktop flash during normal lock/unlock;
- multi-monitor coverage;
- monitor hotplug/removal while locked;
- notification privacy modes;
- media controls not granting broader desktop access;
- logout/user-switch/power actions using their owning session authorities.

Treat failure to securely acquire or maintain the lock as a release blocker when the Meo locker is the default installed session locker.

---

## 7. Updates, repair and recovery

OmniStore owns normal package/system updates through the maintained `meo-update` contract.

Meo Settings owns update status/preferences and invokes the supported update action; it does not implement a second updater.

Quick Repair owns bounded diagnosis and typed repair actions. Meo Settings may deep-link to a repair category but must not copy repair implementations.

Installer/Live ISO owns offline/live recovery entry points. Destructive reset/reinstall flows must not be hidden inside a normal Settings toggle.

---

## 8. Drivers and firmware

Installer already detects a target graphics-driver plan. The installed system also needs a maintained post-install path for hardware changes and optional support.

Long-term ownership:

- hardware detection/inventory: maintained system/Meo backend;
- package availability and mutation: OmniStore/package transaction service;
- user-facing status/choice: Meo Settings > System/Hardware;
- repair of known broken driver state: Quick Repair when a bounded safe action exists.

Do not make Settings execute vendor installers or arbitrary downloaded scripts.

---

## 9. Printers, scanners and common peripherals

A usable desktop eventually needs a native normal path for printing/scanning and common peripherals.

Meo Settings should eventually cover at least:

- detected printers;
- add/remove printer;
- default printer;
- queue/basic status;
- common paper/quality defaults where the backend exposes them;
- detected scanners/status or a maintained scan-application handoff;
- clear diagnostics when CUPS/SANE/backend support is absent.

CUPS, SANE and maintained device services remain authoritative. Vendor-specific administration can remain an advanced handoff.

This is not a P0 installer blocker unless printing/scanning is part of the release target, but it is part of long-term day-to-day Settings coverage.

---

# Priority order

## P0 — make the installation-to-settings path coherent and secure

1. Define input-method selection state and target package resolution in Installer.
2. Define optional Fcitx integration packaging/capability metadata in meo-repo.
3. Add a typed input-method management adapter in meo-kde; preserve the existing theming-only contract as a separate concern.
4. Implement the native Meo Settings input-method workflow against that adapter.
5. Define/implement the shared contextual package transaction API so Settings can safely install missing engines/components.
6. Make Appearance/wallpaper normal native Meo Settings workflows using reusable meo-kde authorities.
7. Make Welcome reflect incomplete first-boot setup rather than only acting as a list of links.
8. Formalize the Meo lock screen as the authoritative default session-lock path and prove fail-closed lock/suspend/resume behavior before treating it as production-ready.
9. Add native Meo Settings coverage for ordinary lock-screen/privacy preferences without moving authentication authority into Settings.

## P1 — normal installed-system completeness

- richer lock-screen media/notification/calendar/weather surfaces with explicit privacy policy;
- default applications and associations;
- driver/firmware status and supported installs;
- robust language-pack installation;
- storage/removable-device workflows;
- native common accessibility controls;
- printer/scanner workflow;
- input-method diagnostics in Quick Repair;
- application repair/uninstall/storage operations through shared OmniStore contracts.

## P2 — advanced integration

- specialist third-party theme/install workflows;
- vendor-specific hardware controls;
- unusual input-method frameworks;
- advanced printer/scanner administration;
- expert KDE KCM coverage that is not required for normal operation.

---

# Cross-repository acceptance rule

Do not call a cross-repository capability complete until at least one installed-session acceptance path proves the entire chain.

For example, Japanese input support is not complete when a Settings row exists or when `fcitx5-mozc` installs successfully in isolation. Acceptance requires the supported chain:

```text
Settings/Installer selection
  -> trusted package resolution
  -> install/apply
  -> session integration
  -> Fcitx engine visible
  -> engine selectable
  -> candidate UI uses Meo presentation
  -> native Wayland sample input works
  -> state survives logout/login
```

Likewise, a lock-screen screenshot is not proof of a secure locker. Acceptance requires the primary lock path, authentication, suspend/resume, failure fallback and privacy behavior to work together in an installed session.

Keep source/static, package-build, VM, installed-session and real-hardware evidence separate.