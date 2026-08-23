#!/usr/bin/env bash
set -u -o pipefail

if ! command -v lynis >/dev/null 2>&1; then
  echo "MEO_FINDING|warning|security.lynis_missing|Lynis is not installed."
  exit 127
fi

state_dir="$(mktemp -d /tmp/meoarch-repair-lynis.XXXXXX)"
case "${state_dir}" in
  /tmp/meoarch-repair-lynis.*) ;;
  *) echo "Unsafe temporary directory." >&2; exit 2 ;;
esac
trap 'rm -rf -- "${state_dir}"' EXIT
report="${state_dir}/report.dat"
log="${state_dir}/audit.log"

lynis audit system --quick --no-colors --auditor "MeoArch Repair" \
  --report-file "${report}" --log-file "${log}" 2>&1 || status="$?"
status="${status:-0}"

if [ -r "${report}" ]; then
  hardening="$(sed -n 's/^hardening_index=//p' "${report}" | tail -n 1)"
  tests="$(sed -n 's/^tests_executed=//p' "${report}" | tail -n 1)"
  printf 'Lynis hardening index: %s; tests: %s\n' "${hardening:-unknown}" "${tests:-unknown}"
  count=0
  while IFS= read -r line && [ "${count}" -lt 80 ]; do
    case "${line}" in
      warning\[\]=*)
        printf 'MEO_FINDING|warning|security.lynis_warning|%s\n' "${line#*=}" | cut -c1-700
        count="$((count + 1))"
        ;;
      suggestion\[\]=*)
        printf 'MEO_FINDING|suggestion|security.lynis_suggestion|%s\n' "${line#*=}" | cut -c1-700
        count="$((count + 1))"
        ;;
    esac
  done <"${report}"
else
  echo "MEO_FINDING|warning|security.no_report|Lynis did not produce a structured report."
fi
exit "${status}"
