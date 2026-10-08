# Current MeoArch milestone

## Goal

Produce one coherent, demonstrable MeoArch path from boot/install into the Meo desktop and its normal first-party workflows. The milestone values a complete, maintainable user path over broad feature count.

This file is a **scope contract**, not a production-readiness claim. Evidence belongs in `production-readiness-matrix.md` and the owning repository's validation records.

## Definition of done

A milestone capability is complete only when:

1. its owner and user-facing route are unambiguous;
2. the implementation uses the authoritative backend rather than duplicated local state or arbitrary shell commands;
3. normal errors are visible and recoverable;
4. security/destructive boundaries fail closed;
5. targeted build/tests pass;
6. any remaining real-session, VM, or hardware validation is explicitly recorded rather than silently assumed.

## P0 — required coherent path

### Boot, Live environment, and installation

- ISO builds deterministically from a clean source state.
- Live environment launches the intended installer surface.
- Installer close/crash behavior cannot silently terminate a destructive install and leave an ambiguous state.
- Network, storage selection, target user, locale/time zone, keyboard layout, target package plan, and target login/session setup have one clear authority.
- Installed target boots into the supported Meo desktop/login path.

### Desktop shell and visual foundation

- Meo Desktop has one supported session path and one coherent Meo visual identity.
- MeoUI is the application UI foundation; MeoStyle provides the Qt Widgets bridge rather than every application inventing local styling.
- Launcher, top bar/quick settings, notifications, basic media/audio presentation, and system status use maintained typed backends.
- Dynamic color and light/dark appearance do not create parallel conflicting theme state.

### Meo Settings daily baseline

Normal daily workflows should remain inside Meo Settings for the milestone subset:

- network basics;
- Bluetooth basics;
- display basics;
- sound basics;
- power basics;
- wallpaper and supported Meo appearance;
- keyboard/input-method status and the supported Fcitx path;
- language/date/time basics;
- default applications;
- common privacy and accessibility controls;
- storage/system/about summaries.

A specialist control may remain behind one clearly marked advanced KDE handoff. Do not scatter ordinary KCM links through otherwise native pages.

### Session entry and security

- Meo Session Lock has one authoritative normal lock path.
- Local unlock remains PAM/session-authentication authoritative; credentials are never reimplemented or persisted in QML/application state.
- Session-entry presentation configuration is schema validated and scoped separately for lock screen and login.
- Login manager remains a separate lifecycle/security boundary from the logged-in session lock.
- If the Meo locker is the default, inability to securely acquire or maintain the lock is a release blocker.

### Software/update trust path

- Package/update operations retain one trusted transaction authority.
- Settings, Installer, Repair, and AI do not gain arbitrary package-manager or shell execution merely for convenience.
- Repository/source identity, signatures, progress, structured failure, and post-transaction state remain owned by the package/update layer.

### Repair and recovery

- Meo Repair receives typed/bounded diagnostic categories rather than arbitrary command execution.
- Installer/Live recovery remains separate from normal Settings toggles.
- Destructive recovery requires explicit confirmation and a clear recovery boundary.

## P1 — important after the P0 path is stable

- richer Fcitx engine management and contextual engine installation;
- richer per-application sound and permission controls;
- complete lock-screen widget/layout customization;
- drivers/firmware management after installation;
- richer Welcome/first-boot guided setup;
- printers/scanners and uncommon peripherals;
- broader app-management surfaces inside Settings;
- additional AI Router capabilities after their owning components expose stable typed APIs.

## Not part of this milestone by default

The following are not automatically implementation tasks merely because long-term documents mention them:

- replacing every KDE KCM;
- arbitrary third-party theme installation;
- restoring every historical branch experiment;
- implementing every possible Fcitx/IBus specialist option;
- implementing a second package manager inside Settings;
- broad AI control of destructive system actions;
- speculative security features without an authoritative backend;
- production claims based only on static source checks or successful compilation.

## Change control

A new item enters P0 only when it is required for the supported end-to-end path, closes a security/data-loss correctness gap, or is explicitly promoted by the project owner. Otherwise record it as P1/future work and keep the current task bounded.
