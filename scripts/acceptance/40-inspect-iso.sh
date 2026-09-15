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
# The Live ISO is intentionally UEFI systemd-boot based.  The repository still
# retains GRUB theme assets for other targets, but they are not ISO payload.
grep -q '/loader/entries/01-archiso-linux.conf' "${evidence_dir}/files.txt"
grep -q '/loader/entries/02-archiso-repair-linux.conf' "${evidence_dir}/files.txt"

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
grep -q 'opt/meo-desktop/themes/look-and-feel/org.meo.desktop/metadata.json' \
  "${evidence_dir}/airootfs-files.txt"
for package in cage networkmanager qtkeychain-qt6 lynis; do
  grep -q "^${package} " "${evidence_dir}/packages.txt"
done
# The Cage Live session deliberately excludes Plasma Desktop, its login manager,
# Workspace, and KWin.  Time-zone selection uses the installer's searchable
# offline list and does not require the Plasma Workspace map module.
for excluded_package in plasma-desktop plasma-login-manager plasma-workspace sddm kwin; do
  if grep -q "^${excluded_package} " "${evidence_dir}/packages.txt"; then
    echo "Cage-only Live ISO unexpectedly includes ${excluded_package}." >&2
    exit 1
  fi
done
grep -q 'etc/systemd/system/graphical.target.wants/meoarch-installer.service' \
  "${evidence_dir}/airootfs-files.txt"
if grep -q 'etc/systemd/system/multi-user.target.wants/meoarch-installer.service' \
  "${evidence_dir}/airootfs-files.txt"; then
  echo "Cage-only Live ISO starts the installer from multi-user.target as well as graphical.target." >&2
  exit 1
fi
if grep -q 'etc/systemd/system/display-manager.service\|etc/sddm.conf.d/10-meoarch-live.conf' \
  "${evidence_dir}/airootfs-files.txt"; then
  echo "Cage-only Live ISO still contains an SDDM launch path." >&2
  exit 1
fi
if grep -q 'etc/xdg/autostart/meoarch-installer.desktop\|usr/local/bin/meoarch-installer-live\|etc/sudoers.d/10-meoarch-live-installer' \
  "${evidence_dir}/airootfs-files.txt"; then
  echo "Cage-only Live ISO still contains a legacy KDE installer launch path." >&2
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
  usr/local/bin/meoarch-installer \
  usr/local/bin/meoarch-installer-kiosk; do
  grep -Eq "^-rwx[^[:space:]]*[[:space:]].*${executable}$" \
    "${evidence_dir}/airootfs-files.txt"
done
if grep -q 'opt/meo-ui/' "${evidence_dir}/airootfs-files.txt"; then
  echo "Obsolete /opt/meo-ui exists in ISO." >&2
  exit 1
fi

for path in \
  usr/lib/libmeoui.so.0 \
  usr/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so; do
  destination="${extract_dir}/$(basename "${path}")"
  unsquashfs -cat "${extract_dir}/airootfs.sfs" "${path}" >"${destination}"
done
readelf -d "${extract_dir}/libmeoui.so.0" |
  tee "${evidence_dir}/libmeoui-readelf.txt"
readelf -d "${extract_dir}/libmeoui_moduleplugin.so" |
  tee "${evidence_dir}/plugin-readelf.txt"
grep -q 'Library soname: \[libmeoui.so.0\]' "${evidence_dir}/libmeoui-readelf.txt"
grep -q 'Shared library: \[libmeoui.so.0\]' "${evidence_dir}/plugin-readelf.txt"

echo "PASS: ISO structure and MeoUI runtime" | tee "${evidence_dir}/inspect-status.txt"
