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
  meoarch-os/grub/themes/meoarch/generate-assets.sh
  meoarch-os/grub/themes/meoarch/brand.png
  meoarch-os/grub/themes/meoarch/meoarch-sans-regular-24.pf2
  meoarch-os/grub/themes/meoarch/meoarch-sans-bold-24.pf2
  installer/qml/Main.qml
  installer/live-system/CMakeLists.txt
  installer/live-system/meosystemliveplugin.cpp
  installer/live-system/qmldir
  repair/qml/Main.qml
  repair/CMakeLists.txt
  repair/core/agentstate.h
  repair/core/capabilityregistry.h
  repair/core/sessionjournal.h
  repair/docs/security-architecture.md
  repair/tests/core-contract-test.cpp
  repair/checks/all.sh
  repair/checks/audio.sh
  repair/checks/display.sh
  repair/actions/rebuild-initramfs.sh
  repair/live-actions/rebuild-initramfs.sh
  repair/data/org.meo.repair.policy
  repair/data/org.meo.Repair1.conf
  repair/data/org.meo.Repair1.service
  repair/data/meoarch-repair-privileged.service
  repair/privileged/privilegedrepairservice.cpp
  repair/privileged/privilegedrepairservice.h
  repair/data/org.meo.repair-live.policy
  repair/data/org.meo.repair-live.rules
  repair/knowledge/manifest.json
  repair/knowledge/system-prompt.md
  repair/knowledge/audio-output.json
  repair/knowledge/display-output.json
  installer/app/repaircontroller.cpp
  installer/data/account.env.example
  installer/data/application-catalog.json
  installer/data/package-catalog.json
  assets/wallpapers/installer_background.png
  installer/translations/meoarch_zh_CN.ts
  installer/backend/generate-config.py
  installer/bin/meoarch-repair-session
  scripts/sync-installer-to-airootfs.sh
  scripts/build-installer-app.sh
  scripts/verify-staging-provenance.sh
  scripts/verify-target-install.sh
)
for path in "${required[@]}"; do
  [ -f "${path}" ] || { echo "Missing ${path}" >&2; exit 1; }
