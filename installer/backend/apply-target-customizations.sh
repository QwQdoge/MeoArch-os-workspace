#!/usr/bin/env bash
set -euo pipefail

target_root="${1:-${MEOARCH_TARGET_ROOT:-/mnt}}"
desktop_source="${2:-/opt/meo-desktop}"
generated_dir="${3:-${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}/generated}"
runtime_source="${MEOARCH_RUNTIME_SOURCE:-/usr}"
customizations_file="${generated_dir}/target-customizations.json"

if [ "${target_root}" = "/" ] || [ -z "${target_root}" ] || [ -L "${target_root}" ]; then
  echo "Refusing unsafe target root: ${target_root}" >&2
  exit 2
fi
target_root="$(realpath -e -- "${target_root}")"
if [ "${target_root}" = "/" ]; then
  echo "Refusing unsafe resolved target root: ${target_root}" >&2
  exit 2
fi
target_desktop_payload="${target_root}/opt/meo-desktop"
if [ ! -d "${target_root}/etc" ] || [ ! -d "${target_root}/usr" ]; then
  echo "Installed target is not mounted at ${target_root}." >&2
  exit 3
fi
if [ ! -f "${customizations_file}" ]; then
  echo "Generated target customizations are missing." >&2
  exit 6
fi
if [ "${MEOARCH_PACKAGE_MANAGED:-1}" != "1" ]; then
if [ ! -f "${desktop_source}/themes/look-and-feel/org.meo.desktop/metadata.json" ]; then
  echo "Meo Desktop payload is missing from ${desktop_source}." >&2
  exit 4
fi
for destructive_target in \
  "${target_root}/usr/lib/qt6/qml/MeoUI" \
  "${target_root}/usr/lib/qt6/qml/MeoKDE" \
  "${target_root}/usr/lib/qt6/qml/Meo/System" \
  "${target_root}/usr/lib/meoarch-repair" \
  "${target_root}/usr/share/plasma/look-and-feel/org.meo.desktop" \
  "${target_root}/usr/share/plasma/desktoptheme/MeoLight" \
  "${target_root}/usr/share/plasma/desktoptheme/MeoDark" \
  "${target_desktop_payload}"; do
  if [ -L "${destructive_target}" ]; then
    echo "Refusing recursive replacement of symlink: ${destructive_target}" >&2
    exit 2
  fi
done
if [ ! -e "${runtime_source}/lib/libmeoui.so.0" ] \
  || [ ! -f "${runtime_source}/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so" ] \
  || [ ! -f "${runtime_source}/lib/qt6/qml/Meo/System/libmeosystemplugin.so" ] \
  || [ ! -d "${runtime_source}/lib/qt6/qml/MeoKDE" ] \
  || [ ! -x "${runtime_source}/bin/meo-dynamic-colors" ] \
  || [ ! -x "${runtime_source}/bin/meo-input-method" ]; then
  echo "MeoUI, MeoKDE, or Meo.System runtime is missing from ${runtime_source}." >&2
  exit 5
fi
if [ ! -x "${runtime_source}/bin/meoarch-repair" ] \
  || [ ! -f "${runtime_source}/lib/meoarch-repair/qml/Main.qml" ] \
  || [ ! -f "${runtime_source}/share/applications/org.meo.repair.desktop" ]; then
  echo "MeoArch Quick Repair runtime is missing from ${runtime_source}." >&2
  exit 5
fi

install -d "${target_root}/opt"
rm -rf "${target_desktop_payload}"
cp -a "${desktop_source}" "${target_desktop_payload}"

