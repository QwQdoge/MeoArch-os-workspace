# MeoArch cross-system design contract

This document is the canonical cross-system product/design contract for MeoArch. It exists to keep the individual repositories aligned when older repository-local documents disagree.

It defines product ownership and interaction boundaries, not proof that every capability is already implemented. Runtime/source status must still be verified in the owning repository before a roadmap item is marked complete.

## 1. Product identity

**MEO = Modern · Expressive · Open.**

MeoArch is not a collection of unrelated KDE themes. KDE Plasma/KWin and maintained Linux services provide the default desktop and system foundations; MeoArch provides a coherent Meo platform, MeoUI presentation layer and first-party system applications above them.

The target architecture is:

```text
Linux / Arch / system services
        ↓
KDE Plasma / KWin / maintained upstream authorities
        ↓
Meo Platform APIs + meo-system-service
        ↓
MeoUI system shell and first-party applications
        ↓
Launcher / Control Center / Notifications / Lock Screen
Meo Settings / Performance Manager / Widgets / AI Router
OmniStore / Installer / Repair / Account
```

A Meo component must not reimplement a maintained system authority only to gain visual control. Meo owns presentation, routing, typed capability adapters, transactions, recovery and product integration.

## 2. UI and design-system ownership

MeoUI is the canonical design runtime for first-party QML applications and system surfaces.

- QML applications import and reuse MeoUI directly.
- Qt Widgets/KDE applications use MeoStyle, which renders QWidget controls while consuming the same canonical colors, typography, shapes, spacing, icons and motion contracts.
- Plasma shell surfaces use Meo-owned QML and MeoUI-compatible tokens; a Qt style alone is not expected to redesign Plasma.
- KDecoration/KWin own titlebar decoration, final window effects, rounding and compositor behavior.
- Electron/Chromium applications are not force-restyled internally. Meo may unify only the surrounding desktop/shell experience.

Do not create separate QSS/Kvantum/token copies that can drift from MeoUI.

The normal navigation model is one canonical responsive sidebar/navigation system: stable route IDs, real route search, persistent navigation on wide layouts and modal/compact navigation on narrow layouts. Ordinary application pages should not invent competing sidebar systems.

## 3. System service boundary

Shared runtime system state should be exposed through maintained typed services/adapters so Settings, Control Center, Launcher, Lock Screen, AI Router, Widgets and Performance Manager do not each implement their own shell-command bridge.

The shared system layer should cover, as applicable:

- NetworkManager networking;
- BlueZ Bluetooth;
- PipeWire/PulseAudio-compatible audio;
- KScreen/KWin display and window state;
- PowerDevil/power profiles, battery and brightness;
- systemd user/system service state through explicit supported adapters;
- hardware/runtime information;
- CPU/GPU/RAM/process/temperature/network/performance telemetry;
- media via MPRIS;
- notifications through the maintained KDE/Meo projection.

QML must not execute `sudo`, arbitrary shell commands, package-manager commands or raw privileged writes.

## 4. Meo Settings

Meo Settings is the default day-to-day system settings surface. KDE System Settings is an advanced compatibility escape hatch, not the normal workflow.

Normal users should be able to manage the following inside Meo Settings when the backend is supported:

- network, Wi-Fi, Ethernet, hotspot, VPN and proxy;
- Bluetooth and connected devices;
- displays, scaling, refresh rate, HDR/VRR where safely supported, brightness and Night Light;
- sound, input/output devices and common per-app streams;
- notifications and Do Not Disturb;
- power, battery and performance profiles;
- appearance, wallpaper, dynamic color and MeoUI preferences;
- desktop, windows, launcher, dock/top-bar and common workspace behavior;
- keyboard, mouse, touchpad and shortcuts;
- language, region, date/time and input methods;
- applications, defaults, permissions, storage and background/autostart behavior;
- privacy, accessibility, accounts/users;
- updates, recovery, diagnostics, firmware/driver status when a maintained authority exists;
- printing/scanning, sharing and other ordinary desktop capabilities as they receive safe native adapters.

Meo Settings follows a schema-first control path for Meo-owned configuration:

```text
Schema → Adapter → Transaction → Renderer
```

Writes use validation and recovery rather than ad-hoc direct mutation when the operation is privileged, destructive, multi-step or otherwise capable of leaving broken state:

```text
Inspect → Validate → Plan → Preview → Authorize
→ Snapshot → Apply → Validate → Commit / Rollback
```

Low-risk per-user preferences may use a narrower validated authoritative writer, but they still need real read/write/error behavior and must not be decorative state.

