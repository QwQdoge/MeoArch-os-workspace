#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: scripts/acceptance/40-inspect-iso.sh [ISO_PATH]

Inspect an ISO and retain evidence in validation/<UTC-run-id>/iso. Extracted
SquashFS content is disposable and defaults to tmp/<UTC-run-id>/iso-inspect.
EOF
}

case "${1:-}" in
  -h|--help)
    usage
    exit 0
    ;;
esac

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
projects_root="$(cd "${repo_root}/.." && pwd)"
default_outputs_root="${MEO_OUTPUT_ROOT:-${projects_root}/outputs}/meo-arch-os-workspace"
outputs_root="${MEOARCH_OUTPUT_ROOT:-${default_outputs_root}}"
if [ -n "${MEOARCH_RUN_DIR:-}" ]; then
  run_dir="${MEOARCH_RUN_DIR}"
  run_id="${MEOARCH_RUN_ID:-$(basename "${run_dir}")}"
else
  run_id="${MEOARCH_RUN_ID:-$(date -u +%Y-%m-%dT%H%M%SZ)-acceptance}"
  run_dir="${outputs_root}/validation/${run_id}"
fi
tmp_dir="${MEOARCH_TMP_DIR:-${outputs_root}/tmp/${run_id}}"
evidence_dir="${run_dir}/iso"
extract_dir="${MEOARCH_ISO_EXTRACT_DIR:-${tmp_dir}/iso-inspect}"
mkdir -p "${evidence_dir}" "${extract_dir}"

iso_path="${1:-}"
if [ -z "${iso_path}" ] && [ -f "${evidence_dir}/iso-path.txt" ]; then
  iso_path="$(cat "${evidence_dir}/iso-path.txt")"
fi
[ -f "${iso_path}" ] || { echo "ISO not found: ${iso_path}" >&2; exit 1; }

xorriso -indev "${iso_path}" -find / -type f -exec lsdl |
  tee "${evidence_dir}/files.txt"
grep -Eiq '/EFI/BOOT/BOOTX64\.EFI' "${evidence_dir}/files.txt"
grep -q '/arch/x86_64/airootfs.sfs' "${evidence_dir}/files.txt"
# The Live ISO uses GRUB for UEFI and Syslinux for legacy BIOS. Validate the
# actual GRUB payload and its branded menu instead of stale systemd-boot files.
grep -q '/boot/grub/grub.cfg' "${evidence_dir}/files.txt"
grep -q '/boot/grub/themes/meoarch/theme.txt' "${evidence_dir}/files.txt"
grep -q '/boot/grub/themes/meoarch/brand.png' "${evidence_dir}/files.txt"
grep -q '/boot/grub/themes/meoarch/meoarch-sans-regular-24.pf2' "${evidence_dir}/files.txt"
if grep -q '/loader/entries/' "${evidence_dir}/files.txt"; then
  echo "UEFI GRUB ISO unexpectedly contains systemd-boot loader entries." >&2
  exit 1
fi

xorriso -osirrox on -indev "${iso_path}" \
  -extract /arch/x86_64/airootfs.sfs "${extract_dir}/airootfs.sfs"
xorriso -osirrox on -indev "${iso_path}" \
  -extract /arch/pkglist.x86_64.txt "${evidence_dir}/packages.txt"
unsquashfs -ll "${extract_dir}/airootfs.sfs" >"${evidence_dir}/airootfs-files.txt"
echo "Recorded $(wc -l <"${evidence_dir}/airootfs-files.txt") airootfs entries."