install -d \
  "${target_root}/usr/lib" \
  "${target_root}/usr/lib/qt6/qml/MeoUI" \
  "${target_root}/usr/lib/qt6/qml/MeoKDE" \
  "${target_root}/usr/lib/qt6/qml/Meo/System" \
  "${target_root}/usr/lib/qt6/plugins/org.kde.kdecoration3" \
  "${target_root}/usr/lib/qt6/plugins/org.kde.kdecoration3.kcm" \
  "${target_root}/usr/lib/qt6/plugins/styles" \
  "${target_root}/usr/lib/systemd/user/default.target.wants" \
  "${target_root}/usr/bin" \
  "${target_root}/usr/share/fonts/meo" \
  "${target_root}/usr/share/fcitx5/themes" \
  "${target_root}/usr/share/meo-desktop/defaults" \
  "${target_root}/usr/share/meo-desktop/input-method/ibus" \
  "${target_root}/usr/share/color-schemes" \
  "${target_root}/usr/share/icons" \
  "${target_root}/usr/share/icons/hicolor/scalable/apps" \
  "${target_root}/usr/share/plasma/look-and-feel" \
  "${target_root}/usr/share/plasma/plasmoids" \
  "${target_root}/usr/share/pixmaps" \
  "${target_root}/usr/share/wallpapers/MeoArch" \
  "${target_root}/etc/environment.d" \
  "${target_root}/etc/fonts/conf.avail" \
  "${target_root}/etc/fonts/conf.d" \
  "${target_root}/etc/xdg/fcitx5/conf"

cp -a "${runtime_source}/lib/libmeoui.so"* "${target_root}/usr/lib/"
rm -rf "${target_root}/usr/lib/qt6/qml/MeoUI"
cp -a "${runtime_source}/lib/qt6/qml/MeoUI" \
  "${target_root}/usr/lib/qt6/qml/MeoUI"
rm -rf "${target_root}/usr/lib/qt6/qml/MeoKDE" "${target_root}/usr/lib/qt6/qml/Meo/System"
cp -a "${runtime_source}/lib/qt6/qml/MeoKDE" \
  "${target_root}/usr/lib/qt6/qml/MeoKDE"
cp -a "${runtime_source}/lib/qt6/qml/Meo/System" \
  "${target_root}/usr/lib/qt6/qml/Meo/System"
rm -rf "${target_root}/usr/lib/meoarch-repair"
cp -a "${runtime_source}/lib/meoarch-repair" \
  "${target_root}/usr/lib/meoarch-repair"
install -Dm755 "${runtime_source}/bin/meoarch-repair" \
  "${target_root}/usr/bin/meoarch-repair"
install -Dm644 "${runtime_source}/share/applications/org.meo.repair.desktop" \
  "${target_root}/usr/share/applications/org.meo.repair.desktop"
install -Dm644 "${runtime_source}/share/icons/hicolor/scalable/apps/meoarch-ai.svg" \
  "${target_root}/usr/share/icons/hicolor/scalable/apps/meoarch-ai.svg"
if [ -d "${runtime_source}/share/fonts/meo" ]; then
  cp -a "${runtime_source}/share/fonts/meo/." "${target_root}/usr/share/fonts/meo/"
fi
for plugin in \
  "org.kde.kdecoration3/org.meo.decoration.so" \
  "org.kde.kdecoration3.kcm/kcm_meodecoration.so" \
  "styles/meostyle.so"; do
  if [ -f "${runtime_source}/lib/qt6/plugins/${plugin}" ]; then
    install -Dm755 "${runtime_source}/lib/qt6/plugins/${plugin}" \
      "${target_root}/usr/lib/qt6/plugins/${plugin}"
  fi
done
for helper in meo-dynamic-colors meo-input-method meo-theme-mode meo-desktop-apply meo-desktop-layout; do
  install -Dm755 "${runtime_source}/bin/${helper}" "${target_root}/usr/bin/${helper}"
done
install -Dm644 "${desktop_source}/defaults/kwin/kwinrc" \
  "${target_root}/usr/share/meo-desktop/defaults/kwinrc"
install -Dm644 "${desktop_source}/defaults/environment/90-meo-applications.conf" \
  "${target_root}/etc/environment.d/90-meo-applications.conf"
install -Dm644 "${desktop_source}/defaults/input-method/fcitx5/conf/classicui.conf" \
  "${target_root}/etc/xdg/fcitx5/conf/classicui.conf"
rm -rf "${target_root}/usr/share/fcitx5/themes/MeoInputMethod-Light" \
  "${target_root}/usr/share/fcitx5/themes/MeoInputMethod-Dark"
cp -a "${runtime_source}/share/fcitx5/themes/MeoInputMethod-Light" \
  "${runtime_source}/share/fcitx5/themes/MeoInputMethod-Dark" \
  "${target_root}/usr/share/fcitx5/themes/"
