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

classify() {
  local path="$1"
  case "${path}" in
    airootfs/opt/meoarch-installer/*|airootfs/usr/local/bin/meoarch-installer*|airootfs/usr/local/bin/meoarch-install)
      printf '%s\t%s\t%s' 'Installer' 'this workspace installer source' 'Installer runtime and kiosk entrypoint'
      ;;
    airootfs/usr/bin/meoarch-repair|airootfs/usr/lib/meoarch-repair/*|airootfs/usr/share/applications/org.meo.repair.desktop|airootfs/usr/share/icons/hicolor/scalable/apps/meoarch-ai.svg)
      printf '%s\t%s\t%s' 'Quick Repair' 'this workspace shared repair source' 'system and Live categorized repair application'
      ;;
    airootfs/usr/lib/libmeoui.so*|airootfs/usr/lib/qt6/qml/MeoUI/*)
      printf '%s\t%s\t%s' 'MeoUI' 'compiled sibling MeoUI runtime' 'shared QML controls and runtime library'
      ;;
    airootfs/usr/lib/qt6/qml/MeoKDE/*|airootfs/usr/share/fonts/meo/*|airootfs/etc/fonts/*)
      printf '%s\t%s\t%s' 'MeoKDE' 'compiled or copied sibling MeoKDE runtime' 'shared KDE QML and font integration'
      ;;
    airootfs/usr/lib/qt6/qml/Meo/System/*)
      printf '%s\t%s\t%s' 'Meo.System' 'compiled sibling MeoKDE native/system module' 'shared NetworkManager and system-state backend'
      ;;
    airootfs/opt/meo-desktop/*|airootfs/usr/share/plasma/look-and-feel/org.meo.desktop/*|airootfs/usr/share/plasma/desktoptheme/*|airootfs/usr/share/plasma/plasmoids/org.meo.shelf/*|airootfs/usr/share/plasma/plasmoids/org.meo.topbar/*|airootfs/usr/share/plasma/plasmoids/org.meo.timecenter/*|airootfs/usr/share/color-schemes/*|airootfs/usr/share/icons/MeoSymbols*/*)
      printf '%s\t%s\t%s' 'MeoKDE desktop' 'declared sibling MeoKDE desktop assets' 'live desktop theme, status surfaces, or retired Shelf cleanup'
      ;;
    airootfs/usr/bin/meo-dynamic-colors|airootfs/usr/bin/meo-input-method|airootfs/usr/bin/meo-theme-mode|airootfs/usr/bin/meo-desktop-apply|airootfs/usr/bin/meo-desktop-layout|airootfs/usr/share/meo-desktop/*|airootfs/usr/share/fcitx5/themes/MeoInputMethod-*/*|airootfs/etc/xdg/fcitx5/*|airootfs/etc/environment.d/90-meo-applications.conf|airootfs/usr/lib/systemd/user/meo-dynamic-colors.*|airootfs/usr/lib/systemd/user/default.target.wants/meo-dynamic-colors.path)
      printf '%s\t%s\t%s' 'MeoKDE integration' 'declared sibling MeoKDE scripts and defaults' 'dynamic palette, application style, and input-method integration'
      ;;
    airootfs/usr/share/wallpapers/MeoArch/*|airootfs/usr/share/pixmaps/meoarch-logo.svg|airootfs/usr/share/icons/hicolor/scalable/apps/meoarch-logo.svg)
      printf '%s\t%s\t%s' 'MeoArch branding' 'workspace assets' 'live session wallpaper and application branding'
      ;;
    airootfs/usr/share/sddm/themes/breeze/theme.conf.user|airootfs/etc/os-release|airootfs/etc/xdg/kdeglobals|airootfs/etc/xdg/kwinrc|airootfs/etc/xdg/plasmarc|airootfs/etc/xdg/plasma-welcomerc)
      printf '%s\t%s\t%s' 'MeoKDE defaults' 'declared sibling MeoKDE defaults' 'installed desktop defaults and branding'
      ;;
    airootfs/usr/lib/qt6/plugins/org.kde.kdecoration3/org.meo.decoration.so|airootfs/usr/lib/qt6/plugins/org.kde.kdecoration3.kcm/kcm_meodecoration.so|airootfs/usr/lib/qt6/plugins/styles/meostyle.so|airootfs/usr/lib/qt6/plugins/kwin/effects/plugins/org.meo.windowcorners.so)
      printf '%s\t%s\t%s' 'MeoKDE native' 'compiled sibling MeoKDE native targets' 'window decoration, KCM, style, and retired-plugin cleanup'
      ;;
    airootfs/root/.ssh/authorized_keys)
      printf '%s\t%s\t%s' 'Acceptance harness' 'MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY' 'ephemeral VM-only SSH access for post-install evidence collection'
      ;;
    airootfs/usr/local/bin/Installation_guide|airootfs/usr/local/bin/choose-mirror|airootfs/usr/local/bin/installer.py|airootfs/usr/local/bin/livecd-sound)
      printf '%s\t%s\t%s' 'ArchISO live helpers' 'explicit MeoArch profile helper source' 'services declared by the ArchISO profile'
      ;;
    airootfs/usr/local/bin/meoarch-installer-live|airootfs/usr/local/bin/meoarch-installer-live-root)
      printf '%s\t%s\t%s' 'Installer' 'this workspace installer source' 'live-session launcher and privilege boundary'
      ;;
    airootfs/usr/bin/meo-boot-status|airootfs/usr/lib/meoarch/*|airootfs/usr/lib/systemd/system/meo-boot-*|airootfs/usr/lib/systemd/system/*.service.d/*)
      printf '%s\t%s\t%s' 'Boot Status' 'this workspace boot status bridge' 'systemd milestone and failure bridge'
      ;;
    airootfs/usr/share/plymouth/themes/meoarch/*|airootfs/etc/plymouth/*)
      printf '%s\t%s\t%s' 'Plymouth theme' 'workspace plymouth theme source' 'MeoArch graphical boot splash theme'
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
