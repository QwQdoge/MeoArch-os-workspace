#!/usr/bin/env bash
set -u -o pipefail

echo "[display] kernel connector state"
kernel_connected=0
for status_path in /sys/class/drm/*/status; do
  [ -r "${status_path}" ] || continue
  state="$(tr -d '\r\n' <"${status_path}")"
  connector="${status_path%/status}"
  connector="${connector##*/}"
  printf '%s: %s\n' "${connector}" "${state}"
  [ "${state}" = "connected" ] && kernel_connected="$((kernel_connected + 1))"
done
if [ "${kernel_connected}" -lt 2 ]; then
  echo "MEO_FINDING|info|display.second_connector_not_detected|The kernel currently detects fewer than two connected display connectors."
fi

if ! command -v kscreen-doctor >/dev/null 2>&1; then
  echo "MEO_FINDING|warning|display.kscreen_unavailable|KScreen display configuration is unavailable in this session."
  exit 0
fi

echo "[display] KScreen outputs"
outputs="$(NO_COLOR=1 kscreen-doctor -o 2>&1)"
status="$?"
plain_outputs="$(printf '%s\n' "${outputs}" | sed -E 's/\x1B\[[0-9;]*[mK]//g')"
printf '%s\n' "${plain_outputs}"
if [ "${status}" -ne 0 ]; then
  echo "MEO_FINDING|warning|display.kscreen_query_failed|KScreen could not read the current display configuration."
  exit 0
fi

connected_count="$(printf '%s\n' "${plain_outputs}" | grep -c '^Output:' || true)"
enabled_count="$(printf '%s\n' "${plain_outputs}" | grep -c $'^\tenabled$' || true)"
if [ "${connected_count}" -lt 2 ]; then
  echo "MEO_FINDING|info|display.second_output_not_available|KScreen currently reports fewer than two connected displays."
fi
if [ "${connected_count}" -gt "${enabled_count}" ]; then
  echo "MEO_FINDING|warning|display.connected_output_disabled|At least one connected display is disabled in the current layout."
fi
if [ "${kernel_connected}" -gt "${connected_count}" ]; then
  echo "MEO_FINDING|warning|display.session_missing_connector|The kernel detects a connected display that is missing from the desktop display configuration."
fi