done
for helper in Installation_guide choose-mirror livecd-sound; do
  helper_path="meoarch-os/airootfs/usr/local/bin/${helper}"
  [ -f "${helper_path}" ] || { echo "Missing ArchISO live helper: ${helper_path}" >&2; exit 1; }
  git ls-files --error-unmatch "${helper_path}" >/dev/null || {
    echo "ArchISO live helper is not version controlled: ${helper_path}" >&2
    exit 1
  }
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
# Plasma's native task manager is the sole floating Dock. Meo owns its theme
# geometry and dynamic colour, not a second task/window model.
grep -q 'bottomPanel.addWidget("org.kde.plasma.icontasks")' "${projects_root}/meo-kde/themes/look-and-feel/org.meo.desktop/contents/layouts/org.kde.plasma.desktop-layout.js"
grep -q 'DockImplementation=native' "${projects_root}/meo-kde/defaults/plasma/meo-shellrc"
! rg -q 'data/autostart/org.meo.dock.desktop' "${projects_root}/meo-kde/packaging/arch/PKGBUILD"
grep -q 'meo-dynamic-colors.path' scripts/sync-installer-to-airootfs.sh
grep -q 'meo-weather-refresh' scripts/sync-installer-to-airootfs.sh
grep -q 'preflight-meo-repository.sh.*0:0:755' meoarch-os/profiledef.sh
grep -q 'configure-meo-repository.sh.*0:0:755' meoarch-os/profiledef.sh
grep -q '90-meo-applications.conf' installer/backend/apply-target-customizations.sh
grep -q 'Target dynamic color, application, or input-method integration is missing' scripts/verify-target-install.sh
grep -q 'git archive --format=tar HEAD meoarch-os' scripts/build-iso.sh
grep -q -- '--acceptance' scripts/build-iso.sh
grep -q 'Refusing acceptance SSH instrumentation without --acceptance' scripts/build-iso.sh
grep -q 'Acceptance ISO output must be isolated under' scripts/build-iso.sh
grep -q 'realpath -m -- "${out_dir}"' scripts/build-iso.sh
grep -q 'packages/iso/acceptance/' scripts/acceptance/30-build-iso.sh
grep -q 'declared sibling MeoKDE desktop assets' scripts/verify-staging-provenance.sh
grep -q '^ExecStart=/usr/local/bin/choose-mirror$' meoarch-os/airootfs/etc/systemd/system/choose-mirror.service
grep -q '^ExecStart=/usr/local/bin/livecd-sound -u$' meoarch-os/airootfs/etc/systemd/system/livecd-alsa-unmuter.service
grep -q '^ExecStart=/usr/local/bin/livecd-sound -p$' meoarch-os/airootfs/etc/systemd/system/livecd-talk.service
grep -q 'NetworkManager' meoarch-os/airootfs/etc/motd
grep -q 'nmcli' meoarch-os/airootfs/etc/motd
! grep -q 'wiki.archlinux.org/title/Installation_guide' meoarch-os/airootfs/etc/motd
! grep -q 'iwctl' meoarch-os/airootfs/etc/motd
! rg -q 'installer\.py' meoarch-os installer/bin scripts/sync-installer-to-airootfs.sh scripts/verify-staging-provenance.sh
! rg -q 'meoarch-installer-live' meoarch-os installer/bin scripts/sync-installer-to-airootfs.sh scripts/verify-staging-provenance.sh
! test -e meoarch-os/airootfs/etc/xdg/autostart/meoarch-installer.desktop
! test -e meoarch-os/airootfs/etc/sudoers.d/10-meoarch-live-installer
! rg -q '10-meoarch-live-installer' meoarch-os/profiledef.sh
grep -q 'native installer host, MeoUI runtime, and repair payload' scripts/build-installer-app.sh
! rg -q 'qml6 fallback|optional native host' scripts/build-installer-app.sh scripts/sync-installer-to-airootfs.sh
grep -q '^lynis$' meoarch-os/packages.x86_64
grep -q '^qtkeychain-qt6$' meoarch-os/packages.x86_64
grep -q '^polkit-qt6$' meoarch-os/packages.x86_64
for package_name in curl gnupg openssl; do
  grep -q "^${package_name}$" meoarch-os/packages.x86_64
done
! grep -q '^konsole$' meoarch-os/packages.x86_64
for package_name in alsa-utils pipewire-audio pipewire-pulse wireplumber; do
  grep -q "^${package_name}$" meoarch-os/packages.x86_64
  grep -q "\"${package_name}\"" installer/backend/generate-config.py
