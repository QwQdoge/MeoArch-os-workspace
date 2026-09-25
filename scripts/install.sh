#!/usr/bin/env bash
set -Eeuo pipefail

install_root="${MEO_INSTALL_ROOT:-${XDG_CACHE_HOME:-${HOME}/.cache}/meo-installer}"
components_root="${install_root}/components"
meokde_root="${components_root}/meo-kde"
meoui_root="${components_root}/MeoUI"
meokde_ref="${MEO_KDE_REF:-main}"
meoui_ref="${MEO_UI_REF:-main}"

usage() {
  cat <<'EOF'
MeoArch desktop bootstrap

Usage:
  curl -fsSL https://raw.githubusercontent.com/QwQdoge/MeoArch-os-workspace/main/scripts/install.sh | bash
  curl -fsSL https://raw.githubusercontent.com/QwQdoge/MeoArch-os-workspace/main/scripts/install.sh | bash -s -- --full
  curl -fsSL https://raw.githubusercontent.com/QwQdoge/MeoArch-os-workspace/main/scripts/install.sh | bash -s -- --full --kde-only

This bootstrap downloads versioned MeoKDE and MeoUI snapshots into the user
cache, then hands control to MeoKDE's guided installer. It does not run pacman,
sudo, systemctl, or modify the live desktop itself.

Environment:
  MEO_INSTALL_ROOT  Cache root. Defaults to ~/.cache/meo-installer.
  MEO_KDE_REF       MeoKDE branch, tag, or commit. Defaults to main.
  MEO_UI_REF        MeoUI branch, tag, or commit. Defaults to main.

All remaining arguments are forwarded unchanged to MeoKDE/install.sh.
EOF
}

if [ "${1:-}" = "--help-bootstrap" ]; then
  usage
  exit 0
fi

if [ "$(uname -s)" != Linux ]; then
  echo "MeoArch desktop bootstrap requires Linux." >&2
  exit 1
fi

for command_name in curl tar mktemp; do
  if ! command -v "${command_name}" >/dev/null 2>&1; then
    echo "Required bootstrap command is unavailable: ${command_name}" >&2
    exit 1
  fi
done

mkdir -p "${components_root}"

download_component() {
  local repo="$1"
  local ref="$2"
  local destination="$3"
  local label="$4"
  local stage archive unpack next old

  stage="$(mktemp -d "${install_root}/.download-XXXXXX")"
  archive="${stage}/source.tar.gz"
  unpack="${stage}/source"
  next="${destination}.next"
  old="${destination}.old"

  cleanup_component_stage() {
    rm -rf "${stage}" "${next}"
  }
  trap cleanup_component_stage RETURN

  printf '\n==> Downloading %s (%s)\n' "${label}" "${ref}"
  curl \
    --fail \
    --location \
    --retry 3 \
    --retry-delay 1 \
    --proto '=https' \
    --tlsv1.2 \
    --output "${archive}" \
    "https://api.github.com/repos/${repo}/tarball/${ref}"

  mkdir -p "${unpack}"
  tar -xzf "${archive}" -C "${unpack}" --strip-components=1

  rm -rf "${next}" "${old}"
  mv "${unpack}" "${next}"

  if [ -e "${destination}" ]; then
    mv "${destination}" "${old}"
  fi

  if ! mv "${next}" "${destination}"; then
    if [ -e "${old}" ]; then
      mv "${old}" "${destination}"
    fi
    echo "Failed to activate downloaded ${label} snapshot." >&2
    return 1
  fi

  rm -rf "${old}" "${stage}"
  trap - RETURN
}

download_component "QwQdoge/meo-kde" "${meokde_ref}" "${meokde_root}" "MeoKDE"
download_component "QwQdoge/MeoUI" "${meoui_ref}" "${meoui_root}" "MeoUI"

if [ ! -x "${meokde_root}/install.sh" ]; then
  echo "Downloaded MeoKDE snapshot does not contain an executable install.sh." >&2
  exit 1
fi

if [ ! -f "${meoui_root}/CMakeLists.txt" ]; then
  echo "Downloaded MeoUI snapshot is incomplete." >&2
  exit 1
fi

export MEO_UI_ROOT="${meoui_root}"

printf '\n==> Starting the Meo Desktop installer\n'
printf '    MeoKDE: %s\n' "${meokde_ref}"
printf '    MeoUI:  %s\n\n' "${meoui_ref}"

# curl | bash consumes stdin, while the real installer is intentionally
# interactive. Reattach stdin/stdout to the controlling terminal when one is
# available so the Yes/No wizard still works from the one-line command.
if [ -r /dev/tty ] && [ -w /dev/tty ]; then
  exec "${meokde_root}/install.sh" "$@" </dev/tty >/dev/tty
fi

exec "${meokde_root}/install.sh" "$@"
