# Live Desktop runtime contract

The default boot is Plasma Wayland, not an Installer-owned compositor:

`GRUB/Syslinux -> graphical.target -> plasmalogin -> live PAM/logind session -> Plasma/MeoKDE -> Live autostart -> Installer`

`meoarch.mode=install|repair|tty` selects the purpose. The independent
`meoarch.session=plasma|cage` selector chooses the compositor. Missing session
selection defaults to Plasma. BIOS, UEFI and GRUB loopback menus expose both
Cage Install/Repair fallbacks; terminal-only remains a separate entry.

## Session and packages

`meoarch-os/` is the source profile. Its Live-only `/etc/plasmalogin.conf` uses
Meo Plasma Login's actual `[Autologin]` User/Session/Relogin keys (`live`,
`plasma.desktop`, `true`). The system package `plasma-login-manager` supplies
plasmalogin and the Arch PAM autologin stack. No SDDM configuration is guessed.
No password is unlocked in shadow, and production SSH stays disabled.

Only the selected compositor may start: plasmalogin rejects Cage/TTY kernel
modes, while `meoarch-installer.service` requires `meoarch.session=cage`.
The Live user home is writable by UID/GID 1000. Login and graphical startup
never depend on an Internet connection.

Staging installs the existing MeoKDE Look-and-Feel, layout, applets, defaults,
Polkit agent and full global Meo.System module. The Installer retains the
smaller existing SystemState adapter at `/opt/meoarch-installer/live-qml`.
Generic UI remains in MeoUI; Plasma/KWin remain the desktop authorities.
The target desktop payload remains separate under `/opt/meo-desktop`.

## Application lifetime

`meoarch-live.desktop` runs the guarded user entrypoint after Plasma autostart.
It checks the compositor socket and plasmashell D-Bus readiness for at most
30 seconds, imports the actual session environment, and starts the independent
`meoarch-live-app.service`. The user service has no Requires/BindsTo relationship
that could make its failure stop Plasma. It never restarts after close/crash.
Successful close stays completed for that login; manual Installer launch remains
available from the application menu. `PartOf=graphical-session.target` only
allows session shutdown to stop the application, not the reverse.

Install mode opens the existing Installer with its explicit desktop fullscreen
property. Repair mode opens the existing unprivileged Quick Repair with
`--live`, without Cage, installation capabilities or a second Polkit agent.
Konsole and Repair remain desktop applications independent of Installer life.
The embedded unprivileged diagnostic console remains useful in Cage fallback.

## Privilege boundary

This migration deliberately preserves the existing root Installer controller
and guarded backend instead of simultaneously replacing every installation API
with a new IPC backend. Plasma, Konsole and Quick Repair remain unprivileged.
Rootless Installer UI with a separate backend is a possible later change; it is
not claimed by this implementation.

The desktop can authorize exactly `/usr/lib/meoarch/live-installer-authorize`
through the ISO-only `org.meo.installer.live.launch` Polkit action. The rule
requires `live`, a local active subject and the exact program/root target.
The helper independently checks `/run/archiso`, install/Plasma boot mode,
`PKEXEC_UID`, active local logind ownership, Wayland/KDE session facts, a private
user runtime directory and a Live-owned non-symlink `wayland-N` socket.
Only session ID and bounded socket basename are accepted. Extra app arguments,
QML/plugin roots, arbitrary shell commands and target paths are not accepted.
Python runs isolated (`-I`). The child receives a constructed environment and a
root-only runtime/state tree, not user HOME, Qt plugin paths or user D-Bus.
Its absolute Wayland socket points to the validated Live compositor.

A root-only lock limits the desktop to one Installer. The helper creates the
existing root-owned 0600 production marker for the child's lifetime and removes
it after exit/crash. Real installation still requires the Controller's ready
plan, identity/handoff verification and explicit user confirmation. Diagnostic
commands still drop privileges. There is no general passwordless sudo.

The policy/helper/autostart are ISO-only staging inputs. Target verification
rejects their installed residue. The target's existing authenticated login
policy remains independent; no Live autologin file is copied to the target.

## Plymouth handoff

Plasmalogin's maintained system unit starts after `plymouth-quit.service`.
Plymouth therefore releases the display as part of desktop/login handoff even
if Installer fails or is never opened. The autostart readiness checkpoint writes
`desktop-ready` to the Live user's boot-status record. This cosmetic checkpoint
cannot hold boot hostage. System and user status records have separate owners.
The desktop Installer still checks that its first Qt frame arrives, but does
not send kiosk systemd-notify or own Plymouth dismissal. Optional Cage keeps
its existing Type=notify/first-frame ready behavior and quiet logo handoff.

## Validation

Source tests prove configuration/security contracts only. Build/staging/ISO
inspection and actual guest runtime each require their own evidence.

1. Run installer/repair unittest discovery and syntax checks.
2. Build components, stage through `scripts/sync-installer-to-airootfs.sh`, and
   run the existing provenance verifier. Build and inspect the actual ISO.
3. Boot with `50-create-vm.sh` / `60-boot-live.sh`. Capture the default boot,
   fullscreen Installer and usable desktop using `65-capture-step.sh`.
4. From the acceptance VM root diagnostic console, run
   `61-check-live-desktop.sh`; after a fresh boot run it with
   `--crash-installer` to assert unchanged Plasma/KWin processes and usable
   Konsole/Repair after SIGKILL. The helper is a guest test, not ISO payload.
5. Separately observe normal close, manual reopen, full-screen state, keyboard
   shortcuts, Repair interaction, offline startup and network reconnect.
6. Boot Cage Install, Cage Repair and terminal-only; verify no compositor races.
   Repeat BIOS/UEFI, GL/software rendering, and verify a temporary installed
   target has no Live autostart/authorization/autologin residue.

A launched QEMU process, screenshots alone, or passing source tests do not prove
this runtime matrix. Record unrun stages as NOT RUN, never PASS.
