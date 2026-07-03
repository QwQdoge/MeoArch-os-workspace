#!/usr/bin/env bash
set -euo pipefail

config="Release"
build_dir="out/build/showcase"
install_dir="out/install/showcase"
qt_prefix=""
do_install=0
do_run=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --config)
      config="$2"
      shift 2
      ;;
    --build-dir)
      build_dir="$2"
      shift 2
      ;;
    --install-dir)
      install_dir="$2"
      shift 2
      ;;
    --qt-prefix)
      qt_prefix="$2"
      shift 2
      ;;
    --install)
      do_install=1
      shift
      ;;
    --run)
      do_run=1
      shift
      ;;
    -h|--help)
      echo "Usage: $0 [--config Release] [--build-dir DIR] [--install-dir DIR] [--qt-prefix DIR] [--install] [--run]"
      exit 0
      ;;
    *)
      echo "Unknown option: $1" >&2
      exit 2
      ;;
  esac
done

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
source_dir="$(cd -- "$script_dir/.." && pwd)"

if ! command -v cmake >/dev/null 2>&1; then
  echo "cmake was not found on PATH. Install CMake and Qt, or source the Qt environment first." >&2
  exit 127
fi

if [[ "$build_dir" != /* ]]; then
  build_dir="$source_dir/$build_dir"
fi
if [[ "$install_dir" != /* ]]; then
  install_dir="$source_dir/$install_dir"
fi

configure_args=(-S "$source_dir" -B "$build_dir" "-DCMAKE_BUILD_TYPE=$config")
if [[ -n "$qt_prefix" ]]; then
  configure_args+=("-DCMAKE_PREFIX_PATH=$qt_prefix")
fi

cmake "${configure_args[@]}"
cmake --build "$build_dir" --config "$config" --target MeoShowcaseDemo

if [[ "$do_install" -eq 1 ]]; then
  cmake --install "$build_dir" --config "$config" --prefix "$install_dir"
fi

if [[ "$do_run" -eq 1 ]]; then
  if [[ -x "$build_dir/MeoShowcaseDemo" ]]; then
    "$build_dir/MeoShowcaseDemo"
  elif [[ -x "$build_dir/$config/MeoShowcaseDemo" ]]; then
    "$build_dir/$config/MeoShowcaseDemo"
  else
    echo "Could not find MeoShowcaseDemo in $build_dir" >&2
    exit 1
  fi
fi
