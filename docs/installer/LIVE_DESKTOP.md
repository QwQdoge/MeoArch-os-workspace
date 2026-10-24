# Live Desktop runtime contract

The default boot is Plasma Wayland, not an Installer-owned compositor:

`GRUB/Syslinux -> graphical.target -> plasmalogin -> live PAM/logind session -> live-session -> startmeo-wayland (Meo Desktop on Plasma) -> Live autostart -> Installer`

`meoarch.mode=install|ai|repair|tty` selects the purpose. The default
`ai` entry starts native Meo AI after the language/Wi-Fi setup overlay; `repair`
is retained for the existing Cage Quick Repair fallback. The independent
`meoarch.session=plasma|cage` selector chooses the compositor. Missing session
selection defaults to Plasma. BIOS, UEFI and GRUB loopback menus expose both
Cage Install/Repair fallbacks; terminal-only remains a separate entry.

## Session and packages

`meoarch-os/` is the source profile. Its Live-only `/etc/plasmalogin.conf` uses
Meo Plasma Login's actual `[Autologin]` User/Session/Relogin keys (`live`,
`meoarch-live.desktop`, `true`). The `meo-plasma-login-manager` package (which provides and
replaces the upstream `plasma-login-manager`) supplies plasmalogin and the PAM autologin
stack, exactly as on an installed system. No SDDM configuration is guessed.
No password is unlocked in shadow, and production SSH stays disabled.

Only the selected compositor may start: plasmalogin rejects Cage/TTY kernel
modes, while `meoarch-installer.service` requires `meoarch.session=cage`.
The Live user home is writable by UID/GID 1000. Login and graphical startup
never depend on an Internet connection.

The Live desktop is the same Meo Desktop session as an installed system and runs
the same signed packages: `meoui-qml`, `meo-icons` and `meo-desktop` (listed in
`packages.x86_64`) provide MeoUI, MeoKDE, the full Meo.System module, the Look-and-Feel,
shell, applets, themes, window decoration/style, helper tools and the session defaults.
`scripts/sync-installer-to-airootfs.sh` stages none of these files, and
`scripts/verify-staging-provenance.sh` rejects them as undeclared, because the
overlay is extracted after pacstrap and would shadow the packages. The profile
carries no global `/etc/xdg` KDE/Meo defaults or `environment.d` overrides either:
`startmeo-wayland` seeds them into `~/.config/meo-desktop` from the package, and the
only Live-specific override is `~/.config/meo-desktop/kscreenlockerrc` (no auto-lock).
What the workspace still stages is ISO-owned: the Installer (with its smaller
SystemState adapter at `/opt/meoarch-installer/live-qml`), Quick Repair and its
`meo-polkit-agent` for the Cage session, the Live session wrapper/autostart, boot
status and Plymouth. Generic UI remains in MeoUI; Plasma/KWin remain the desktop
authorities. No `/opt/meo-desktop` payload is staged: the installed system gets its desktop from pacman only.

The Installer and Quick Repair are compiled from the sibling MeoUI checkout but load
`libmeoui` from the packaged `meoui-qml`. Set `MEOARCH_RELEASE_MANIFEST` to the
meo-repo release manifest the ISO is built against and the sync step fails unless the
checkout is exactly that manifest's pinned `meoui-qml` commit
(`scripts/check-meoui-pin.py`); without it a warning is printed.

## Application lifetime

`meoarch-live.desktop` runs the guarded user entrypoint after Plasma autostart.
It checks the compositor socket and KWin D-Bus readiness for at most
30 seconds, imports the actual session environment, and starts the independent
`meoarch-live-app.service`. The user service has no Requires/BindsTo relationship
that could make its failure stop Plasma. It never restarts after close/crash.
The service uses Type=exec, Restart=no and a bounded stop timeout. After close
it becomes inactive; manual Installer launch remains available from the application menu. `PartOf=graphical-session.target` only
allows session shutdown to stop the application, not the reverse.