Runtime information must be detected from the real system. Do not hard-code hardware, session, version or capability state. Unsupported/unavailable capabilities must be shown as unavailable or omitted, not simulated.

### Input methods

The supported default is **Meo-managed Fcitx5 on Wayland**. Users must be able to select:

1. Meo-managed Fcitx5;
2. Fcitx5, self-managed;
3. Custom / another input method.

Meo Settings should add/remove/reorder input methods, show framework/integration status and install missing language engines contextually through the shared package transaction service. Settings owns the contextual flow; OmniStore/package services own installation transactions. Changing mode must not silently delete user dictionaries, engines or configuration.

## 5. Desktop shell

Meo's first-party shell experience includes:

- Launcher;
- Control Center / Quick Settings;
- Notification Center;
- time/calendar surface;
- desktop and context-menu integration;
- dock/task presentation;
- top bar / application menu integration;
- foreground-launch feedback;
- lock screen;
- widget platform;
- performance manager.

The product-facing **Meo Desktop** session currently starts Plasma 6 Wayland and KWin. It is a Meo product layer on top of the maintained Plasma platform, not a separate compositor or window manager.

Shell controls must be service-backed, asynchronous and expose per-module busy/error state. A decorative toggle that does not reflect the real system state is not considered implemented.

## 6. Lock screen and login

MeoArch currently carries more than one lock implementation because different desktop/session runtimes have different security authorities. Documentation and Settings adapters must always name the runtime they target.

### Meo Desktop / Plasma Wayland

The default Meo Desktop product session currently uses Plasma 6 Wayland + KWin. Its lock-screen security core remains KScreenLocker, with the Meo Look-and-Feel providing the Meo presentation.

Meo Settings already has a persistent `LockScreenPresentationBackend` for the supported presentation subset. It reads and writes the Meo Look-and-Feel keys in `kscreenlockerrc` and must not be described as preview-only.

The corresponding notification privacy default is **count only**. Application names and full content are more permissive explicit choices. Album artwork and weather-location visibility are independent presentation/privacy controls.

### Standalone Meo Session Lock

MeoKDE also carries a resident standalone Meo Session Lock for sessions that use a Quickshell/Wayland-session-lock runtime, currently documented around the Hyprland/UWSM path. It uses PAM-backed authentication and has a separate lifecycle/configuration boundary from KScreenLocker.

The existence of this implementation does not make the Plasma/KScreenLocker path obsolete. Likewise, KScreenLocker documentation does not define the standalone runtime. If the standalone runtime becomes a supported user-selectable/configurable session, Settings needs an explicit adapter for it instead of writing both backends blindly.

### Shared security rules

Regardless of runtime:

- authentication success is owned by the trusted PAM/upstream authenticator, never by QML password comparison;
- visual unlock motion must not cause or precede authentication success;
- login/greeter is a separate security boundary owned by Meo Login Manager and its upstream authentication/session-start path;
- ambient lock surfaces may show only explicitly permitted bounded data;
- authentication UI must not expose unrelated private content;
- failures of weather/media/notification providers must never block authentication.

The richer lock-screen layout editor in Settings is a simulated editor until the corresponding validated persistent layout writer exists. Only reviewed Meo secure widgets may be projected into a security surface; arbitrary Plasma applets/QML cannot cross the security boundary.

The privileged Login Manager configuration writer/transaction service is separate unfinished work and must never mutate PAM ad hoc.

## 7. Widgets

MeoArch provides one Add Widgets entry and one searchable widget catalogue.

The platform should support real desktop placement, movement, resize/configuration, multi-display persistence and compatibility with the maintained Plasma applet lifecycle where appropriate.

Meo first-party widgets use a shared MeoWidget contract and may render as Native, Meo Framed or Adaptive depending on content. Lock-screen widgets are a separate reviewed security-safe subset and are not the same live instances as desktop widgets.

A first-party widget bundle may include clock, media, performance and explorer/system widgets. A general Settings entry for widget management is required; source-ready styling without a user entry is not a complete product path.

## 8. Performance Manager

Performance monitoring is a first-party system component, not a theme panel.

A common telemetry backend should serve the dedicated performance manager, quick-settings summaries, widgets and AI read-only queries. At minimum the shared model should be able to expose supported CPU, GPU, RAM, process, temperature, uptime, battery and network metrics without each client scraping `/proc` independently.

The package boundary may use an independent `meo-system-monitor`/monitor service while keeping all UI surfaces on the same authority.

## 9. System AI Router

Meo AI is an intent/router layer, not a privileged shell executor.

