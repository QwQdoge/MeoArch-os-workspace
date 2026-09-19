#!/usr/bin/env bash
set -euo pipefail

scope="system"
target_root="/mnt"
while [ "$#" -gt 0 ]; do
  case "$1" in
    --scope)
      [ "$#" -ge 2 ] || { echo "Missing scope value." >&2; exit 2; }
      scope="$2"
      shift 2
      ;;
    --target-root)
      [ "$#" -ge 2 ] || { echo "Missing target root value." >&2; exit 2; }
      target_root="$2"
      shift 2
      ;;
    *)
      echo "Unsupported action argument." >&2
      exit 2
      ;;
  esac
done
case "${scope}" in live|system) ;; *) echo "Unsupported repair scope." >&2; exit 2 ;; esac
[ "${target_root}" = "/mnt" ] || { echo "Unexpected target root." >&2; exit 2; }

[ "$(id -u)" -eq 0 ] || { echo "Root authorization is required." >&2; exit 77; }
if [ "${scope}" = "live" ]; then
  [ ! -L /mnt ] && [ -d /mnt/etc ] && [ -x /mnt/usr/bin/mkinitcpio ] \
    || { echo "A valid installed target is not mounted at /mnt." >&2; exit 3; }
  /usr/bin/arch-chroot /mnt /usr/bin/mkinitcpio -P
  /usr/bin/arch-chroot /mnt /usr/bin/find /boot -maxdepth 1 -type f -name 'initramfs-*.img' -size +0c -print -quit \
    | /usr/bin/grep -q .
  echo "Post-check passed: the target has a non-empty initramfs image."
  exit 0
fi
/usr/bin/mkinitcpio -P
/usr/bin/find /boot -maxdepth 1 -type f -name 'initramfs-*.img' -size +0c -print -quit \
  | /usr/bin/grep -q .
echo "Post-check passed: the system has a non-empty initramfs image."
