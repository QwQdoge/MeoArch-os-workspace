#!/usr/bin/env bash
set -u -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
status=0
for category in network boot packages storage graphics security; do
  printf '\n===== MeoArch %s check =====\n' "${category}"
  if "${script_dir}/${category}.sh"; then
    :
  else
    code="$?"
    printf 'MEO_FINDING|warning|%s.check_failed|The %s check returned a non-zero status (%s).\n' \
      "${category}" "${category}" "${code}"
    status=1
  fi
done
exit "${status}"
