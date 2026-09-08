#!/usr/bin/env bash
# Automated Post-Install Target System Validator for MeoArch OS

set -euo pipefail

target_root="${1:-/mnt}"

if [ "${MEOARCH_PACKAGE_MANAGED:-1}" = 1 ]; then
  exec python3 "$(dirname -- "${BASH_SOURCE[0]}")/../installer/backend/verify-target.py" "$target_root"
fi

echo "Validating MeoArch OS installation at ${target_root}..."

if [ ! -d "${target_root}/etc" ] || [ ! -d "${target_root}/usr" ]; then
  echo "FAIL: Installed target is missing /etc or /usr at ${target_root}." >&2
  exit 1
fi

# 1. Verify /etc/fstab
if [ ! -s "${target_root}/etc/fstab" ]; then
  echo "FAIL: Target /etc/fstab is empty or missing." >&2
  exit 2
fi

# 2. Verify Kernel & initramfs
if [ ! -f "${target_root}/boot/vmlinuz-linux" ] || [ ! -f "${target_root}/boot/initramfs-linux.img" ]; then
  echo "FAIL: Target kernel or initramfs is missing in /boot." >&2
  exit 3
fi

# 3. Verify Plymouth & Meo Theme
if [ ! -d "${target_root}/usr/share/plymouth/themes/meoarch" ] || [ ! -f "${target_root}/etc/plymouth/plymouthd.conf" ]; then
  echo "FAIL: Target Plymouth theme or configuration is missing." >&2
  exit 4
fi

# 4. Verify MeoUI & Meo.System Runtime
if [ ! -f "${target_root}/usr/lib/libmeoui.so.0" ] \
  || [ ! -f "${target_root}/usr/lib/qt6/qml/MeoUI/qmldir" ] \
  || [ ! -f "${target_root}/usr/lib/qt6/qml/Meo/System/libmeosystemplugin.so" ]; then
  echo "FAIL: Target MeoUI or Meo.System runtime is missing." >&2
  exit 5
fi

# 5. Verify Meo Desktop Payload
if [ ! -d "${target_root}/usr/share/plasma/look-and-feel/org.meo.desktop" ] \
  || [ ! -x "${target_root}/usr/bin/plasmalogin" ] \
  || [ ! -f "${target_root}/usr/lib/systemd/system/plasmalogin.service" ]; then
  echo "FAIL: Target Meo Desktop theme or Plasma Login Manager is missing." >&2
  exit 6
fi

# 6. Verify OmniStore Provisioning Payload
if [ ! -d "${target_root}/opt/meo-desktop" ] || [ ! -f "${target_root}/usr/share/pixmaps/meoarch-logo.svg" ]; then
  echo "FAIL: Target branding or OmniStore desktop payload is missing." >&2
  exit 7
fi

# 7. Verify cross-application dynamic color and input-method integration.
if [ ! -x "${target_root}/usr/bin/meo-dynamic-colors" ] \
  || [ ! -x "${target_root}/usr/bin/meo-input-method" ] \
  || [ ! -f "${target_root}/etc/environment.d/90-meo-applications.conf" ] \
  || [ ! -f "${target_root}/usr/lib/systemd/user/meo-dynamic-colors.path" ] \
  || [ ! -L "${target_root}/usr/lib/systemd/user/default.target.wants/meo-dynamic-colors.path" ] \
  || [ ! -f "${target_root}/usr/share/fcitx5/themes/MeoInputMethod-Light/theme.conf" ] \
  || [ ! -f "${target_root}/usr/share/meo-desktop/input-method/ibus/gtk.css.in" ]; then
  echo "FAIL: Target dynamic color, application, or input-method integration is missing." >&2
  exit 8
fi

if [ -d "${target_root}/usr/share/plasma/plasmoids/org.meo.shelf" ] \
  || [ ! -d "${target_root}/usr/share/plasma/plasmoids/org.meo.topbar" ] \
  || [ ! -d "${target_root}/usr/share/plasma/plasmoids/org.meo.timecenter" ]; then
  echo "FAIL: Target Plasma shell payload does not match the native-Dock layout." >&2
  exit 9
fi

# 9. Verify the system and Live repair application share the installed payload.
if [ ! -x "${target_root}/usr/bin/meoarch-repair" ] \
  || [ ! -f "${target_root}/usr/lib/meoarch-repair/qml/Main.qml" ] \
  || [ ! -x "${target_root}/usr/lib/meoarch-repair/checks/all.sh" ] \
  || [ ! -x "${target_root}/usr/lib/meoarch-repair/actions/rebuild-initramfs.sh" ] \
  || [ ! -f "${target_root}/usr/share/applications/org.meo.repair.desktop" ]; then
  echo "FAIL: Target MeoArch Quick Repair payload is missing." >&2
  exit 10
fi

echo "PASS: All post-install target system validation checks passed successfully for ${target_root}!"
