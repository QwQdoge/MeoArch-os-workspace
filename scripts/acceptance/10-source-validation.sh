#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/acceptance/10-source-validation.sh

Run source validation and retain its log/status under
validation/<UTC-run-id>/source. The default run directory is global output.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
  "")
    ;;
  *)
    usage >&2
    exit 2
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
projects_root="$(cd "${repo_root}/.." && pwd)"
meoui_source="${MEOUI_SOURCE_DIR:-${projects_root}/meo-ui}"
if [ ! -f "${meoui_source}/CMakeLists.txt" ] && [ -f "${projects_root}/MeoUI/CMakeLists.txt" ]; then
  meoui_source="${projects_root}/MeoUI"
fi
default_outputs_root="${MEO_OUTPUT_ROOT:-${projects_root}/outputs}/meo-arch-os-workspace"
outputs_root="${MEOARCH_OUTPUT_ROOT:-${default_outputs_root}}"
if [ -n "${MEOARCH_RUN_DIR:-}" ]; then
  run_dir="${MEOARCH_RUN_DIR}"
else
  run_id="${MEOARCH_RUN_ID:-$(date -u +%Y-%m-%dT%H%M%SZ)-acceptance}"
  run_dir="${outputs_root}/validation/${run_id}"
fi
evidence_dir="${run_dir}/source"
mkdir -p "${evidence_dir}"
exec > >(tee "${evidence_dir}/source-validation.log") 2>&1
cd "${repo_root}"
python_command=""
for candidate in python3 python; do
  if command -v "${candidate}" >/dev/null 2>&1; then
    python_command="${candidate}"
    break
  fi
done
[ -n "${python_command}" ] || { echo "Missing Python 3 interpreter." >&2; exit 127; }

required=(
  meoarch-os/profiledef.sh
  meoarch-os/packages.x86_64
  meoarch-os/grub/themes/meoarch/theme.txt
  meoarch-os/grub/themes/meoarch/brand.png
  meoarch-os/grub/themes/meoarch/meoarch-sans-regular-24.pf2
  meoarch-os/grub/themes/meoarch/meoarch-sans-bold-24.pf2
  installer/qml/Main.qml
  repair/qml/Main.qml
  repair/CMakeLists.txt
  repair/checks/all.sh
  repair/actions/rebuild-initramfs.sh
  installer/app/repaircontroller.cpp
  installer/data/account.env.example
  installer/data/application-catalog.json
  installer/data/package-catalog.json
  installer/translations/meoarch_zh_CN.ts
  installer/backend/generate-config.py
  scripts/sync-installer-to-airootfs.sh
  scripts/verify-staging-provenance.sh
  scripts/verify-target-install.sh
)
for path in "${required[@]}"; do
  [ -f "${path}" ] || { echo "Missing ${path}" >&2; exit 1; }
done
for path in \
  "${projects_root}/meo-kde/packaging/arch/PKGBUILD" \
  "${projects_root}/meo-kde/native/decoration/metadata.json" \
  "${projects_root}/meo-kde/native/application-style/src/meostyle.cpp" \
  "${projects_root}/meo-kde/native/dynamic-color/dynamiccolors.cpp" \
  "${meoui_source}/CMakeLists.txt"; do
  [ -f "${path}" ] || { echo "Missing external source: ${path}" >&2; exit 1; }
done

if find meoarch-os/airootfs -path '*/opt/meo-ui*' -print -quit | grep -q .; then
  echo "Obsolete /opt/meo-ui payload exists." >&2
  exit 1
