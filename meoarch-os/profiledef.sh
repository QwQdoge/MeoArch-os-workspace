#!/usr/bin/env bash
# shellcheck disable=SC2034

iso_name="meoarch-os"
iso_label="MEOARCH_$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y%m)"
iso_publisher="MeoArch <https://github.com/QwQdoge>"
iso_application="MeoArch OS Live/Rescue ISO"
iso_version="$(date --date="@${SOURCE_DATE_EPOCH:-$(date +%s)}" +%Y.%m.%d)"
install_dir="arch"
buildmodes=('iso')
bootmodes=('bios.syslinux'
           'uefi.systemd-boot')
pacman_conf="pacman.conf"
airootfs_image_type="squashfs"
airootfs_image_tool_options=('-comp' 'xz' '-Xbcj' 'x86' '-b' '1M' '-Xdict-size' '1M')
bootstrap_tarball_compression=('zstd' '-c' '-T0' '--auto-threads=logical' '--long' '-19')
file_permissions=(
  ["/etc/shadow"]="0:0:400"
  ["/etc/meoarch/account.env"]="0:0:600"
  ["/root"]="0:0:750"
  ["/root/.automated_script.sh"]="0:0:755"
  ["/root/.gnupg"]="0:0:700"
  ["/usr/local/bin/choose-mirror"]="0:0:755"
  ["/usr/local/bin/Installation_guide"]="0:0:755"
  ["/usr/local/bin/livecd-sound"]="0:0:755"
  ["/usr/local/bin/meoarch-installer"]="0:0:755"
  ["/usr/local/bin/meoarch-installer-kiosk"]="0:0:755"
  ["/usr/local/bin/meoarch-install"]="0:0:755"
  ["/usr/bin/meoarch-repair"]="0:0:755"
  ["/usr/lib/meoarch/meo-boot-status"]="0:0:755"
  ["/usr/lib/meoarch-repair/checks/all.sh"]="0:0:755"
  ["/usr/lib/meoarch-repair/checks/network.sh"]="0:0:755"
  ["/usr/lib/meoarch-repair/checks/boot.sh"]="0:0:755"
  ["/usr/lib/meoarch-repair/checks/packages.sh"]="0:0:755"
  ["/usr/lib/meoarch-repair/checks/storage.sh"]="0:0:755"
  ["/usr/lib/meoarch-repair/checks/graphics.sh"]="0:0:755"
  ["/usr/lib/meoarch-repair/checks/security.sh"]="0:0:755"
  ["/usr/lib/meoarch-repair/actions/reload-systemd-manager.sh"]="0:0:755"
  ["/usr/lib/meoarch-repair/actions/restart-network-manager.sh"]="0:0:755"
  ["/usr/lib/meoarch-repair/actions/rebuild-initramfs.sh"]="0:0:755"
  ["/usr/lib/meoarch-repair/actions/refresh-pacman-keyring.sh"]="0:0:755"
  ["/opt/meoarch-installer/bin/meoarch-installer-app"]="0:0:755"
  ["/opt/meoarch-installer/backend/apply-target-customizations.sh"]="0:0:755"
  ["/opt/meoarch-installer/backend/archinstall-preflight.sh"]="0:0:755"
  ["/opt/meoarch-installer/backend/generate-config.py"]="0:0:755"
  ["/opt/meoarch-installer/backend/hardware.py"]="0:0:755"
  ["/opt/meoarch-installer/backend/run-archinstall.sh"]="0:0:755"
)
