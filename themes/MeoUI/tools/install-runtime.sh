#!/usr/bin/env bash
set -euo pipefail

version="${MEO_UI_VERSION:-0.3.1}"
action="install"
install_root="${MEO_UI_PREFIX:-/opt/meo-ui}"
font_target="${MEO_UI_FONT_DIR:-/usr/local/share/fonts/meo-ui}"
qml_source="${MEO_UI_QML_SOURCE:-}"
font_source="${MEO_UI_FONT_SOURCE:-}"
yes=0

usage() {
  cat <<'EOF'
Usage: install-runtime.sh [install|update|upgrade|verify|uninstall] [options]

Options:
  --prefix DIR      Install root. Default: /opt/meo-ui
  --font-dir DIR    Font install dir. Default: /usr/local/share/fonts/meo-ui
  --qml-source DIR  QML module source directory.
  --font-source DIR Font source directory.
  --version VALUE   Version marker. Default: 0.3.1
  -y, --yes         Non-interactive approval.
  -h, --help        Show this help.
EOF
}

die() {
  echo "error: $*" >&2
  exit 1
}

confirm() {
  if [[ "$yes" -eq 1 ]]; then
    return 0
  fi
  local answer
  read -r -p "$1 [y/N] " answer
  case "$answer" in y|Y|yes|YES) return 0 ;; *) return 1 ;; esac
}

copy_dir() {
  local src="$1"
  local dst="$2"
  mkdir -p "$dst"
  if command -v rsync >/dev/null 2>&1; then
    rsync -a --delete "$src/" "$dst/"
  else
    find "$dst" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
    cp -a "$src/." "$dst/"
  fi
}

remove_path() {
  local path="$1"
  if [[ -L "$path" || -e "$path" ]]; then
    rm -rf "$path"
  fi
}

version_cmp() {
  local a="$1"
  local b="$2"
  if [[ "$a" == "$b" ]]; then echo 0; return; fi
  local first
  first="$(printf '%s\n%s\n' "$a" "$b" | sort -V | head -n1)"
  [[ "$first" == "$a" ]] && echo -1 || echo 1
}

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "$script_dir/qml/Meo/UI" || -d "$script_dir/components" ]]; then
  package_root="$script_dir"
else
  package_root="$(cd -- "$script_dir/.." && pwd)"
fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    install|update|upgrade|verify|uninstall) action="$1"; shift ;;
    --prefix) install_root="$2"; shift 2 ;;
    --font-dir) font_target="$2"; shift 2 ;;
    --qml-source) qml_source="$2"; shift 2 ;;
    --font-source) font_source="$2"; shift 2 ;;
    --version) version="$2"; shift 2 ;;
    -y|--yes) yes=1; shift ;;
    -h|--help) usage; exit 0 ;;
    *) die "unknown option or action: $1" ;;
  esac
done

[[ "$(uname -s)" == "Linux" ]] || die "use tools/install-runtime.ps1 on Windows"

qml_target="$install_root/qml/Meo/UI"
qml_compat_target="$install_root/qml/MeoUI"
version_file="$install_root/VERSION"
manifest_file="$install_root/install-manifest.txt"

resolve_sources() {
  if [[ -z "$qml_source" ]]; then
    if [[ -d "$package_root/qml/Meo/UI" ]]; then
      qml_source="$package_root/qml/Meo/UI"
    elif [[ -d "$package_root/out/build/showcase/MeoUI" ]]; then
      qml_source="$package_root/out/build/showcase/MeoUI"
    elif [[ -f "$package_root/MeoTheme.qml" && -d "$package_root/components" ]]; then
      qml_source="$package_root"
    fi
  fi
  if [[ -z "$font_source" ]]; then
    if [[ -d "$package_root/fonts" ]]; then
      font_source="$package_root/fonts"
    elif [[ -d "$qml_source/assets/fonts" ]]; then
      font_source="$qml_source/assets/fonts"
    elif [[ -d "$package_root/assets/fonts" ]]; then
      font_source="$package_root/assets/fonts"
    fi
  fi
}

