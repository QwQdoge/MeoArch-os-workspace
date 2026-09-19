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
  echo "Restarting the live network would interrupt the repair session; action blocked." >&2
  exit 4
fi
/usr/bin/systemctl restart NetworkManager.service
/usr/bin/systemctl is-active --quiet NetworkManager.service
/usr/bin/ip route show | /usr/bin/grep -q '^default '
[ -r /etc/resolv.conf ] && /usr/bin/grep -Eq '^[[:space:]]*nameserver[[:space:]]+' /etc/resolv.conf
echo "Post-check passed: NetworkManager is active and IPv4 route and DNS checks pass after restart."
