#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${repo_root}/build/installer-host"

if ! command -v cmake >/dev/null 2>&1 \
  || ! command -v ninja >/dev/null 2>&1 \
  || ! command -v pkg-config >/dev/null 2>&1 \
  || ! pkg-config --exists Qt6Core Qt6Gui Qt6Qml Qt6Quick Qt6Network; then
  echo "Qt 6 development libraries are not available on this build machine." >&2
  echo "Skipping the optional native host; the ISO will use qml6 from qt6-declarative." >&2
  rm -f "${build_dir}/meoarch-installer-app"
  exit 0
fi

cmake -S "${repo_root}/installer" -B "${build_dir}" -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build "${build_dir}"
