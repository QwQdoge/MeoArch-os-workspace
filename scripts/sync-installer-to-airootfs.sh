#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
airootfs="${repo_root}/MeoArch os/airootfs"
installer_src="${repo_root}/installer"
installer_dst="${airootfs}/opt/meoarch-installer"
meoui_dst="${airootfs}/opt/meo-ui/qml/MeoUI"

install -d "${meoui_dst}"
rm -rf "${meoui_dst}/components" "${meoui_dst}/patterns" "${meoui_dst}/widgets"
cp -a "${repo_root}/themes/MeoUI/components" "${meoui_dst}/components"
cp -a "${repo_root}/themes/MeoUI/patterns" "${meoui_dst}/patterns"
cp -a "${repo_root}/themes/MeoUI/widgets" "${meoui_dst}/widgets"
install -Dm644 "${repo_root}/themes/MeoUI/MeoTheme.qml" "${meoui_dst}/MeoTheme.qml"
install -Dm644 "${repo_root}/themes/MeoUI/MeoWindowMetrics.qml" "${meoui_dst}/MeoWindowMetrics.qml"

rm -rf "${installer_dst}"
install -d "${installer_dst}"
cp -a "${installer_src}/qml" "${installer_dst}/qml"
cp -a "${installer_src}/backend" "${installer_dst}/backend"
cp -a "${installer_src}/data" "${installer_dst}/data"
cp -a "${installer_src}/app" "${installer_dst}/app"
install -Dm644 "${installer_src}/CMakeLists.txt" "${installer_dst}/CMakeLists.txt"
cp -a "${repo_root}/assets" "${installer_dst}/assets"
find "${installer_dst}/backend" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod 755 {} +
find "${installer_dst}/data" -type f -exec chmod 644 {} +

native_binary="${MEOARCH_INSTALLER_NATIVE_BINARY:-${repo_root}/build/installer-host/meoarch-installer-app}"
if [ -x "${native_binary}" ]; then
  install -Dm755 "${native_binary}" "${installer_dst}/bin/meoarch-installer-app"
else
  echo "Compiled installer host not found; ISO will use qml6 from qt6-declarative." >&2
fi

install -Dm755 "${installer_src}/bin/meoarch-installer" \
  "${airootfs}/usr/local/bin/meoarch-installer"
install -Dm755 "${installer_src}/bin/meoarch-installer-kiosk" \
  "${airootfs}/usr/local/bin/meoarch-installer-kiosk"
