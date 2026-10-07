#!/usr/bin/env bash
set -u -o pipefail

# Read-only Fcitx 5 / Wayland diagnostics for Meo Repair.
# This check never installs packages, edits config, starts services, or executes
# model-provided commands. It only inspects fixed local state.

echo "[input-method] session"
printf 'Session type: %s\n' "${XDG_SESSION_TYPE:-unknown}"
printf 'Desktop: %s\n' "${XDG_CURRENT_DESKTOP:-unknown}"

if [ "${XDG_SESSION_TYPE:-}" != "wayland" ]; then
  echo "MEO_FINDING|info|input_method.not_wayland|The current session is not Wayland, so the Meo-managed Wayland input-method path cannot be fully verified here."
fi

echo "[input-method] framework"
if [ ! -x /usr/bin/fcitx5 ]; then
  echo "MEO_FINDING|warning|input_method.framework_missing|Fcitx 5 is not installed at /usr/bin/fcitx5."
else
  /usr/bin/fcitx5 --version 2>/dev/null | head -n 1 || true
fi

# Query D-Bus ownership directly. GetNameOwner is read-only and does not ask
# D-Bus to activate a missing service.
echo "[input-method] runtime"
if command -v busctl >/dev/null 2>&1; then
  if busctl --user call org.freedesktop.DBus /org/freedesktop/DBus \
      org.freedesktop.DBus GetNameOwner s org.fcitx.Fcitx5 >/dev/null 2>&1; then
    echo "Fcitx 5 session service: active"
  else
    echo "Fcitx 5 session service: inactive"
    if [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
      echo "MEO_FINDING|warning|input_method.runtime_inactive|Fcitx 5 is installed or expected, but its session D-Bus service is not currently active."
    else
      echo "MEO_FINDING|info|input_method.runtime_not_observed|The Fcitx 5 session service is not active in this diagnostic session."
    fi
  fi
else
  echo "MEO_FINDING|info|input_method.dbus_probe_unavailable|busctl is unavailable, so Repair cannot verify the Fcitx 5 session service without starting another client."
fi

echo "[input-method] packages"
if command -v pacman >/dev/null 2>&1; then
  for package in fcitx5 fcitx5-qt fcitx5-gtk; do
    if pacman -Q "${package}" >/dev/null 2>&1; then
      printf '%s: installed\n' "${package}"
    else
      printf '%s: not installed\n' "${package}"
      case "${package}" in
        fcitx5)
          echo "MEO_FINDING|warning|input_method.package_framework_missing|The Fcitx 5 framework package is not installed."
          ;;
        fcitx5-qt)
          echo "MEO_FINDING|info|input_method.qt_bridge_missing|The optional Fcitx 5 Qt bridge package is not installed."
          ;;
        fcitx5-gtk)
          echo "MEO_FINDING|info|input_method.gtk_bridge_missing|The optional Fcitx 5 GTK bridge package is not installed."
          ;;
      esac
    fi
  done
else
  echo "MEO_FINDING|info|input_method.package_probe_unavailable|pacman is unavailable, so Repair cannot inspect installed Fcitx package bridges."
fi

echo "[input-method] environment"
for variable in QT_IM_MODULE GTK_IM_MODULE XMODIFIERS; do
  value="${!variable-}"
  if [ -n "${value}" ]; then
    printf '%s=%s\n' "${variable}" "${value}"
  else
    printf '%s=<unset>\n' "${variable}"
  fi
done

# On Plasma Wayland, the authoritative input-method integration is expected to
# come from the compositor/session path rather than Repair mutating environment
# variables. We therefore report unusual overrides but do not rewrite them.
if [ "${XDG_SESSION_TYPE:-}" = "wayland" ] && [ -n "${QT_IM_MODULE-}" ] \
    && [ "${QT_IM_MODULE}" != "fcitx" ] && [ "${QT_IM_MODULE}" != "fcitx5" ]; then
  echo "MEO_FINDING|warning|input_method.qt_override_unexpected|QT_IM_MODULE is set to a non-Fcitx value in a Wayland session."
fi
if [ -n "${GTK_IM_MODULE-}" ] && [ "${GTK_IM_MODULE}" != "fcitx" ] \
    && [ "${GTK_IM_MODULE}" != "fcitx5" ]; then
  echo "MEO_FINDING|info|input_method.gtk_override_unexpected|GTK_IM_MODULE is set to a non-Fcitx value."
fi
if [ -n "${XMODIFIERS-}" ] && [[ "${XMODIFIERS}" != *fcitx* ]]; then
  echo "MEO_FINDING|info|input_method.xmodifiers_unexpected|XMODIFIERS is set but does not reference Fcitx."
fi

echo "[input-method] user configuration"
config_home="${XDG_CONFIG_HOME:-${HOME:-}/.config}"
if [ -n "${config_home}" ] && [ -d "${config_home}/fcitx5" ]; then
  if [ -r "${config_home}/fcitx5/profile" ]; then
    echo "Fcitx profile: present"
  else
    echo "MEO_FINDING|info|input_method.profile_missing|The Fcitx 5 user configuration exists but no readable profile file was found."
  fi
else
  echo "MEO_FINDING|info|input_method.user_config_missing|No per-user Fcitx 5 configuration directory was found for this session."
fi

exit 0
