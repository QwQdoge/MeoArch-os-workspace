#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: $0 BASELINE_PROFILE STAGED_PROFILE MANIFEST" >&2
}

[ "$#" -eq 3 ] || { usage; exit 2; }
baseline="$1"
staged="$2"
manifest="$3"

[ -d "${baseline}" ] && [ -d "${staged}" ] || {
  echo "Both profiles must exist." >&2
  exit 2
}

tmp_diff="$(mktemp)"
trap 'rm -f "${tmp_diff}"' EXIT
set +e
git diff --no-index --no-renames --name-status -- "${baseline}" "${staged}" >"${tmp_diff}"
diff_status=$?
set -e
[ "${diff_status}" -le 1 ] || exit "${diff_status}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

classify() {
  local path="$1"
  case "${path}" in
    airootfs/opt/meoarch-installer/*|airootfs/usr/local/bin/meoarch-installer*|airootfs/usr/local/bin/meoarch-install|airootfs/usr/local/bin/meoarch-repair-session)
      printf '%s\t%s\t%s' 'Installer' 'this workspace installer source' 'Installer runtime and desktop/kiosk entrypoints'
      ;;
    airootfs/usr/lib/meoarch/live-session|airootfs/usr/local/bin/meoarch-ai-open-installer|airootfs/usr/share/wayland-sessions/meoarch-live.desktop|airootfs/etc/xdg/autostart/meoarch-live.desktop|airootfs/usr/lib/meoarch/live-installer-authorize|airootfs/usr/lib/systemd/user/meoarch-live-app.service|airootfs/usr/share/applications/org.meo.installer-live.desktop|airootfs/usr/share/polkit-1/actions/org.meo.installer-live.policy|airootfs/usr/share/polkit-1/rules.d/49-meoarch-live-installer.rules)
      printf '%s\t%s\t%s' 'Live Installer' 'this workspace guarded desktop launcher' 'ISO-only authorized installer autostart'
      ;;
    airootfs/usr/bin/meoarch-repair|airootfs/usr/lib/meoarch-repair/*|airootfs/usr/share/meoarch-repair/*|airootfs/usr/share/polkit-1/actions/org.meo.repair*.policy|airootfs/usr/share/polkit-1/rules.d/49-meoarch-live-repair.rules|airootfs/usr/share/applications/org.meo.repair.desktop|airootfs/usr/share/icons/hicolor/scalable/apps/meoarch-ai.svg|airootfs/usr/lib/meo-polkit-agent|airootfs/usr/lib/systemd/user/default.target.wants/meo-agent-service.service)
      printf '%s\t%s\t%s' 'Quick Repair' 'this workspace shared repair source' 'system and Live categorized repair application'
      ;;
    airootfs/etc/fonts/conf.d/50-meo-fonts.conf|airootfs/usr/lib/systemd/user/default.target.wants/meo-dynamic-colors.path|airootfs/usr/lib/systemd/user/default.target.wants/meo-weather-refresh.timer)
      printf '%s\t%s\t%s' 'Live enablement' 'ISO-only symlinks into meo-desktop package files' 'font alias and user-unit enablement for the Live medium'
      ;;
    airootfs/home/live/.ssh/authorized_keys)
      printf '%s\t%s\t%s' 'Acceptance harness' 'MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY' 'ephemeral VM-only SSH access for post-install evidence collection'
      ;;
    airootfs/etc/systemd/system/sysinit.target.wants/debug-shell.service)
      printf '%s\t%s\t%s' 'Acceptance harness' 'MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY' 'ephemeral VM-only tty9 diagnostic shell'
      ;;
    airootfs/etc/systemd/system/multi-user.target.wants/sshd.service)
      printf '%s\t%s\t%s' 'Acceptance harness' 'MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY' 'ephemeral VM-only SSH service'
      ;;
    airootfs/usr/local/bin/Installation_guide|airootfs/usr/local/bin/choose-mirror|airootfs/usr/local/bin/livecd-sound)
      printf '%s\t%s\t%s' 'ArchISO live helpers' 'explicit MeoArch profile helper source' 'services declared by the ArchISO profile'
      ;;
    airootfs/usr/bin/meo-boot-status|airootfs/usr/lib/meoarch/*|airootfs/usr/lib/systemd/system/meo-boot-*|airootfs/usr/lib/systemd/system/*.service.d/*)
      printf '%s\t%s\t%s' 'Boot Status' 'this workspace boot status bridge' 'systemd milestone and failure bridge'
      ;;
    airootfs/usr/share/plymouth/themes/meoarch/*|airootfs/etc/plymouth/*)
      printf '%s\t%s\t%s' 'Plymouth theme' 'workspace plymouth theme source' 'MeoArch graphical boot splash theme'
      ;;
    airootfs/etc/meoarch/account.env)
      # Only the reviewed public example may be staged, never local credentials.
      cmp -s "${staged}/${path}" "${repo_root}/installer/data/account.env.example" || return 1
      printf '%s\t%s\t%s' 'Account public configuration' 'installer/data/account.env.example' 'non-secret Account endpoint defaults'
      ;;
    airootfs/etc/pacman.d/gnupg/*)
      printf '%s\t%s\t%s' 'Build trust seed' 'public Arch keyring and ISO Meo bootstrap' 'pacstrap verification only; no private key material'
      ;;
    pacman.conf)
      # Declaring this path must not authorize repository or signature-policy
      # changes. Only the generated short GnuPG home may differ from baseline.
      normalized_pacman_conf="$(mktemp)"
      sed '/^GPGDir = \/tmp\/meo-archiso-build-gpg\.[[:alnum:]]\{6\}$/d' "${staged}/pacman.conf" >"${normalized_pacman_conf}"
      if [ "${MEOARCH_STAGING_ACCEPTANCE:-0}" = 1 ]; then
        # Acceptance intentionally disables signature verification for the
        # unsigned local preview mirror. Compare policy lines as a declared
        # exception while keeping every other pacman setting exact.
        sed -Ei 's/^SigLevel[[:space:]]*=.*/SigLevel = <acceptance-policy>/; s/^LocalFileSigLevel[[:space:]]*=.*/LocalFileSigLevel = <acceptance-policy>/' "${normalized_pacman_conf}"
        baseline_normalized_pacman_conf="$(mktemp)"
        sed -E 's/^SigLevel[[:space:]]*=.*/SigLevel = <acceptance-policy>/; s/^LocalFileSigLevel[[:space:]]*=.*/LocalFileSigLevel = <acceptance-policy>/' "${baseline}/pacman.conf" >"${baseline_normalized_pacman_conf}"
      else
        baseline_normalized_pacman_conf="${baseline}/pacman.conf"
      fi
      if ! cmp -s "${baseline_normalized_pacman_conf}" "${normalized_pacman_conf}"; then
        if [ "${baseline_normalized_pacman_conf}" != "${baseline}/pacman.conf" ]; then
          rm -f -- "${baseline_normalized_pacman_conf}"
        fi
        rm -f -- "${normalized_pacman_conf}"
        return 1
      fi
      if [ "${baseline_normalized_pacman_conf}" != "${baseline}/pacman.conf" ]; then
        rm -f -- "${baseline_normalized_pacman_conf}"
      fi
      rm -f -- "${normalized_pacman_conf}"
      printf '%s\t%s\t%s' 'Build pacman configuration' 'ISO build script' 'disposable public-keyring path for rootless pacstrap only'
      ;;
    profiledef.sh)
      printf '%s\t%s\t%s' 'Profile version' 'ISO build script' 'timestamped ISO versioning'
      ;;
    *) return 1 ;;
  esac
}

mkdir -p "$(dirname "${manifest}")"
printf 'status\tpath\towner\tsource\tpurpose\n' >"${manifest}"
unknown=0
while IFS=$'\t' read -r status left right; do
  [ -n "${status}" ] || continue
  case "${status}" in
    A) path="${left#${staged}/}" ;;
    D|M) path="${left#${baseline}/}" ;;
    *) echo "FAIL: unsupported staging diff status: ${status}" >&2; exit 1 ;;
  esac
  if metadata="$(classify "${path}")"; then
    printf '%s\t%s\t%s\n' "${status}" "${path}" "${metadata}" >>"${manifest}"
  else
    echo "UNDECLARED\t${path}" >>"${manifest}"
    echo "FAIL: undeclared staged path: ${path}" >&2
    unknown=1
  fi
done <"${tmp_diff}"

[ "${unknown}" -eq 0 ] || exit 1
echo "PASS: staging provenance recorded at ${manifest}"
