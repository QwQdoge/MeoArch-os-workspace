#!/usr/bin/env bash
set -euo pipefail

target_root="${1:-${MEOARCH_TARGET_ROOT:-/mnt}}"
desktop_source="${2:-/opt/meo-desktop}"
generated_dir="${3:-${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}/generated}"
runtime_source="${MEOARCH_RUNTIME_SOURCE:-/usr}"
customizations_file="${generated_dir}/target-customizations.json"

if [ "${target_root}" = "/" ] || [ -z "${target_root}" ]; then
  echo "Refusing unsafe target root: ${target_root}" >&2
  exit 2
fi
if [ ! -d "${target_root}/etc" ] || [ ! -d "${target_root}/usr" ]; then
  echo "Installed target is not mounted at ${target_root}." >&2
  exit 3
fi
if [ ! -f "${customizations_file}" ]; then
  echo "Generated target customizations are missing." >&2
  exit 6
fi
if [ ! -f "${desktop_source}/themes/look-and-feel/org.meo.desktop/metadata.json" ]; then
  echo "Meo Desktop payload is missing from ${desktop_source}." >&2
  exit 4
fi
if [ ! -e "${runtime_source}/lib/libmeoui.so.0" ] \
  || [ ! -f "${runtime_source}/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so" ] \
  || [ ! -f "${runtime_source}/lib/qt6/qml/Meo/System/libmeosystemplugin.so" ] \
  || [ ! -d "${runtime_source}/lib/qt6/qml/MeoKDE" ]; then
  echo "MeoUI, MeoKDE, or Meo.System runtime is missing from ${runtime_source}." >&2
  exit 5
fi

install -d \
  "${target_root}/usr/lib" \
  "${target_root}/usr/lib/qt6/qml/MeoUI" \
  "${target_root}/usr/lib/qt6/qml/MeoKDE" \
  "${target_root}/usr/lib/qt6/qml/Meo/System" \
  "${target_root}/usr/lib/qt6/plugins/org.kde.kdecoration3" \
  "${target_root}/usr/lib/qt6/plugins/org.kde.kdecoration3.kcm" \
  "${target_root}/usr/lib/qt6/plugins/styles" \
  "${target_root}/usr/share/fonts/meo" \
  "${target_root}/usr/share/color-schemes" \
  "${target_root}/usr/share/icons" \
  "${target_root}/usr/share/icons/hicolor/scalable/apps" \
  "${target_root}/usr/share/plasma/look-and-feel" \
  "${target_root}/usr/share/plasma/plasmoids" \
  "${target_root}/usr/share/pixmaps" \
  "${target_root}/usr/share/sddm/themes/breeze" \
  "${target_root}/usr/share/wallpapers/MeoArch" \
  "${target_root}/etc/sddm.conf.d" \
  "${target_root}/etc/xdg"

cp -a "${runtime_source}/lib/libmeoui.so"* "${target_root}/usr/lib/"
rm -rf "${target_root}/usr/lib/qt6/qml/MeoUI"
cp -a "${runtime_source}/lib/qt6/qml/MeoUI" \
  "${target_root}/usr/lib/qt6/qml/MeoUI"
rm -rf "${target_root}/usr/lib/qt6/qml/MeoKDE" "${target_root}/usr/lib/qt6/qml/Meo/System"
cp -a "${runtime_source}/lib/qt6/qml/MeoKDE" \
  "${target_root}/usr/lib/qt6/qml/MeoKDE"
cp -a "${runtime_source}/lib/qt6/qml/Meo/System" \
  "${target_root}/usr/lib/qt6/qml/Meo/System"
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

rm -rf "${target_root}/usr/share/plasma/look-and-feel/org.meo.desktop"
cp -a "${desktop_source}/themes/look-and-feel/org.meo.desktop" \
  "${target_root}/usr/share/plasma/look-and-feel/org.meo.desktop"
if [ -d "${desktop_source}/themes/desktoptheme" ]; then
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
  "${airootfs:-/opt/meoarch-installer}/etc/xdg/plasma-welcomerc" 2>/dev/null || true

# Target System Plymouth Theme & Hook Configuration
target_plymouth_dst="${target_root}/usr/share/plymouth/themes/meoarch"
rm -rf "${target_plymouth_dst}"
install -d "${target_plymouth_dst}" "${target_root}/etc/plymouth" "${target_root}/usr/lib/meoarch" "${target_root}/usr/bin"
if [ -d "/usr/share/plymouth/themes/meoarch" ]; then
  cp -a "/usr/share/plymouth/themes/meoarch/." "${target_plymouth_dst}/"