cp -a "${runtime_source}/share/meo-desktop/input-method/ibus/." \
  "${target_root}/usr/share/meo-desktop/input-method/ibus/"
install -Dm644 "${desktop_source}/defaults/systemd/meo-dynamic-colors.path" \
  "${target_root}/usr/lib/systemd/user/meo-dynamic-colors.path"
install -Dm644 "${runtime_source}/lib/systemd/user/meo-dynamic-colors.service" \
  "${target_root}/usr/lib/systemd/user/meo-dynamic-colors.service"
ln -sfn ../meo-dynamic-colors.path \
  "${target_root}/usr/lib/systemd/user/default.target.wants/meo-dynamic-colors.path"
install -Dm644 "${desktop_source}/defaults/fonts/50-meo-fonts.conf" \
  "${target_root}/etc/fonts/conf.avail/50-meo-fonts.conf"
ln -sfn ../conf.avail/50-meo-fonts.conf \
  "${target_root}/etc/fonts/conf.d/50-meo-fonts.conf"

rm -rf "${target_root}/usr/share/plasma/look-and-feel/org.meo.desktop"
cp -a "${desktop_source}/themes/look-and-feel/org.meo.desktop" \
  "${target_root}/usr/share/plasma/look-and-feel/org.meo.desktop"
if [ -d "${desktop_source}/themes/desktoptheme" ]; then
  rm -rf "${target_root}/usr/share/plasma/desktoptheme/MeoLight" \
    "${target_root}/usr/share/plasma/desktoptheme/MeoDark"
  cp -a "${desktop_source}/themes/desktoptheme/." \
    "${target_root}/usr/share/plasma/desktoptheme/"
fi
if [ -d "${desktop_source}/themes/color-schemes" ]; then
  cp -a "${desktop_source}/themes/color-schemes/." \
    "${target_root}/usr/share/color-schemes/"
fi
if [ -d "${desktop_source}/themes/icons" ]; then
  cp -a "${desktop_source}/themes/icons/." "${target_root}/usr/share/icons/"
fi

if [ -d "${desktop_source}/plasmoids" ]; then
  for retired_plasmoid in org.meo.shelf org.meo.toptasks org.meo.launcher org.meo.quicksettings; do
    rm -rf "${target_root}/usr/share/plasma/plasmoids/${retired_plasmoid}"
  done
  for plasmoid in org.meo.topbar org.meo.timecenter; do
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
rm -f "${target_root}/etc/os-release"
install -Dm644 "${desktop_source}/defaults/system/os-release" \
  "${target_root}/etc/os-release"
install -Dm644 "${desktop_source}/defaults/kde/kdeglobals" \
  "${target_root}/etc/xdg/kdeglobals"
install -Dm644 "${desktop_source}/defaults/kde/kglobalshortcutsrc" \
  "${target_root}/etc/xdg/kglobalshortcutsrc"
install -Dm644 "${desktop_source}/defaults/kwin/kwinrc" \
  "${target_root}/etc/xdg/kwinrc"
install -Dm644 "${desktop_source}/defaults/plasma/plasmarc" \
  "${target_root}/etc/xdg/plasmarc"
install -Dm644 "${desktop_source}/defaults/plasma/plasma-welcomerc" \
  "${target_root}/etc/xdg/plasma-welcomerc"
fi

# Apply the signed package's branding template without dereferencing Arch's
# /etc/os-release symlink (which may otherwise point outside this host view).
if [ "${MEOARCH_PACKAGE_MANAGED:-1}" = "1" ]; then
  os_release_template="${target_root}/usr/share/meo-desktop/os-release"
  [ -s "$os_release_template" ] && [ ! -L "$os_release_template" ] || {
    echo "Packaged target os-release template is missing." >&2; exit 13;
  }
  os_release_stage="$(mktemp "${target_root}/etc/.meo-os-release.XXXXXX")"
  install -m644 "$os_release_template" "$os_release_stage"
  mv -T -- "$os_release_stage" "${target_root}/etc/os-release"
fi

