#!/usr/bin/env sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
package_dir=$(CDPATH= cd -- "${script_dir}/.." && pwd)
sources_file=$(mktemp)
trap 'rm -f "${sources_file}"' EXIT HUP INT TERM

(
    cd "${package_dir}"
    find contents -type f \( -name '*.qml' -o -name '*.js' \) -print | LC_ALL=C sort
) > "${sources_file}"
xgettext --from-code=UTF-8 --language=JavaScript --keyword=i18n:1 \
    --package-name=plasma_applet_org.meo.timecenter \
    --directory="${package_dir}" --output="${script_dir}/template.pot" --files-from="${sources_file}"
msgmerge --update --backup=none --no-fuzzy-matching "${script_dir}/zh_CN.po" "${script_dir}/template.pot"
