#!/usr/bin/env bash
set -euo pipefail

export GDK_BACKEND=wayland
export XKB_DEFAULT_LAYOUT="${XKB_DEFAULT_LAYOUT:-us}"

exec cage -s -- meoarch-installer

