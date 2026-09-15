#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
projects_root="$(cd "${repo_root}/.." && pwd)"
meo_kde_src="${projects_root}/meo-kde"
meoui_source="${MEOUI_SOURCE_DIR:-${projects_root}/meo-ui}"
if [ ! -f "${meoui_source}/CMakeLists.txt" ] && [ -f "${projects_root}/MeoUI/CMakeLists.txt" ]; then
  meoui_source="${projects_root}/MeoUI"
fi
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
# ArchISO builds synchronize into a generated profile copy.  The upstream live
# helpers must always come from the versioned source profile, never from the
# generated destination (which is intentionally empty before synchronization).
profile_live_tools="${repo_root}/meoarch-os/airootfs/usr/local/bin"
required_live_helpers=(Installation_guide choose-mirror livecd-sound)
installer_dst="${airootfs}/opt/meoarch-installer"
repair_dst="${airootfs}/usr/lib/meoarch-repair"
desktop_dst="${airootfs}/opt/meo-desktop"
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
  "${repair_dst}" "${desktop_dst}"; do
  if [ -L "${destructive_target}" ]; then
    echo "Refusing recursive replacement of symlink: ${destructive_target}" >&2
    exit 2
  fi
done

# These are the ArchISO releng live helpers retained by this profile. Validate
# the versioned sources before compiling sibling projects so a clean-checkout
# staging failure is immediate and cannot be masked by generated airootfs
# leftovers.
for helper in "${required_live_helpers[@]}"; do
  helper_source="${profile_live_tools}/${helper}"
  [ -f "${helper_source}" ] && [ ! -L "${helper_source}" ] || {
    echo "Required ArchISO live helper is missing or unsafe: ${helper_source}" >&2
    exit 1
  }
done

"${repo_root}/scripts/build-installer-app.sh"
if [ ! -f "${runtime_root}/lib/libmeoui.so.0" ] \
  || [ ! -x "${runtime_root}/bin/meoarch-repair" ] \
  || [ ! -f "${runtime_root}/lib/meoarch-repair/qml/Main.qml" ] \
  || [ ! -f "${runtime_root}/lib/qt6/qml/MeoUI/qmldir" ] \
  || [ ! -x "${runtime_root}/bin/meoarch-installer-app" ]; then
  echo "The required native installer runtime is missing; build-installer-app.sh must provide the host, MeoUI, and repair payload." >&2
  exit 1
fi

# The ISO must never consume an unvalidated sibling checkout. This gate uses
# the freshly built MeoUI runtime above and records evidence in MeoKDE's own
# global output subtree, preserving project ownership.
MEO_KDE_VALIDATION_RUN_ID="${MEOARCH_VALIDATION_RUN_ID:-$(date -u +%Y-%m-%dT%H%M%SZ)-iso-sync}" \
MEOUI_IMPORT_ROOT="${runtime_root}/lib/qt6/qml" \
MEOUI_SOURCE_DIR="${meoui_source}" \
  "${meo_kde_src}/scripts/validate.sh"

cmake --fresh -S "${meo_kde_src}/native/system" -B "${meosystem_build}" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo
cmake --build "${meosystem_build}" --parallel
cmake --fresh -S "${meo_kde_src}/native" -B "${meokde_native_build}" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo -DMEOUI_SOURCE_DIR="${meoui_source}" \
  -DMEO_BUILD_STANDALONE_DOCK=OFF
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
install -Dm755 "${meosystem_build}/meo-session-actiond" \
  "${airootfs}/usr/bin/meo-session-actiond"
install -Dm755 "${meosystem_build}/meo-weather-refresh" \
  "${airootfs}/usr/bin/meo-weather-refresh"
install -Dm644 "${meo_kde_src}/native/system/org.meo.SessionAction1.service" \
  "${airootfs}/usr/share/dbus-1/services/org.meo.SessionAction1.service"
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
install -Dm644 "${meo_kde_src}/defaults/kde/kglobalshortcutsrc" \
  "${airootfs}/etc/xdg/kglobalshortcutsrc"
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
install -Dm644 "${meo_kde_src}/defaults/systemd/meo-weather-refresh.service" \
  "${airootfs}/usr/lib/systemd/user/meo-weather-refresh.service"
install -Dm644 "${meo_kde_src}/defaults/systemd/meo-weather-refresh.timer" \
  "${airootfs}/usr/lib/systemd/user/meo-weather-refresh.timer"
ln -sfn ../meo-weather-refresh.timer \
  "${airootfs}/usr/lib/systemd/user/default.target.wants/meo-weather-refresh.timer"

rm -rf "${installer_dst}"
install -d "${installer_dst}"
cp -a "${installer_src}/qml" "${installer_dst}/qml"
cp -a "${installer_src}/backend" "${installer_dst}/backend"
cp -a "${installer_src}/data" "${installer_dst}/data"
if [ -d "${installer_src}/bootstrap" ]; then
  cp -a "${installer_src}/bootstrap" "${installer_dst}/bootstrap"
fi
cp -a "${installer_src}/app" "${installer_dst}/app"
cp -a "${repo_root}/meoarch-os/grub/themes/meoarch" "${installer_dst}/boot-theme"
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

# Keep the target desktop payload under /opt/meo-desktop for the installer,
# but do not stage Plasma, KWin, or SDDM files into the Live root.  Cage is the
# only Live compositor; target customisation installs these assets after the
# disk installation has succeeded.
install -Dm644 "${meo_kde_src}/defaults/system/os-release" \
  "${airootfs}/etc/os-release"

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

for dropin in systemd-udev-settle.service.d NetworkManager.service.d plasmalogin.service.d; do
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

native_binary="${MEOARCH_INSTALLER_NATIVE_BINARY:-${runtime_root}/bin/meoarch-installer-app}"
[ -x "${native_binary}" ] || {
  echo "Required native installer host is missing: ${native_binary}" >&2
  exit 1
}
install -Dm755 "${native_binary}" "${installer_dst}/bin/meoarch-installer-app"

install -Dm755 "${installer_src}/bin/meoarch-installer" \
  "${airootfs}/usr/local/bin/meoarch-installer"
install -Dm755 "${installer_src}/bin/meoarch-installer-kiosk" \
  "${airootfs}/usr/local/bin/meoarch-installer-kiosk"
install -Dm755 "${installer_src}/bin/meoarch-install" \
  "${airootfs}/usr/local/bin/meoarch-install"
install -Dm755 "${installer_src}/backend/preflight-meo-repository.sh" \
  "${installer_dst}/backend/preflight-meo-repository.sh"
for helper in "${required_live_helpers[@]}"; do
  helper_source="${profile_live_tools}/${helper}"
  helper_destination="${airootfs}/usr/local/bin/${helper}"
  if [ "${helper_source}" != "${helper_destination}" ]; then
    install -Dm755 "${helper_source}" "${helper_destination}"
  else
    chmod 755 "${helper_destination}"
  fi
done
