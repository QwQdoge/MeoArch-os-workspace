#!/usr/bin/env bash
set -euo pipefail

[ "$#" -eq 1 ] || {
  echo "Usage: $0 /path/to/meoarch-repair-ai-flow-smoke" >&2
  exit 2
}

smoke_binary="$1"
[ -x "${smoke_binary}" ] || {
  echo "AI-flow smoke binary is missing or not executable." >&2
  exit 2
}

command -v bwrap >/dev/null 2>&1 || {
  echo "Bubblewrap is required for isolated write-action validation." >&2
  exit 2
}
command -v dbus-run-session >/dev/null 2>&1 || {
  echo "dbus-run-session is required for typed D-Bus validation." >&2
  exit 2
}

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
fixture_root="$(mktemp -d "${TMPDIR:-/tmp}/meoarch-ai-write-smoke.XXXXXX")"
marker_path="${fixture_root}/write-action.marker"
mkdir -p "${fixture_root}/tmp"
trap 'rm -rf -- "${fixture_root}"' EXIT

cat >"${fixture_root}/network-check" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail
[ "$#" -eq 0 ] || exit 2
echo "[network] isolated write-action smoke"
echo "MEO_FINDING|warning|network.manager_inactive|NetworkManager is inactive in the isolated fixture."
EOF
chmod 0755 "${fixture_root}/network-check"

source_check="${repo_root}/repair/checks/network.sh"
installed_check=/usr/lib/meoarch-repair/checks/network.sh
if [ -e "${installed_check}" ]; then
  selected_check="${installed_check}"
else
  selected_check="${source_check}"
fi

dbus-run-session -- bash -c 'export DBUS_SYSTEM_BUS_ADDRESS="$DBUS_SESSION_BUS_ADDRESS"; exec "$@"' _ \
  bwrap \
  --die-with-parent \
  --unshare-all \
  --share-net \
  --new-session \
  --ro-bind / / \
  --dev /dev \
  --proc /proc \
  --bind "${fixture_root}" "${fixture_root}" \
  --ro-bind "${fixture_root}/network-check" "${selected_check}" \
  --setenv TMPDIR "${fixture_root}/tmp" \
  --setenv MEOARCH_REPAIR_SMOKE_SANDBOX 1 \
  --setenv MEOARCH_REPAIR_SMOKE_MARKER "${marker_path}" \
  "${smoke_binary}"

grep -qxF MEOARCH_WRITE_ACTION_OK "${marker_path}"