# libmeoui.so.0 is the ABI SONAME symlink; its implementation file is versioned.
grep -Eq 'usr/lib/libmeoui\.so\.0( -> libmeoui\.so\.[0-9.]+)?$' "${evidence_dir}/airootfs-files.txt"
grep -q 'usr/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so' "${evidence_dir}/airootfs-files.txt"
grep -q 'opt/meoarch-installer/qml/Main.qml' "${evidence_dir}/airootfs-files.txt"
grep -q 'opt/meoarch-installer/translations/meoarch_zh_CN.qm' "${evidence_dir}/airootfs-files.txt"
grep -q 'usr/lib/qt6/qml/Meo/System/libmeosystemplugin.so' "${evidence_dir}/airootfs-files.txt"
grep -q 'usr/lib/meoarch-repair/qml/Main.qml' "${evidence_dir}/airootfs-files.txt"
for path in \
  usr/share/meoarch-repair/knowledge/manifest.json \
  usr/share/meoarch-repair/knowledge/system-prompt.md \
  usr/share/meoarch-repair/knowledge/risk-review-prompt.md \
  usr/share/meoarch-repair/knowledge/system-general.json \
  usr/share/meoarch-repair/knowledge/audio-output.json \
  usr/share/meoarch-repair/knowledge/display-output.json \
  usr/share/meoarch-repair/knowledge/network-connectivity.json \
  usr/share/meoarch-repair/knowledge/boot-startup.json \
  usr/share/meoarch-repair/knowledge/package-health.json \
  usr/share/meoarch-repair/knowledge/storage-health.json \
  usr/share/meoarch-repair/knowledge/graphics-session.json \
  usr/share/meoarch-repair/knowledge/security-posture.json \
  usr/share/polkit-1/actions/org.meo.repair.policy \
  usr/share/polkit-1/actions/org.meo.repair-live.policy \
  usr/share/polkit-1/rules.d/49-meoarch-live-repair.rules \
  usr/lib/systemd/user/plasma-polkit-agent.service; do
  grep -q "${path}$" "${evidence_dir}/airootfs-files.txt"
done
grep -q 'opt/meo-desktop/themes/look-and-feel/org.meo.desktop/metadata.json' \
  "${evidence_dir}/airootfs-files.txt"
for package in plasma-desktop plasma-workspace plasma-login-manager kwin konsole plasma-nm plasma-pa alsa-utils cage networkmanager qtkeychain-qt6 lynis noto-fonts pipewire-audio pipewire-pulse wireplumber polkit-qt6; do
  grep -q "^${package} " "${evidence_dir}/packages.txt"
done
# Default Live desktop and optional Cage must both be present.
for live_path in \
  etc/plasmalogin.conf \
  etc/systemd/system/display-manager.service \
  etc/systemd/system/plasmalogin.service.d/20-meoarch-live.conf \
  etc/xdg/autostart/meoarch-live.desktop \
  usr/local/bin/meoarch-installer-live \
  usr/lib/meoarch/live-installer-authorize \
  usr/lib/systemd/user/meoarch-live-app.service \
  usr/share/polkit-1/actions/org.meo.installer-live.policy \
  usr/share/polkit-1/rules.d/49-meoarch-live-installer.rules \
  usr/share/plasma/look-and-feel/org.meo.desktop/metadata.json \
  opt/meoarch-installer/live-qml/Meo/System/libmeosystemplugin.so; do
  grep -q "${live_path}" "${evidence_dir}/airootfs-files.txt"
done
grep -q 'etc/systemd/system/display-manager.service -> /usr/lib/systemd/system/plasmalogin.service' \
  "${evidence_dir}/airootfs-files.txt"
grep -q 'etc/systemd/system/graphical.target.wants/meoarch-installer.service' \
  "${evidence_dir}/airootfs-files.txt"
grep -q 'etc/systemd/system/getty@tty1.service.d/meoarch-tty.conf' \
  "${evidence_dir}/airootfs-files.txt"
if grep -q 'etc/systemd/system/multi-user.target.wants/meoarch-installer.service' \
  "${evidence_dir}/airootfs-files.txt"; then
  echo "Optional Cage must not also start from multi-user.target." >&2
  exit 1
fi
if grep -q 'etc/sudoers.d/10-meoarch-live-installer' "${evidence_dir}/airootfs-files.txt"; then
  echo "Live Installer must not use general passwordless sudo." >&2
  exit 1
