#!/usr/bin/env bash
set -euo pipefail

export QT_QPA_PLATFORM="${QT_QPA_PLATFORM:-wayland}"
export XKB_DEFAULT_LAYOUT="${XKB_DEFAULT_LAYOUT:-us}"

exec cage -s -- meoarch-installer
