#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
projects_root="$(cd "${repo_root}/.." && pwd)"
meo_kde_src="${projects_root}/meo-kde"
airootfs="${MEOARCH_AIROOTFS:-${repo_root}/meoarch-os/airootfs}"
installer_src="${repo_root}/installer"
airootfs="$(realpath -m -- "${airootfs}")"
case "${airootfs}" in
  "${repo_root}"/*) ;;
  *) echo "Refusing ISO staging outside the workspace: ${airootfs}" >&2; exit 2 ;;
esac
if [ ! -d "${airootfs}" ] || [ -L "${airootfs}" ]; then
  echo "ISO airootfs must be an existing real directory: ${airootfs}" >&2
  exit 2
fi
legacy_live_tools="${airootfs}/usr/local/bin"
installer_dst="${airootfs}/opt/meoarch-installer"
repair_dst="${airootfs}/usr/lib/meoarch-repair"
desktop_dst="${airootfs}/opt/meo-desktop"
desktop_live_theme="${airootfs}/usr/share/plasma/look-and-feel/org.meo.desktop"
desktop_light_theme="${airootfs}/usr/share/plasma/desktoptheme/MeoLight"
desktop_dark_theme="${airootfs}/usr/share/plasma/desktoptheme/MeoDark"
desktop_live_wallpaper="${airootfs}/usr/share/wallpapers/MeoArch"
runtime_root="${repo_root}/build/installer-runtime-root/usr"
meoui_qml_dst="${airootfs}/usr/lib/qt6/qml/MeoUI"
meokde_qml_dst="${airootfs}/usr/lib/qt6/qml/MeoKDE"
meosystem_qml_dst="${airootfs}/usr/lib/qt6/qml/Meo/System"
meokde_fonts_dst="${airootfs}/usr/share/fonts/meo"
meosystem_build="${repo_root}/build/meo-system"
meokde_native_build="${repo_root}/build/meo-kde-native"
legacy_meoui_dst="${airootfs}/opt/meo-ui"

for destructive_target in \
  "${legacy_meoui_dst}" "${meoui_qml_dst}" "${meokde_qml_dst}" \
  "${meosystem_qml_dst}" "${meokde_fonts_dst}" "${installer_dst}" \
  "${repair_dst}" \
  "${desktop_dst}" "${desktop_live_theme}" "${desktop_light_theme}" \
  "${desktop_dark_theme}"; do
  if [ -L "${destructive_target}" ]; then
    echo "Refusing recursive replacement of symlink: ${destructive_target}" >&2
    exit 2
  fi
done

"${repo_root}/scripts/build-installer-app.sh"
if [ ! -f "${runtime_root}/lib/libmeoui.so.0" ] \
  || [ ! -x "${runtime_root}/bin/meoarch-repair" ] \
  || [ ! -f "${runtime_root}/lib/meoarch-repair/qml/Main.qml" ] \
  || [ ! -f "${runtime_root}/lib/qt6/qml/MeoUI/qmldir" ]; then
  echo "The compiled MeoUI runtime is missing. Run scripts/build-installer-app.sh first." >&2
  exit 1
fi

# The ISO must never consume an unvalidated sibling checkout. This gate uses
# the freshly built MeoUI runtime above and records evidence in MeoKDE's own
# global output subtree, preserving project ownership.
MEO_KDE_VALIDATION_RUN_ID="${MEOARCH_VALIDATION_RUN_ID:-$(date -u +%Y-%m-%dT%H%M%SZ)-iso-sync}" \
MEOUI_IMPORT_ROOT="${runtime_root}/lib/qt6/qml" \
MEOUI_SOURCE_DIR="${projects_root}/meo-ui" \
  "${meo_kde_src}/scripts/validate.sh"

cmake --fresh -S "${meo_kde_src}/native/system" -B "${meosystem_build}" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build "${meosystem_build}" --parallel
cmake --fresh -S "${meo_kde_src}/native" -B "${meokde_native_build}" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo -DMEOUI_SOURCE_DIR="${projects_root}/meo-ui"
cmake --build "${meokde_native_build}" --parallel

rm -rf "${legacy_meoui_dst}" "${meoui_qml_dst}" "${meokde_qml_dst}" "${meosystem_qml_dst}" "${meokde_fonts_dst}"
install -d "${meoui_qml_dst}" "${meokde_qml_dst}" "${meosystem_qml_dst}" "${meokde_fonts_dst}" \
  "${airootfs}/usr/lib" "${airootfs}/usr/bin" \
  "${airootfs}/usr/share/meo-desktop/defaults" \
  "${airootfs}/usr/share/meo-desktop/input-method/ibus" \
  "${airootfs}/usr/share/fcitx5/themes" \
  "${airootfs}/usr/lib/systemd/user/default.target.wants" \
  "${airootfs}/etc/environment.d" "${airootfs}/etc/xdg/fcitx5/conf"
cp -a "${runtime_root}/lib/libmeoui.so"* "${airootfs}/usr/lib/"
cp -a "${runtime_root}/lib/qt6/qml/MeoUI/." "${meoui_qml_dst}/"
cp -a "${meo_kde_src}/qml/MeoKDE/." "${meokde_qml_dst}/"
cp -a "${meosystem_build}/qml/Meo/System/." "${meosystem_qml_dst}/"
cp -a "${meo_kde_src}/assets/fonts/"*.ttf "${meokde_fonts_dst}/"

rm -rf "${repair_dst}"
cp -a "${runtime_root}/lib/meoarch-repair" "${repair_dst}"
install -Dm755 "${runtime_root}/bin/meoarch-repair" \
  "${airootfs}/usr/bin/meoarch-repair"
install -Dm644 "${runtime_root}/share/applications/org.meo.repair.desktop" \
  "${airootfs}/usr/share/applications/org.meo.repair.desktop"
install -Dm644 "${runtime_root}/share/icons/hicolor/scalable/apps/meoarch-ai.svg" \
  "${airootfs}/usr/share/icons/hicolor/scalable/apps/meoarch-ai.svg"
install -Dm644 "${meo_kde_src}/defaults/fonts/50-meo-fonts.conf" \
  "${airootfs}/etc/fonts/conf.avail/50-meo-fonts.conf"
install -d "${airootfs}/etc/fonts/conf.d"
ln -sfn ../conf.avail/50-meo-fonts.conf \
  "${airootfs}/etc/fonts/conf.d/50-meo-fonts.conf"
install -Dm755 "${meokde_native_build}/dynamic-color/meo-dynamic-colors" \
  "${airootfs}/usr/bin/meo-dynamic-colors"
install -Dm755 "${meo_kde_src}/tools/input-method/meo-input-method.sh" \
  "${airootfs}/usr/bin/meo-input-method"
install -Dm755 "${meo_kde_src}/tools/theme/apply-meo-mode.sh" \
  "${airootfs}/usr/bin/meo-theme-mode"
install -Dm755 "${meo_kde_src}/tools/theme/apply-meo-desktop.sh" \
  "${airootfs}/usr/bin/meo-desktop-apply"
install -Dm755 "${meo_kde_src}/tools/shell/apply-meo-panel-layout.sh" \
  "${airootfs}/usr/bin/meo-desktop-layout"
install -Dm644 "${meo_kde_src}/defaults/kwin/kwinrc" \
  "${airootfs}/usr/share/meo-desktop/defaults/kwinrc"
install -Dm644 "${meo_kde_src}/defaults/environment/90-meo-applications.conf" \
  "${airootfs}/etc/environment.d/90-meo-applications.conf"
install -Dm644 "${meo_kde_src}/defaults/input-method/fcitx5/conf/classicui.conf" \
  "${airootfs}/etc/xdg/fcitx5/conf/classicui.conf"
rm -rf "${airootfs}/usr/share/fcitx5/themes/MeoInputMethod-Light" \
  "${airootfs}/usr/share/fcitx5/themes/MeoInputMethod-Dark"
cp -a "${meo_kde_src}/themes/input-method/fcitx5/MeoInputMethod-Light" \
  "${meo_kde_src}/themes/input-method/fcitx5/MeoInputMethod-Dark" \
  "${airootfs}/usr/share/fcitx5/themes/"
install -Dm644 "${meo_kde_src}/themes/input-method/ibus/gtk.css.in" \
  "${airootfs}/usr/share/meo-desktop/input-method/ibus/gtk.css.in"
install -Dm644 "${meo_kde_src}/themes/input-method/ibus/index.theme" \
  "${airootfs}/usr/share/meo-desktop/input-method/ibus/index.theme"
install -Dm644 "${meo_kde_src}/defaults/systemd/meo-dynamic-colors.path" \
  "${airootfs}/usr/lib/systemd/user/meo-dynamic-colors.path"
install -Dm644 "${meo_kde_src}/defaults/systemd/meo-dynamic-colors.service" \
  "${airootfs}/usr/lib/systemd/user/meo-dynamic-colors.service"
sed -i 's|%h/.local/bin/|/usr/bin/|g' \
  "${airootfs}/usr/lib/systemd/user/meo-dynamic-colors.service"
ln -sfn ../meo-dynamic-colors.path \
  "${airootfs}/usr/lib/systemd/user/default.target.wants/meo-dynamic-colors.path"

rm -rf "${installer_dst}"
install -d "${installer_dst}"
cp -a "${installer_src}/qml" "${installer_dst}/qml"
cp -a "${installer_src}/backend" "${installer_dst}/backend"
cp -a "${installer_src}/data" "${installer_dst}/data"
if [ -d "${installer_src}/bootstrap" ]; then
  cp -a "${installer_src}/bootstrap" "${installer_dst}/bootstrap"
fi
cp -a "${installer_src}/app" "${installer_dst}/app"
install -Dm600 "${installer_src}/data/account.env.example" \
  "${airootfs}/etc/meoarch/account.env"
if [ -d "${repo_root}/build/installer-host/translations" ]; then
  cp -a "${repo_root}/build/installer-host/translations" "${installer_dst}/translations"
else
  echo "Installer translations are missing; build the native installer before ISO synchronization." >&2
  exit 1
fi
install -Dm644 "${installer_src}/CMakeLists.txt" "${installer_dst}/CMakeLists.txt"
cp -a "${repo_root}/assets" "${installer_dst}/assets"
find "${installer_dst}/backend" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod 755 {} +
find "${installer_dst}/data" -type f -exec chmod 644 {} +

rm -rf "${desktop_dst}"
install -d \
  "${desktop_dst}/themes/look-and-feel" \
  "${desktop_dst}/themes/desktoptheme" \
  "${desktop_dst}/themes/color-schemes" \
  "${desktop_dst}/themes/icons" \
  "${desktop_dst}/icons" \
  "${desktop_dst}/plasmoids" \
  "${desktop_dst}/branding" \
  "${desktop_dst}/defaults" \
  "${desktop_dst}/wallpaper"
cp -a "${meo_kde_src}/themes/look-and-feel/org.meo.desktop" \
  "${desktop_dst}/themes/look-and-feel/org.meo.desktop"
cp -a "${meo_kde_src}/themes/desktoptheme/." \
  "${desktop_dst}/themes/desktoptheme/"
cp -a "${meo_kde_src}/themes/color-schemes/." \
  "${desktop_dst}/themes/color-schemes/"
cp -a "${meo_kde_src}/themes/icons/." \
  "${desktop_dst}/themes/icons/"
cp -a "${meo_kde_src}/icons/." "${desktop_dst}/icons/"
for plasmoid in org.meo.topbar org.meo.timecenter; do
  if [ -d "${meo_kde_src}/plasmoids/${plasmoid}" ]; then
    cp -a "${meo_kde_src}/plasmoids/${plasmoid}" \
      "${desktop_dst}/plasmoids/${plasmoid}"
  fi
done
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
  "${airootfs}/usr/share/color-schemes" \
  "${airootfs}/usr/share/icons/hicolor/scalable/apps" \
  "${airootfs}/usr/share/pixmaps" \
  "${airootfs}/usr/share/sddm/themes/breeze" \
  "${airootfs}/usr/lib/qt6/plugins/org.kde.kdecoration3" \
  "${airootfs}/usr/lib/qt6/plugins/org.kde.kdecoration3.kcm" \
  "${airootfs}/usr/lib/qt6/plugins/styles" \
  "${airootfs}/usr/lib/qt6/plugins/kwin/effects/plugins" \
  "${desktop_live_wallpaper}" \
  "${airootfs}/etc/sddm.conf.d" \
  "${airootfs}/etc/xdg"
cp -a "${meo_kde_src}/themes/look-and-feel/org.meo.desktop" \
  "${desktop_live_theme}"
if [ -d "${meo_kde_src}/themes/desktoptheme" ]; then
  rm -rf "${desktop_light_theme}" "${desktop_dark_theme}"
  cp -a "${meo_kde_src}/themes/desktoptheme/." "${airootfs}/usr/share/plasma/desktoptheme/"
fi
cp -a "${meo_kde_src}/themes/color-schemes/." "${airootfs}/usr/share/color-schemes/"
cp -a "${meo_kde_src}/themes/icons/." "${airootfs}/usr/share/icons/"
# Meo's current shell consists of the top status surface and time center. The
# bottom Dock is Plasma's native Icons-Only Task Manager; remove the retired
# custom Shelf so stale ISO staging cannot shadow that layout.
for retired_plasmoid in org.meo.shelf org.meo.toptasks org.meo.launcher org.meo.quicksettings; do
  rm -rf "${airootfs}/usr/share/plasma/plasmoids/${retired_plasmoid}"
done
for plasmoid in org.meo.topbar org.meo.timecenter; do
  if [ -d "${meo_kde_src}/plasmoids/${plasmoid}" ]; then
    rm -rf "${airootfs}/usr/share/plasma/plasmoids/${plasmoid}"
    cp -a "${meo_kde_src}/plasmoids/${plasmoid}" \
      "${airootfs}/usr/share/plasma/plasmoids/${plasmoid}"
  fi
done
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

plymouth_theme_dst="${airootfs}/usr/share/plymouth/themes/meoarch"
rm -rf "${plymouth_theme_dst}"
install -d "${plymouth_theme_dst}" "${airootfs}/etc/plymouth" "${airootfs}/usr/lib/meoarch" "${airootfs}/usr/bin"
cp -a "${repo_root}/themes/plymouth/meoarch/." "${plymouth_theme_dst}/"
cat <<'EOF' >"${airootfs}/etc/plymouth/plymouthd.conf"
[Daemon]
Theme=meoarch
ShowDelay=0
DeviceTimeout=5
EOF

install -Dm755 "${installer_src}/bin/meo-boot-status" "${airootfs}/usr/lib/meoarch/meo-boot-status"
ln -sfn /usr/lib/meoarch/meo-boot-status "${airootfs}/usr/bin/meo-boot-status"

for unit_file in meo-boot-status-failure@.service meo-boot-early.service meo-boot-storage.service meo-boot-services.service; do
  install -Dm644 "${installer_src}/data/systemd/${unit_file}" "${airootfs}/usr/lib/systemd/system/${unit_file}"
done

mkdir -p "${airootfs}/etc/systemd/system/sysinit.target.wants" \
         "${airootfs}/etc/systemd/system/local-fs.target.wants" \
         "${airootfs}/etc/systemd/system/multi-user.target.wants"
ln -sfn /usr/lib/systemd/system/meo-boot-early.service "${airootfs}/etc/systemd/system/sysinit.target.wants/meo-boot-early.service"
ln -sfn /usr/lib/systemd/system/meo-boot-storage.service "${airootfs}/etc/systemd/system/local-fs.target.wants/meo-boot-storage.service"
ln -sfn /usr/lib/systemd/system/meo-boot-services.service "${airootfs}/etc/systemd/system/multi-user.target.wants/meo-boot-services.service"

for dropin in systemd-udev-settle.service.d NetworkManager.service.d sddm.service.d; do
  install -d "${airootfs}/usr/lib/systemd/system/${dropin}"
  install -Dm644 "${installer_src}/data/systemd/dropins/${dropin}/10-meo-boot-status.conf" \
    "${airootfs}/usr/lib/systemd/system/${dropin}/10-meo-boot-status.conf"
done
install -Dm755 "${meokde_native_build}/bin/org.kde.kdecoration3/org.meo.decoration.so" \
  "${airootfs}/usr/lib/qt6/plugins/org.kde.kdecoration3/org.meo.decoration.so"
install -Dm755 "${meokde_native_build}/decoration/kcm_meodecoration.so" \
  "${airootfs}/usr/lib/qt6/plugins/org.kde.kdecoration3.kcm/kcm_meodecoration.so"
install -Dm755 "${meokde_native_build}/qt-plugins/styles/meostyle.so" \
  "${airootfs}/usr/lib/qt6/plugins/styles/meostyle.so"
# The old clipping effect is intentionally retired. KWin's maintained shape
# corners effect and the native decoration now own the window geometry.
rm -f "${airootfs}/usr/lib/qt6/plugins/kwin/effects/plugins/org.meo.windowcorners.so"

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
install -Dm755 "${installer_src}/bin/meoarch-install" \
  "${airootfs}/usr/local/bin/meoarch-install"
install -Dm755 "${installer_src}/backend/preflight-meo-repository.sh" \
  "${installer_dst}/backend/preflight-meo-repository.sh"
for helper in Installation_guide choose-mirror installer.py livecd-sound; do
  [ -f "${legacy_live_tools}/${helper}" ] || {
    echo "Required ArchISO live helper is missing: ${legacy_live_tools}/${helper}" >&2
    exit 1
  }
  if [ "${legacy_live_tools}/${helper}" != "${airootfs}/usr/local/bin/${helper}" ]; then
    install -Dm755 "${legacy_live_tools}/${helper}" "${airootfs}/usr/local/bin/${helper}"
  else
    chmod 755 "${airootfs}/usr/local/bin/${helper}"
  fi
done
install -Dm755 "${installer_src}/bin/meoarch-installer-live" \
  "${airootfs}/usr/local/bin/meoarch-installer-live"
install -Dm755 "${installer_src}/bin/meoarch-installer-live-root" \
  "${airootfs}/usr/local/bin/meoarch-installer-live-root"
