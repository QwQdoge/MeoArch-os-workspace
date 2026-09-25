#!/usr/bin/env bash
set -Eeuo pipefail

channel="stable"
profile="recommended"
full_mode=0
dry_run=0
apply_desktop=1
force_no_color=0

bootstrap_base="https://raw.githubusercontent.com/QwQdoge/MeoArch-os-workspace/main/installer/bootstrap"
stable_repo_server='https://packages.meoarch.org/$repo/os/$arch'
pacman_include='Include = /etc/pacman.d/meo-channel.conf'

declare -A bootstrap_sha256=(
  [meo.gpg]="67912eaaab10f6b57658c9aad9854bd8023cc99e3cb99a2320d5c175ec87e5e9"
  [meo-trusted]="53044baf901563b0ee354ae995ecd702b461b00319a5461df269882e2f1d8bfb"
  [meo-revoked]="bf84cedbff5a2ed7f27e1c39fba21db4bf54807190219248f245d47149e224f8"
)

usage() {
  cat <<'EOF'
MeoArch desktop installer

Usage:
  curl -fsSL https://raw.githubusercontent.com/QwQdoge/MeoArch-os-workspace/main/scripts/install.sh | bash

  curl -fsSL https://raw.githubusercontent.com/QwQdoge/MeoArch-os-workspace/main/scripts/install.sh \
    | bash -s -- --full

Options:
  --full        Install the Stable recommended MeoArch desktop without prompts.
  --beta        Use the signed Beta overlay (meo-beta -> meo).
  --stable      Use the Stable channel (default).
  --core        Install meo-core-meta instead of the recommended app bundle.
  --kde-only    Alias for --core.
  --no-apply    Install packages but do not activate/reset the current Plasma layout.
  --dry-run     Show the package/repository plan without modifying the system.
  --no-color    Disable ANSI color.
  -h, --help    Show this help.

Package model:
  Meo-owned software is installed from packages.meoarch.org through pacman.
  Arch/Qt/KDE upstream dependencies continue to come from the configured Arch
  repositories. No Meo component source tree is cloned or built on the client.
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --full) full_mode=1; channel="stable"; profile="recommended"; apply_desktop=1 ;;
    --beta) channel="beta" ;;
    --stable) channel="stable" ;;
    --core|--kde-only) profile="core" ;;
    --no-apply) apply_desktop=0 ;;
    --dry-run) dry_run=1 ;;
    --no-color) force_no_color=1 ;;
    -h|--help) usage; exit 0 ;;
    *) printf 'Unknown option: %s\n\n' "$1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

interactive=0
if [ -r /dev/tty ] && [ -w /dev/tty ] && [ "${full_mode}" -eq 0 ]; then
  interactive=1
  exec 3</dev/tty
else
  exec 3<&0
fi

use_color=0
if [ "${force_no_color}" -eq 0 ] && [ -z "${NO_COLOR:-}" ] && [ -t 1 ]; then
  use_color=1
fi

if [ "${use_color}" -eq 1 ]; then
  reset=$'\033[0m'
  bold=$'\033[1m'
  accent=$'\033[38;5;111m'
  good=$'\033[38;5;114m'
  warn=$'\033[38;5;221m'
  bad=$'\033[38;5;203m'
  muted=$'\033[38;5;245m'
else
  reset=''; bold=''; accent=''; good=''; warn=''; bad=''; muted=''
fi

section() {
  printf '\n%s==> %s%s\n' "${accent}" "$1" "${reset}"
}

ok() {
  printf '  %s[ok]%s %s\n' "${good}" "${reset}" "$1"
}

note() {
  printf '  %s- %s%s\n' "${muted}" "$1" "${reset}"
}

warning() {
  printf '  %s[!]%s %s\n' "${warn}" "${reset}" "$1"
}

die() {
  printf '\n%sError:%s %s\n' "${bad}${bold}" "${reset}" "$*" >&2
  exit 1
}

ask_yes_no() {
  local question="$1"
  local default_answer="${2:-yes}"
  local answer suffix

  if [ "${interactive}" -eq 0 ]; then
    [ "${default_answer}" = yes ]
    return
  fi

  if [ "${default_answer}" = yes ]; then
    suffix="[Y/n]"
  else
    suffix="[y/N]"
  fi

  while true; do
    printf '  %s?%s %s %s ' "${bold}" "${reset}" "${question}" "${suffix}" >/dev/tty
    IFS= read -r answer <&3 || answer=""
    case "${answer,,}" in
      y|yes) return 0 ;;
      n|no) return 1 ;;
      "") [ "${default_answer}" = yes ]; return ;;
      *) warning "Please answer yes or no." ;;
    esac
  done
}

