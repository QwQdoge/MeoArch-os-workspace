#!/usr/bin/env bash
set -euo pipefail

# Run INSIDE a disposable acceptance VM, from its root diagnostic console.
# This is a guest runtime check, not a substitute for booting/capturing an ISO.
# --crash-installer intentionally kills only the Installer in that VM.
case "${1:-}" in
  --help|-h) echo 'Usage (inside Live VM): 61-check-live-desktop.sh [--crash-installer]'; exit 0 ;;
  ''|--crash-installer) ;;
  *) exit 2 ;;
esac
[ "$#" -le 1 ] && [ "$(id -u)" = 0 ] && [ -d /run/archiso ] || {
  echo 'Requires the root console inside the Live acceptance VM.' >&2; exit 126;
}
case " $(cat /proc/cmdline) " in *' meoarch.session=cage '*|*' meoarch.mode=tty '*) exit 126 ;; esac
live_uid="$(id -u live)"
session="$(loginctl show-user live --property=Display --value)"
[ -n "${session}" ]
[ "$(loginctl show-session "${session}" --property=User --value)" = "${live_uid}" ]
[ "$(loginctl show-session "${session}" --property=Type --value)" = wayland ]
[ "$(loginctl show-session "${session}" --property=Active --value)" = yes ]
systemctl is-active --quiet plasmalogin.service
systemctl is-active --quiet NetworkManager.service
! systemctl is-active --quiet meoarch-installer.service
shell_pid="$(pgrep -u live -x plasmashell)"
kwin_pid="$(pgrep -u live -x kwin_wayland)"
[ -n "${shell_pid}" ] && [ -n "${kwin_pid}" ]

user_env=(/usr/bin/runuser -u live -- /usr/bin/env -i HOME=/home/live USER=live LOGNAME=live
  PATH=/usr/bin:/usr/local/bin XDG_RUNTIME_DIR="/run/user/${live_uid}"
  DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${live_uid}/bus"
  XDG_SESSION_TYPE=wayland XDG_CURRENT_DESKTOP=KDE)
# Use the session manager's actual socket; never assume wayland-0 in runtime tests.
display="$("${user_env[@]}" systemctl --user show-environment | sed -n 's/^WAYLAND_DISPLAY=//p')"
[[ "${display}" =~ ^wayland-[0-9]+$ ]]
user_env+=(WAYLAND_DISPLAY="${display}")
"${user_env[@]}" busctl --user status org.kde.plasmashell >/dev/null
"${user_env[@]}" busctl --user status org.kde.KWin >/dev/null
"${user_env[@]}" systemctl --user show meoarch-live-app.service --property=ActiveState,SubState,Result
loginctl show-session "${session}" --property=User,Type,Active,Remote,Desktop
nmcli -t -f DEVICE,TYPE,STATE device status

if [ "${1:-}" = --crash-installer ]; then
  # Verify the executable path and root ownership, rather than pkill matching
  # an arbitrary command line. Limit the action to the bundled native host.
  mapfile -t installer_pids < <(pgrep -u root -f '^/opt/meoarch-installer/bin/meoarch-installer-app( |$)')
  [ "${#installer_pids[@]}" = 1 ] || { echo 'Expected exactly one root Installer.' >&2; exit 1; }
  [ "$(readlink "/proc/${installer_pids[0]}/exe")" = /opt/meoarch-installer/bin/meoarch-installer-app ]
  kill -KILL "${installer_pids[0]}"
  sleep 3
  ! pgrep -u root -f '^/opt/meoarch-installer/bin/meoarch-installer-app( |$)' >/dev/null
  [ "$(pgrep -u live -x plasmashell)" = "${shell_pid}" ]
  [ "$(pgrep -u live -x kwin_wayland)" = "${kwin_pid}" ]
  systemctl is-active --quiet NetworkManager.service
  [ ! -e /run/meoarch-installer/production-capability ]
fi

# Start the real existing desktop applications after the exit/crash checkpoint.
# Keep the windows open for QMP screenshots and manual interaction checks.
"${user_env[@]}" /usr/bin/konsole --separate --hold -e /usr/bin/nmcli device status >/dev/null 2>&1 &
"${user_env[@]}" /usr/bin/meoarch-repair --live >/dev/null 2>&1 &
sleep 3
pgrep -u live -x konsole >/dev/null
pgrep -u live -f '^/usr/bin/meoarch-repair( |$)' >/dev/null
"${user_env[@]}" busctl --user status org.kde.KWin >/dev/null
printf '%s\n' 'PASS: Live Plasma session and desktop recovery processes remain available.'
printf '%s\n' 'Still required: screenshots, fullscreen/normal-close/reopen, offline boot, network reconnect and Cage/TTY boots.'
