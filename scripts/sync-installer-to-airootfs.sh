#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
projects_root="$(cd "${repo_root}/.." && pwd)"
meo_kde_src="${projects_root}/meo-kde"
meoui_source="${MEOUI_SOURCE_DIR:-${projects_root}/meo-ui}"
if [ ! -f "${meoui_source}/CMakeLists.txt" ] && [ -f "${projects_root}/MeoUI/CMakeLists.txt" ]; then
  meoui_source="${projects_root}/MeoUI"
fi
meo_kde_src="$(realpath -e -- "${meo_kde_src}")"
meoui_source="$(realpath -e -- "${meoui_source}")"
airootfs="${MEOARCH_AIROOTFS:-${repo_root}/meoarch-os/airootfs}"
installer_src="${repo_root}/installer"
airootfs="$(realpath -m -- "${airootfs}")"
outputs_tmp_root="$(realpath -m -- "${MEO_OUTPUT_ROOT:-${projects_root}/outputs}/meo-arch-os-workspace/tmp")"
case "${airootfs}" in
  "${repo_root}"/*|"${outputs_tmp_root}"/archiso-staging/*/profile/airootfs) ;;
  *) echo "Refusing ISO staging outside the workspace or managed output profile: ${airootfs}" >&2; exit 2 ;;
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
repair_knowledge_dst="${airootfs}/usr/share/meoarch-repair"
repair_policy_dst="${airootfs}/usr/share/polkit-1/actions/org.meo.repair.policy"
repair_live_policy_dst="${airootfs}/usr/share/polkit-1/actions/org.meo.repair-live.policy"
repair_live_rule_dst="${airootfs}/usr/share/polkit-1/rules.d/49-meoarch-live-repair.rules"
legacy_desktop_payload_dst="${airootfs}/opt/meo-desktop"
build_root="$(realpath -m -- "${MEOARCH_BUILD_ROOT:-${repo_root}/build}")"
outputs_tmp_root="$(realpath -m -- "${MEO_OUTPUT_ROOT:-${projects_root}/outputs}/meo-arch-os-workspace/tmp")"
case "${build_root}" in
  "${repo_root}/build"|"${repo_root}/build/"*|"${outputs_tmp_root}/"*) ;;
  *) echo "Refusing unsafe ISO build root: ${build_root}" >&2; exit 2 ;;
esac
runtime_root="${build_root}/installer-runtime-root/usr"
meosystem_live_build="${build_root}/meo-system-live"
meokde_native_build="${build_root}/meo-kde-native"
cmake_refresh_args=()
if [ -z "${MEOARCH_BUILD_ROOT:-}" ]; then
  cmake_refresh_args+=(--fresh)
fi
legacy_meoui_dst="${airootfs}/opt/meo-ui"

for destructive_target in \
  "${legacy_meoui_dst}" "${installer_dst}" \
  "${repair_dst}" "${repair_knowledge_dst}" "${repair_policy_dst}" \
  "${repair_live_policy_dst}" \
  "${repair_live_rule_dst}" "${legacy_desktop_payload_dst}"; do
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
  || [ ! -f "${runtime_root}/share/meoarch-repair/knowledge/manifest.json" ] \
  || [ ! -f "${runtime_root}/share/polkit-1/actions/org.meo.repair.policy" ] \
  || [ ! -f "${runtime_root}/lib/qt6/qml/MeoUI/qmldir" ] \
  || [ ! -x "${runtime_root}/bin/meoarch-installer-app" ]; then
  echo "The required native installer runtime is missing; build-installer-app.sh must provide the host, MeoUI, and repair payload." >&2
  exit 1
fi

# The desktop's MeoUI comes from the signed `meoui-qml` package, but the
# Installer and Quick Repair built above link the sibling checkout. Pin them to
# the same MeoUI commit when a release manifest names the Live content.
if [ -n "${MEOARCH_RELEASE_MANIFEST:-}" ]; then
  python3 "${repo_root}/scripts/check-meoui-pin.py" "${meoui_source}" "${MEOARCH_RELEASE_MANIFEST}"
else
  echo "WARNING: MEOARCH_RELEASE_MANIFEST is not set; the Installer's MeoUI is not checked against the packaged meoui-qml." >&2
fi

# The ISO must never consume an unvalidated sibling checkout. This gate uses
# the freshly built MeoUI runtime above and records evidence in MeoKDE's own
# global output subtree, preserving project ownership.
# MEOARCH_SKIP_MEOKDE_VALIDATE=1 is an explicit, logged developer opt-out for
# test ISOs only: the Live desktop itself comes from signed packages, and the
# sibling MeoKDE source contributes just the Cage session's polkit agent and the
# installer's Meo.System adapter.
if [ "${MEOARCH_SKIP_MEOKDE_VALIDATE:-0}" = 1 ]; then
  echo "WARNING: MEOARCH_SKIP_MEOKDE_VALIDATE=1; the sibling MeoKDE validation gate was skipped." >&2
