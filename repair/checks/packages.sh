#!/usr/bin/env bash
set -u -o pipefail

run_package_checks() {
  local prefix=("$@")
  "${prefix[@]}" /usr/bin/pacman -Dk 2>&1 || {
    echo "MEO_FINDING|warning|packages.database_inconsistent|The package database consistency check reported a problem."
  }
  timeout 120 "${prefix[@]}" /usr/bin/pacman -Qk 2>&1 | sed -n '1,400p' || {
    echo "MEO_FINDING|warning|packages.files_inconsistent|Package file verification reported missing or altered files."
  }
}

if [ "${MEOARCH_REPAIR_SCOPE:-system}" = "live" ]; then
  echo "[packages] mounted installed target"
  if [ -x /usr/bin/arch-chroot ] && [ -d /mnt/etc ] && [ -x /mnt/usr/bin/pacman ]; then
    run_package_checks /usr/bin/arch-chroot /mnt
    if [ -x /mnt/usr/bin/pacman-key ] \
       && ! timeout 15 /usr/bin/arch-chroot /mnt /usr/bin/pacman-key --list-keys >/dev/null 2>&1; then
      echo "MEO_FINDING|warning|packages.keyring_unreadable|The mounted target package signing keyring could not be read."
    fi
  else
    echo "MEO_FINDING|warning|packages.target_not_mounted|No usable installed pacman system is mounted at /mnt."
  fi
  exit 0
fi

echo "[packages] installed system"
if [ -x /usr/bin/pacman ]; then
  run_package_checks
else
  echo "MEO_FINDING|warning|packages.pacman_missing|pacman is not installed in the current environment."
fi

echo "[packages] keyring"
if command -v pacman-key >/dev/null 2>&1 \
   && ! timeout 15 pacman-key --list-keys >/dev/null 2>&1; then
  echo "MEO_FINDING|warning|packages.keyring_unreadable|The package signing keyring could not be read."
fi