done
! grep -q '^libplasma$' meoarch-os/packages.x86_64
grep -q 'MEO_KDE_SOURCE_DIR' installer/live-system/CMakeLists.txt
grep -q 'systemstatehub.cpp' installer/live-system/CMakeLists.txt
grep -q 'qmlRegisterSingletonType<SystemStateHub>' installer/live-system/meosystemliveplugin.cpp
grep -q 'runDiagnosticCommand' installer/app/installercontroller.cpp
grep -q '#include <KLocalizedQmlContext>' installer/app/main.cpp
grep -q 'KLocalization::setupLocalizedContext(&engine)' installer/app/main.cpp
! rg -q 'KLocalizedContext' installer/app/main.cpp
! rg -q 'openDebugTerminal|debugTerminalAvailable|debugTerminalMessage' installer/app
grep -q 'openDiagnosticTty' installer/app/repaircontroller.cpp
grep -q 'TTYPath=/dev/tty3' installer/app/repaircontroller.cpp
grep -q 'structured_diagnostic_findings' installer/app/repaircontroller.cpp
grep -q 'actionSupportedByEvidence' installer/app/repaircontroller.cpp
grep -q 'org.meo.repair-plan-binding/v1' installer/app/repaircontroller.cpp
grep -q 'dispatchPrivilegedServiceAction' installer/app/repaircontroller.cpp
grep -q 'checkAuthorizationSync' repair/privileged/privilegedrepairservice.cpp
! rg -q 'Execute\(|RunCommand|commandArgument|programArgument' repair/privileged
grep -q 'storage_destructive_repair' repair/core/capabilityregistry.cpp
grep -q 'State::WaitConfirm' repair/core/agentstate.cpp
grep -q 'm_displayRecoverySeconds = 15' installer/app/repaircontroller.cpp
grep -q 'import Meo.System 1.0' repair/qml/Main.qml
grep -q 'Never request an administrator password' repair/knowledge/system-prompt.md
grep -q 'wiki.archlinux.org/title/Installation_guide' installer/qml/PageFrame.qml
grep -q 'meoarch.mode=repair' meoarch-os/grub/grub.cfg
grep -q 'themes/meoarch/theme.txt' meoarch-os/grub/grub.cfg
grep -q 'Diagnostics and repair - no installation' meoarch-os/grub/grub.cfg
grep -q 'Diagnostics and repair - no installation' meoarch-os/grub/loopback.cfg
grep -q 'selected_item_pixmap_style = "select_\*.png"' meoarch-os/grub/themes/meoarch/theme.txt
! grep -q 'menu_pixmap_style = "panel_\*.png"' meoarch-os/grub/themes/meoarch/theme.txt
grep -q 'selected_item_color = "#FFFFFF"' meoarch-os/grub/themes/meoarch/theme.txt
grep -q 'assets/icons/Logo.svg' meoarch-os/grub/themes/meoarch/generate-assets.sh
grep -q 'syslinux/splash.png' meoarch-os/grub/themes/meoarch/generate-assets.sh
! grep -q -- '-annotate' meoarch-os/grub/themes/meoarch/generate-assets.sh
grep -q '#ff6750a4' meoarch-os/syslinux/archiso_head.cfg
grep -q '#ff49454f' meoarch-os/syslinux/archiso_head.cfg
grep -q 'display_text = f"ERROR: {title} - {message}"' installer/bin/meo-boot-status
grep -q 'MeoArch Sans Bold 24' meoarch-os/grub/themes/meoarch/theme.txt
grep -q 'Everything has a GUI. Every choice is yours.' meoarch-os/grub/themes/meoarch/theme.txt
grep -q 'Window.SetBackgroundTopColor(0.0, 0.0, 0.0)' themes/plymouth/meoarch/meoarch.script
grep -q 'logo_image = Image("logo.png")' themes/plymouth/meoarch/meoarch.script
grep -q 'logo_glow_image = logo_image.Scale' themes/plymouth/meoarch/meoarch.script
grep -q 'Math.Cos(frame_count \* 0.08)' themes/plymouth/meoarch/meoarch.script
! rg -q 'spinner_image|progress_bar_image|background.png' themes/plymouth/meoarch/meoarch.script
cmp -s themes/plymouth/meoarch/meoarch.script meoarch-os/airootfs/usr/share/plymouth/themes/meoarch/meoarch.script
! rg -q 'STAGE:' themes/plymouth/meoarch installer/bin/meo-boot-status
grep -q 'GRUB_TIMEOUT.*3' installer/backend/apply-target-customizations.sh
grep -q 'meo-session-actiond' scripts/sync-installer-to-airootfs.sh
grep -q 'org.meo.SessionAction1.service' installer/backend/verify-target.py
grep -Fq 'Ctrl+Meta+Delete' "${projects_root}/meo-kde/defaults/kde/kglobalshortcutsrc"
grep -q 'MeoHoldToConfirm' "${projects_root}/meo-kde/themes/look-and-feel/org.meo.desktop/contents/logout/Logout.qml"
! rg -q 'AI Repair MeoArch OS|✨' meoarch-os/grub meoarch-os/efiboot meoarch-os/syslinux
grep -q '/usr/local/bin/meoarch-repair-session' installer/bin/meoarch-installer-kiosk
grep -q '/usr/bin/meoarch-repair --live --kiosk' installer/bin/meoarch-repair-session
grep -q '/usr/lib/meo-polkit-agent &' installer/bin/meoarch-repair-session
grep -q 'org.kde.polkit-kde-authentication-agent-1' installer/bin/meoarch-repair-session
grep -q 'QProcess::execute(repairProgram, forwarded)' installer/app/main.cpp
! rg -q 'RepairMain.qml' installer
grep -q 'EnvironmentFile=-/etc/meoarch/account.env' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^After=systemd-user-sessions.service systemd-logind.service seatd.service$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^Wants=NetworkManager.service seatd.service$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^StartLimitIntervalSec=30s$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^StartLimitBurst=3$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^Environment=XDG_RUNTIME_DIR=/run/meoarch-installer$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^RuntimeDirectory=meoarch-installer$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^RuntimeDirectoryMode=0700$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^ExecStartPre=/usr/bin/usermod -aG audio,seat,tty live$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^ExecStartPre=/usr/bin/install -m 0600 -o root -g root /dev/null /run/meoarch-installer/production-capability$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '^WantedBy=graphical.target$' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
grep -q '/usr/bin/runuser -u live' installer/bin/meoarch-installer-kiosk
grep -q 'user-runtime-dir@${live_uid}.service' installer/bin/meoarch-installer-kiosk
grep -q 'subject.user === "live"' repair/data/org.meo.repair-live.rules
grep -q 'subject.local === true' repair/data/org.meo.repair-live.rules
grep -q 'subject.active === true' repair/data/org.meo.repair-live.rules
grep -q 'action.lookup("program") === fixedLiveActions\[action.id\]' repair/data/org.meo.repair-live.rules
grep -q 'action.lookup("user") === "root"' repair/data/org.meo.repair-live.rules
grep -q 'polkit.Result.YES' repair/data/org.meo.repair-live.rules
! grep -q 'org.meo.repair-live.rules' repair/CMakeLists.txt
! grep -q 'org.meo.repair-live.policy' repair/CMakeLists.txt
! rg -q '^Before=getty@tty1.service$|^Conflicts=.*getty@tty1.service' meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service
test "$(readlink meoarch-os/airootfs/etc/systemd/system/getty@tty1.service)" = '/dev/null'
for unit in systemd-networkd.service systemd-networkd.socket systemd-networkd-varlink.socket systemd-networkd-varlink-metrics.socket systemd-networkd-resolve-hook.socket; do
  test "$(readlink "meoarch-os/airootfs/etc/systemd/system/${unit}")" = '/dev/null'