require_command() {
  command -v "$1" >/dev/null 2>&1 || die "Required command is unavailable: $1"
}

if [ "$(uname -s)" != Linux ] || [ ! -e /etc/arch-release ]; then
  die "This installer currently supports existing Arch Linux systems."
fi

for command_name in pacman pacman-conf pacman-key curl sha256sum mktemp awk grep; do
  require_command "${command_name}"
done

if [ "${interactive}" -eq 1 ]; then
  section "Install profile"

  if ask_yes_no "Use the Beta channel?" no; then
    channel="beta"
  else
    channel="stable"
  fi

  if ask_yes_no "Install the complete recommended Meo app bundle?" yes; then
    profile="recommended"
  else
    profile="core"
  fi

  if ask_yes_no "Apply the Meo Plasma theme and recommended panel layout after installation?" yes; then
    apply_desktop=1
  else
    apply_desktop=0
  fi
fi

case "${profile}" in
  recommended) meta_package="meo-recommended-meta" ;;
  core) meta_package="meo-core-meta" ;;
  *) die "Unsupported install profile: ${profile}" ;;
esac

case "${channel}" in
  stable) channel_package="meo-channel-stable"; expected_repositories=("meo") ;;
  beta) channel_package="meo-channel-beta"; expected_repositories=("meo-beta" "meo") ;;
  *) die "Unsupported channel: ${channel}" ;;
esac

section "Plan"
note "Channel: ${channel}"
note "Package profile: ${meta_package}"
note "Meo software source: signed packages.meoarch.org repository"
note "Arch/Qt/KDE dependencies: configured Arch repositories"
if [ "${apply_desktop}" -eq 1 ]; then
  note "After packages install: apply Meo Look-and-Feel and recommended Plasma layout"
else
  note "Current Plasma layout will not be activated/reset"
fi
note "No Meo source repositories will be cloned or compiled on this machine."

if [ "${dry_run}" -eq 1 ]; then
  section "Dry run"
  note "Would bootstrap Meo public trust material if [meo] is not configured."
  note "Would install: meo-keyring meo-mirrorlist ${channel_package} meo-release"
  note "Would install: ${meta_package}"
  [ "${apply_desktop}" -eq 0 ] || note "Would run: meo-desktop-apply --reset-layout"
  exit 0
fi

if [ "${interactive}" -eq 1 ] && ! ask_yes_no "Continue with this plan?" yes; then
  note "Cancelled before any system changes."
  exit 0
fi

require_command sudo
sudo -v

work_dir="$(mktemp -d)"
backup_root="/var/lib/meo-desktop/bootstrap-backups/$(date -u +%Y%m%dT%H%M%SZ)"
pacman_backup="${backup_root}/pacman.conf"
temporary_keyring=0
pacman_conf_changed=0

cleanup() {
  rm -rf -- "${work_dir}"
}
trap cleanup EXIT

rollback_on_error() {
  local status=$?
  if [ "${status}" -eq 0 ]; then
    return
  fi

  printf '\n%sInstallation stopped%s (exit %d).\n' "${bad}${bold}" "${reset}" "${status}" >&2
  if [ "${pacman_conf_changed}" -eq 1 ] && sudo test -f "${pacman_backup}"; then
    warning "Restoring /etc/pacman.conf from the pre-install backup."
    sudo cp -a "${pacman_backup}" /etc/pacman.conf || true
  fi
  exit "${status}"
}
trap rollback_on_error ERR

repo_configured=0
mapfile -t current_repositories < <(pacman-conf --repo-list 2>/dev/null || true)
for repository in "${current_repositories[@]}"; do
  if [ "${repository}" = meo ]; then
    repo_configured=1
    break
  fi
done

