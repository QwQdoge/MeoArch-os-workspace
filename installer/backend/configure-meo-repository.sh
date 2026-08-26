#!/usr/bin/env bash
# Bootstrap only public trust material, validate it, then atomically install a
# package-owned channel file in the mounted target.  Never downloads keys.
set -euo pipefail

target_root="${1:?target root is required}"
generated_dir="${2:?generated directory is required}"
bootstrap_dir="${3:-/opt/meoarch-installer/bootstrap}"
target_root="$(realpath -e -- "$target_root")"
[ "$target_root" != / ] || { echo "Refusing root target" >&2; exit 2; }
plan_file="$generated_dir/install-plan.json"
[ -f "$plan_file" ] || { echo "Missing generated install plan" >&2; exit 3; }
pacman_conf="$target_root/etc/pacman.conf"
[ -f "$pacman_conf" ] || { echo "Target pacman configuration is missing" >&2; exit 3; }
backup_conf="$target_root/etc/pacman.conf.meo-bootstrap-backup"
cp -- "$pacman_conf" "$backup_conf"
restore_on_error() {
  status=$?
  if [ "$status" -ne 0 ] && [ -f "$backup_conf" ]; then
    mv -f -- "$backup_conf" "$pacman_conf"
    rm -f -- "$target_root/etc/pacman.d/meo-channel.conf" "$target_root/etc/pacman.d/meo-mirrorlist"
  fi
  exit "$status"
}
trap restore_on_error EXIT
install -d "$target_root/etc/pacman.d"
install -Dm644 /dev/stdin "$target_root/etc/pacman.d/meo-mirrorlist" <<'EOF'
Server = https://packages.meoarch.org/$repo/os/$arch
EOF
install -Dm644 /dev/stdin "$target_root/etc/pacman.d/meo-channel.conf" <<'EOF'
[meo]
SigLevel = Required TrustedOnly
Include = /etc/pacman.d/meo-mirrorlist
EOF
printf '\n# Managed by MeoArch bootstrap; meo-channel-* owns the included file.\nInclude = /etc/pacman.d/meo-channel.conf\n' >>"$pacman_conf"
for file in meo.gpg meo-trusted meo-revoked; do
  [ -s "$bootstrap_dir/$file" ] || { echo "Missing ISO keyring bootstrap file: $file" >&2; exit 4; }
  install -Dm644 "$bootstrap_dir/$file" "$target_root/usr/share/pacman/keyrings/$file"
done
arch-chroot "$target_root" pacman-key --init
arch-chroot "$target_root" pacman-key --populate archlinux meo
# The channel package is deliberately first fetched only from [meo], which the
# ISO bootstrap configuration exposes.  It owns the final Include file.
channel="$(python3 - "$plan_file" <<'PY'
import json,sys
print(json.load(open(sys.argv[1]))['repository']['channelPackage'])
PY
)"
arch-chroot "$target_root" pacman -S --needed --noconfirm meo-keyring meo-mirrorlist "$channel"
arch-chroot "$target_root" pacman -Syy --noconfirm
arch-chroot "$target_root" pacman-conf --repo-list | grep -qx meo
rm -f -- "$backup_conf"
trap - EXIT
