#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
desktop_root="${repo_root}/meo-desktop"
config_root="${XDG_CONFIG_HOME:-${HOME}/.config}"
data_root="${XDG_DATA_HOME:-${HOME}/.local/share}"
state_root="${XDG_STATE_HOME:-${HOME}/.local/state}/meo-desktop"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_root="${state_root}/backups/${timestamp}"
dry_run=0

if [ "${1:-}" = "--dry-run" ]; then
  dry_run=1
elif [ "$#" -gt 0 ]; then
  echo "Usage: $0 [--dry-run]" >&2
  exit 2
fi

run() {
  printf '%q ' "$@"
  printf '\n'
  if [ "${dry_run}" -eq 0 ]; then
    "$@"
  fi
}

for required in \
  "${desktop_root}/themes/look-and-feel/org.meo.desktop/metadata.json" \
  "${repo_root}/assets/wallpapers/installer_background.png"; do
  if [ ! -f "${required}" ]; then
    echo "Required Meo Desktop asset is missing: ${required}" >&2
    exit 1
  fi
done

run mkdir -p "${backup_root}" "${data_root}/plasma/look-and-feel" "${data_root}/wallpapers/MeoArch" "${config_root}"

for config in kdeglobals kwinrc plasmarc; do
  if [ -e "${config_root}/${config}" ]; then
    run cp -a "${config_root}/${config}" "${backup_root}/${config}"
  fi
done

run rm -rf "${data_root}/plasma/look-and-feel/org.meo.desktop"
run cp -a "${desktop_root}/themes/look-and-feel/org.meo.desktop" "${data_root}/plasma/look-and-feel/org.meo.desktop"
run cp -a "${repo_root}/assets/wallpapers/installer_background.png" "${data_root}/wallpapers/MeoArch/installer_background.png"
run cp -a "${desktop_root}/defaults/kde/kdeglobals" "${config_root}/kdeglobals"
run cp -a "${desktop_root}/defaults/kwin/kwinrc" "${config_root}/kwinrc"
run cp -a "${desktop_root}/defaults/plasma/plasmarc" "${config_root}/plasmarc"

if [ "${dry_run}" -eq 0 ]; then
  printf '%s\n' "${backup_root}" > "${state_root}/last-backup"
fi

if command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
  run plasma-apply-lookandfeel -a org.meo.desktop
elif command -v lookandfeeltool >/dev/null 2>&1; then
  run lookandfeeltool -a org.meo.desktop
else
  echo "Plasma look-and-feel tool is unavailable; files were staged for the next Plasma login." >&2
fi
