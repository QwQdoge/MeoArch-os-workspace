#!/usr/bin/env bash
set -euo pipefail

target_root="${1:-${MEOARCH_TARGET_ROOT:-/mnt}}"
generated_dir="${2:-${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}/generated}"
runtime_source="${MEOARCH_RUNTIME_SOURCE:-/usr}"
customizations_file="${generated_dir}/target-customizations.json"

resolve_existing_path() {
  # GNU realpath's -e option is not available on every developer host.  Python
  # is already required by the installer, and strict resolution gives the same
  # "must exist" contract without following a caller-supplied target symlink.
  python3 - "$1" <<'PY'
from pathlib import Path
import sys

try:
    print(Path(sys.argv[1]).resolve(strict=True))
except OSError as error:
    raise SystemExit(error)
PY
}

install_file() {
  local mode="$1"
  local source="$2"
  local destination="$3"
  command install -d "$(dirname -- "${destination}")"
  command install -m "${mode}" "${source}" "${destination}"
}

if [ "${target_root}" = "/" ] || [ -z "${target_root}" ] || [ -L "${target_root}" ]; then
  echo "Refusing unsafe target root: ${target_root}" >&2
  exit 2
fi
target_root="$(resolve_existing_path "${target_root}")"
if [ "${target_root}" = "/" ]; then
  echo "Refusing unsafe resolved target root: ${target_root}" >&2
  exit 2
fi
for target_directory in etc usr boot; do
  if [ -L "${target_root}/${target_directory}" ] || [ ! -d "${target_root}/${target_directory}" ]; then
    echo "Installed target has an unsafe ${target_directory} directory at ${target_root}." >&2
    exit 3
  fi
done
if [ ! -f "${customizations_file}" ] || [ -L "${customizations_file}" ]; then
  echo "Generated target customizations are missing or unsafe." >&2
  exit 6
fi
# Every Meo component (MeoUI, MeoKDE, Meo.System, the Meo session and its
# defaults, themes, applets, Quick Repair, login manager) is installed and owned
# by pacman from the signed Meo repository before this script runs. This script
# only applies target-local state (branding template, boot theme, accounts,
# services, swap); it never copies desktop files from the Live medium.

# Apply the signed package's branding template without dereferencing Arch's
# /etc/os-release symlink (which may otherwise point outside this host view).
os_release_template="${target_root}/usr/share/meo-desktop/os-release"
[ -s "$os_release_template" ] && [ ! -L "$os_release_template" ] || {
  echo "Packaged target os-release template is missing." >&2; exit 13;
}
os_release_stage="$(mktemp "${target_root}/etc/.meo-os-release.XXXXXX")"
install -m644 "$os_release_template" "$os_release_stage"
# `mv -T` is a GNU-only flag.  os-release is required to be a non-directory
# destination, so ordinary same-filesystem rename atomically replaces a
# symlink instead of writing through it on both GNU and BSD userlands.
[ ! -d "${target_root}/etc/os-release" ] || {
  echo "Target os-release must not be a directory." >&2; exit 13;
}
mv -f "$os_release_stage" "${target_root}/etc/os-release"

# The package provides the executable; this target-owned entry starts the
# independent first-login flow for every user.  meo-welcome itself stores the
# explicit Skip/Done decision in that user's settings and exits thereafter.
install_file 644 "$(dirname -- "${BASH_SOURCE[0]}")/../data/autostart/org.meo.welcome.desktop" \
  "${target_root}/etc/xdg/autostart/org.meo.welcome.desktop"

# Target System Plymouth Theme & Hook Configuration
boot_theme_source="${MEOARCH_GRUB_THEME_SOURCE:-$(dirname -- "${BASH_SOURCE[0]}")/../boot-theme}"
boot_splash_source="${MEOARCH_GRUB_SPLASH_SOURCE:-${boot_theme_source}/../boot-splash.png}"
if [ ! -f "${boot_theme_source}/theme.txt" ] || [ ! -f "${boot_theme_source}/brand.png" ]; then
  echo "Meo GRUB theme is missing from ${boot_theme_source}." >&2
  exit 13
