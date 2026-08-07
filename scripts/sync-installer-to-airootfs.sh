#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
projects_root="$(cd "${repo_root}/.." && pwd)"
meo_kde_src="${projects_root}/meo-kde"
airootfs="${MEOARCH_AIROOTFS:-${repo_root}/meoarch-os/airootfs}"
installer_src="${repo_root}/installer"
installer_dst="${airootfs}/opt/meoarch-installer"
desktop_dst="${airootfs}/opt/meo-desktop"
desktop_live_theme="${airootfs}/usr/share/plasma/look-and-feel/org.meo.desktop"
desktop_live_wallpaper="${airootfs}/usr/share/wallpapers/MeoArch"
runtime_root="${repo_root}/build/installer-runtime-root/usr"
meoui_qml_dst="${airootfs}/usr/lib/qt6/qml/MeoUI"
meokde_qml_dst="${airootfs}/usr/lib/qt6/qml/MeoKDE"
meosystem_qml_dst="${airootfs}/usr/lib/qt6/qml/Meo/System"
meokde_fonts_dst="${airootfs}/usr/share/fonts/meo"
meosystem_build="${repo_root}/build/meo-system"
legacy_meoui_dst="${airootfs}/opt/meo-ui"

if [ ! -f "${runtime_root}/lib/libmeoui.so.0" ] \
  || [ ! -f "${runtime_root}/lib/qt6/qml/MeoUI/qmldir" ]; then
  echo "The compiled MeoUI runtime is missing. Run scripts/build-installer-app.sh first." >&2
  exit 1
fi

cmake -S "${meo_kde_src}/native/system" -B "${meosystem_build}" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build "${meosystem_build}" --parallel

rm -rf "${legacy_meoui_dst}" "${meoui_qml_dst}" "${meokde_qml_dst}" "${meosystem_qml_dst}" "${meokde_fonts_dst}"
install -d "${meoui_qml_dst}" "${meokde_qml_dst}" "${meosystem_qml_dst}" "${meokde_fonts_dst}" "${airootfs}/usr/lib"
cp -a "${runtime_root}/lib/libmeoui.so"* "${airootfs}/usr/lib/"
cp -a "${runtime_root}/lib/qt6/qml/MeoUI/." "${meoui_qml_dst}/"
cp -a "${meo_kde_src}/qml/MeoKDE/." "${meokde_qml_dst}/"
cp -a "${meosystem_build}/qml/Meo/System/." "${meosystem_qml_dst}/"
cp -a "${meo_kde_src}/assets/fonts/"*.ttf "${meokde_fonts_dst}/"
install -Dm644 "${meo_kde_src}/defaults/fonts/50-meo-fonts.conf" \
  "${airootfs}/etc/fonts/conf.avail/50-meo-fonts.conf"
install -d "${airootfs}/etc/fonts/conf.d"
ln -sfn ../conf.avail/50-meo-fonts.conf \
  "${airootfs}/etc/fonts/conf.d/50-meo-fonts.conf"

rm -rf "${installer_dst}"
install -d "${installer_dst}"
cp -a "${installer_src}/qml" "${installer_dst}/qml"
cp -a "${installer_src}/backend" "${installer_dst}/backend"
cp -a "${installer_src}/data" "${installer_dst}/data"
cp -a "${installer_src}/app" "${installer_dst}/app"
install -Dm644 "${installer_src}/CMakeLists.txt" "${installer_dst}/CMakeLists.txt"
cp -a "${repo_root}/assets" "${installer_dst}/assets"
find "${installer_dst}/backend" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod 755 {} +
find "${installer_dst}/data" -type f -exec chmod 644 {} +

rm -rf "${desktop_dst}"
install -d \
  "${desktop_dst}/themes/look-and-feel" \
  "${desktop_dst}/themes/desktoptheme" \
  "${desktop_dst}/icons" \
  "${desktop_dst}/plasmoids" \
  "${desktop_dst}/branding" \
  "${desktop_dst}/defaults" \
  "${desktop_dst}/wallpaper"
cp -a "${meo_kde_src}/themes/look-and-feel/org.meo.desktop" \
  "${desktop_dst}/themes/look-and-feel/org.meo.desktop"
cp -a "${meo_kde_src}/themes/desktoptheme/MeoLight" \
  "${desktop_dst}/themes/desktoptheme/MeoLight"