done
grep -q '^PLYMOUTH_COMMAND_TIMEOUT_SECONDS = 1$' installer/bin/meo-boot-status
for milestone in early storage services; do
  grep -q '^TimeoutStartSec=5s$' "installer/data/systemd/meo-boot-${milestone}.service"
done
if rg -q -e '^sddm$' -e '^plasma-login-manager$' -e '^plasma-(desktop|workspace)$' -e '^kwin$' meoarch-os/packages.x86_64; then
  echo "Cage-only Live package profile includes a Plasma session component." >&2
  exit 1
fi
grep -q '^seatd
! test -e meoarch-os/airootfs/etc/systemd/system/display-manager.service
test "$(readlink meoarch-os/airootfs/etc/systemd/system/graphical.target.wants/meoarch-installer.service)" = '../meoarch-installer.service'
! test -e meoarch-os/airootfs/etc/systemd/system/multi-user.target.wants/meoarch-installer.service

grep -q "bootmodes=('bios.syslinux'" meoarch-os/profiledef.sh
grep -q "'uefi.grub')" meoarch-os/profiledef.sh
! grep -q "'uefi.systemd-boot'" meoarch-os/profiledef.sh
grep -q '^airootfs_image_type="squashfs"$' meoarch-os/profiledef.sh
expected_live_options='archisobasedir=%INSTALL_DIR% archisosearchuuid=%ARCHISO_UUID% meoarch.mode=install quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0 plymouth.enable=1'
bios_live_options="$(awk '/^LABEL arch$/ { label=1; next } label && /^APPEND / { sub(/^APPEND /, ""); print; exit }' meoarch-os/syslinux/archiso_sys-linux.cfg)"
uefi_live_options="$(awk '/^menuentry "Install MeoArch OS - graphical setup/ { entry=1; next } entry && /^[[:space:]]*linux / { sub(/^[[:space:]]*linux[[:space:]]+\/%INSTALL_DIR%\/boot\/%ARCH%\/vmlinuz-linux[[:space:]]+/, ""); print; exit }' meoarch-os/grub/grub.cfg)"
[ "${bios_live_options}" = "${expected_live_options}" ]
[ "${uefi_live_options}" = "${expected_live_options}" ]
expected_repair_options="${expected_live_options/meoarch.mode=install/meoarch.mode=repair}"
bios_repair_options="$(awk '/^LABEL archrepair$/ { label=1; next } label && /^APPEND / { sub(/^APPEND /, ""); print; exit }' meoarch-os/syslinux/archiso_sys-linux.cfg)"
uefi_repair_options="$(awk '/^menuentry "Diagnostics and repair - no installation/ { entry=1; next } entry && /^[[:space:]]*linux / { sub(/^[[:space:]]*linux[[:space:]]+\/%INSTALL_DIR%\/boot\/%ARCH%\/vmlinuz-linux[[:space:]]+/, ""); print; exit }' meoarch-os/grub/grub.cfg)"
[ "${bios_repair_options}" = "${expected_repair_options}" ]
[ "${uefi_repair_options}" = "${expected_repair_options}" ]
grep -q '^APPEND .*meoarch.mode=install accessibility=on$' meoarch-os/syslinux/archiso_sys-linux.cfg
for hook in base udev plymouth microcode modconf kms archiso block filesystems keyboard; do
  grep -Eq "(^|[[:space:]\\(])${hook}([[:space:]\\)])" meoarch-os/airootfs/etc/mkinitcpio.conf.d/archiso.conf
