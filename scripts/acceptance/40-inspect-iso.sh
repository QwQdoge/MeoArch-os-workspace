#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
run_dir="${MEOARCH_RUN_DIR:-${repo_root}/artifacts/validation/test-runs/$(date -u +%Y%m%dT%H%M%SZ)}"
evidence_dir="${run_dir}/iso"
extract_dir="${run_dir}/iso-extract"
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
grep -q '/boot/grub/themes/meoarch/theme.txt' "${evidence_dir}/files.txt"
grep -q '/boot/grub/themes/meoarch/brand.png' "${evidence_dir}/files.txt"

xorriso -osirrox on -indev "${iso_path}" \
  -extract /arch/x86_64/airootfs.sfs "${extract_dir}/airootfs.sfs"
xorriso -osirrox on -indev "${iso_path}" \
  -extract /arch/pkglist.x86_64.txt "${evidence_dir}/packages.txt"
unsquashfs -ll "${extract_dir}/airootfs.sfs" >"${evidence_dir}/airootfs-files.txt"
echo "Recorded $(wc -l <"${evidence_dir}/airootfs-files.txt") airootfs entries."

grep -q 'usr/lib/libmeoui.so.0.3.1' "${evidence_dir}/airootfs-files.txt"
grep -q 'usr/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so' "${evidence_dir}/airootfs-files.txt"
grep -q 'opt/meoarch-installer/qml/Main.qml' "${evidence_dir}/airootfs-files.txt"
grep -q 'opt/meoarch-installer/translations/meoarch_zh_CN.qm' "${evidence_dir}/airootfs-files.txt"
grep -q 'usr/lib/qt6/qml/Meo/System/libmeosystemplugin.so' "${evidence_dir}/airootfs-files.txt"
grep -q 'usr/lib/meoarch-repair/qml/Main.qml' "${evidence_dir}/airootfs-files.txt"
grep -q 'opt/meo-desktop/themes/look-and-feel/org.meo.desktop/metadata.json' \
  "${evidence_dir}/airootfs-files.txt"
for package in plasma-desktop plasma-workspace sddm networkmanager qtkeychain-qt6 lynis; do
  grep -q "^${package} " "${evidence_dir}/packages.txt"
done
for executable in \
  opt/meoarch-installer/bin/meoarch-installer-app \
  opt/meoarch-installer/backend/generate-config.py \
  opt/meoarch-installer/backend/run-archinstall.sh \
  usr/bin/meoarch-repair \
  usr/lib/meoarch-repair/checks/all.sh \
  usr/local/bin/meoarch-installer-live; do
  grep -Eq "^-rwx[^[:space:]]*[[:space:]].*${executable}$" \
    "${evidence_dir}/airootfs-files.txt"
done
if grep -q 'opt/meo-ui/' "${evidence_dir}/airootfs-files.txt"; then
  echo "Obsolete /opt/meo-ui exists in ISO." >&2
  exit 1
fi

for path in \
  usr/lib/libmeoui.so.0.3.1 \
  usr/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so; do
  destination="${extract_dir}/$(basename "${path}")"
  unsquashfs -cat "${extract_dir}/airootfs.sfs" "${path}" >"${destination}"
done
readelf -d "${extract_dir}/libmeoui.so.0.3.1" |
  tee "${evidence_dir}/libmeoui-readelf.txt"
readelf -d "${extract_dir}/libmeoui_moduleplugin.so" |
  tee "${evidence_dir}/plugin-readelf.txt"
grep -q 'Library soname: \[libmeoui.so.0\]' "${evidence_dir}/libmeoui-readelf.txt"
grep -q 'Shared library: \[libmeoui.so.0\]' "${evidence_dir}/plugin-readelf.txt"

echo "PASS: ISO structure and MeoUI runtime" | tee "${evidence_dir}/inspect-status.txt"
