#!/usr/bin/env bash
# Read-only online preflight. It runs before archinstall can touch a disk and
# has no unsigned or cache-only fallback.
set -euo pipefail

plan_file="${1:?install plan is required}"
bootstrap_dir="${2:-/opt/meoarch-installer/bootstrap}"
command -v curl >/dev/null || { echo "curl is required for Meo repository preflight" >&2; exit 2; }
command -v gpgv >/dev/null || { echo "gpgv is required for Meo repository preflight" >&2; exit 2; }
command -v gpg >/dev/null || { echo "gpg is required for Meo repository preflight" >&2; exit 2; }
command -v bsdtar >/dev/null || { echo "bsdtar is required for Meo repository preflight" >&2; exit 2; }
python3 "$(dirname -- "${BASH_SOURCE[0]}")/validate_meo_keyring.py" "$bootstrap_dir"

readarray -t plan_values < <(python3 - "$plan_file" <<'PY'
import json
import re
import sys
from urllib.parse import urlparse

plan = json.load(open(sys.argv[1], encoding="utf-8"))
if plan.get("schemaVersion") != 2 or plan.get("architecture") != "x86_64":
    raise SystemExit("unsupported Meo install plan")
repository = plan.get("repository", {})
repos = repository.get("repositories")
channel = repository.get("channel")
if (channel == "stable" and repos != ["meo"]) or (channel == "beta" and repos != ["meo-beta", "meo"]):
    raise SystemExit("invalid Meo channel repository order")
base_url = repository.get("baseUrl")
parsed_url = urlparse(base_url if isinstance(base_url, str) else "")
if parsed_url.scheme != "https" or not parsed_url.netloc or parsed_url.path not in {"", "/"}:
    raise SystemExit("invalid Meo repository base URL")
if repository.get("coreTrainAvailable") is not True:
    message = repository.get("availabilityMessage")
    if not isinstance(message, str) or not message:
        message = "The selected Meo channel has no published core train."
    raise SystemExit(message)
core = repository.get("corePackages")
packages = plan.get("package", {}).get("packages")
bootstrap = repository.get("bootstrapPackages")
channel_package = repository.get("channelPackage")
for values, label in ((core, "core"), (packages, "package"), (bootstrap, "bootstrap")):
    if not isinstance(values, list) or not values or any(
        not isinstance(name, str) or not re.fullmatch(r"[A-Za-z0-9@._+:-]{1,128}", name)
        for name in values
    ):
        raise SystemExit(f"invalid Meo {label} package plan")
if not isinstance(channel_package, str) or not re.fullmatch(r"[A-Za-z0-9@._+:-]{1,128}", channel_package):
    raise SystemExit("invalid Meo channel package")
print(base_url.rstrip("/"))
for marker, values in (
    ("--repositories--", repos),
    ("--core--", core),
    ("--packages--", packages),
    ("--bootstrap--", bootstrap),
):
    print(marker)
    print(*values, sep="\n")
print("--channel-package--")
print(channel_package)
PY
)

base_url="${plan_values[0]}"
repositories=()
core_packages=()
selected_packages=()
bootstrap_packages=()
channel_package=""
mode=""
for value in "${plan_values[@]:1}"; do
  case "$value" in
    --repositories--|--core--|--packages--|--bootstrap--|--channel-package--)
      mode="$value"
      continue
      ;;
  esac
  case "$mode" in
    --repositories--) repositories+=("$value") ;;
    --core--) core_packages+=("$value") ;;
    --packages--) selected_packages+=("$value") ;;
    --bootstrap--) bootstrap_packages+=("$value") ;;
    --channel-package--) channel_package="$value" ;;
    *) echo "Invalid serialized Meo install plan" >&2; exit 3 ;;
  esac
done

work_dir="$(mktemp -d)"
trap 'rm -rf -- "$work_dir"' EXIT
declare -A repository_packages
all_packages=$'\n'
for repository in "${repositories[@]}"; do
  db="$work_dir/$repository.db"
  signature="$db.sig"
  url="$base_url/$repository/os/x86_64/$repository.db"
  curl --fail --silent --show-error --location --retry 2 --output "$db" "$url"
  curl --fail --silent --show-error --location --retry 2 --output "$signature" "$url.sig"
  gpgv --keyring "$bootstrap_dir/meo.gpg" "$signature" "$db" >/dev/null
  extract_dir="$work_dir/$repository"
  install -d "$extract_dir"
  bsdtar -xf "$db" -C "$extract_dir"
  names=$'\n'
  while IFS= read -r desc; do
    name="$(awk 'found { print; exit } $0 == "%NAME%" { found=1 }' "$desc")"
    [ -n "$name" ] && names+="$name"$'\n'
  done < <(find "$extract_dir" -name desc -type f -print)
  repository_packages["$repository"]="$names"
  all_packages+="$names"
done

has_package() {
  local repository="$1"
  local package="$2"
  case "${repository_packages[$repository]:-}" in
    *$'\n'"$package"$'\n'*) return 0 ;;
    *) return 1 ;;
  esac
}

for package in "${bootstrap_packages[@]}" "$channel_package" meo-release; do
  has_package meo "$package" || {
    echo "Foundation package is absent from signed meo metadata: $package" >&2
    exit 4
  }
done
if [ "${repositories[0]}" = "meo-beta" ]; then
  for package in "${core_packages[@]}"; do
    has_package meo-beta "$package" || {
      echo "Core beta package is absent from signed meo-beta metadata: $package" >&2
      exit 4
    }
  done
else
  for package in "${core_packages[@]}"; do
    has_package meo "$package" || {
      echo "Core Stable package is absent from signed meo metadata: $package" >&2
      exit 4
    }
  done
fi
for package in "${selected_packages[@]}"; do
  case "$all_packages" in
    *$'\n'"$package"$'\n'*) ;;
    *) echo "Selected Meo package is absent from signed repository metadata: $package" >&2; exit 4 ;;
  esac
done
