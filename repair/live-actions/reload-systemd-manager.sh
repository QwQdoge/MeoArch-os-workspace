#!/usr/bin/env bash
set -euo pipefail

[ "$#" -eq 0 ] || { echo "This fixed Live action accepts no arguments." >&2; exit 2; }
[ "$(id -u)" -eq 0 ] || { echo "Root authorization is required." >&2; exit 77; }
exec /usr/lib/meoarch-repair/actions/reload-systemd-manager.sh --scope live --target-root /mnt
