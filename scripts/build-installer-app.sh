#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_dir="${repo_root}/build/installer-host"
runtime_root="${repo_root}/build/installer-runtime-root"

case "${runtime_root}" in
  "${repo_root}/build/"*) ;;
  *) echo "Refusing unsafe installer runtime root: ${runtime_root}" >&2; exit 2 ;;
esac
if [ -L "${runtime_root}" ]; then
  echo "Refusing recursive replacement of symlink: ${runtime_root}" >&2
  exit 2
fi

if ! command -v cmake >/dev/null 2>&1 \
  || ! command -v ninja >/dev/null 2>&1 \
  || ! command -v pkg-config >/dev/null 2>&1 \
  || ! pkg-config --exists Qt6Core Qt6Gui Qt6Qml Qt6Quick Qt6Network; then
  echo "Qt 6 development libraries are required to build the installer runtime." >&2
  echo "The ISO staging contract requires the native installer host, MeoUI runtime, and repair payload; no qml6 fallback is supported." >&2
  exit 127
fi

cmake -S "${repo_root}/installer" -B "${build_dir}" -G Ninja -DCMAKE_BUILD_TYPE=Release
cmake --build "${build_dir}"
rm -rf "${runtime_root}"
DESTDIR="${runtime_root}" cmake --install "${build_dir}" --prefix /usr
