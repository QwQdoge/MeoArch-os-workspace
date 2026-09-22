#!/usr/bin/env bash
set -u -o pipefail

echo "[graphics] PCI display devices and active drivers"
if command -v lspci >/dev/null 2>&1; then
  gpu_pci="$(lspci -nnk 2>&1 | grep -A4 -Ei 'VGA|3D controller|Display controller' || true)"
  printf '%s\n' "${gpu_pci}"
  driver_lines="$(printf '%s\n' "${gpu_pci}" | sed -n 's/^[[:space:]]*Kernel driver in use:[[:space:]]*/Kernel driver in use: /p')"
  if [ -n "${driver_lines}" ]; then
    printf '%s\n' "${driver_lines}"
  else
    echo "No active PCI graphics kernel driver was reported by lspci."
  fi
else
  gpu_pci=""
  echo "lspci is unavailable."
fi

echo "[graphics] DRM nodes"
find /dev/dri -maxdepth 1 -type c -printf '%f\n' 2>/dev/null | sort || true
render_count="$(find /dev/dri -maxdepth 1 -type c -name 'renderD*' 2>/dev/null | wc -l)"
printf 'DRM render nodes: %s\n' "${render_count}"
if [ ! -e /dev/dri/card0 ] && [ ! -e /dev/dri/renderD128 ]; then
  echo "MEO_FINDING|warning|graphics.no_drm_device|No DRM graphics device node is available."
fi

echo "[graphics] loaded modules"
loaded_gpu_modules="$(lsmod 2>&1 | grep -E '^(amdgpu|radeon|i915|xe|nouveau|nvidia|nvidia_drm)[[:space:]]' || true)"
printf '%s\n' "${loaded_gpu_modules:-No common GPU kernel module is currently listed.}"

if grep -Eqi 'NVIDIA' <<<"${gpu_pci}"; then
  if lsmod | grep -q '^nvidia[[:space:]]'; then
    echo "NVIDIA proprietary kernel module: loaded"
  elif lsmod | grep -q '^nouveau[[:space:]]'; then
    echo "NVIDIA GPU is using the Nouveau kernel driver."
  else
    echo "MEO_FINDING|info|graphics.nvidia_module_not_loaded|An NVIDIA GPU was detected but the proprietary NVIDIA module is not loaded."
  fi
  if [ -r /sys/module/nvidia_drm/parameters/modeset ]; then
    modeset="$(cat /sys/module/nvidia_drm/parameters/modeset 2>/dev/null || true)"
    printf 'NVIDIA DRM modeset: %s\n' "${modeset:-unknown}"
    if ! grep -Eq '^[Yy1]$' <<<"${modeset}"; then
      echo "MEO_FINDING|warning|graphics.nvidia_drm_modeset_disabled|NVIDIA DRM kernel modesetting is disabled. Wayland may not start correctly."
    fi
  fi
fi

if grep -Eqi 'AMD|ATI' <<<"${gpu_pci}"; then
  if lsmod | grep -Eq '^(amdgpu|radeon)[[:space:]]'; then
    echo "AMD graphics kernel module: loaded"
  else
    echo "AMD graphics hardware was detected, but no amdgpu/radeon module is listed."
  fi
fi

if grep -Eqi 'Intel.*(Graphics|VGA|Display)|VGA.*Intel|Display controller.*Intel' <<<"${gpu_pci}"; then
  if lsmod | grep -Eq '^(i915|xe)[[:space:]]'; then
    echo "Intel graphics kernel module: loaded"
  else
    echo "Intel graphics hardware was detected, but no i915/xe module is listed."
  fi
fi

echo "[graphics] session"
printf 'XDG session type: %s\n' "${XDG_SESSION_TYPE:-unknown}"
printf 'Wayland display: %s\n' "${WAYLAND_DISPLAY:-none}"
printf 'Display socket: %s\n' "${DISPLAY:-none}"

echo "[graphics] kernel warnings"
journalctl -b -k -p warning..alert --no-pager 2>/dev/null \
  | grep -Ei 'drm|gpu|amdgpu|radeon|i915|xe|nouveau|nvidia' | tail -n 120 || true