needs_root() {
  local target="$1"
  [[ "$EUID" -ne 0 && "$target" == /* && "$target" != "$HOME"/* ]]
}

reexec_with_sudo_if_needed() {
  if needs_root "$install_root" || needs_root "$font_target"; then
    command -v sudo >/dev/null 2>&1 || die "root privileges are required; choose user-writable --prefix/--font-dir or install sudo"
    local args=("$action" --prefix "$install_root" --font-dir "$font_target" --qml-source "$qml_source" --font-source "$font_source" --version "$version")
    [[ "$yes" -eq 1 ]] && args+=(--yes)
    exec sudo bash "$0" "${args[@]}"
  fi
}

sanitize_qmldir() {
  awk '!/^(linktarget|optional plugin|classname|prefer)[[:space:]]/' "$1" > "$1.tmp"
  mv "$1.tmp" "$1"
}

generate_qmldir() {
  local root="$1"
  {
    echo "module MeoUI"
    echo "singleton MeoTheme 1.0 MeoTheme.qml"
    for subdir in components widgets patterns showcase; do
      [[ -d "$root/$subdir" ]] || continue
      find "$root/$subdir" -type f -name "*.qml" | sort | while read -r qml_file; do
        relative_path="${qml_file#"$root"/}"
        type_name="$(basename "$qml_file" .qml)"
        echo "$type_name 1.0 $relative_path"
      done
    done
    echo "depends QtQuick"
  } > "$root/qmldir"
}

verify_runtime() {
  local failed=0
  for path in "$version_file" "$qml_target/MeoTheme.qml" "$qml_target/qmldir" "$qml_compat_target"; do
    [[ -e "$path" || -L "$path" ]] || { echo "missing: $path" >&2; failed=1; }
  done
  for font in MaterialSymbolsRounded.ttf Roboto-Regular.ttf Roboto-Medium.ttf Roboto-Bold.ttf Comfortaa-Bold.ttf; do
    [[ -f "$font_target/$font" ]] || { echo "missing: $font_target/$font" >&2; failed=1; }
  done
  if [[ "$failed" -eq 0 ]]; then
    echo "MeoUI runtime verified."
    echo "Version: $(tr -d '[:space:]' < "$version_file")"
    echo "QML import path: $install_root/qml"
    echo "Fonts: $font_target"
  fi
  return "$failed"
}

install_runtime() {
  resolve_sources
  [[ -d "$qml_source" ]] || die "QML source directory not found"
  [[ -d "$font_source" ]] || die "font source directory not found"
  reexec_with_sudo_if_needed

  if [[ -f "$version_file" ]]; then
    installed_version="$(tr -d '[:space:]' < "$version_file")"
    cmp="$(version_cmp "$version" "$installed_version")"
    case "$action" in
      install)
        if [[ "$cmp" == "-1" ]]; then
          confirm "Installed version is $installed_version; requested $version is older. Downgrade?" || exit 0
        elif [[ "$cmp" == "0" ]]; then
          confirm "MeoUI runtime $version is already installed. Reinstall it?" || exit 0
        else
          confirm "Upgrade MeoUI runtime from $installed_version to $version?" || exit 0
        fi
        ;;
      update)
        confirm "Update MeoUI runtime at $install_root to $version?" || exit 0
        ;;
      upgrade)
        [[ "$cmp" == "1" ]] || die "upgrade requires a newer version than installed $installed_version"
        confirm "Upgrade MeoUI runtime from $installed_version to $version?" || exit 0
        ;;
    esac
  elif [[ -d "$qml_target" || -L "$qml_compat_target" || -d "$font_target" ]]; then
    confirm "Existing MeoUI files were found without a version marker. Overwrite them?" || exit 0
  fi

  mkdir -p "$install_root/qml/Meo" "$font_target"
  copy_dir "$qml_source" "$qml_target"
  copy_dir "$font_source" "$font_target"
  remove_path "$qml_target/libmeoui_moduleplugin.a"
  remove_path "$qml_target/meoui_module_qml_module_dir_map.qrc"
  if [[ -f "$qml_target/qmldir" ]]; then
    sanitize_qmldir "$qml_target/qmldir"
  else
    generate_qmldir "$qml_target"
  fi
  remove_path "$qml_compat_target"
  ln -s "$qml_target" "$qml_compat_target"
  printf '%s\n' "$version" > "$version_file"
  printf '%s\n' "$version_file" "$qml_target" "$qml_compat_target" "$font_target" > "$manifest_file"
  command -v fc-cache >/dev/null 2>&1 && fc-cache -f "$font_target" >/dev/null || true
  verify_runtime
}

uninstall_runtime() {
  reexec_with_sudo_if_needed
  [[ -e "$install_root" || -e "$font_target" ]] || { echo "MeoUI runtime is not installed."; return 0; }
  confirm "Remove MeoUI runtime from $install_root and fonts from $font_target?" || exit 0
  remove_path "$qml_compat_target"
  remove_path "$qml_target"
  remove_path "$install_root/qml/Meo"
  remove_path "$install_root/qml"
  remove_path "$version_file"
  remove_path "$manifest_file"
  remove_path "$font_target"
  rmdir "$install_root" 2>/dev/null || true
  command -v fc-cache >/dev/null 2>&1 && fc-cache -f >/dev/null || true
  echo "MeoUI runtime uninstalled."
}

case "$action" in
  install|update|upgrade) install_runtime ;;
  verify) verify_runtime ;;
  uninstall) uninstall_runtime ;;
  *) die "unknown action: $action" ;;
esac