fi
if [ ! -f "${boot_splash_source}" ] || [ -L "${boot_splash_source}" ]; then
  echo "Meo GRUB background is missing or unsafe: ${boot_splash_source}." >&2
  exit 13
fi
for theme_file in meoarch.plymouth meoarch.script logo.png; do
  [ -s "${runtime_source}/share/plymouth/themes/meoarch/$theme_file" ] || {
    echo "Required live Plymouth asset is missing: $theme_file" >&2; exit 13;
  }
done
target_grub_theme="${target_root}/boot/grub/themes/meoarch"
[ ! -L "${target_grub_theme}" ] || { echo "Refusing symlinked target GRUB theme." >&2; exit 13; }
install -d "${target_grub_theme}" "${target_root}/boot/grub"
cp -a "${boot_theme_source}/." "${target_grub_theme}/"
install_file 644 "${boot_splash_source}" "${target_root}/boot/grub/splash.png"
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
  install_file 755 "${runtime_source}/lib/meoarch/meo-boot-status" "${target_root}/usr/lib/meoarch/meo-boot-status"
  ln -sfn /usr/lib/meoarch/meo-boot-status "${target_root}/usr/bin/meo-boot-status"
fi

# meo-session-actiond and its D-Bus service are owned by the meo-desktop
# package; verify-target.py requires them in the installed target.

for unit_file in meo-boot-status-failure@.service meo-boot-early.service meo-boot-storage.service meo-boot-services.service; do
  if [ -f "${runtime_source}/lib/systemd/system/${unit_file}" ]; then
    install_file 644 "${runtime_source}/lib/systemd/system/${unit_file}" "${target_root}/usr/lib/systemd/system/${unit_file}"
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

if [ -f "${generated_dir}/plasma-localerc" ] && [ ! -L "${generated_dir}/plasma-localerc" ]; then
  install_file 644 "${generated_dir}/plasma-localerc" \
    "${target_root}/etc/xdg/plasma-localerc"
elif [ -L "${generated_dir}/plasma-localerc" ]; then
  echo "Generated Plasma locale file is unsafe." >&2
  exit 7
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
elif isinstance(value, list):
    for item in value:
        if isinstance(item, str):
            print(item)
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
mapfile -t guest_services < <(read_customization guestIntegration.services)

case "${username}" in
  ""|*[!a-z0-9_-]*) echo "Invalid generated username." >&2; exit 7 ;;
esac
case "${login_manager}" in
  meo-plasma-login-manager) ;;
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
  echo "Automatic login is not supported by the Meo Plasma Login Manager backend yet." >&2
  exit 7
fi
# The login model matches the session basename (FileNameRole), not its full path.
# This installer-owned override also repairs the older package default.
login_config_dir="${target_root}/etc/plasmalogin.conf.d"
login_session_config="${login_config_dir}/30-meoarch-session.conf"
[ ! -L "$login_config_dir" ] && [ ! -L "$login_session_config" ] || {
  echo "Refusing symlinked target login configuration." >&2; exit 7;
}
install -d "$login_config_dir"
printf '[Greeter]\nPreselectedSession=meo.desktop\n' >"$login_session_config"
chmod 644 "$login_session_config"
systemctl --root="${target_root}" enable plasmalogin.service

# Guest services are generated only from the detected hypervisor PCI plan.
# Keep a hard whitelist here so a modified state file cannot enable an
# arbitrary target service through this convenience field.
for guest_service in "${guest_services[@]}"; do
  case "${guest_service}" in
    vmtoolsd.service|vboxservice.service) ;;
    *) echo "Unsupported generated guest integration service: ${guest_service}" >&2; exit 7 ;;
  esac
  [ -f "${target_root}/usr/lib/systemd/system/${guest_service}" ] || {
    echo "Selected guest integration service is not installed: ${guest_service}" >&2
    exit 7
  }
  systemctl --root="${target_root}" enable "${guest_service}"
done

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
