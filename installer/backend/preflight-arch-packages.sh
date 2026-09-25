#!/usr/bin/env bash
set -euo pipefail

config_file="${1:-}"
state_dir="${2:-${MEOARCH_INSTALLER_STATE_DIR:-/tmp/meoarch-installer}}"

if [ -z "${config_file}" ] || [ ! -f "${config_file}" ] || [ -L "${config_file}" ]; then
  echo "Generated Archinstall configuration is missing or unsafe." >&2
  exit 2
fi
if ! command -v python3 >/dev/null 2>&1 || ! command -v pacman >/dev/null 2>&1; then
  echo "python3 and pacman are required for Arch package preflight." >&2
  exit 127
fi

ensure_private_directory() {
  python3 - "$1" <<'PY'
import os
import stat
import sys
from pathlib import Path

path = Path(sys.argv[1])
if path.is_symlink():
    raise SystemExit("preflight directory must not be a symlink")
path.mkdir(parents=True, exist_ok=True, mode=0o700)
info = path.stat()
if not stat.S_ISDIR(info.st_mode) or info.st_uid != os.geteuid():
    raise SystemExit("preflight directory has unsafe ownership")
os.chmod(path, 0o700)
PY
}

ensure_private_directory "${state_dir}"
pacman_db="${state_dir}/pacman-preflight-db"
pacman_cache="${state_dir}/pacman-preflight-cache"
ensure_private_directory "${pacman_db}"
ensure_private_directory "${pacman_cache}"

# A blank local database makes pacman resolve the full fresh-system dependency
# transaction instead of treating packages already present in the Live ISO as
# satisfied. Sync metadata is refreshed on every invocation.
rm -rf -- "${pacman_db}/local" "${pacman_db}/sync"
mkdir -m700 "${pacman_db}/local" "${pacman_db}/sync"

mapfile -t arch_packages < <(python3 - "${config_file}" <<'PY'
import json
import re
import sys

config = json.load(open(sys.argv[1], encoding="utf-8"))
packages = [
    "base",
    "linux-firmware",
    "mkinitcpio",
    "grub",
    "efibootmgr",
    "networkmanager",
    "sudo",
    "dosfstools",
]

for kernel in config.get("kernels", []):
    if isinstance(kernel, str):
        packages.append(kernel)

for package in config.get("packages", []):
    if isinstance(package, str):
        packages.append(package)

profile_config = config.get("profile_config", {})
profile = profile_config.get("profile", {}) if isinstance(profile_config, dict) else {}
details = profile.get("details", []) if isinstance(profile, dict) else []
if isinstance(details, list) and "KDE Plasma" in details:
    packages.append("plasma-meta")

# Mirror Archinstall's own implicit desktop graphics additions when its runtime
# API is available.  If a future Archinstall changes this API, the explicit
# Meo hardware packages above still get checked and Archinstall's own config
# validation remains authoritative; do not invent a stale hardcoded fallback.
gfx_driver = profile_config.get("gfx_driver") if isinstance(profile_config, dict) else None
if isinstance(gfx_driver, str):
    try:
        from archinstall.lib.hardware import GfxDriver
        packages.extend(package.value for package in GfxDriver(gfx_driver).gfx_packages())
    except (ImportError, AttributeError, ValueError):
        pass

# Archinstall may add the host CPU's microcode package on physical hardware.
# Ask the same runtime for that decision so VM installs are not needlessly
# blocked on a package they would never install.
try:
    from archinstall.lib.hardware import SysInfo
    if not SysInfo.is_vm():
        vendor = SysInfo.cpu_vendor()
        ucode = vendor.get_ucode() if vendor is not None else None
        if ucode is not None:
            packages.append(ucode.stem)
except (ImportError, AttributeError, OSError, ValueError):
    pass

disk_config = config.get("disk_config", {})
mods = disk_config.get("device_modifications", []) if isinstance(disk_config, dict) else []
for modification in mods:
    if not isinstance(modification, dict):
        continue
    for partition in modification.get("partitions", []):
        if not isinstance(partition, dict):
            continue
        fs_type = partition.get("fs_type")
        if fs_type == "btrfs":
            packages.append("btrfs-progs")
        elif fs_type == "ext4":
            packages.append("e2fsprogs")

seen = set()
for package in packages:
    if not isinstance(package, str) or not re.fullmatch(r"[A-Za-z0-9@._+:-]+", package):
        raise SystemExit("generated Arch package name is invalid")
    if package not in seen:
        seen.add(package)
        print(package)
PY
)

if [ "${#arch_packages[@]}" -eq 0 ]; then
  echo "Generated Arch package set is empty." >&2
  exit 3
fi

echo "Refreshing Arch package databases for installation preflight."
pacman --sync --refresh --noconfirm \
  --dbpath "${pacman_db}" \
  --cachedir "${pacman_cache}" \
  --logfile /dev/null

echo "Resolving required Arch package transaction."
pacman --sync --print --print-format '%n %v' --noconfirm \
  --dbpath "${pacman_db}" \
  --cachedir "${pacman_cache}" \
  --logfile /dev/null \
  "${arch_packages[@]}" >/dev/null

echo "Arch package transaction is resolvable."