done

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
 meoarch-os/packages.x86_64
grep -q '^networkmanager
! test -e meoarch-os/airootfs/etc/systemd/system/display-manager.service
test "$(readlink meoarch-os/airootfs/etc/systemd/system/graphical.target.wants/meoarch-installer.service)" = '../meoarch-installer.service'
! test -e meoarch-os/airootfs/etc/systemd/system/multi-user.target.wants/meoarch-installer.service

grep -q "bootmodes=('bios.syslinux'" meoarch-os/profiledef.sh
grep -q "'uefi.grub')" meoarch-os/profiledef.sh
! grep -q "'uefi.systemd-boot'" meoarch-os/profiledef.sh
grep -q '^airootfs_image_type="squashfs"$' meoarch-os/profiledef.sh
expected_live_options='archisobasedir=%INSTALL_DIR% archisosearchuuid=%ARCHISO_UUID% meoarch.mode=install quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0 plymouth.enable=1'
bios_live_options="$(awk '/^LABEL arch$/ { label=1; next } label && /^APPEND / { sub(/^APPEND /, ""); print; exit }' meoarch-os/syslinux/archiso_sys-linux.cfg)"
uefi_live_options="$(awk '/^menuentry "Install MeoArch OS - graphical setup/ { entry=1; next } entry && /^[[:space:]]*linux / { sub(/^[[:space:]]*linux[[:space:]]+\/%INSTALL_DIR%\/boot\/%ARCH%\/vmlinuz-linux[[:space:]]+/, ""); print; exit }' meoarch-os/grub/grub.cfg)"
[ "${bios_live_options}" = "${expected_live_options}" ]
[ "${uefi_live_options}" = "${expected_live_options}" ]
expected_repair_options="${expected_live_options/meoarch.mode=install/meoarch.mode=repair}"
bios_repair_options="$(awk '/^LABEL archrepair$/ { label=1; next } label && /^APPEND / { sub(/^APPEND /, ""); print; exit }' meoarch-os/syslinux/archiso_sys-linux.cfg)"
uefi_repair_options="$(awk '/^menuentry "Diagnostics and repair - no installation/ { entry=1; next } entry && /^[[:space:]]*linux / { sub(/^[[:space:]]*linux[[:space:]]+\/%INSTALL_DIR%\/boot\/%ARCH%\/vmlinuz-linux[[:space:]]+/, ""); print; exit }' meoarch-os/grub/grub.cfg)"
[ "${bios_repair_options}" = "${expected_repair_options}" ]
[ "${uefi_repair_options}" = "${expected_repair_options}" ]
grep -q '^APPEND .*meoarch.mode=install accessibility=on$' meoarch-os/syslinux/archiso_sys-linux.cfg
for hook in base udev plymouth microcode modconf kms archiso block filesystems keyboard; do
  grep -Eq "(^|[[:space:]\\(])${hook}([[:space:]\\)])" meoarch-os/airootfs/etc/mkinitcpio.conf.d/archiso.conf
