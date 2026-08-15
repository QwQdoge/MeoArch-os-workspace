#!/usr/bin/env bash
# Automated Post-Install Target System Validator for MeoArch OS

set -euo pipefail

target_root="${1:-/mnt}"

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
  || [ ! -f "${target_root}/etc/sddm.conf.d/20-meoarch.conf" ]; then
  echo "FAIL: Target Meo Desktop theme or SDDM configuration is missing." >&2
  exit 6
fi

# 6. Verify OmniStore Provisioning Payload
if [ ! -d "${target_root}/opt/meo-desktop" ] || [ ! -f "${target_root}/usr/share/pixmaps/meoarch-logo.svg" ]; then
  echo "FAIL: Target branding or OmniStore desktop payload is missing." >&2
  exit 7
fi

echo "PASS: All post-install target system validation checks passed successfully for ${target_root}!"