else
MEO_KDE_VALIDATION_RUN_ID="${MEO_KDE_VALIDATION_RUN_ID:-${MEOARCH_VALIDATION_RUN_ID:-$(date -u +%Y-%m-%dT%H%M%SZ)-iso-sync}}" \
MEOUI_IMPORT_ROOT="${runtime_root}/lib/qt6/qml" \
MEOUI_SOURCE_DIR="${meoui_source}" \
  "${meo_kde_src}/scripts/validate.sh"
fi

cmake "${cmake_refresh_args[@]}" -S "${repo_root}/installer/live-system" -B "${meosystem_live_build}" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo -DMEO_KDE_SOURCE_DIR="${meo_kde_src}"
cmake --build "${meosystem_live_build}" --parallel "${MEO_BUILD_PARALLEL_LEVEL:-1}"
cmake "${cmake_refresh_args[@]}" -S "${meo_kde_src}/native" -B "${meokde_native_build}" \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo -DMEOUI_SOURCE_DIR="${meoui_source}" \
  -DMEO_BUILD_STANDALONE_DOCK=OFF
cmake --build "${meokde_native_build}" --target meo-polkit-agent \
  --parallel "${MEO_BUILD_PARALLEL_LEVEL:-1}"

# The desktop runtime (MeoUI, MeoKDE, Meo.System, themes, plasmoids, session
# defaults, window decoration/style, helper tools and their user units) is owned
# by the signed `meoui-qml`, `meo-icons` and `meo-desktop` packages listed in
# packages.x86_64. This overlay is applied after pacstrap and would shadow them,
# so it must not stage any of those files: Live and the installed system run
# the same package versions.
rm -rf "${legacy_meoui_dst}"
install -d "${airootfs}/usr/lib" "${airootfs}/usr/bin"
rm -rf "${repair_dst}" "${repair_knowledge_dst}"
cp -a "${runtime_root}/lib/meoarch-repair" "${repair_dst}"
cp -a "${runtime_root}/share/meoarch-repair" "${repair_knowledge_dst}"
install -Dm755 "${runtime_root}/bin/meoarch-repair" \
  "${airootfs}/usr/bin/meoarch-repair"
install -Dm644 "${runtime_root}/share/applications/org.meo.repair.desktop" \
  "${airootfs}/usr/share/applications/org.meo.repair.desktop"
install -Dm644 "${runtime_root}/share/polkit-1/actions/org.meo.repair.policy" \
  "${repair_policy_dst}"
install -Dm644 "${repo_root}/repair/data/org.meo.repair-live.policy" \
  "${repair_live_policy_dst}"
install -Dm644 "${repo_root}/repair/data/org.meo.repair-live.rules" \
  "${repair_live_rule_dst}"
install -d "${repair_dst}/live-actions"
install -m755 "${repo_root}/repair/live-actions/"*.sh \
  "${repair_dst}/live-actions/"
install -Dm755 "${meokde_native_build}/authentication/meo-polkit-agent" \
  "${airootfs}/usr/lib/meo-polkit-agent"
# polkit-kde-agent owns plasma-polkit-agent.service in the ISO package set.
# Keep the Meo helper binary available to repair tooling, but do not stage a
# second unit with the same path or bus name.
# AgentService is a Live ISO dependency of the native Meo AI client.  Activate
# it through the user manager rather than relying on KDE autostart ordering;
# this symlink is ISO-only and is not copied into an installed target.
install -d "${airootfs}/usr/lib/systemd/user/default.target.wants"
ln -sfn ../meo-agent-service.service \
  "${airootfs}/usr/lib/systemd/user/default.target.wants/meo-agent-service.service"
repair_icon="${runtime_root}/share/icons/hicolor/scalable/apps/meo-ai.svg"
if [ ! -f "${repair_icon}" ]; then
  repair_icon="${runtime_root}/share/icons/hicolor/scalable/apps/meoarch-ai.svg"
fi
[ -f "${repair_icon}" ] || { echo "Repair icon is missing from installer runtime." >&2; exit 1; }
install -Dm644 "${repair_icon}" \
  "${airootfs}/usr/share/icons/hicolor/scalable/apps/meoarch-ai.svg"