done

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
 meoarch-os/packages.x86_64
grep -q '^wpa_supplicant
! test -e meoarch-os/airootfs/etc/systemd/system/display-manager.service
test "$(readlink meoarch-os/airootfs/etc/systemd/system/graphical.target.wants/meoarch-installer.service)" = '../meoarch-installer.service'
! test -e meoarch-os/airootfs/etc/systemd/system/multi-user.target.wants/meoarch-installer.service

grep -q "bootmodes=('bios.syslinux'" meoarch-os/profiledef.sh
grep -q "'uefi.grub')" meoarch-os/profiledef.sh
! grep -q "'uefi.systemd-boot'" meoarch-os/profiledef.sh
grep -q '^airootfs_image_type="squashfs"$' meoarch-os/profiledef.sh
expected_live_options='archisobasedir=%INSTALL_DIR% archisosearchuuid=%ARCHISO_UUID% meoarch.mode=install quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0 plymouth.enable=1'
bios_live_options="$(awk '/^LABEL arch$/ { label=1; next } label && /^APPEND / { sub(/^APPEND /, ""); print; exit }' meoarch-os/syslinux/archiso_sys-linux.cfg)"
uefi_live_options="$(awk '/^menuentry "Install MeoArch OS - graphical setup/ { entry=1; next } entry && /^[[:space:]]*linux / { sub(/^[[:space:]]*linux[[:space:]]+\/%INSTALL_DIR%\/boot\/%ARCH%\/vmlinuz-linux[[:space:]]+/, ""); print; exit }' meoarch-os/grub/grub.cfg)"
[ "${bios_live_options}" = "${expected_live_options}" ]
[ "${uefi_live_options}" = "${expected_live_options}" ]
expected_repair_options="${expected_live_options/meoarch.mode=install/meoarch.mode=repair}"
bios_repair_options="$(awk '/^LABEL archrepair$/ { label=1; next } label && /^APPEND / { sub(/^APPEND /, ""); print; exit }' meoarch-os/syslinux/archiso_sys-linux.cfg)"
uefi_repair_options="$(awk '/^menuentry "Diagnostics and repair - no installation/ { entry=1; next } entry && /^[[:space:]]*linux / { sub(/^[[:space:]]*linux[[:space:]]+\/%INSTALL_DIR%\/boot\/%ARCH%\/vmlinuz-linux[[:space:]]+/, ""); print; exit }' meoarch-os/grub/grub.cfg)"
[ "${bios_repair_options}" = "${expected_repair_options}" ]
[ "${uefi_repair_options}" = "${expected_repair_options}" ]
grep -q '^APPEND .*meoarch.mode=install accessibility=on$' meoarch-os/syslinux/archiso_sys-linux.cfg
for hook in base udev plymouth microcode modconf kms archiso block filesystems keyboard; do
  grep -Eq "(^|[[:space:]\\(])${hook}([[:space:]\\)])" meoarch-os/airootfs/etc/mkinitcpio.conf.d/archiso.conf
