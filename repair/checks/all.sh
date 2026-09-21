#!/usr/bin/env bash
set -u -o pipefail

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
scope="${MEOARCH_REPAIR_SCOPE:-system}"
status=0

run_category() {
  local category="$1"
  printf '\n===== MeoArch %s check =====\n' "${category}"
  if "${script_dir}/${category}.sh"; then
    :
  else
    code="$?"
    printf 'MEO_FINDING|warning|%s.check_failed|The %s check returned a non-zero status (%s).\n' \
      "${category}" "${category}" "${code}"
    status=1
  fi
}

if [ "${scope}" = "live" ]; then
  printf '===== Diagnostic subject: Live Environment =====\n'
  echo 'MEO_FINDING|info|scope.live_environment|Hardware, session, network, graphics, audio, and Live security checks describe the currently booted Live environment.'
  for category in audio display network graphics security; do
    run_category "${category}"
  done

  printf '\n===== Diagnostic subject: Mounted Installed System (/mnt) =====\n'
  if [ -d /mnt/etc ] && [ -d /mnt/usr ]; then
    echo 'MEO_FINDING|info|scope.installed_target|Boot, package, and storage checks below describe the installed system mounted at /mnt where supported.'
  else
    echo 'MEO_FINDING|warning|scope.target_not_mounted|No installed system is mounted at /mnt; target-specific checks will report limited results.'
  fi
  for category in boot packages storage; do
    run_category "${category}"
  done
else
  printf '===== Diagnostic subject: Installed System =====\n'
  echo 'MEO_FINDING|info|scope.installed_system|All checks describe the currently running installed MeoArch system.'
  for category in audio display network boot packages storage graphics security; do
    run_category "${category}"
  done
fi

exit "${status}"
