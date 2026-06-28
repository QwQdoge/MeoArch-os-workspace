#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
airootfs="${repo_root}/MeoArch os/airootfs"

install -Dm755 "${repo_root}/scripts/installer/meoarch_installer.py" \
  "${airootfs}/opt/meoarch-installer/meoarch_installer.py"
install -Dm755 "${repo_root}/MeoArch os/airootfs/usr/local/bin/meoarch-installer" \
  "${airootfs}/usr/local/bin/meoarch-installer"
install -Dm755 "${repo_root}/MeoArch os/airootfs/usr/local/bin/meoarch-installer-kiosk" \
  "${airootfs}/usr/local/bin/meoarch-installer-kiosk"

