#!/usr/bin/env bash
set -euo pipefail
# Explicit fault injection in a disposable LIVE VM only. Never use a real
# installation in progress for these launcher/session crash tests.
case "${1:-}" in
  --help|-h) echo 'Usage (root inside disposable Live VM): 62-check-live-recovery.sh --helper-kill|--session-loop'; exit 0 ;;
  --helper-kill|--session-loop) ;;
  *) exit 2 ;;
esac
[ "$#" = 1 ] && [ "$(id -u)" = 0 ] && [ -d /run/archiso ] || exit 126
if pgrep -f '[/]backend/run-archinstall.sh|[/]usr/bin/archinstall' >/dev/null; then
  echo 'Refusing fault injection while the installation backend is running.' >&2
  exit 126
fi
uid="$(id -u live)"
live=(runuser -u live -- env -i HOME=/home/live USER=live LOGNAME=live PATH=/usr/bin:/usr/local/bin
  XDG_RUNTIME_DIR="/run/user/${uid}" DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/${uid}/bus"
  XDG_SESSION_TYPE=wayland XDG_CURRENT_DESKTOP=KDE)
display="$("${live[@]}" systemctl --user show-environment | sed -n 's/^WAYLAND_DISPLAY=//p')"
[[ "$display" =~ ^wayland-[0-9]+$ ]]
live+=(WAYLAND_DISPLAY="$display")
systemctl is-active --quiet getty@tty2.service
if [ "$1" = --helper-kill ]; then
  mapfile -t helper < <(pgrep -u root -f '[/]usr/lib/meoarch/live-installer-authorize( |$)')
  mapfile -t app < <(pgrep -u root -f '^/opt/meoarch-installer/bin/meoarch-installer-app( |$)')
  [ "${#helper[@]}" = 1 ] && [ "${#app[@]}" = 1 ]
  [ "$(readlink "/proc/${app[0]}/exe")" = /opt/meoarch-installer/bin/meoarch-installer-app ]
  kill -KILL "${helper[0]}"
  sleep 2
  if kill -0 "${app[0]}" 2>/dev/null; then
    # If a child survives its helper, the inherited lock must remain exclusive.
    python - <<'PY'
import fcntl
with open('/run/meoarch-installer/desktop.lock', 'r') as lock:
    try:
        fcntl.flock(lock, fcntl.LOCK_EX | fcntl.LOCK_NB)
    except BlockingIOError:
        pass
    else:
        raise SystemExit('FAIL: live Installer lost its launcher lock')
PY
    kill -KILL "${app[0]}"
    sleep 1
  fi
  # The helper was killed before finally; reopen must reclaim the stale marker.
  [ -f /run/meoarch-installer/production-capability ]
  "${live[@]}" systemctl --user start --no-block meoarch-live-app.service
  ready=0
  for ((attempt=0; attempt<40; attempt++)); do
    if pgrep -u root -f '^/opt/meoarch-installer/bin/meoarch-installer-app( |$)' >/dev/null; then ready=1; break; fi
    sleep 0.5
  done
  [ "$ready" = 1 ]
  echo 'PASS: surviving child retains lock; stale marker permits reopening.'
else
  # Stopping the workspace simulates a session exit without killing the guard.
  # First exit can follow a long stable run; the following two are short.
  safe=0
  for ((failure=0; failure<3; failure++)); do
    "${live[@]}" systemctl --user stop plasma-workspace.target
    ready=0
    for ((attempt=0; attempt<40; attempt++)); do
      if "${live[@]}" busctl --user status org.kde.KWin >/dev/null 2>&1; then ready=1; break; fi
      sleep 0.5
    done
    [ "$ready" = 1 ]
    if "${live[@]}" systemctl --user show-environment | grep -q '^MEOARCH_LIVE_SAFE=1$'; then safe=1; break; fi
  done
  [ "$safe" = 1 ]
  "${live[@]}" systemctl --user show-environment | grep -q '/safe-config$'
  "${live[@]}" systemctl --user stop plasma-workspace.target
  sleep 3
  ! "${live[@]}" busctl --user status org.kde.KWin >/dev/null 2>&1
  pgrep -u live -f '[/]usr/lib/meoarch/live-session' >/dev/null
  systemctl is-active --quiet getty@tty2.service
  systemctl is-active --quiet NetworkManager.service
  echo 'PASS: repeated session exits choose stock Plasma; failed safe mode stops the loop with TTY2 available.'
fi
