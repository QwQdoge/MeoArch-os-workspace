#!/usr/bin/env bash
set -u -o pipefail

echo "[graphics] PCI display devices"
if command -v lspci >/dev/null 2>&1; then
  lspci -nnk 2>&1 | grep -A4 -Ei 'VGA|3D controller|Display controller' || true
fi

echo "[graphics] DRM nodes"
find /dev/dri -maxdepth 1 -type c -print 2>/dev/null || true
if [ ! -e /dev/dri/card0 ] && [ ! -e /dev/dri/renderD128 ]; then
  echo "MEO_FINDING|warning|graphics.no_drm_device|No DRM graphics device node is available."
fi

echo "[graphics] loaded modules"
lsmod 2>&1 | grep -E '^(amdgpu|i915|xe|nouveau|nvidia)[[:space:]]' || true

echo "[graphics] kernel warnings"
journalctl -b -k -p warning..alert --no-pager 2>/dev/null \
  | grep -Ei 'drm|gpu|amdgpu|i915|xe|nouveau|nvidia' | tail -n 120 || true
