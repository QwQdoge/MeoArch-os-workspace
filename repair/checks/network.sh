#!/usr/bin/env bash
set -u -o pipefail

echo "[network] NetworkManager"
if command -v nmcli >/dev/null 2>&1; then
  nmcli general status 2>&1 || true
  nmcli -t -f DEVICE,TYPE,STATE,CONNECTION device status 2>&1 || true
fi
if ! systemctl is-active --quiet NetworkManager.service 2>/dev/null; then
  echo "MEO_FINDING|warning|network.manager_inactive|NetworkManager is not active."
fi

echo "[network] links and addresses"
ip -brief link 2>&1 || true
ip -brief address 2>&1 || true

echo "[network] routes"
routes="$(ip route show 2>&1 || true)"
printf '%s\n' "${routes}"
if ! grep -q '^default ' <<<"${routes}"; then
  echo "MEO_FINDING|warning|network.no_default_route|No IPv4 default route is configured."
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