fi
for executable in \
  opt/meoarch-installer/bin/meoarch-installer-app \
  opt/meoarch-installer/backend/configure-meo-repository.sh \
  opt/meoarch-installer/backend/generate-config.py \
  opt/meoarch-installer/backend/preflight-meo-repository.sh \
  opt/meoarch-installer/backend/run-archinstall.sh \
  usr/bin/meoarch-repair \
  usr/lib/meoarch-repair/checks/all.sh \
  usr/lib/meoarch-repair/checks/audio.sh \
  usr/lib/meoarch-repair/checks/display.sh \
  usr/lib/meoarch-repair/live-actions/rebuild-initramfs.sh \
  usr/lib/meoarch-repair/live-actions/refresh-pacman-keyring.sh \
  usr/lib/meoarch-repair/live-actions/reload-systemd-manager.sh \
  usr/lib/meoarch-repair/live-actions/restart-network-manager.sh \
  usr/lib/meo-polkit-agent \
  usr/local/bin/meoarch-installer \
  usr/local/bin/meoarch-installer-kiosk \
  usr/local/bin/meoarch-installer-live \
  usr/lib/meoarch/live-installer-authorize \
  usr/local/bin/meoarch-repair-session; do
  grep -Eq "^-rwx[^[:space:]]*[[:space:]].*${executable}$" \
    "${evidence_dir}/airootfs-files.txt"
done
if grep -q 'opt/meo-ui/' "${evidence_dir}/airootfs-files.txt"; then
  echo "Obsolete /opt/meo-ui exists in ISO." >&2
  exit 1
fi

for path in \
  usr/lib/libmeoui.so.0 \
  usr/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so \
  opt/meoarch-installer/live-qml/Meo/System/libmeosystemplugin.so; do
  destination="${extract_dir}/$(basename "${path}")"
  unsquashfs -cat "${extract_dir}/airootfs.sfs" "${path}" >"${destination}"
done
# Keep stored ABI evidence in a stable language because the assertions below
# match readelf's labels and must not vary with the build host locale.
LC_ALL=C readelf -d "${extract_dir}/libmeoui.so.0" |
  tee "${evidence_dir}/libmeoui-readelf.txt"
LC_ALL=C readelf -d "${extract_dir}/libmeoui_moduleplugin.so" |
  tee "${evidence_dir}/plugin-readelf.txt"
LC_ALL=C readelf -d "${extract_dir}/libmeosystemplugin.so" |
  tee "${evidence_dir}/meosystem-plugin-readelf.txt"
grep -q 'Library soname: \[libmeoui.so.0\]' "${evidence_dir}/libmeoui-readelf.txt"
grep -q 'Shared library: \[libmeoui.so.0\]' "${evidence_dir}/plugin-readelf.txt"
if grep -Eq 'Shared library: \[(libPlasma\.so\.7|libkrdb\.so)\]' \
  "${evidence_dir}/meosystem-plugin-readelf.txt"; then
  echo "Private Installer Meo.System must not depend on Plasma Workspace libraries." >&2
  exit 1
fi

for path in \
  manifest.json \
  system-prompt.md \
  risk-review-prompt.md \
  system-general.json \
  audio-output.json \
  display-output.json \
  network-connectivity.json \
  boot-startup.json \
  package-health.json \
  storage-health.json \
  graphics-session.json \
  security-posture.json; do
  unsquashfs -cat "${extract_dir}/airootfs.sfs" \
    "usr/share/meoarch-repair/knowledge/${path}" >"${extract_dir}/${path}"
  cmp "${repo_root}/repair/knowledge/${path}" "${extract_dir}/${path}"
done
unsquashfs -cat "${extract_dir}/airootfs.sfs" \
  usr/share/polkit-1/actions/org.meo.repair.policy \
  >"${extract_dir}/org.meo.repair.policy"