# The package provides the executable; this target-owned entry starts the
# independent first-login flow for every user.  meo-welcome itself stores the
# explicit Skip/Done decision in that user's settings and exits thereafter.
install -Dm644 "$(dirname -- "${BASH_SOURCE[0]}")/../data/autostart/org.meo.welcome.desktop" \
  "${target_root}/etc/xdg/autostart/org.meo.welcome.desktop"

# Target System Plymouth Theme & Hook Configuration
boot_theme_source="${MEOARCH_GRUB_THEME_SOURCE:-$(dirname -- "${BASH_SOURCE[0]}")/../boot-theme}"
if [ ! -f "${boot_theme_source}/theme.txt" ] || [ ! -f "${boot_theme_source}/brand.png" ]; then
  echo "Meo GRUB theme is missing from ${boot_theme_source}." >&2
  exit 13
fi
for theme_file in meoarch.plymouth meoarch.script background.png logo.png spinner.png warning.png progress_box.png progress_bar.png; do
  [ -s "${runtime_source}/share/plymouth/themes/meoarch/$theme_file" ] || {
    echo "Required live Plymouth asset is missing: $theme_file" >&2; exit 13;
  }
done
target_grub_theme="${target_root}/boot/grub/themes/meoarch"
[ ! -L "${target_grub_theme}" ] || { echo "Refusing symlinked target GRUB theme." >&2; exit 13; }
install -d "${target_grub_theme}" "${target_root}/boot/grub"
cp -a "${boot_theme_source}/." "${target_grub_theme}/"
[ -f "${target_root}/etc/default/grub" ] || { echo "Target GRUB defaults are missing." >&2; exit 13; }
python3 - "${target_root}/etc/default/grub" <<'PY'
import re
import sys
from pathlib import Path

path = Path(sys.argv[1])
if path.is_symlink():
    raise SystemExit("Target GRUB defaults must be a regular file")
text = path.read_text(encoding="utf-8")
updates = {
    "GRUB_TIMEOUT": "3",
    "GRUB_TIMEOUT_STYLE": "menu",
    "GRUB_GFXMODE": '"1920x1080,1440x900,1280x720,auto"',
    "GRUB_GFXPAYLOAD_LINUX": "keep",
    "GRUB_THEME": '"/boot/grub/themes/meoarch/theme.txt"',
}
for key, value in updates.items():
    pattern = re.compile(rf"(?m)^\\s*{re.escape(key)}=.*$")
    line = f"{key}={value}"
    text, count = pattern.subn(line, text, count=1)
    if not count:
        text += ("" if text.endswith("\n") else "\n") + line + "\n"
path.write_text(text, encoding="utf-8")
PY
[ -x "${target_root}/usr/bin/grub-mkconfig" ] || { echo "Target grub-mkconfig is missing." >&2; exit 13; }
arch-chroot "${target_root}" /usr/bin/grub-mkconfig -o /boot/grub/grub.cfg

target_plymouth_dst="${target_root}/usr/share/plymouth/themes/meoarch"
[ ! -L "$target_plymouth_dst" ] || { echo "Refusing symlinked target Plymouth theme." >&2; exit 13; }
install -d "${target_plymouth_dst}" "${target_root}/etc/plymouth" "${target_root}/usr/lib/meoarch" "${target_root}/usr/bin"
cp -a "${runtime_source}/share/plymouth/themes/meoarch/." "${target_plymouth_dst}/"
cat <<'EOF' >"${target_root}/etc/plymouth/plymouthd.conf"
[Daemon]
Theme=meoarch
ShowDelay=0
DeviceTimeout=5
EOF

if [ -f "${runtime_source}/lib/meoarch/meo-boot-status" ]; then
  install -Dm755 "${runtime_source}/lib/meoarch/meo-boot-status" "${target_root}/usr/lib/meoarch/meo-boot-status"
  ln -sfn /usr/lib/meoarch/meo-boot-status "${target_root}/usr/bin/meo-boot-status"
fi

for session_action_file in \
  "${runtime_source}/bin/meo-session-actiond" \
  "${runtime_source}/share/dbus-1/services/org.meo.SessionAction1.service"; do
  [ -s "${session_action_file}" ] || { echo "Required Meo session action runtime is missing: ${session_action_file}" >&2; exit 13; }
