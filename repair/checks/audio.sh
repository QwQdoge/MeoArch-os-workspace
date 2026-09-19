#!/usr/bin/env bash
set -u -o pipefail

echo "[audio] user audio services"
for unit in pipewire.service pipewire-pulse.service wireplumber.service; do
  state="$(systemctl --user is-active "${unit}" 2>/dev/null || true)"
  printf '%s: %s\n' "${unit}" "${state:-unavailable}"
  case "${unit}:${state}" in
    pipewire.service:active|pipewire-pulse.service:active|wireplumber.service:active) ;;
    pipewire.service:*)
      echo "MEO_FINDING|warning|audio.pipewire_inactive|The PipeWire user service is not active."
      ;;
    pipewire-pulse.service:*)
      echo "MEO_FINDING|warning|audio.pipewire_pulse_inactive|The PipeWire PulseAudio compatibility service is not active."
      ;;
    wireplumber.service:*)
      echo "MEO_FINDING|warning|audio.wireplumber_inactive|The WirePlumber session manager is not active."
      ;;
  esac
done

echo "[audio] Bluetooth transport"
if compgen -G '/sys/class/bluetooth/hci*' >/dev/null; then
  bluetooth_state="$(systemctl is-active bluetooth.service 2>/dev/null || true)"
  printf 'bluetooth.service: %s\n' "${bluetooth_state:-unavailable}"
  if [ "${bluetooth_state}" != active ]; then
    echo "MEO_FINDING|warning|audio.bluetooth_service_inactive|Bluetooth audio hardware is present, but the Bluetooth system service is not active."
  elif command -v bluetoothctl >/dev/null 2>&1; then
    bluetooth_controller="$(bluetoothctl show 2>/dev/null || true)"
    if [ -z "${bluetooth_controller}" ]; then
      echo "MEO_FINDING|warning|audio.bluetooth_controller_unavailable|Bluetooth hardware exists, but BlueZ cannot expose a usable controller."
    elif ! printf '%s\n' "${bluetooth_controller}" | grep -Eq '^[[:space:]]*Powered:[[:space:]]+yes$'; then
      echo "MEO_FINDING|info|audio.bluetooth_powered_off|The Bluetooth controller is powered off, so a wireless audio output cannot appear."
    fi
  else
    echo "MEO_FINDING|info|audio.bluetoothctl_missing|Bluetooth audio state cannot be inspected because the BlueZ control tool is unavailable."
  fi
fi

if ! command -v pactl >/dev/null 2>&1; then
  echo "MEO_FINDING|warning|audio.pactl_missing|The installed audio inspection interface is unavailable."
  exit 0
fi

echo "[audio] server"
pactl info 2>&1 || {
  echo "MEO_FINDING|warning|audio.server_unreachable|The desktop audio server could not be reached from this user session."
  exit 0
}

echo "[audio] outputs"
sinks="$(pactl list short sinks 2>&1 || true)"
printf '%s\n' "${sinks}"
sink_count="$(printf '%s\n' "${sinks}" | awk 'NF { count++ } END { print count + 0 }')"
if [ "${sink_count}" -eq 0 ]; then
  echo "MEO_FINDING|warning|audio.no_outputs|No audio output device is available to the desktop session."
  exit 0
fi
physical_sink_count="$(printf '%s\n' "${sinks}" | awk '
  NF && $2 !~ /(^|[._-])(auto_)?null($|[._-])/ && $2 !~ /(^|[._-])dummy($|[._-])/ { count++ }
  END { print count + 0 }
')"
if [ "${physical_sink_count}" -eq 0 ]; then
  echo "MEO_FINDING|warning|audio.no_physical_outputs|Only a dummy audio output is available; no hardware, HDMI, USB, or Bluetooth output is exposed to this session."
  exit 0
fi
if [ "${sink_count}" -gt 1 ]; then
  echo "MEO_FINDING|info|audio.multiple_outputs|Multiple audio outputs are available; the selected default may not be the device the user expects."
fi

default_sink="$(pactl get-default-sink 2>/dev/null || true)"
printf 'Default sink: %s\n' "${default_sink:-none}"
if [ -z "${default_sink}" ]; then
  echo "MEO_FINDING|warning|audio.no_default_output|No default audio output is selected."
elif ! printf '%s\n' "${sinks}" | awk -v sink="${default_sink}" '$2 == sink { found=1 } END { exit found ? 0 : 1 }'; then
  echo "MEO_FINDING|warning|audio.default_output_missing|The configured default audio output is no longer present."
else
  mute="$(pactl get-sink-mute "${default_sink}" 2>/dev/null || true)"
  volume="$(pactl get-sink-volume "${default_sink}" 2>/dev/null || true)"
  printf '%s\n%s\n' "${mute}" "${volume}"
  if printf '%s\n' "${mute}" | grep -Eqi '(^|[[:space:]])yes([[:space:]]|$)'; then
    echo "MEO_FINDING|warning|audio.output_muted|The current default audio output is muted."
  fi
  if printf '%s\n' "${volume}" | grep -Eq '(^|[[:space:]])0%([[:space:]]|$)'; then
    echo "MEO_FINDING|warning|audio.output_volume_zero|The current default audio output volume is zero."
  fi
fi

echo "[audio] PipeWire graph"
if command -v wpctl >/dev/null 2>&1; then
  pipewire_status="$(wpctl status 2>&1 || true)"
  printf '%s\n' "${pipewire_status}"
  saved_default="$(printf '%s\n' "${pipewire_status}" \
    | awk '$1 == "0." && $2 == "Audio/Sink" { print $3; exit }')"
  if [ -n "${saved_default}" ] \
    && ! printf '%s\n' "${sinks}" | awk -v sink="${saved_default}" '$2 == sink { found=1 } END { exit found ? 0 : 1 }'; then
    echo "MEO_FINDING|info|audio.saved_default_missing|The saved preferred audio output is not currently available; the desktop is using a fallback output."
  fi
else
  echo "MEO_FINDING|info|audio.wpctl_missing|Detailed PipeWire routing information is unavailable."
fi