cp -a "${meo_kde_src}/icons/Meo" "${desktop_dst}/icons/Meo" 2>/dev/null || true
if [ -d "${meo_kde_src}/plasmoids" ]; then
  cp -a "${meo_kde_src}/plasmoids/." "${desktop_dst}/plasmoids/"
fi
cp -a "${meo_kde_src}/defaults/." "${desktop_dst}/defaults/"
install -Dm644 "${repo_root}/assets/icons/Logo.svg" \
  "${desktop_dst}/branding/Logo.svg"
install -Dm644 "${repo_root}/assets/wallpapers/installer_background.png" \
  "${desktop_dst}/wallpaper/installer_background.png"

rm -rf "${desktop_live_theme}"
install -d \
  "${airootfs}/usr/share/plasma/look-and-feel" \
  "${airootfs}/usr/share/plasma/desktoptheme" \
  "${airootfs}/usr/share/plasma/plasmoids" \
  "${airootfs}/usr/share/icons" \
  "${airootfs}/usr/share/icons/hicolor/scalable/apps" \
  "${airootfs}/usr/share/pixmaps" \
  "${airootfs}/usr/share/sddm/themes/breeze" \
  "${desktop_live_wallpaper}" \
  "${airootfs}/etc/sddm.conf.d" \
  "${airootfs}/etc/xdg"
cp -a "${meo_kde_src}/themes/look-and-feel/org.meo.desktop" \
  "${desktop_live_theme}"
if [ -d "${meo_kde_src}/themes/desktoptheme" ]; then
  cp -a "${meo_kde_src}/themes/desktoptheme/." "${airootfs}/usr/share/plasma/desktoptheme/"
fi
if [ -d "${meo_kde_src}/plasmoids" ]; then
  for plasmoid in org.meo.shelf org.meo.topbar; do
    if [ -d "${meo_kde_src}/plasmoids/${plasmoid}" ]; then
      rm -rf "${airootfs}/usr/share/plasma/plasmoids/${plasmoid}"
      cp -a "${meo_kde_src}/plasmoids/${plasmoid}" "${airootfs}/usr/share/plasma/plasmoids/${plasmoid}"
    fi
  done
fi
install -Dm644 "${repo_root}/assets/wallpapers/installer_background.png" \
  "${desktop_live_wallpaper}/installer_background.png"
install -Dm644 "${repo_root}/assets/icons/Logo.svg" \
  "${airootfs}/usr/share/pixmaps/meoarch-logo.svg"
install -Dm644 "${repo_root}/assets/icons/Logo.svg" \
  "${airootfs}/usr/share/icons/hicolor/scalable/apps/meoarch-logo.svg"
install -Dm644 "${meo_kde_src}/defaults/sddm/theme.conf.user" \
  "${airootfs}/usr/share/sddm/themes/breeze/theme.conf.user"
install -Dm644 "${meo_kde_src}/defaults/system/os-release" \
  "${airootfs}/etc/os-release"
install -Dm644 "${meo_kde_src}/defaults/kde/kdeglobals" \
  "${airootfs}/etc/xdg/kdeglobals"
install -Dm644 "${meo_kde_src}/defaults/kwin/kwinrc" \
  "${airootfs}/etc/xdg/kwinrc"
install -Dm644 "${meo_kde_src}/defaults/plasma/plasmarc" \
  "${airootfs}/etc/xdg/plasmarc"
install -Dm644 "${meo_kde_src}/defaults/plasma/plasma-welcomerc" \
  "${airootfs}/etc/xdg/plasma-welcomerc"

native_binary="${MEOARCH_INSTALLER_NATIVE_BINARY:-${repo_root}/build/installer-host/meoarch-installer-app}"
if [ -x "${native_binary}" ]; then
  install -Dm755 "${native_binary}" "${installer_dst}/bin/meoarch-installer-app"
else
  echo "Compiled installer host not found; ISO will use qml6 from qt6-declarative." >&2
fi

install -Dm755 "${installer_src}/bin/meoarch-installer" \
  "${airootfs}/usr/local/bin/meoarch-installer"
install -Dm755 "${installer_src}/bin/meoarch-installer-kiosk" \
  "${airootfs}/usr/local/bin/meoarch-installer-kiosk"
