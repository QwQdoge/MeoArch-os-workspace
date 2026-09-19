#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
package_dir=$(CDPATH= cd -- "${script_dir}/.." && pwd)
catalog_path="${package_dir}/contents/locale/zh_CN/LC_MESSAGES/plasma_applet_org.meo.topbar.mo"

mkdir -p "$(dirname -- "${catalog_path}")"
msgfmt --check --output-file="${catalog_path}" "${script_dir}/zh_CN.po"
