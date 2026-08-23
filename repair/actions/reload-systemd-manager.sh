#!/usr/bin/env bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Root authorization is required." >&2; exit 77; }
if [ "${MEOARCH_REPAIR_SCOPE:-system}" = "live" ]; then
  echo "Reloading a non-running target systemd manager from Live is not supported." >&2
  exit 4
fi
exec /usr/bin/systemctl daemon-reload
