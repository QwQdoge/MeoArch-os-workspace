#!/usr/bin/env bash
# Bootstrap only public trust material, validate it, then atomically install a
# package-owned channel file in the mounted target.  Never downloads keys.
set -euo pipefail

target_root="${1:?target root is required}"
generated_dir="${2:?generated directory is required}"
bootstrap_dir="${3:-/opt/meoarch-installer/bootstrap}"
if [ -L "$target_root" ]; then
  echo "Refusing symlinked target root" >&2
  exit 2
fi
target_root="$(python3 - "$target_root" <<'PY'
from pathlib import Path
import sys

try:
    print(Path(sys.argv[1]).resolve(strict=True))
except OSError as error:
    raise SystemExit(error)
PY
)"
[ "$target_root" != / ] || { echo "Refusing root target" >&2; exit 2; }
for target_directory in etc; do
  if [ -L "$target_root/$target_directory" ] || [ ! -d "$target_root/$target_directory" ]; then
    echo "Target $target_directory directory is missing or unsafe" >&2
    exit 2
  fi
done
install_file() {
  local mode="$1"
  local source="$2"
  local destination="$3"
  command install -d "$(dirname -- "${destination}")"
  command install -m "${mode}" "${source}" "${destination}"
}
plan_file="$generated_dir/install-plan.json"
[ -f "$plan_file" ] || { echo "Missing generated install plan" >&2; exit 3; }
pacman_conf="$target_root/etc/pacman.conf"
[ -f "$pacman_conf" ] || { echo "Target pacman configuration is missing" >&2; exit 3; }
backup_conf="$target_root/etc/pacman.conf.meo-bootstrap-backup"
cp -- "$pacman_conf" "$backup_conf"
# arch-chroot mounts over /run and /tmp. Keep these public, short-lived inputs
# under /etc so every chroot invocation sees the same bootstrap configuration.
bootstrap_work="$(mktemp -d "$target_root/etc/meo-bootstrap.XXXXXX")"
chroot_bootstrap="${bootstrap_work#"$target_root"}"
restore_on_error() {
  status=$?
  if [ "$status" -ne 0 ] && [ -f "$backup_conf" ]; then
    mv -f -- "$backup_conf" "$pacman_conf"
  fi
  rm -rf -- "$bootstrap_work"
  exit "$status"
}
trap restore_on_error EXIT
cp -- "$pacman_conf" "$bootstrap_work/pacman.conf"
# Temporary bootstrap files must not occupy paths owned by the packages about
# to be installed. Otherwise pacman rejects the transaction as file conflicts.
cat >>"$bootstrap_work/pacman.conf" <<'EOF'

[meo]
SigLevel = Required TrustedOnly
Server = https://packages.meoarch.org/$repo/os/$arch
EOF
for file in meo.gpg meo-trusted meo-revoked; do
  [ -s "$bootstrap_dir/$file" ] || { echo "Missing ISO keyring bootstrap file: $file" >&2; exit 4; }
  install_file 644 "$bootstrap_dir/$file" "$bootstrap_work/keyrings/$file"
done
arch-chroot "$target_root" pacman-key --init
arch-chroot "$target_root" pacman-key --populate archlinux
arch-chroot "$target_root" pacman-key --populate-from "$chroot_bootstrap/keyrings" --populate meo
# The channel package is deliberately first fetched only from [meo], which the
# ISO bootstrap configuration exposes.  It owns the final Include file.
channel="$(python3 - "$plan_file" <<'PY'
import json,sys
repository = json.load(open(sys.argv[1]))['repository']
channel = repository.get('channel')
expected = {'stable': ['meo'], 'beta': ['meo-beta', 'meo']}
if (channel not in expected or repository.get('repositories') != expected[channel]
        or repository.get('channelPackage') != f'meo-channel-{channel}'):
    raise SystemExit('invalid Meo channel plan')
print(repository['channelPackage'])
PY
)"
# Bootstrap the signed repository controls as a full system upgrade. A fresh
# target must never refresh package databases and then perform a partial -S
# transaction.
arch-chroot "$target_root" pacman --config "$chroot_bootstrap/pacman.conf" \
  -Syu --needed --noconfirm \
  meo/meo-keyring meo/meo-mirrorlist "meo/$channel" meo/meo-release
printf '\n# Managed by MeoArch bootstrap; meo-channel-* owns the included file.\nInclude = /etc/pacman.d/meo-channel.conf\n' >>"$pacman_conf"
repository_output="$(arch-chroot "$target_root" pacman-conf --repo-list)"
python3 - "$plan_file" "$repository_output" <<'PY'
import json, sys
plan = json.load(open(sys.argv[1], encoding="utf-8"))
expected = plan["repository"]["repositories"]
actual = [name.strip() for name in sys.argv[2].splitlines()
          if name.strip() in {"meo", "meo-beta"}]
if actual != expected:
    raise SystemExit(f"installed Meo repository order is {actual!r}, expected {expected!r}")
PY
rm -f -- "$backup_conf"
