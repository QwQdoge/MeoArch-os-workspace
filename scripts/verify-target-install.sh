#!/usr/bin/env bash
# Post-install validator for a package-managed MeoArch OS target.

set -euo pipefail

target_root="${1:-/mnt}"

exec python3 "$(dirname -- "${BASH_SOURCE[0]}")/../installer/backend/verify-target.py" "$target_root"