# `meo-desktop` ships the fontconfig snippet under conf.avail only; Live enables
# it the way the installer does. User units are package-owned too, but are not
# enabled globally by the package, so the Live medium enables them here (ISO-only).
install -d "${airootfs}/etc/fonts/conf.d"
ln -sfn ../conf.avail/50-meo-fonts.conf \
  "${airootfs}/etc/fonts/conf.d/50-meo-fonts.conf"
ln -sfn ../meo-dynamic-colors.path \
  "${airootfs}/usr/lib/systemd/user/default.target.wants/meo-dynamic-colors.path"
ln -sfn ../meo-weather-refresh.timer \
  "${airootfs}/usr/lib/systemd/user/default.target.wants/meo-weather-refresh.timer"

rm -rf "${installer_dst}"
install -d "${installer_dst}"
cp -a "${installer_src}/qml" "${installer_dst}/qml"
install -d "${installer_dst}/live-qml/Meo/System"
cp -a "${meosystem_live_build}/qml/Meo/System/." "${installer_dst}/live-qml/Meo/System/"
cp -a "${installer_src}/backend" "${installer_dst}/backend"
cp -a "${installer_src}/data" "${installer_dst}/data"
if [ -d "${installer_src}/bootstrap" ]; then
  cp -a "${installer_src}/bootstrap" "${installer_dst}/bootstrap"
fi
cp -a "${installer_src}/app" "${installer_dst}/app"
cp -a "${repo_root}/meoarch-os/grub/themes/meoarch" "${installer_dst}/boot-theme"
install -Dm644 "${repo_root}/meoarch-os/grub/splash.png" "${installer_dst}/boot-splash.png"
install -Dm600 "${installer_src}/data/account.env.example" \
  "${airootfs}/etc/meoarch/account.env"
if [ -d "${build_root}/installer-host/translations" ]; then
  cp -a "${build_root}/installer-host/translations" "${installer_dst}/translations"
else
  echo "Installer translations are missing; build the native installer before ISO synchronization." >&2
  exit 1
fi
install -Dm644 "${installer_src}/CMakeLists.txt" "${installer_dst}/CMakeLists.txt"
cp -a "${repo_root}/assets" "${installer_dst}/assets"
find "${installer_dst}/backend" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod 755 {} +
find "${installer_dst}/data" -type f -exec chmod 644 {} +

# The installed system gets its desktop from pacman, never from a payload on the
# Live medium, so no /opt/meo-desktop tree is staged (and a stale one from an
# older staging run is removed).
rm -rf "${legacy_desktop_payload_dst}"

# The Live desktop itself (look-and-feel, shell, plasmoids, themes, wallpaper,
# branding, session defaults) comes from the `meo-desktop` package. The Live
# session entry below only wraps `startmeo-wayland`.
install -Dm755 "${installer_src}/bin/meoarch-live-session" \
  "${airootfs}/usr/lib/meoarch/live-session"
install -Dm644 "${installer_src}/data/wayland-sessions/meoarch-live.desktop" \
  "${airootfs}/usr/share/wayland-sessions/meoarch-live.desktop"
install -Dm755 "${installer_src}/bin/meoarch-ai-open-installer" \
  "${airootfs}/usr/local/bin/meoarch-ai-open-installer"
install -Dm755 "${installer_src}/bin/meoarch-installer-live" \
  "${airootfs}/usr/local/bin/meoarch-installer-live"
install -Dm755 "${installer_src}/bin/meoarch-live-installer-authorize" \
  "${airootfs}/usr/lib/meoarch/live-installer-authorize"
install -Dm644 "${installer_src}/data/systemd/user/meoarch-live-app.service" \
  "${airootfs}/usr/lib/systemd/user/meoarch-live-app.service"
install -Dm644 "${installer_src}/data/autostart/meoarch-live.desktop" \
  "${airootfs}/etc/xdg/autostart/meoarch-live.desktop"
install -Dm644 "${installer_src}/data/applications/org.meo.installer-live.desktop" \
  "${airootfs}/usr/share/applications/org.meo.installer-live.desktop"
# Override only the Live launcher, so opening Repair from the menu selects the
# correct live scope without launching Cage or a second authentication agent.
install -Dm644 "${installer_src}/data/applications/org.meo.repair-live.desktop" \
  "${airootfs}/usr/share/applications/org.meo.repair.desktop"
install -Dm644 "${installer_src}/data/org.meo.installer-live.policy" \
  "${airootfs}/usr/share/polkit-1/actions/org.meo.installer-live.policy"
install -Dm644 "${installer_src}/data/org.meo.installer-live.rules" \
  "${airootfs}/usr/share/polkit-1/rules.d/49-meoarch-live-installer.rules"
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
install -Dm755 "${installer_src}/bin/meoarch-repair-session" \
  "${airootfs}/usr/local/bin/meoarch-repair-session"
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
