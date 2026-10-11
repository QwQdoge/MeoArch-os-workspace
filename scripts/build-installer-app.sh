#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
build_root="${MEOARCH_BUILD_ROOT:-${repo_root}/build}"
build_root="$(realpath -m -- "${build_root}")"
outputs_tmp_root="$(realpath -m -- "${MEO_OUTPUT_ROOT:-${repo_root}/../outputs}/meo-arch-os-workspace/tmp")"
case "${build_root}" in
  "${repo_root}/build"|"${repo_root}/build/"*|"${outputs_tmp_root}/"*) ;;
  *) echo "Refusing unsafe installer build root: ${build_root}" >&2; exit 2 ;;
esac
build_dir="${build_root}/installer-host"
runtime_root="${build_root}/installer-runtime-root"

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

qml_cachegen_args=()
build_type=Release
if [ "${MEO_QT_QML_NO_CACHEGEN:-0}" = "1" ]; then
  qml_cachegen_args+=("-DQT_QML_NO_CACHEGEN=ON")
  build_type=Debug
fi
cmake -S "${repo_root}/installer" -B "${build_dir}" -G Ninja "-DCMAKE_BUILD_TYPE=${build_type}" "${qml_cachegen_args[@]}"
cmake --build "${build_dir}" --parallel "${MEO_BUILD_PARALLEL_LEVEL:-1}"
rm -rf "${runtime_root}"
DESTDIR="${runtime_root}" cmake --install "${build_dir}" --prefix /usr