Install mode opens the existing Installer with its explicit desktop fullscreen
property. AI mode opens `meo-ai --live-recovery` as Live user, with no elevated installer
capability. Its setup overlay handles language selection and NetworkManager
Wi-Fi setup. Chat can propose a plan but only Installer and Quick Repair own
writes and confirmations. If Meo AI is missing, Quick Repair opens instead.
Repair mode opens the existing unprivileged Quick Repair with
`--live`, without Cage, installation capabilities or a second Polkit agent.
Konsole and Repair remain desktop applications independent of Installer life.
The embedded unprivileged diagnostic console remains useful in Cage fallback.

## Recovery and session guard

Window close, Alt+F4 and page exit share the same running-installation guard.
Restart/shutdown are also blocked while running. This prevents ordinary UI exits
from destroying its QProcess; it does not make installation survive SIGKILL,
OOM, compositor loss or power failure. A separate root backend with narrow IPC
is required for that stronger guarantee.

A failed page can return to the Live desktop. Installation failure offers a
bounded, selectable plain-text log viewer, unprivileged Quick Repair, desktop
return and hold-to-confirm restart. Controller and backend use the same private
state directory. Another disk installation still requires a clean Live reboot.

The Live session wrapper starts `startmeo-wayland` and retries one short failure. Two exits within
60 seconds switch to a separate Breeze config profile with stock Plasma layout,
Breeze decoration/style, and disabled Meo window effects. Network, Konsole,
Quick Repair and Installer entries remain the existing applications. If stock
Plasma also fails quickly, the wrapper waits instead of returning to a relogin
loop. `meoarch.live-safe=1` explicitly selects this stock profile.

Ctrl+Alt+F2 always starts an unprivileged `live` diagnostic shell, including when
PAM/autologin or the greeter fails. Journal group membership gives read-only
logs; nmcli remains available. Neither account passwords nor general sudo are
unlocked. TTY1's existing explicit terminal-only mode is separate. A failed
wrapper/daemon can still reach a locked greeter; TTY2 is the independent escape.

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
SO_PEERCRED must identify the root-owned `/usr/bin/kwin_wayland` executable in
the Live user cgroup, and its PID must match the session bus `org.kde.KWin` owner.
This reduces endpoint substitution; the Live user still controls KWin and can
replace endpoints after a check. Root GUI/compositor trust remains security debt.
Only session ID and bounded socket basename are accepted. Extra app arguments,
QML/plugin roots, arbitrary shell commands and target paths are not accepted.
Python runs isolated (`-I`). The child receives a constructed environment and a
root-only runtime/state tree, not user HOME, Qt plugin paths or user D-Bus.
Its absolute Wayland socket points to the validated Live compositor.

A root-only lock limits the desktop to one Installer. The child inherits the flock FD, retaining exclusivity if the helper is killed.
After acquiring the lock, the helper reclaims only an empty, regular, single-link
root:root 0600 stale marker; unexpected objects fail closed. Normal exit removes
the capability marker. Policy defaults are all `no`: unmatched authorization
fails immediately instead of requesting a locked administrator password. Real installation still requires the Controller's ready
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
The desktop Installer still checks that its first Qt frame arrives, but skips the Cage logo splash and does
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
5. On separate disposable Live boots, run `62-check-live-recovery.sh --helper-kill`
   and `--session-loop` to exercise inherited locking/stale marker reclamation
   and bounded stock-session recovery with TTY2. These refuse a running backend.
   Observe Alt+F4 and page exit rejection during a disposable test installation;
   helper SIGKILL with a live child, stale-marker recovery after child death,
   two fast session crashes into stock safe mode, safe-mode failure into TTY2,
   broken autologin into TTY2, page-load escape and failed-install log/Repair/restart.
   Separately observe normal close, manual reopen, full-screen state, keyboard
   shortcuts, Repair interaction, offline startup and network reconnect.
6. Boot Cage Install, Cage Repair and terminal-only; verify no compositor races.
   Repeat BIOS/UEFI, GL/software rendering, and verify a temporary installed
   target has no Live autostart/authorization/autologin residue.

A launched QEMU process, screenshots alone, or passing source tests do not prove
this runtime matrix. Record unrun stages as NOT RUN, never PASS.
