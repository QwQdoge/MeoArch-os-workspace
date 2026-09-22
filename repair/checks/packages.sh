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

show_local_update_view() {
  local sync_root="$1"
  shift
  local prefix=("$@")
  local output=""
  local newest=""
  local count=0
  local now=""
  local age_days=""

  echo "[packages] local sync database update view"
  echo "This is read-only and does not refresh repository metadata."

  if [ -d "${sync_root}" ]; then
    newest="$(find "${sync_root}" -maxdepth 1 -type f -printf '%T@\n' 2>/dev/null | sort -nr | head -n1 || true)"
    if [ -n "${newest}" ]; then
      newest="${newest%%.*}"
      if [[ "${newest}" =~ ^[0-9]+$ ]]; then
        printf 'Newest local sync database file: %s\n' "$(date -d "@${newest}" '+%Y-%m-%d %H:%M:%S %z' 2>/dev/null || echo unknown)"
        now="$(date +%s 2>/dev/null || true)"
        if [[ "${now}" =~ ^[0-9]+$ ]] && [ "${now}" -ge "${newest}" ]; then
          age_days="$(((now - newest) / 86400))"
          printf 'Local sync database age: %s day(s).\n' "${age_days}"
          if [ "${age_days}" -gt 7 ]; then
            echo "The local repository metadata is older than 7 days, so the upgrade count may be stale."
          fi
        fi
      fi
    else
      echo "No local repository sync database files were found."
    fi
  else
    echo "Local repository sync database directory is missing."
  fi

  if output="$(timeout 20 "${prefix[@]}" /usr/bin/pacman -Qu 2>/dev/null)"; then
    if [ -n "${output}" ]; then
      count="$(printf '%s\n' "${output}" | sed '/^[[:space:]]*$/d' | wc -l)"
      printf 'Local database currently lists %s upgrade(s).\n' "${count}"
      printf '%s\n' "${output}" | sed -n '1,120p'
      if [ "${count}" -gt 120 ]; then
        printf '... %s additional upgrade(s) omitted from the diagnostic log.\n' "$((count - 120))"
      fi
    else
      echo "The current local sync database does not list any package upgrades."
    fi
  else
    echo "Unable to calculate upgrades from the current local sync database."
  fi
}

if [ "${MEOARCH_REPAIR_SCOPE:-system}" = "live" ]; then
  echo "[packages] mounted installed target"
  if [ -x /usr/bin/arch-chroot ] && [ -d /mnt/etc ] && [ -x /mnt/usr/bin/pacman ]; then
    run_package_checks /usr/bin/arch-chroot /mnt
    show_local_update_view /mnt/var/lib/pacman/sync /usr/bin/arch-chroot /mnt
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
  show_local_update_view /var/lib/pacman/sync
else
  echo "MEO_FINDING|warning|packages.pacman_missing|pacman is not installed in the current environment."
fi

echo "[packages] keyring"
if command -v pacman-key >/dev/null 2>&1 \
   && ! timeout 15 pacman-key --list-keys >/dev/null 2>&1; then
  echo "MEO_FINDING|warning|packages.keyring_unreadable|The package signing keyring could not be read."
fi