done

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
 meoarch-os/packages.x86_64
! test -e meoarch-os/airootfs/etc/systemd/system/multi-user.target.wants/iwd.service
! test -L meoarch-os/airootfs/etc/systemd/system/multi-user.target.wants/iwd.service
! test -e meoarch-os/airootfs/etc/systemd/system/display-manager.service
test "$(readlink meoarch-os/airootfs/etc/systemd/system/graphical.target.wants/meoarch-installer.service)" = '../meoarch-installer.service'
! test -e meoarch-os/airootfs/etc/systemd/system/multi-user.target.wants/meoarch-installer.service

grep -q "bootmodes=('bios.syslinux'" meoarch-os/profiledef.sh
grep -q "'uefi.grub')" meoarch-os/profiledef.sh
! grep -q "'uefi.systemd-boot'" meoarch-os/profiledef.sh
grep -q '^airootfs_image_type="squashfs"$' meoarch-os/profiledef.sh
expected_live_options='archisobasedir=%INSTALL_DIR% archisosearchuuid=%ARCHISO_UUID% meoarch.mode=install quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0 plymouth.enable=1'
bios_live_options="$(awk '/^LABEL arch$/ { label=1; next } label && /^APPEND / { sub(/^APPEND /, ""); print; exit }' meoarch-os/syslinux/archiso_sys-linux.cfg)"
uefi_live_options="$(awk '/^menuentry "Install MeoArch OS - graphical setup/ { entry=1; next } entry && /^[[:space:]]*linux / { sub(/^[[:space:]]*linux[[:space:]]+\/%INSTALL_DIR%\/boot\/%ARCH%\/vmlinuz-linux[[:space:]]+/, ""); print; exit }' meoarch-os/grub/grub.cfg)"
[ "${bios_live_options}" = "${expected_live_options}" ]
[ "${uefi_live_options}" = "${expected_live_options}" ]
expected_repair_options="${expected_live_options/meoarch.mode=install/meoarch.mode=repair}"
bios_repair_options="$(awk '/^LABEL archrepair$/ { label=1; next } label && /^APPEND / { sub(/^APPEND /, ""); print; exit }' meoarch-os/syslinux/archiso_sys-linux.cfg)"
uefi_repair_options="$(awk '/^menuentry "Diagnostics and repair - no installation/ { entry=1; next } entry && /^[[:space:]]*linux / { sub(/^[[:space:]]*linux[[:space:]]+\/%INSTALL_DIR%\/boot\/%ARCH%\/vmlinuz-linux[[:space:]]+/, ""); print; exit }' meoarch-os/grub/grub.cfg)"
[ "${bios_repair_options}" = "${expected_repair_options}" ]
[ "${uefi_repair_options}" = "${expected_repair_options}" ]
grep -q '^APPEND .*meoarch.mode=install accessibility=on$' meoarch-os/syslinux/archiso_sys-linux.cfg
for hook in base udev plymouth microcode modconf kms archiso block filesystems keyboard; do
  grep -Eq "(^|[[:space:]\\(])${hook}([[:space:]\\)])" meoarch-os/airootfs/etc/mkinitcpio.conf.d/archiso.conf
done

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
