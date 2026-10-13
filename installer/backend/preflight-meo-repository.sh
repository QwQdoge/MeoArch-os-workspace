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
expected_repos = {"stable": ["meo"], "beta": ["meo-beta", "meo"]}
if channel not in expected_repos or repos != expected_repos[channel]:
    raise SystemExit("invalid Meo channel repository order")
generation = plan.get("generation")
packages = plan.get("package", {}).get("packages", [])
bootstrap_packages = repository.get("bootstrapPackages")
channel_package = repository.get("channelPackage")
if (not isinstance(generation, str) or not re.fullmatch(r"[0-9]{4}\.[0-9]{2}", generation)
        or not isinstance(packages, list) or not packages or "meo-release" not in packages
        or bootstrap_packages != ["meo-keyring", "meo-mirrorlist"]
        or channel_package != f"meo-channel-{channel}"
        or any(not isinstance(name, str) or not re.fullmatch(r"[A-Za-z0-9@_+][A-Za-z0-9@._+:-]{0,127}", name)
               for name in [*packages, *bootstrap_packages, channel_package])):
    raise SystemExit("invalid Meo package plan")

has_release_generations = "releaseGenerations" in repository
has_repository_policy = "repositoryReleaseGenerations" in repository
if has_release_generations != has_repository_policy:
    raise SystemExit("incomplete Meo release generation policy")
explicit_release_policy = has_release_generations
release_generations = repository.get("releaseGenerations", [generation])
repository_policy = repository.get(
    "repositoryReleaseGenerations", {repo: [generation] for repo in repos}
)
if (not isinstance(release_generations, list) or not release_generations
        or release_generations[0] != generation
        or len(set(release_generations)) != len(release_generations)
        or any(not isinstance(item, str) or not re.fullmatch(r"[0-9]{4}\.[0-9]{2}", item)
               for item in release_generations)
        or not isinstance(repository_policy, dict)
        or set(repository_policy) != set(repos)):
    raise SystemExit("invalid Meo release generation policy")
policy_union = set()
for repo in repos:
    allowed = repository_policy.get(repo)
    if (not isinstance(allowed, list) or not allowed or generation not in allowed
            or len(set(allowed)) != len(allowed)
            or any(not isinstance(item, str) or item not in release_generations for item in allowed)):
        raise SystemExit("invalid Meo repository generation policy")
    policy_union.update(allowed)
if policy_union != set(release_generations):
    raise SystemExit("unbound Meo release generation policy")
if channel == "stable":
    if release_generations != [generation] or repository_policy["meo"] != [generation]:
        raise SystemExit("Stable release generation policy must be strict")
else:
    if repository_policy["meo-beta"] != [generation]:
        raise SystemExit("Beta overlay release generation policy must be strict")

transaction_packages = list(dict.fromkeys([*bootstrap_packages, channel_package, *packages]))
print("https://packages.meoarch.org")
print(*repos, sep="\n")
print("--generation--")
print(generation)
print("--policy-mode--")
print("explicit" if explicit_release_policy else "legacy")
print("--release-generations--")
print(*release_generations, sep="\n")
print("--generation-policy--")
for repo in repos:
    print(f"{repo}={','.join(repository_policy[repo])}")
print("--packages--")
print(*transaction_packages, sep="\n")
print("--bootstrap--")
print(*bootstrap_packages, channel_package, sep="\n")
PY
)" || { echo "Invalid Meo install plan; repository preflight stopped" >&2; exit 2; }
readarray -t plan_values <<<"$plan_output"

base_url="${plan_values[0]}"
repositories=(); packages=(); bootstrap_packages=(); release_generations=(); generation=""; policy_mode="legacy"; mode="repositories"
declare -A repository_generation_policy=()
for value in "${plan_values[@]:1}"; do
  if [ "$value" = "--generation--" ]; then mode="generation"; continue; fi
  if [ "$value" = "--policy-mode--" ]; then mode="policy-mode"; continue; fi
  if [ "$value" = "--release-generations--" ]; then mode="release-generations"; continue; fi
  if [ "$value" = "--generation-policy--" ]; then mode="generation-policy"; continue; fi
  if [ "$value" = "--packages--" ]; then mode="packages"; continue; fi
  if [ "$value" = "--bootstrap--" ]; then mode="bootstrap"; continue; fi
  case "$mode" in
    repositories) repositories+=("$value") ;;
    generation) generation="$value" ;;
    policy-mode) policy_mode="$value" ;;
    release-generations) release_generations+=("$value") ;;
    generation-policy)
      repository_generation_policy["${value%%=*}"]="${value#*=}"
      ;;
    packages) packages+=("$value") ;;
    bootstrap) bootstrap_packages+=("$value") ;;
  esac
done
work_dir="$(mktemp -d)"
trap 'rm -rf -- "$work_dir"' EXIT
available_packages=$'\n'
stable_packages=$'\n'
declare -A repository_release_versions=()
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
  if [ "$repository" = meo ]; then
    stable_packages+="$names"$'\n'
  fi
  repository_release_versions["$repository"]="$(python3 - "$db" <<'PY'
import sys, tarfile
versions = []
with tarfile.open(sys.argv[1], "r:*") as archive:
    for entry in archive:
        if not entry.isfile() or not entry.name.endswith("/desc"):
            continue
        fields = archive.extractfile(entry).read().decode("utf-8").splitlines()
        if "%NAME%" not in fields or "%VERSION%" not in fields:
            continue
        name = fields[fields.index("%NAME%") + 1]
        if name == "meo-release":
            versions.append(fields[fields.index("%VERSION%") + 1])
if len(versions) > 1:
    raise SystemExit("signed repository metadata contains duplicate meo-release records")
print(versions[0] if versions else "")
PY
)"
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

stable_release_version="${repository_release_versions[meo]:-}"
if [ -z "$stable_release_version" ]; then
  echo "Signed Stable metadata is missing meo-release" >&2
  exit 4
fi
if [ "$policy_mode" = legacy ]; then
  case "$stable_release_version" in
    "$generation"-*) ;;
    *)
      echo "Signed Stable meo-release generation does not match the installer catalog: expected $generation, found $stable_release_version" >&2
      exit 4
      ;;
  esac
else
  for repository in "${repositories[@]}"; do
    release_version="${repository_release_versions[$repository]:-}"
    [ -n "$release_version" ] || continue
    release_generation="${release_version%%-*}"
    allowed=",${repository_generation_policy[$repository]},"
    case "$allowed" in
      *",$release_generation,"*) ;;
      *)
        if [ "$repository" = meo ] && [ "${#repositories[@]}" -eq 1 ]; then
          echo "Signed Stable meo-release generation does not match the installer catalog: expected $generation, found $release_version" >&2
        else
          echo "Signed $repository meo-release generation is not allowed by the installer plan: allowed ${repository_generation_policy[$repository]}, found $release_version" >&2
        fi
        exit 4
        ;;
    esac
  done
fi

echo "Repository preflight = PASS"