cmp "${repo_root}/repair/data/org.meo.repair.policy" \
  "${extract_dir}/org.meo.repair.policy"
unsquashfs -cat "${extract_dir}/airootfs.sfs" \
  usr/share/polkit-1/actions/org.meo.repair-live.policy \
  >"${extract_dir}/org.meo.repair-live.policy"
cmp "${repo_root}/repair/data/org.meo.repair-live.policy" \
  "${extract_dir}/org.meo.repair-live.policy"
unsquashfs -cat "${extract_dir}/airootfs.sfs" \
  usr/share/polkit-1/rules.d/49-meoarch-live-repair.rules \
  >"${extract_dir}/49-meoarch-live-repair.rules"
cmp "${repo_root}/repair/data/org.meo.repair-live.rules" \
  "${extract_dir}/49-meoarch-live-repair.rules"
for action in rebuild-initramfs refresh-pacman-keyring reload-systemd-manager restart-network-manager; do
  unsquashfs -cat "${extract_dir}/airootfs.sfs" \
    "usr/lib/meoarch-repair/live-actions/${action}.sh" \
    >"${extract_dir}/live-${action}.sh"
  cmp "${repo_root}/repair/live-actions/${action}.sh" \
    "${extract_dir}/live-${action}.sh"
done
for path in \
  etc/systemd/system/meoarch-installer.service \
  etc/systemd/system/getty@tty1.service.d/meoarch-tty.conf \
  usr/local/bin/meoarch-installer-kiosk \
  usr/local/bin/meoarch-installer-live \
  usr/lib/meoarch/live-installer-authorize \
  usr/local/bin/meoarch-repair-session \
  usr/lib/systemd/user/plasma-polkit-agent.service; do
  destination="${extract_dir}/$(basename "${path}")"
  unsquashfs -cat "${extract_dir}/airootfs.sfs" "${path}" >"${destination}"
done
cmp "${repo_root}/meoarch-os/airootfs/etc/systemd/system/meoarch-installer.service" \
  "${extract_dir}/meoarch-installer.service"
cmp "${repo_root}/meoarch-os/airootfs/etc/systemd/system/getty@tty1.service.d/meoarch-tty.conf" \
  "${extract_dir}/meoarch-tty.conf"
cmp "${repo_root}/installer/bin/meoarch-installer-kiosk" \
  "${extract_dir}/meoarch-installer-kiosk"
cmp "${repo_root}/installer/bin/meoarch-repair-session" \
  "${extract_dir}/meoarch-repair-session"
cmp "${projects_root}/meo-kde/native/authentication/data/plasma-polkit-agent.service" \
  "${extract_dir}/plasma-polkit-agent.service"

for mapping in \
  "installer/bin/meoarch-installer-live:usr/local/bin/meoarch-installer-live" \
  "installer/bin/meoarch-live-installer-authorize:usr/lib/meoarch/live-installer-authorize" \
  "installer/data/org.meo.installer-live.policy:usr/share/polkit-1/actions/org.meo.installer-live.policy" \
  "installer/data/org.meo.installer-live.rules:usr/share/polkit-1/rules.d/49-meoarch-live-installer.rules" \
  "installer/data/autostart/meoarch-live.desktop:etc/xdg/autostart/meoarch-live.desktop" \
  "installer/data/systemd/user/meoarch-live-app.service:usr/lib/systemd/user/meoarch-live-app.service" \
  "meoarch-os/airootfs/etc/plasmalogin.conf:etc/plasmalogin.conf"; do
  source_path="${mapping%%:*}"
  iso_relative="${mapping#*:}"
  unsquashfs -cat "${extract_dir}/airootfs.sfs" "${iso_relative}" >"${extract_dir}/live-compare"
  cmp "${repo_root}/${source_path}" "${extract_dir}/live-compare"
done
echo "PASS: ISO structure and Help/MeoUI runtime payload" | tee "${evidence_dir}/inspect-status.txt"
