#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_DIR="${MEO_UI_SOURCE_DIR:-${SCRIPT_DIR}}"

if [[ ! -f "${SOURCE_DIR}/CMakeLists.txt" && -f "${SCRIPT_DIR}/../CMakeLists.txt" ]]; then
    SOURCE_DIR="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
fi

BUILD_DIR="${MEO_UI_BUILD_DIR:-${SOURCE_DIR}/out/build/showcase-linux}"
QT_PREFIX="${MEO_UI_QT_PREFIX:-}"

if [[ "$(uname -s)" != "Linux" ]]; then
    echo "error: this launcher only supports Linux" >&2
    exit 1
fi

if ! command -v cmake >/dev/null 2>&1; then
    echo "error: cmake was not found. Install CMake and Qt 6 first." >&2
    exit 127
fi

configure_args=(-S "${SOURCE_DIR}" -B "${BUILD_DIR}" -DCMAKE_BUILD_TYPE=Release)
if [[ -n "${QT_PREFIX}" ]]; then
    configure_args+=("-DCMAKE_PREFIX_PATH=${QT_PREFIX}")
fi

cmake "${configure_args[@]}"
cmake --build "${BUILD_DIR}" --target MeoShowcaseDemo

if [[ -x "${BUILD_DIR}/MeoShowcaseDemo" ]]; then
    exec "${BUILD_DIR}/MeoShowcaseDemo"
fi

echo "error: build finished but MeoShowcaseDemo was not found in ${BUILD_DIR}" >&2
exit 1
