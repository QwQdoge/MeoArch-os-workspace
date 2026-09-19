#!/usr/bin/env bash
set -euo pipefail

scope="system"
target_root="/mnt"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scope)
      [ "$#" -ge 2 ] || { echo "Missing scope value." >&2; exit 2; }
      scope="$2"
      shift 2
      ;;
    --target-root)
      [ "$#" -ge 2 ] || { echo "Missing target root value." >&2; exit 2; }
      target_root="$2"
      shift 2
      ;;
    *)
      echo "Unsupported action argument." >&2
      exit 2
      ;;
  esac
done
case "${scope}" in live|system) ;; *) echo "Unsupported repair scope." >&2; exit 2 ;; esac
[ "${target_root}" = "/mnt" ] || { echo "Unexpected target root." >&2; exit 2; }

[ "$(id -u)" -eq 0 ] || { echo "Root authorization is required." >&2; exit 77; }
if [ "${scope}" = "live" ]; then
  echo "Reloading a non-running target systemd manager from Live is not supported." >&2
  exit 4
fi
/usr/bin/systemctl daemon-reload
/usr/bin/systemctl show --property=Version --value >/dev/null
echo "Post-check passed: the system service manager responded after daemon-reload."
