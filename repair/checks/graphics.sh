#!/usr/bin/env bash
set -u -o pipefail

echo "[graphics] PCI display devices"
if command -v lspci >/dev/null 2>&1; then
  gpu_pci="$(lspci -nnk 2>&1 | grep -A4 -Ei 'VGA|3D controller|Display controller' || true)"
  printf '%s\n' "${gpu_pci}"
else
  gpu_pci=""
fi

echo "[graphics] DRM nodes"
find /dev/dri -maxdepth 1 -type c -print 2>/dev/null || true
if [ ! -e /dev/dri/card0 ] && [ ! -e /dev/dri/renderD128 ]; then
  echo "MEO_FINDING|warning|graphics.no_drm_device|No DRM graphics device node is available."
fi

echo "[graphics] loaded modules"
lsmod 2>&1 | grep -E '^(amdgpu|i915|xe|nouveau|nvidia)[[:space:]]' || true

if grep -Eqi 'NVIDIA' <<<"${gpu_pci}"; then
  if ! lsmod | grep -q '^nvidia[[:space:]]'; then
    echo "MEO_FINDING|info|graphics.nvidia_module_not_loaded|An NVIDIA GPU was detected but the proprietary NVIDIA module is not loaded."
  fi
  if [ -r /sys/module/nvidia_drm/parameters/modeset ] \
     && ! grep -Eq '^[Yy1]$' /sys/module/nvidia_drm/parameters/modeset; then
    echo "MEO_FINDING|warning|graphics.nvidia_drm_modeset_disabled|NVIDIA DRM kernel modesetting is disabled. Wayland may not start correctly."
  fi
fi

echo "[graphics] kernel warnings"
journalctl -b -k -p warning..alert --no-pager 2>/dev/null \
  | grep -Ei 'drm|gpu|amdgpu|i915|xe|nouveau|nvidia' | tail -n 120 || true
