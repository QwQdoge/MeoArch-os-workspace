#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
desktop_root="${repo_root}"
config_root="${XDG_CONFIG_HOME:-${HOME}/.config}"
data_root="${XDG_DATA_HOME:-${HOME}/.local/share}"
qml_root="${MEO_KDE_QML_ROOT:-${HOME}/.local/lib/qt6/qml}"
native_build_root="${repo_root}/out/build/system"
state_root="${XDG_STATE_HOME:-${HOME}/.local/state}/meo-desktop"
timestamp="$(date -u +%Y%m%dT%H%M%SZ)"
backup_root="${state_root}/backups/${timestamp}"
dry_run=0
reset_layout=0

while [ "$#" -gt 0 ]; do
  case "$1" in
    --dry-run) dry_run=1 ;;
    --reset-layout) reset_layout=1 ;;
    *) echo "Usage: $0 [--dry-run] [--reset-layout]" >&2; exit 2 ;;
  esac
  shift
done

run() {
  printf '%q ' "$@"
  printf '\n'
  if [ "${dry_run}" -eq 0 ]; then
    "$@"
  fi
}

for required in \
  "${desktop_root}/themes/look-and-feel/org.meo.desktop/metadata.json" \
  "${repo_root}/qml/MeoKDE/qmldir" \
  "${repo_root}/assets/wallpapers/installer_background.png"; do
  if [ ! -f "${required}" ]; then
    echo "Required Meo Desktop asset is missing: ${required}" >&2
    exit 1
  fi
done

run mkdir -p "${backup_root}" "${data_root}/plasma/look-and-feel" "${data_root}/plasma/desktoptheme" "${data_root}/plasma/plasmoids" "${data_root}/icons" "${data_root}/wallpapers/MeoArch" "${data_root}/fonts/meo" "${qml_root}/MeoKDE" "${config_root}/fontconfig/conf.d"

for config in kdeglobals kwinrc plasmarc plasma-org.kde.plasma.desktop-appletsrc; do
  if [ -e "${config_root}/${config}" ]; then
    run cp -a "${config_root}/${config}" "${backup_root}/${config}"
  fi
done

# Install Look-and-Feel package
run rm -rf "${data_root}/plasma/look-and-feel/org.meo.desktop"
run cp -a "${desktop_root}/themes/look-and-feel/org.meo.desktop" "${data_root}/plasma/look-and-feel/org.meo.desktop"
run rm -rf "${data_root}/plasma/desktoptheme/Meo"
run cp -a "${desktop_root}/themes/desktoptheme/Meo" "${data_root}/plasma/desktoptheme/Meo"
run rm -rf "${data_root}/icons/Meo"
run cp -a "${desktop_root}/icons/Meo" "${data_root}/icons/Meo"

# Install Meo Plasmoids (Shelf, TopBar, Launcher, QuickSettings)
for legacy_plasmoid in org.meo.launcher org.meo.quicksettings; do
  run rm -rf "${data_root}/plasma/plasmoids/${legacy_plasmoid}"
done
for plasmoid in org.meo.shelf org.meo.topbar; do
  if [ -d "${desktop_root}/plasmoids/${plasmoid}" ]; then
    run rm -rf "${data_root}/plasma/plasmoids/${plasmoid}"
    run cp -a "${desktop_root}/plasmoids/${plasmoid}" "${data_root}/plasma/plasmoids/${plasmoid}"
  fi
done

run cp -a "${repo_root}/qml/MeoKDE/." "${qml_root}/MeoKDE/"
run cmake -S "${repo_root}/native/system" -B "${native_build_root}" -DCMAKE_BUILD_TYPE=RelWithDebInfo
run cmake --build "${native_build_root}" --parallel
run mkdir -p "${qml_root}/Meo/System"
run cp -a "${native_build_root}/qml/Meo/System/." "${qml_root}/Meo/System/"
run cp -a "${repo_root}/assets/fonts/." "${data_root}/fonts/meo/"
run cp -a "${repo_root}/defaults/fonts/50-meo-fonts.conf" "${config_root}/fontconfig/conf.d/50-meo-fonts.conf"

run cp -a "${repo_root}/assets/wallpapers/installer_background.png" "${data_root}/wallpapers/MeoArch/installer_background.png"
if command -v fc-cache >/dev/null 2>&1; then
  run fc-cache -f "${data_root}/fonts/meo"
fi

if [ "${dry_run}" -eq 0 ]; then
  printf '%s\n' "${backup_root}" > "${state_root}/last-backup"
fi

if command -v plasma-apply-lookandfeel >/dev/null 2>&1; then
  if [ "${reset_layout}" -eq 1 ]; then
    run plasma-apply-lookandfeel -a org.meo.desktop --resetLayout
  else
    run plasma-apply-lookandfeel -a org.meo.desktop
  fi
elif command -v lookandfeeltool >/dev/null 2>&1; then
  run lookandfeeltool -a org.meo.desktop
else
  echo "Plasma look-and-feel tool is unavailable; files were staged for the next Plasma login." >&2
fi
