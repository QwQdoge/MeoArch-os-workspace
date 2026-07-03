#!/usr/bin/env bash
set -euo pipefail

VERSION="${MEO_UI_VERSION:-0.2.0}"
INSTALL_ROOT="${MEO_UI_PREFIX:-/opt/meo-ui}"
QML_TARGET="${INSTALL_ROOT}/qml/Meo/UI"
QML_COMPAT_TARGET="${INSTALL_ROOT}/qml/MeoUI"
FONT_TARGET="${MEO_UI_FONT_DIR:-/usr/local/share/fonts/meo-ui}"
VERSION_FILE="${INSTALL_ROOT}/VERSION"

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -d "${SCRIPT_DIR}/qml/Meo/UI" || -d "${SCRIPT_DIR}/out/build/showcase/MeoUI" ]]; then
    PACKAGE_ROOT="${SCRIPT_DIR}"
else
    PACKAGE_ROOT="$(cd -- "${SCRIPT_DIR}/.." && pwd)"
fi

die() {
    echo "error: $*" >&2
    exit 1
}

need_cmd() {
    command -v "$1" >/dev/null 2>&1 || die "missing required command: $1"
}

confirm() {
    local prompt="$1"
    local answer
    read -r -p "${prompt} [y/N] " answer
    case "${answer}" in
        y|Y|yes|YES) return 0 ;;
        *) return 1 ;;
    esac
}

version_cmp() {
    local a="$1"
    local b="$2"
    if [[ "${a}" == "${b}" ]]; then
        echo 0
        return
    fi
    local first
    first="$(printf '%s\n%s\n' "${a}" "${b}" | sort -V | head -n1)"
    if [[ "${first}" == "${a}" ]]; then
        echo -1
    else
        echo 1
    fi
}

copy_dir() {
    local src="$1"
    local dst="$2"
    mkdir -p "${dst}"
    if command -v rsync >/dev/null 2>&1; then
        rsync -a --delete "${src}/" "${dst}/"
    else
        find "${dst}" -mindepth 1 -maxdepth 1 -exec rm -rf {} +
        cp -a "${src}/." "${dst}/"
    fi
}

if [[ "$(uname -s)" != "Linux" ]]; then
    die "this installer only supports Linux"
fi

need_cmd cp
need_cmd find
need_cmd sort
need_cmd awk

QML_SOURCE="${MEO_UI_QML_SOURCE:-${PACKAGE_ROOT}/qml/Meo/UI}"
FONT_SOURCE="${MEO_UI_FONT_SOURCE:-${PACKAGE_ROOT}/fonts}"

if [[ ! -d "${QML_SOURCE}" && -d "${PACKAGE_ROOT}/out/build/showcase/MeoUI" ]]; then
    QML_SOURCE="${PACKAGE_ROOT}/out/build/showcase/MeoUI"
fi

if [[ ! -d "${FONT_SOURCE}" && -d "${QML_SOURCE}/assets/fonts" ]]; then
    FONT_SOURCE="${QML_SOURCE}/assets/fonts"
fi

[[ -d "${QML_SOURCE}" ]] || die "QML source directory not found: ${QML_SOURCE}"
[[ -f "${QML_SOURCE}/qmldir" ]] || die "QML source is missing qmldir: ${QML_SOURCE}/qmldir"
[[ -d "${FONT_SOURCE}" ]] || die "font source directory not found: ${FONT_SOURCE}"

if [[ -f "${VERSION_FILE}" ]]; then
    INSTALLED_VERSION="$(tr -d '[:space:]' < "${VERSION_FILE}")"
    CMP="$(version_cmp "${VERSION}" "${INSTALLED_VERSION}")"
    if [[ "${CMP}" == "0" ]]; then
        confirm "Meo UI runtime ${VERSION} is already installed. Overwrite it?" || exit 0
    elif [[ "${CMP}" == "-1" ]]; then
        confirm "Installed version is ${INSTALLED_VERSION}; requested ${VERSION} is older. Downgrade?" || exit 0
    else
        confirm "Upgrade Meo UI runtime from ${INSTALLED_VERSION} to ${VERSION}?" || exit 0
    fi
elif [[ -d "${QML_TARGET}" || -L "${QML_COMPAT_TARGET}" || -d "${FONT_TARGET}" ]]; then
    confirm "Existing Meo UI files were found without a version marker. Overwrite them?" || exit 0
fi

if [[ "${EUID}" -ne 0 ]]; then
    if command -v sudo >/dev/null 2>&1; then
        exec sudo MEO_UI_VERSION="${VERSION}" MEO_UI_PREFIX="${INSTALL_ROOT}" MEO_UI_FONT_DIR="${FONT_TARGET}" MEO_UI_QML_SOURCE="${QML_SOURCE}" MEO_UI_FONT_SOURCE="${FONT_SOURCE}" bash "$0"
    fi
    die "root privileges are required to install to ${INSTALL_ROOT} and ${FONT_TARGET}"
fi

mkdir -p "${INSTALL_ROOT}/qml/Meo" "${FONT_TARGET}"
copy_dir "${QML_SOURCE}" "${QML_TARGET}"
copy_dir "${FONT_SOURCE}" "${FONT_TARGET}"

rm -f "${QML_TARGET}/libmeoui_moduleplugin.a" "${QML_TARGET}/meoui_module_qml_module_dir_map.qrc"

if [[ -f "${QML_TARGET}/qmldir" ]]; then
    awk '!/^(linktarget|optional plugin|classname|prefer)[[:space:]]/' "${QML_TARGET}/qmldir" > "${QML_TARGET}/qmldir.tmp"
    mv "${QML_TARGET}/qmldir.tmp" "${QML_TARGET}/qmldir"
fi

rm -rf "${QML_COMPAT_TARGET}"
ln -s "${QML_TARGET}" "${QML_COMPAT_TARGET}"

printf '%s\n' "${VERSION}" > "${VERSION_FILE}"

if command -v fc-cache >/dev/null 2>&1; then
    fc-cache -f "${FONT_TARGET}" >/dev/null
fi

cat <<EOF
Meo UI runtime ${VERSION} installed.
QML:   ${QML_TARGET}
Fonts: ${FONT_TARGET}
Compat import path: ${QML_COMPAT_TARGET}

For Qt apps, add this import path:
  ${INSTALL_ROOT}/qml
EOF
