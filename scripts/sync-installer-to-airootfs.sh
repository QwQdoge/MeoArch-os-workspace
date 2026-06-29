#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
airootfs="${repo_root}/MeoArch os/airootfs"
installer_src="${repo_root}/installer"
installer_dst="${airootfs}/opt/meoarch-installer"

rm -rf "${installer_dst}"
install -d "${installer_dst}"
cp -a "${installer_src}/qml" "${installer_dst}/qml"
install -Dm644 "${repo_root}/themes/MeoUI/MeoTheme.qml" \
  "${installer_dst}/qml/MeoTheme.qml"
cp -a "${installer_src}/backend" "${installer_dst}/backend"
cp -a "${installer_src}/data" "${installer_dst}/data"
cp -a "${repo_root}/assets" "${installer_dst}/assets"
find "${installer_dst}/backend" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod 755 {} +
find "${installer_dst}/data" -type f -exec chmod 644 {} +

install -Dm755 "${installer_src}/bin/meoarch-installer" \
  "${airootfs}/usr/local/bin/meoarch-installer"
install -Dm755 "${installer_src}/bin/meoarch-installer-kiosk" \
  "${airootfs}/usr/local/bin/meoarch-installer-kiosk"
