#!/usr/bin/env bash
# Bootstrap only reviewed public trust material, then install the package-owned
# channel configuration in the mounted target. Never downloads keys.
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

readarray -t plan_values < <(python3 - "$plan_file" <<'PY'
import json
import sys
from urllib.parse import urlparse

plan = json.load(open(sys.argv[1], encoding="utf-8"))
repository = plan.get("repository", {})
channel = repository.get("channel")
repos = repository.get("repositories")
if (channel == "stable" and repos != ["meo"]) or (channel == "beta" and repos != ["meo-beta", "meo"]):
    raise SystemExit("invalid Meo channel repository order")
if repository.get("coreTrainAvailable") is not True:
    raise SystemExit(repository.get("availabilityMessage") or "Selected channel has no published core train")
base_url = repository.get("baseUrl")
parsed = urlparse(base_url if isinstance(base_url, str) else "")
if parsed.scheme != "https" or not parsed.netloc or parsed.path not in {"", "/"}:
    raise SystemExit("invalid Meo repository base URL")
channel_package = repository.get("channelPackage")
if not isinstance(channel_package, str) or not channel_package:
    raise SystemExit("missing package-owned channel selector")
print(base_url.rstrip("/"))
print(channel)
print(channel_package)
print(*repos, sep="\n")
PY
)

base_url="${plan_values[0]}"
channel="${plan_values[1]}"
channel_package="${plan_values[2]}"
expected_repositories=("${plan_values[@]:3}")
for file in meo.gpg meo-trusted meo-revoked meo-keyring.json; do
  [ -s "$bootstrap_dir/$file" ] || { echo "Missing ISO keyring bootstrap file: $file" >&2; exit 4; }
done
python3 "$(dirname -- "${BASH_SOURCE[0]}")/validate_meo_keyring.py" "$bootstrap_dir"

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

install -d "$target_root/etc/pacman.d" "$target_root/usr/share/pacman/keyrings" \
  "$target_root/usr/share/meo-release"
install -Dm644 /dev/stdin "$target_root/etc/pacman.d/meo-mirrorlist" <<EOF
Server = $base_url/\$repo/os/\$arch
EOF
install -Dm644 /dev/stdin "$target_root/etc/pacman.d/meo-channel.conf" <<'EOF'
[meo]
SigLevel = Required TrustedOnly
Include = /etc/pacman.d/meo-mirrorlist
EOF
printf '\n# Managed by MeoArch bootstrap; meo-channel-* owns the included file.\nInclude = /etc/pacman.d/meo-channel.conf\n' >>"$pacman_conf"

for file in meo.gpg meo-trusted meo-revoked; do
  install -Dm644 "$bootstrap_dir/$file" "$target_root/usr/share/pacman/keyrings/$file"
done
install -Dm644 "$bootstrap_dir/meo-keyring.json" "$target_root/usr/share/meo-release/keyring.json"

arch-chroot "$target_root" pacman-key --init
arch-chroot "$target_root" pacman-key --populate archlinux meo
# The channel selector is deliberately fetched first from [meo], which the ISO
# bootstrap configuration exposes. It owns the final included configuration.
arch-chroot "$target_root" pacman -S --needed --noconfirm \
  meo-keyring meo-mirrorlist "$channel_package"

for file in meo.gpg meo-trusted meo-revoked; do
  cmp --silent "$bootstrap_dir/$file" "$target_root/usr/share/pacman/keyrings/$file" || {
    echo "Installed meo-keyring differs from reviewed ISO bootstrap: $file" >&2
    exit 5
  }
done
cmp --silent "$bootstrap_dir/meo-keyring.json" \
  "$target_root/usr/share/meo-release/keyring.json" || {
  echo "Installed meo-keyring metadata differs from reviewed ISO bootstrap" >&2
  exit 5
}

arch-chroot "$target_root" pacman -Syy --noconfirm
mapfile -t resolved_meo_repositories < <(
  arch-chroot "$target_root" pacman-conf --repo-list | awk '$0 == "meo" || $0 == "meo-beta"'
)
if [ "${resolved_meo_repositories[*]}" != "${expected_repositories[*]}" ]; then
  echo "Resolved Meo repository order does not match the signed install plan" >&2
  exit 6
fi
if [ "$channel" = beta ] && [ "${resolved_meo_repositories[*]}" != "meo-beta meo" ]; then
  echo "Beta must resolve meo-beta before meo" >&2
  exit 6
fi

rm -f -- "$backup_conf"
trap - EXIT
