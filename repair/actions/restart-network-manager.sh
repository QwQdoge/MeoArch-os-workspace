#!/usr/bin/env bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Root authorization is required." >&2; exit 77; }
if [ "${MEOARCH_REPAIR_SCOPE:-system}" = "live" ]; then
  echo "Restarting the live network would interrupt the repair session; action blocked." >&2
  exit 4
fi
exec /usr/bin/systemctl restart NetworkManager.service