fi
grep -q 'qt_add_qml_module(meoui_module' "${meoui_source}/CMakeLists.txt"
grep -A5 'qt_add_qml_module(meoui_module' "${meoui_source}/CMakeLists.txt" | grep -q 'SHARED'
grep -q 'SOVERSION 0' "${meoui_source}/CMakeLists.txt"
grep -q '"schemaVersion": 1' installer/data/default_selections.json
grep -q 'import Meo.System 1.0' installer/qml/pages/NetworkPage.qml
! rg -q 'readonly property var wifiNetworks' installer/qml/pages/NetworkPage.qml
! rg -q 'preview-disk' installer/app/installercontroller.cpp
grep -q 'for plasmoid in org.meo.topbar org.meo.timecenter; do' scripts/sync-installer-to-airootfs.sh
# The installed desktop owns the floating Meo Dock; it superseded the old
# hard-coded Icons-Only Task Manager layout checked here previously.
grep -q 'org.meo.dock starts as an independent Layer Shell surface' "${projects_root}/meo-kde/themes/look-and-feel/org.meo.desktop/contents/layouts/org.kde.plasma.desktop-layout.js"
grep -q 'meo-dynamic-colors.path' scripts/sync-installer-to-airootfs.sh
grep -q '90-meo-applications.conf' installer/backend/apply-target-customizations.sh
grep -q 'Target dynamic color, application, or input-method integration is missing' scripts/verify-target-install.sh
grep -q 'git archive --format=tar HEAD meoarch-os' scripts/build-iso.sh
grep -q 'declared sibling MeoKDE desktop assets' scripts/verify-staging-provenance.sh
grep -q '^lynis$' meoarch-os/packages.x86_64
grep -q '^qtkeychain-qt6$' meoarch-os/packages.x86_64
grep -q 'meoarch.mode=repair' meoarch-os/grub/grub.cfg
grep -q 'themes/meoarch/theme.txt' meoarch-os/grub/grub.cfg
grep -q 'Repair MeoArch OS' meoarch-os/grub/grub.cfg
grep -q 'selected_item_pixmap_style = "select_\*.png"' meoarch-os/grub/themes/meoarch/theme.txt
grep -q 'MeoArch Sans Bold 24' meoarch-os/grub/themes/meoarch/theme.txt
! rg -q 'AI Repair MeoArch OS|✨' meoarch-os/grub meoarch-os/efiboot meoarch-os/syslinux
grep -q '/usr/bin/meoarch-repair --live --kiosk' installer/bin/meoarch-installer-kiosk
grep -q 'QProcess::execute(repairProgram, forwarded)' installer/app/main.cpp
! rg -q 'RepairMain.qml' installer
grep -q 'EnvironmentFile=-/etc/meoarch/account.env' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^After=systemd-user-sessions.service systemd-logind.service seatd.service$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^Wants=NetworkManager.service seatd.service$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^Environment=XDG_RUNTIME_DIR=/run/meoarch-installer$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^RuntimeDirectory=meoarch-installer$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^RuntimeDirectoryMode=0700$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^WantedBy=graphical.target$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
! rg -q '^Before=getty@tty1.service$|^Conflicts=.*getty@tty1.service' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
test "$(readlink meoarch-os/airootfs/etc/systemd/system/getty@tty1.service)" = '/dev/null'
for unit in systemd-networkd.service systemd-networkd.socket systemd-networkd-varlink.socket systemd-networkd-varlink-metrics.socket systemd-networkd-resolve-hook.socket; do
  test "$(readlink "meoarch-os/airootfs/etc/systemd/system/${unit}")" = '/dev/null'
done
grep -q '^PLYMOUTH_COMMAND_TIMEOUT_SECONDS = 1$' installer/bin/meo-boot-status
for milestone in early storage services; do
  grep -q '^TimeoutStartSec=5s$' "installer/data/systemd/meo-boot-${milestone}.service"
done
! rg -q '^sddm$|^plasma-(desktop|workspace)$|^kwin$' meoarch-os/packages.x86_64
grep -q '^seatd$' meoarch-os/packages.x86_64
! test -e meoarch-os/airootfs/etc/systemd/system/display-manager.service
test "$(readlink meoarch-os/airootfs/etc/systemd/system/graphical.target.wants/meoarch-installer.service)" = '../meoarch-installer.service'
! test -e meoarch-os/airootfs/etc/systemd/system/multi-user.target.wants/meoarch-installer.service

duplicates="$(sed '/^[[:space:]]*#/d;/^[[:space:]]*$/d' meoarch-os/packages.x86_64 |
  sort | uniq -d)"
if [ -n "${duplicates}" ]; then
  echo "Duplicate packages:"
  echo "${duplicates}"
  exit 1
fi

"${python_command}" -m unittest discover -s installer/tests -v
find scripts installer repair -type f -name '*.sh' -print0 |
  xargs -0 -n1 bash -n
"${python_command}" - <<'PY'
import json
from pathlib import Path
for root in ("installer", "meoarch-os"):
    for path in Path(root).rglob("*.json"):
        with path.open(encoding="utf-8") as handle:
            json.load(handle)
PY
git diff --check
echo "PASS: source validation" | tee "${evidence_dir}/status.txt"