bootstrap_trust() {
  local filename destination actual expected

  section "Bootstrapping Meo package trust"
  for filename in meo.gpg meo-trusted meo-revoked; do
    destination="${work_dir}/${filename}"
    curl \
      --fail \
      --silent \
      --show-error \
      --location \
      --retry 3 \
      --proto '=https' \
      --tlsv1.2 \
      --output "${destination}" \
      "${bootstrap_base}/${filename}"

    actual="$(sha256sum "${destination}" | awk '{print $1}')"
    expected="${bootstrap_sha256[${filename}]}"
    [ "${actual}" = "${expected}" ] || die "Bootstrap hash mismatch for ${filename}."
  done
  ok "Pinned Meo public keyring payload verified"

  if pacman -Q meo-keyring >/dev/null 2>&1; then
    sudo pacman-key --init
    sudo pacman-key --populate archlinux meo
    ok "Existing meo-keyring populated into pacman trust database"
    return
  fi

  for filename in meo.gpg meo-trusted meo-revoked; do
    destination="/usr/share/pacman/keyrings/${filename}"
    if sudo test -e "${destination}"; then
      if sudo pacman -Qo "${destination}" >/dev/null 2>&1; then
        die "Unexpected package-owned bootstrap path exists: ${destination}"
      fi
      die "Unowned Meo keyring path already exists: ${destination}"
    fi
    sudo install -Dm644 "${work_dir}/${filename}" "${destination}"
  done
  temporary_keyring=1

  sudo pacman-key --init
  sudo pacman-key --populate archlinux meo

  for filename in meo.gpg meo-trusted meo-revoked; do
    sudo rm -f "/usr/share/pacman/keyrings/${filename}"
  done
  temporary_keyring=0
  ok "Meo signing key populated without leaving unowned keyring files"
}

build_bootstrap_pacman_conf() {
  local output="$1"
  cat /etc/pacman.conf >"${output}"
  cat >>"${output}" <<EOF

[meo]
SigLevel = Required TrustedOnly
Server = ${stable_repo_server}
EOF
}

install_repository_controls() {
  local bootstrap_conf="${work_dir}/pacman-bootstrap.conf"

  build_bootstrap_pacman_conf "${bootstrap_conf}"

  section "Installing repository controls"
  note "This is one full pacman sync/upgrade transaction; no partial upgrade is used."
  sudo pacman --config "${bootstrap_conf}" -Syu --needed \
    meo/meo-keyring \
    meo/meo-mirrorlist \
    "meo/${channel_package}" \
    meo/meo-release

  sudo install -d -m755 "${backup_root}"
  sudo cp -a /etc/pacman.conf "${pacman_backup}"

  if ! grep -Fqx "${pacman_include}" /etc/pacman.conf; then
    printf '\n# MeoArch signed package channel. meo-channel-* owns the included file.\n%s\n' \
      "${pacman_include}" | sudo tee -a /etc/pacman.conf >/dev/null
    pacman_conf_changed=1
  fi
}

if [ "${repo_configured}" -eq 0 ]; then
  bootstrap_trust
  install_repository_controls
else
  section "Meo repository"
  ok "A Meo repository is already configured"

  section "Selecting channel"
  sudo pacman -Syu --needed "${channel_package}" meo-release
fi

section "Verifying repository order"
mapfile -t resolved_meo_repositories < <(
  pacman-conf --repo-list | awk '$0 == "meo" || $0 == "meo-beta" { print }'
)

if [ "${#resolved_meo_repositories[@]}" -ne "${#expected_repositories[@]}" ]; then
  die "Meo repository order is incomplete after channel setup."
fi
for index in "${!expected_repositories[@]}"; do
  if [ "${resolved_meo_repositories[${index}]}" != "${expected_repositories[${index}]}" ]; then
    die "Unexpected Meo repository order after channel setup."
  fi
done
ok "Repository order: ${resolved_meo_repositories[*]}"

section "Installing MeoArch"
note "pacman will resolve Meo-owned packages from the selected Meo channel and upstream dependencies from Arch."
sudo pacman -Syu --needed "${meta_package}"

if [ "${apply_desktop}" -eq 1 ]; then
  section "Applying Meo Plasma experience"
  if command -v meo-desktop-apply >/dev/null 2>&1; then
    meo-desktop-apply --reset-layout
  else
    warning "meo-desktop-apply is unavailable after package installation; packages are installed but the current Plasma layout was not activated."
  fi
fi

trap - ERR

section "Finished"
ok "MeoArch packages installed through pacman"
note "Future Meo updates now arrive through normal pacman/OmniStore updates."
note "No Meo component source checkout was installed."
note "The installer did not force a logout or reboot."
if [ "${apply_desktop}" -eq 1 ]; then
  note "Log out and sign back into Plasma when convenient so all native integration is reloaded."
fi
