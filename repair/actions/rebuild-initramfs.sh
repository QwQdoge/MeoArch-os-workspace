#!/usr/bin/env bash
set -euo pipefail
[ "$(id -u)" -eq 0 ] || { echo "Root authorization is required." >&2; exit 77; }
if [ "${MEOARCH_REPAIR_SCOPE:-system}" = "live" ]; then
  [ "${MEOARCH_TARGET_ROOT:-/mnt}" = "/mnt" ] || { echo "Unexpected target root." >&2; exit 2; }
  [ ! -L /mnt ] && [ -d /mnt/etc ] && [ -x /mnt/usr/bin/mkinitcpio ] \
    || { echo "A valid installed target is not mounted at /mnt." >&2; exit 3; }
  exec /usr/bin/arch-chroot /mnt /usr/bin/mkinitcpio -P
fi
exec /usr/bin/mkinitcpio -P
