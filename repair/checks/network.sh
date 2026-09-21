#!/usr/bin/env bash
set -u -o pipefail

echo "[network] NetworkManager"
if command -v nmcli >/dev/null 2>&1; then
  general_state="$(nmcli -g STATE general 2>/dev/null || true)"
  connectivity="$(nmcli -g CONNECTIVITY general 2>/dev/null || true)"
  printf 'State: %s\nConnectivity: %s\n' "${general_state:-unknown}" "${connectivity:-unknown}"
  nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>&1 || true
  nmcli -t -f NAME,TYPE,DEVICE connection show --active 2>&1 || true

  case "${connectivity}" in
    full) ;;
    portal)
      echo "MEO_FINDING|warning|network.captive_portal|The network is connected but requires browser sign-in through a captive portal."
      ;;
    limited)
      echo "MEO_FINDING|warning|network.limited_connectivity|A network is connected, but NetworkManager reports limited internet connectivity."
      ;;
    none)
      echo "MEO_FINDING|warning|network.no_internet|NetworkManager reports no internet connectivity."
      ;;
    unknown|"")
      echo "MEO_FINDING|info|network.connectivity_unknown|NetworkManager cannot confirm internet connectivity."
      ;;
  esac

  if nmcli -t -f DEVICE,TYPE device status 2>/dev/null | grep -q ':wifi$'; then
    wifi_radio="$(nmcli radio wifi 2>/dev/null || true)"
    printf 'Wi-Fi radio: %s\n' "${wifi_radio:-unknown}"
    if [ "${wifi_radio}" = "disabled" ]; then
      echo "MEO_FINDING|info|network.wifi_disabled|A Wi-Fi device exists, but the Wi-Fi radio is disabled."
    fi
  fi
fi
if ! systemctl is-active --quiet NetworkManager.service 2>/dev/null; then
  echo "MEO_FINDING|warning|network.manager_inactive|NetworkManager is not active."
fi

echo "[network] links and addresses"
ip -brief link 2>&1 || true
ip -brief address 2>&1 || true

echo "[network] routes"
routes4="$(ip -4 route show 2>&1 || true)"
routes6="$(ip -6 route show 2>&1 || true)"
printf '%s\n%s\n' "${routes4}" "${routes6}"
if ! grep -q '^default ' <<<"${routes4}" && ! grep -q '^default ' <<<"${routes6}"; then
  echo "MEO_FINDING|warning|network.no_default_route|No IPv4 or IPv6 default route is configured."
fi

echo "[network] resolver"
if command -v resolvectl >/dev/null 2>&1; then
  resolvectl status --no-pager 2>&1 || true
elif [ -r /etc/resolv.conf ]; then
  sed -n '1,80p' /etc/resolv.conf
fi
if [ -r /etc/resolv.conf ] && ! grep -Eq '^[[:space:]]*nameserver[[:space:]]+' /etc/resolv.conf; then
  echo "MEO_FINDING|warning|network.no_dns_server|No DNS nameserver is present in resolv.conf."
fi