Canonical request flow:

```text
User
  ↓
Meo AI
  ↓
System AI Router
  ↓
Intent
  ↓
Owning App / System Component
  ↓
Typed Capability
  ↓
Policy / Permission / Confirmation
  ↓
Owning App API / trusted backend
  ↓
Verify
  ↓
Result
```

Examples of intent families include:

- `settings.bluetooth.open`;
- `desktop.audio.setVolume(30%)`;
- `file.search`;
- application launch/open;
- read-only system/performance queries;
- owned application actions exposed through registered typed capabilities.

The Router:

- has no root authority;
- accepts model output only as untrusted routing input;
- can execute only registered typed capabilities;
- must reject invented actions/arguments;
- must not read provider API keys directly;
- does not inherit OS permission merely because model/inference consent exists;
- delegates package installation, repair and other privileged transactions to their owning applications/services;
- binds confirmations to the exact action/arguments/caller and expires them;
- verifies or reads back results where the capability contract supports it.

The capability registry is the product API between AI and applications. Applications own their actions; AI does not grow a parallel command implementation for every app.

## 10. Installer and Live environment

The normal Live environment is a Plasma Wayland desktop, similar in product shape to a conventional graphical distro live session. The Installer launches full-screen on top of that desktop; closing or crashing the Installer must not destroy the Live desktop session.

Cage remains an optional kiosk/fallback path, not the canonical normal Live UX.

The Installer runs as the live user. Privileged/destructive operations go through a narrow trusted backend/DBus/Polkit boundary. Long-running installation work must not be owned only by the lifetime of the GUI window.

GUI and CLI share the same configuration/planning path:

```text
InstallConfig → InstallPlan → trusted runner/backend
```

The Installer handles initial system/channel/component selection. Installed-system package/channel management belongs to OmniStore/package services.

## 11. Packages, channels and application catalogue

The resolved pacman configuration is the installed system's source of truth for Stable/Beta package channels.

Ownership:

- Installer: initial installation choices;
- OmniStore/shared package service: installed-system software and channel transactions;
- Meo Settings: system preferences plus read-only package/update projections and contextual install requests;
- `meo-repo`: release control plane;
- package repository/R2 distribution: delivery layer.

Formal Meo installation must consume built/signed repository packages. It must not clone and compile MeoUI/MeoKDE from GitHub on the user's target system.

The software catalogue should have a canonical versioned manifest used by Installer, OmniStore and release tooling rather than maintaining separate hard-coded lists.

Core shell/runtime components such as Launcher, Quick Settings, Notification Center, the active lock-screen implementation, top bar/dock integration, MeoUI runtime, icons and login manager are system components, not ordinary removable Store apps.

## 12. Application ownership boundaries

- **MeoUI**: design/runtime/components/tokens.
- **MeoStyle**: Qt Widgets/KDE application style using MeoUI design contracts.
- **MeoKDE / desktop**: shell, session integration, lock-screen integrations, widgets and desktop adapters.
- **Meo Settings**: user-facing settings and safe configuration transactions.
- **OmniStore**: catalogue/package/application transactions.
- **Meo Account**: account/OAuth/KWallet/inference grants and connection state.
- **AI Router**: typed intent routing only.
- **Repair**: evidence-backed diagnostics and fixed typed repair capabilities; no model-generated command execution.
- **Installer/workspace**: Live/installation planning and install execution orchestration.
- **meo-repo**: release/package-channel control plane.

When two applications need the same system state, prefer a shared backend/service over duplicated logic.

## 13. Precedence and stale documentation

When repository-local documents conflict, use the following order until the docs are reconciled:

1. current merged runtime architecture for the **specific session/backend being discussed** and its security authority;
2. this cross-system design contract;
3. repository-local architecture/security contracts that match that runtime;
4. older implementation plans/roadmaps;
5. historical acceptance reports and stale runbooks.

A roadmap checkbox, old release note or successful source build must never be treated as runtime proof.

Known documentation conflicts that should be normalized around this contract include:

- documents that incorrectly treat either KScreenLocker or standalone Meo Session Lock as the only current lock runtime for every session;
- `full-content` lock-screen notification default versus the conservative `count` default;
- old statements that the Plasma lock-screen presentation writer does not exist, despite the implemented `LockScreenPresentationBackend`;
- Cage-only Installer descriptions versus Plasma Wayland Live as the normal path;
- direct KCM handoffs versus Meo Settings as the day-to-day settings surface;
- duplicated package/catalog lists versus a single release-pinned canonical catalogue.