done
install -Dm755 "${runtime_source}/bin/meo-session-actiond" "${target_root}/usr/bin/meo-session-actiond"
install -Dm644 "${runtime_source}/share/dbus-1/services/org.meo.SessionAction1.service" \
  "${target_root}/usr/share/dbus-1/services/org.meo.SessionAction1.service"

for unit_file in meo-boot-status-failure@.service meo-boot-early.service meo-boot-storage.service meo-boot-services.service; do
  if [ -f "${runtime_source}/lib/systemd/system/${unit_file}" ]; then
    install -Dm644 "${runtime_source}/lib/systemd/system/${unit_file}" "${target_root}/usr/lib/systemd/system/${unit_file}"
  fi
done

mkdir -p "${target_root}/etc/systemd/system/sysinit.target.wants" \
         "${target_root}/etc/systemd/system/local-fs.target.wants" \
         "${target_root}/etc/systemd/system/multi-user.target.wants"
ln -sfn /usr/lib/systemd/system/meo-boot-early.service "${target_root}/etc/systemd/system/sysinit.target.wants/meo-boot-early.service"
ln -sfn /usr/lib/systemd/system/meo-boot-storage.service "${target_root}/etc/systemd/system/local-fs.target.wants/meo-boot-storage.service"
ln -sfn /usr/lib/systemd/system/meo-boot-services.service "${target_root}/etc/systemd/system/multi-user.target.wants/meo-boot-services.service"

for dropin in systemd-udev-settle.service.d NetworkManager.service.d plasmalogin.service.d; do
  if [ -d "${runtime_source}/lib/systemd/system/${dropin}" ]; then
    install -d "${target_root}/usr/lib/systemd/system/${dropin}"
    cp -a "${runtime_source}/lib/systemd/system/${dropin}/." "${target_root}/usr/lib/systemd/system/${dropin}/"
  fi
done

python3 "$(dirname -- "${BASH_SOURCE[0]}")/configure-plymouth-hooks.py" "${target_root}/etc/mkinitcpio.conf"
[ -x "${target_root}/usr/bin/mkinitcpio" ] || { echo "Target mkinitcpio is missing." >&2; exit 13; }
arch-chroot "${target_root}" /usr/bin/mkinitcpio -P
# A later mkinitcpio.conf.d override must not silently remove Plymouth.
arch-chroot "${target_root}" /usr/bin/lsinitcpio /boot/initramfs-linux.img | grep -E '(^|/)plymouthd$' >/dev/null

if [ -f "${generated_dir}/plasma-localerc" ]; then
  install -Dm644 "${generated_dir}/plasma-localerc" \
    "${target_root}/etc/xdg/plasma-localerc"
fi

read_customization() {
  local key="$1"
  python3 - "${customizations_file}" "${key}" <<'PY'
import json
import sys
payload = json.load(open(sys.argv[1], encoding="utf-8"))
value = payload
for part in sys.argv[2].split("."):
    value = value.get(part) if isinstance(value, dict) else None
if isinstance(value, bool):
    print("true" if value else "false")
elif isinstance(value, (str, int)):
    print(value)
PY
}

username="$(read_customization username)"
full_name="$(read_customization fullName)"
automatic_login="$(read_customization automaticLogin)"
login_manager="$(read_customization loginManager)"
firewall="$(read_customization firewall)"
network_handoff_enabled="$(read_customization networkHandoff.enabled)"
network_handoff_file="$(read_customization networkHandoff.file)"
calendar_primary="$(read_customization calendar.primary)"
calendar_secondary="$(read_customization calendar.secondary)"
calendar_hebcal_enabled="$(read_customization calendar.hebcalEnabled)"
# Calendar choices were added after the first installer selection schema.  A
# generated legacy plan must keep the documented safe defaults rather than
# fail target customisation after disks have already been prepared.
calendar_primary="${calendar_primary:-gregorian}"
calendar_secondary="${calendar_secondary:-none}"
calendar_hebcal_enabled="${calendar_hebcal_enabled:-false}"
swap_mode="$(read_customization swap.mode)"
swap_size_mib="$(read_customization swap.fileSizeMiB)"

case "${username}" in
  ""|*[!a-z0-9_-]*) echo "Invalid generated username." >&2; exit 7 ;;
