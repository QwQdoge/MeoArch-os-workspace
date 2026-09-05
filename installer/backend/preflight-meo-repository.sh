#!/usr/bin/env bash
# Read-only online preflight. It runs before archinstall can touch a disk and
# has no unsigned or cache-only fallback.
set -euo pipefail

plan_file="${1:?install plan is required}"
bootstrap_dir="${2:-/opt/meoarch-installer/bootstrap}"
command -v curl >/dev/null || { echo "curl is required for Meo repository preflight" >&2; exit 2; }
command -v gpg >/dev/null || { echo "gpg is required for Meo repository preflight" >&2; exit 2; }
for keyring_file in meo.gpg meo-trusted meo-revoked; do
  [ -s "$bootstrap_dir/$keyring_file" ] || { echo "Missing ISO keyring bootstrap file: $keyring_file" >&2; exit 3; }
done

plan_output="$(python3 - "$plan_file" <<'PY'
import json, re, sys
plan = json.load(open(sys.argv[1], encoding="utf-8"))
if plan.get("schemaVersion") != 2 or plan.get("architecture") != "x86_64":
    raise SystemExit("unsupported Meo install plan")
repository = plan.get("repository", {})
repos, channel = repository.get("repositories"), repository.get("channel")
if channel not in {"stable", "beta"} or repos != ({"stable": ["meo"], "beta": ["meo-beta", "meo"]}[channel]):
    raise SystemExit("invalid Meo channel repository order")
packages = plan.get("package", {}).get("packages", [])
bootstrap_packages = repository.get("bootstrapPackages")
channel_package = repository.get("channelPackage")
if (not isinstance(packages, list) or not packages
        or bootstrap_packages != ["meo-keyring", "meo-mirrorlist"]
        or channel_package != f"meo-channel-{channel}"
        or any(not isinstance(name, str) or not re.fullmatch(r"[A-Za-z0-9@_+][A-Za-z0-9@._+:-]{0,127}", name)
               for name in [*packages, *bootstrap_packages, channel_package])):
    raise SystemExit("invalid Meo package plan")
transaction_packages = list(dict.fromkeys([*bootstrap_packages, channel_package, *packages]))
print("https://packages.meoarch.org")
print(*repos, sep="\n")
print("--packages--")
print(*transaction_packages, sep="\n")
print("--bootstrap--")
print(*bootstrap_packages, channel_package, sep="\n")
PY
)" || { echo "Invalid Meo install plan; repository preflight stopped" >&2; exit 2; }
readarray -t plan_values <<<"$plan_output"

base_url="${plan_values[0]}"
repositories=(); packages=(); bootstrap_packages=(); mode="repositories"
for value in "${plan_values[@]:1}"; do
  if [ "$value" = "--packages--" ]; then mode="packages"; continue; fi
  if [ "$value" = "--bootstrap--" ]; then mode="bootstrap"; continue; fi
  case "$mode" in
    repositories) repositories+=("$value") ;;
    packages) packages+=("$value") ;;
    bootstrap) bootstrap_packages+=("$value") ;;
  esac
done
work_dir="$(mktemp -d)"
trap 'rm -rf -- "$work_dir"' EXIT
available_packages=$'\n'
stable_packages=$'\n'
for repository in "${repositories[@]}"; do
  db="$work_dir/$repository.db"; signature="$db.sig"
  url="$base_url/$repository/os/x86_64/$repository.db"
  curl --fail --silent --show-error --location --connect-timeout 10 --max-time 60 --retry 2 --output "$db" "$url"
  curl --fail --silent --show-error --location --connect-timeout 10 --max-time 60 --retry 2 --output "$signature" "$url.sig"
  python3 "$(dirname -- "${BASH_SOURCE[0]}")/verify-repository-signature.py" "$bootstrap_dir" "$signature" "$db"
  # Read metadata without extracting repository-controlled paths onto the ISO.
  names="$(python3 - "$db" <<'PY'
import re, sys, tarfile
with tarfile.open(sys.argv[1], "r:*") as archive:
    for entry in archive:
        if not entry.isfile() or not entry.name.endswith("/desc"):
            continue
        if entry.size > 1024 * 1024:
            raise SystemExit("oversized repository package metadata")
        fields = archive.extractfile(entry).read().decode("utf-8").splitlines()
        if fields.count("%NAME%") != 1:
            raise SystemExit("invalid repository package metadata")
        name = fields[fields.index("%NAME%") + 1]
        if not re.fullmatch(r"[A-Za-z0-9@._+:-]{1,128}", name):
            raise SystemExit("invalid repository package name")
        print(name)
PY
)"
  available_packages+="$names"$'\n'
  [ "$repository" != meo ] || stable_packages+="$names"$'\n'
done
for package in "${bootstrap_packages[@]}"; do
  case "$stable_packages" in *$'\n'"$package"$'\n'*) ;; *)
    echo "Bootstrap package is absent from signed Stable metadata: $package" >&2; exit 4;;
  esac
done
for package in "${packages[@]}"; do
  case "$available_packages" in *$'\n'"$package"$'\n'*) ;; *)
    echo "Selected Meo package is absent from signed repository metadata: $package" >&2; exit 4;;
  esac
done
echo "Repository preflight = PASS"