fi
cat <<'EOF' >"${target_root}/etc/plymouth/plymouthd.conf"
[Daemon]
Theme=meoarch
ShowDelay=0
DeviceTimeout=5
EOF

if [ -f "/usr/lib/meoarch/meo-boot-status" ]; then
  install -Dm755 "/usr/lib/meoarch/meo-boot-status" "${target_root}/usr/lib/meoarch/meo-boot-status"
  ln -sfn /usr/lib/meoarch/meo-boot-status "${target_root}/usr/bin/meo-boot-status"
fi

for unit_file in meo-boot-status-failure@.service meo-boot-early.service meo-boot-storage.service meo-boot-services.service; do
  if [ -f "/usr/lib/systemd/system/${unit_file}" ]; then
    install -Dm644 "/usr/lib/systemd/system/${unit_file}" "${target_root}/usr/lib/systemd/system/${unit_file}"
  fi
done

mkdir -p "${target_root}/etc/systemd/system/sysinit.target.wants" \
         "${target_root}/etc/systemd/system/local-fs.target.wants" \
         "${target_root}/etc/systemd/system/multi-user.target.wants"
ln -sfn /usr/lib/systemd/system/meo-boot-early.service "${target_root}/etc/systemd/system/sysinit.target.wants/meo-boot-early.service"
ln -sfn /usr/lib/systemd/system/meo-boot-storage.service "${target_root}/etc/systemd/system/local-fs.target.wants/meo-boot-storage.service"
ln -sfn /usr/lib/systemd/system/meo-boot-services.service "${target_root}/etc/systemd/system/multi-user.target.wants/meo-boot-services.service"

for dropin in systemd-udev-settle.service.d NetworkManager.service.d sddm.service.d; do
  if [ -d "/usr/lib/systemd/system/${dropin}" ]; then
    install -d "${target_root}/usr/lib/systemd/system/${dropin}"
    cp -a "/usr/lib/systemd/system/${dropin}/." "${target_root}/usr/lib/systemd/system/${dropin}/"
  fi
done

if [ -f "${target_root}/etc/mkinitcpio.conf" ]; then
  if ! grep -q "plymouth" "${target_root}/etc/mkinitcpio.conf"; then
    sed -i -e 's/HOOKS=(\(.*\)udev\(.*\))/HOOKS=(\1udev plymouth\2)/g' "${target_root}/etc/mkinitcpio.conf"
  fi
  if [ -x "${target_root}/usr/bin/mkinitcpio" ]; then
    chroot "${target_root}" /usr/bin/mkinitcpio -P 2>/dev/null || true
  fi
fi

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
sddm_session="$(read_customization sddmSession)"
firewall="$(read_customization firewall)"
swap_mode="$(read_customization swap.mode)"
swap_size_mib="$(read_customization swap.fileSizeMiB)"

case "${username}" in
  ""|*[!a-z0-9_-]*) echo "Invalid generated username." >&2; exit 7 ;;
esac
case "${sddm_session}" in
  plasma.desktop) ;;
  *) echo "Unsupported generated SDDM session." >&2; exit 7 ;;
esac
case "${swap_mode}" in zram|file|none) ;; *) echo "Unsupported generated swap mode." >&2; exit 7 ;; esac
case "${swap_size_mib}" in *[!0-9]*|"") echo "Invalid generated swap size." >&2; exit 7 ;; esac

if [ -n "${full_name}" ]; then
  chroot "${target_root}" /usr/bin/usermod -c "${full_name}" "${username}"
fi
if [ "${automatic_login}" = "true" ]; then
  install -Dm644 /dev/stdin "${target_root}/etc/sddm.conf.d/30-meoarch-autologin.conf" <<EOF
[Autologin]
User=${username}
Session=${sddm_session}
Relogin=false
EOF
else
  rm -f "${target_root}/etc/sddm.conf.d/30-meoarch-autologin.conf"
fi
if [ "${firewall}" = "true" ]; then
  systemctl --root="${target_root}" enable firewalld.service
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

echo "MeoUI runtime and Meo Desktop defaults installed into ${target_root}."