esac
case "${login_manager}" in
  plasma-login-manager) ;;
  *) echo "Unsupported generated login manager." >&2; exit 7 ;;
esac
case "${swap_mode}" in zram|file|none) ;; *) echo "Unsupported generated swap mode." >&2; exit 7 ;; esac
case "${swap_size_mib}" in *[!0-9]*|"") echo "Invalid generated swap size." >&2; exit 7 ;; esac
case "${calendar_primary}" in gregorian) ;; *) echo "Unsupported primary calendar." >&2; exit 7 ;; esac
case "${calendar_secondary}" in none|buddhist|islamic-civil|hebcal) ;; *) echo "Unsupported secondary calendar." >&2; exit 7 ;; esac
case "${calendar_hebcal_enabled}" in true|false) ;; *) echo "Invalid online calendar setting." >&2; exit 7 ;; esac

if [ -n "${full_name}" ]; then
  chroot "${target_root}" /usr/bin/usermod -c "${full_name}" "${username}"
fi
if [ "${automatic_login}" = "true" ]; then
  echo "Automatic login is not supported by the Plasma Login Manager backend yet." >&2
  exit 7
fi
systemctl --root="${target_root}" enable plasmalogin.service

# A selected active NetworkManager profile is the only credential-bearing
# installer handoff. It is prepared outside selections.json with mode 0600;
# reject paths, links, and unsupported filenames before copying it to the
# target's authoritative NetworkManager directory.
if [ "${network_handoff_enabled}" = "true" ]; then
  case "${network_handoff_file}" in network-handoff.nmconnection) ;; *) echo "Invalid network handoff file." >&2; exit 7 ;; esac
  handoff_source="${generated_dir}/${network_handoff_file}"
  [ -f "${handoff_source}" ] && [ ! -L "${handoff_source}" ] || { echo "Selected network handoff is missing." >&2; exit 7; }
  handoff_mode="$(stat -c '%a' "${handoff_source}")"
  [ "${handoff_mode}" = "600" ] || { echo "Selected network handoff is not protected." >&2; exit 7; }
  install -d -m700 "${target_root}/etc/NetworkManager/system-connections"
  install -m600 "${handoff_source}" "${target_root}/etc/NetworkManager/system-connections/meo-install.nmconnection"
  rm -f -- "${handoff_source}"
fi

install -d -m755 "${target_root}/etc/xdg/MeoArch"
cat >"${target_root}/etc/xdg/MeoArch/Calendar.ini" <<EOF
[Calendar]
Primary=${calendar_primary}
Secondary=${calendar_secondary}
HebcalEnabled=${calendar_hebcal_enabled}
EOF
chmod 644 "${target_root}/etc/xdg/MeoArch/Calendar.ini"
if [ "${firewall}" = "true" ]; then
  systemctl --root="${target_root}" enable firewalld.service
fi
systemctl --root="${target_root}" enable \
  com.system76.Scheduler.service power-profiles-daemon.service
# The CachyOS classification database is consumed by System76 Scheduler only.
# Never leave Ananicy's competing nice-policy daemon enabled in the target.
if [ -f "${target_root}/usr/lib/systemd/system/ananicy-cpp.service" ]; then
  systemctl --root="${target_root}" disable ananicy-cpp.service
fi
if [ "${swap_mode}" = "file" ]; then
  if [ -e "${target_root}/swapfile" ]; then
    echo "Refusing to overwrite an existing target swapfile." >&2
    exit 8
  fi
  if [ -x "${target_root}/usr/bin/btrfs" ] && findmnt -no FSTYPE -T "${target_root}" 2>/dev/null | grep -qx btrfs; then
    chroot "${target_root}" /usr/bin/btrfs filesystem mkswapfile --size "${swap_size_mib}M" /swapfile
  else
    chroot "${target_root}" /usr/bin/fallocate -l "${swap_size_mib}M" /swapfile
    chmod 600 "${target_root}/swapfile"
    chroot "${target_root}" /usr/bin/mkswap /swapfile
  fi
  printf '/swapfile none swap defaults 0 0\n' >>"${target_root}/etc/fstab"
fi
ldconfig -r "${target_root}"

echo "Package-managed Meo components and target customizations applied to ${target_root}."
