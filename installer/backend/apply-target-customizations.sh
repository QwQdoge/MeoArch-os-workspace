#!/usr/bin/env bash
set -euo pipefail

target_root="${1:-${MEOARCH_TARGET_ROOT:-/mnt}}"
desktop_source="${2:-/opt/meo-desktop}"
generated_dir="${3:-${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}/generated}"
runtime_source="${MEOARCH_RUNTIME_SOURCE:-/usr}"

if [ "${target_root}" = "/" ] || [ -z "${target_root}" ]; then
  echo "Refusing unsafe target root: ${target_root}" >&2
  exit 2
fi
if [ ! -d "${target_root}/etc" ] || [ ! -d "${target_root}/usr" ]; then
  echo "Installed target is not mounted at ${target_root}." >&2
  exit 3
fi
if [ ! -f "${desktop_source}/themes/look-and-feel/org.meo.desktop/metadata.json" ]; then
  echo "Meo Desktop payload is missing from ${desktop_source}." >&2
  exit 4
fi
if [ ! -e "${runtime_source}/lib/libmeoui.so.0" ] \
  || [ ! -f "${runtime_source}/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so" ]; then
  echo "MeoUI shared runtime is missing from ${runtime_source}." >&2
  exit 5
fi

install -d \
  "${target_root}/usr/lib" \
  "${target_root}/usr/lib/qt6/qml/MeoUI" \
  "${target_root}/usr/share/icons/hicolor/scalable/apps" \
  "${target_root}/usr/share/plasma/look-and-feel" \
  "${target_root}/usr/share/plasma/plasmoids" \
  "${target_root}/usr/share/pixmaps" \
  "${target_root}/usr/share/sddm/themes/breeze" \
  "${target_root}/usr/share/wallpapers/MeoArch" \
  "${target_root}/etc/sddm.conf.d" \
  "${target_root}/etc/xdg" \
  "${target_root}/var/lib/omnistore"

cp -a "${runtime_source}/lib/libmeoui.so"* "${target_root}/usr/lib/"
rm -rf "${target_root}/usr/lib/qt6/qml/MeoUI"
cp -a "${runtime_source}/lib/qt6/qml/MeoUI" \
  "${target_root}/usr/lib/qt6/qml/MeoUI"

rm -rf "${target_root}/usr/share/plasma/look-and-feel/org.meo.desktop"
cp -a "${desktop_source}/themes/look-and-feel/org.meo.desktop" \
  "${target_root}/usr/share/plasma/look-and-feel/org.meo.desktop"

if [ -d "${desktop_source}/plasmoids" ]; then
  for plasmoid in org.meo.shelf org.meo.topbar org.meo.launcher org.meo.quicksettings; do
    if [ -d "${desktop_source}/plasmoids/${plasmoid}" ]; then
      rm -rf "${target_root}/usr/share/plasma/plasmoids/${plasmoid}"
      cp -a "${desktop_source}/plasmoids/${plasmoid}" "${target_root}/usr/share/plasma/plasmoids/${plasmoid}"
    fi
  done
fi
install -Dm644 "${desktop_source}/wallpaper/installer_background.png" \
  "${target_root}/usr/share/wallpapers/MeoArch/installer_background.png"
install -Dm644 "${desktop_source}/branding/Logo.svg" \
  "${target_root}/usr/share/pixmaps/meoarch-logo.svg"
install -Dm644 "${desktop_source}/branding/Logo.svg" \
  "${target_root}/usr/share/icons/hicolor/scalable/apps/meoarch-logo.svg"
install -Dm644 "${desktop_source}/defaults/sddm/meoarch.conf" \
  "${target_root}/etc/sddm.conf.d/20-meoarch.conf"
install -Dm644 "${desktop_source}/defaults/sddm/theme.conf.user" \
  "${target_root}/usr/share/sddm/themes/breeze/theme.conf.user"
rm -f "${target_root}/etc/os-release"
install -Dm644 "${desktop_source}/defaults/system/os-release" \
  "${target_root}/etc/os-release"
install -Dm644 "${desktop_source}/defaults/kde/kdeglobals" \
  "${target_root}/etc/xdg/kdeglobals"
install -Dm644 "${desktop_source}/defaults/kwin/kwinrc" \
  "${target_root}/etc/xdg/kwinrc"
install -Dm644 "${desktop_source}/defaults/plasma/plasmarc" \
  "${target_root}/etc/xdg/plasmarc"
install -Dm644 "${desktop_source}/defaults/plasma/plasma-welcomerc" \
  "${target_root}/etc/xdg/plasma-welcomerc"

if [ -f "${generated_dir}/plasma-localerc" ]; then
  install -Dm644 "${generated_dir}/plasma-localerc" \
    "${target_root}/etc/xdg/plasma-localerc"
fi
if [ -f "${generated_dir}/omnistore-provisioning.json" ]; then
  install -Dm644 "${generated_dir}/omnistore-provisioning.json" \
    "${target_root}/var/lib/omnistore/provisioning.json"
fi
ldconfig -r "${target_root}"

echo "MeoUI runtime, Meo Desktop defaults, and OmniStore provisioning intent installed into ${target_root}."
