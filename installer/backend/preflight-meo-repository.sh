#!/usr/bin/env bash
# Read-only online preflight. It runs before archinstall can touch a disk and
# has no unsigned or cache-only fallback.
set -euo pipefail

plan_file="${1:?install plan is required}"
bootstrap_dir="${2:-/opt/meoarch-installer/bootstrap}"
command -v curl >/dev/null || { echo "curl is required for Meo repository preflight" >&2; exit 2; }
command -v gpgv >/dev/null || { echo "gpgv is required for Meo repository preflight" >&2; exit 2; }
command -v bsdtar >/dev/null || { echo "bsdtar is required for Meo repository preflight" >&2; exit 2; }
for keyring_file in meo.gpg meo-trusted meo-revoked; do
  [ -s "$bootstrap_dir/$keyring_file" ] || { echo "Missing ISO keyring bootstrap file: $keyring_file" >&2; exit 3; }
done

readarray -t plan_values < <(python3 - "$plan_file" <<'PY'
import json, re, sys
plan = json.load(open(sys.argv[1], encoding="utf-8"))
if plan.get("schemaVersion") != 2 or plan.get("architecture") != "x86_64":
    raise SystemExit("unsupported Meo install plan")
repository = plan.get("repository", {})
repos, channel = repository.get("repositories"), repository.get("channel")
if (channel == "stable" and repos != ["meo"]) or (channel == "beta" and repos != ["meo-beta", "meo"]):
    raise SystemExit("invalid Meo channel repository order")
packages = plan.get("package", {}).get("packages", [])
bootstrap_packages = repository.get("bootstrapPackages")
channel_package = repository.get("channelPackage")
if (not packages
        or not isinstance(bootstrap_packages, list)
        or not bootstrap_packages
        or not isinstance(channel_package, str)
        or any(not isinstance(name, str) or not re.fullmatch(r"[A-Za-z0-9@._+:-]{1,128}", name)
               for name in [*packages, *bootstrap_packages, channel_package])):
    raise SystemExit("invalid Meo package plan")
transaction_packages = list(dict.fromkeys([*bootstrap_packages, channel_package, *packages]))
print("https://packages.meoarch.org")
print(*repos, sep="\n")
print("--packages--")
print(*transaction_packages, sep="\n")
PY
)

base_url="${plan_values[0]}"
repositories=(); packages=(); mode="repositories"
for value in "${plan_values[@]:1}"; do
  if [ "$value" = "--packages--" ]; then mode="packages"; continue; fi
  if [ "$mode" = "repositories" ]; then repositories+=("$value"); else packages+=("$value"); fi
done
work_dir="$(mktemp -d)"
trap 'rm -rf -- "$work_dir"' EXIT
available_packages=$'\n'
for repository in "${repositories[@]}"; do
  db="$work_dir/$repository.db"; signature="$db.sig"
  url="$base_url/$repository/os/x86_64/$repository.db"
  curl --fail --silent --show-error --location --retry 2 --output "$db" "$url"
  curl --fail --silent --show-error --location --retry 2 --output "$signature" "$url.sig"
  gpgv --keyring "$bootstrap_dir/meo.gpg" "$signature" "$db" >/dev/null
  mkdir -p "$work_dir/$repository"
  bsdtar -xf "$db" -C "$work_dir/$repository"
  while IFS= read -r desc; do
    name="$(awk 'found { print; exit } $0 == "%NAME%" { found=1 }' "$desc")"
    [ -n "$name" ] && available_packages+="$name"$'\n'
  done < <(find "$work_dir/$repository" -name desc -type f -print)
done
for package in "${packages[@]}"; do
  case "$available_packages" in *$'\n'"$package"$'\n'*) ;; *)
    echo "Selected Meo package is absent from signed repository metadata: $package" >&2; exit 4;;
  esac
done
