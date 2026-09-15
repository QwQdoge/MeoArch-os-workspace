#!/usr/bin/env python3
"""Offline checks of the package-managed target; not installed-boot acceptance."""
from pathlib import Path
import re
import sys

REQUIRED_FILES = (
    "etc/fstab", "etc/os-release", "boot/vmlinuz-linux", "boot/initramfs-linux.img", "boot/grub/grub.cfg",
    "usr/lib/libmeoui.so.0", "usr/lib/qt6/qml/MeoUI/qmldir",
    "usr/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so", "usr/lib/qt6/qml/MeoKDE/qmldir",
    "usr/lib/qt6/qml/Meo/System/qmldir", "usr/lib/qt6/qml/Meo/System/plugins.qmltypes",
    "usr/lib/qt6/qml/Meo/System/libmeosystemplugin.so",
    "usr/share/plasma/look-and-feel/org.meo.desktop/metadata.json",
    "usr/share/plasma/look-and-feel/org.meo.desktop/contents/layouts/org.kde.plasma.desktop-layout.js",
    "usr/share/plasma/plasmoids/org.meo.topbar/metadata.json",
    "usr/share/plasma/plasmoids/org.meo.timecenter/metadata.json",
    "etc/xdg/autostart/org.meo.welcome.desktop", "etc/xdg/meo-shellrc",
    "etc/xdg/MeoArch/Calendar.ini",
    "usr/share/applications/org.meo.welcome.desktop",
    "usr/lib/systemd/system/plasmalogin.service", "usr/share/wayland-sessions/plasma.desktop",
    "usr/share/pixmaps/meoarch-logo.svg", "usr/share/meo-release/package-catalog.json",
    "etc/environment.d/90-meo-applications.conf", "usr/lib/systemd/user/meo-dynamic-colors.path",
    "usr/lib/systemd/user/meo-dynamic-colors.service", "usr/lib/systemd/user/pipewire.service",
    "usr/share/fcitx5/themes/MeoInputMethod-Light/theme.conf",
    "usr/share/meo-desktop/input-method/ibus/gtk.css.in", "etc/plymouth/plymouthd.conf",
    "usr/share/plymouth/themes/meoarch/meoarch.plymouth", "usr/share/plymouth/themes/meoarch/meoarch.script",
    "boot/grub/themes/meoarch/theme.txt",
    "usr/share/plasma/look-and-feel/org.meo.desktop/contents/splash/Splash.qml",
    "usr/share/plasma/look-and-feel/org.meo.desktop/contents/logout/Logout.qml",
    "usr/share/dbus-1/services/org.meo.SessionAction1.service",
    "usr/lib/systemd/user/meo-weather-refresh.service",
    "usr/lib/systemd/user/meo-weather-refresh.timer",
    "usr/lib/systemd/user/default.target.wants/meo-weather-refresh.timer",
    "etc/gamemode.ini",
    "etc/system76-scheduler/process-scheduler/meo-cachyos.kdl",
    "usr/lib/systemd/zram-generator.conf.d/50-meo-desktop.conf",
    "usr/lib/systemd/system-preset/50-meo-responsiveness.preset",
    "usr/share/meo-desktop/optional/preload-ng.toml",
    "usr/share/meo-desktop/optional/prelockd.conf",
    "usr/lib/systemd/system/com.system76.Scheduler.service",
    "usr/lib/systemd/system/power-profiles-daemon.service",
    "usr/lib/systemd/system/dbus.service",
)
REQUIRED_EXECUTABLES = ("usr/bin/meo-dynamic-colors", "usr/bin/meo-input-method",
                        "usr/bin/plasmalogin", "usr/bin/startplasma-wayland", "usr/bin/NetworkManager",
                        "usr/bin/meo-welcome", "usr/bin/meo-session-actiond",
                        "usr/bin/meo-weather-refresh",
                        "usr/bin/system76-scheduler", "usr/bin/gamemoded", "usr/bin/powerprofilesctl",
                        "usr/bin/dbus-broker-launch", "usr/lib/systemd/system-generators/zram-generator")
REQUIRED_ENABLED_SERVICES = (
    "display-manager.service",
    "multi-user.target.wants/NetworkManager.service",
    "multi-user.target.wants/com.system76.Scheduler.service",
    "multi-user.target.wants/power-profiles-daemon.service",
)
FORBIDDEN_ENABLED_SERVICES = (
    "multi-user.target.wants/ananicy-cpp.service",
)
FORBIDDEN_FILES = (
    "etc/xdg/autostart/org.meo.dock.desktop",
    "usr/bin/meo-dock",
)
FORBIDDEN_LIVE_INSTALLER_PATHS = (
    # These paths belong exclusively to the ArchISO Live environment.  The
    # installed target must not re-enter a root kiosk installer at first boot.
    "etc/systemd/system/meoarch-installer.service",
    "etc/systemd/system/graphical.target.wants/meoarch-installer.service",
    "usr/local/bin/meoarch-installer",
    "usr/local/bin/meoarch-installer-kiosk",
)


def target_path(root: Path, relative: str) -> Path:
    """Resolve symlinks as the target would, never against the host's /usr."""
    pending, parts, links = relative.split("/"), [], 0
    while pending:
        part = pending.pop(0)
        if part in {"", "."}:
            continue
        if part == "..":
            if not parts:
                raise ValueError("target path escapes root")
            parts.pop()
            continue
        path = root.joinpath(*parts, part)
        if path.is_symlink():
            links += 1
            if links > 40:
                raise ValueError("target symlink cycle")
            link = str(path.readlink())
            if link.startswith("/"):
                parts = []
            pending = link.split("/") + pending
        else:
            parts.append(part)
    return root.joinpath(*parts)


def fstab_has_root_mount(contents: str) -> bool:
    """Require an actual root entry, not merely a non-empty fstab file."""
    for line in contents.splitlines():
        line = line.strip()
        if not line or line.startswith("#"):
            continue
        fields = line.split()
        if len(fields) >= 2 and fields[1] == "/":
            return True
    return False


def grub_references_linux_kernel(contents: str) -> bool:
    """Check the generated GRUB config references both boot-critical images."""
    linux = re.search(r"(?m)^\s*(?:linux|linuxefi)\s+.*\bvmlinuz-linux(?:\s|$)", contents)
    # GRUB may load CPU microcode and initramfs from the same initrd line.
    initramfs = re.search(r"(?m)^\s*(?:initrd|initrdefi)\s+.*\binitramfs-linux\.img(?:\s|$)", contents)
    return bool(linux and initramfs)


def verify(root: Path, expected_system_owner: tuple[int, int] = (0, 0)) -> None:
    if root.is_symlink() or root.resolve() == Path("/"):
        raise ValueError("refusing unsafe target root")
    root = root.resolve(strict=True)
    for relative in ("", "etc", "usr", "var"):
        path = root / relative
        if path.is_symlink() or not path.is_dir():
            raise ValueError(f"target system directory is missing: /{relative}")
        owner = (path.stat().st_uid, path.stat().st_gid)
        if owner != expected_system_owner:
            display = "/" if not relative else f"/{relative}"
            raise ValueError(
                f"target system directory has unsafe ownership: {display} "
                f"is {owner[0]}:{owner[1]}, expected "
                f"{expected_system_owner[0]}:{expected_system_owner[1]}"
            )
    for relative in (*REQUIRED_FILES, *REQUIRED_EXECUTABLES):
        path = target_path(root, relative)
        if not path.is_file() or not path.stat().st_size:
            raise ValueError(f"target payload missing: {relative}")
        if relative in REQUIRED_EXECUTABLES and not path.stat().st_mode & 0o111:
            raise ValueError(f"target command is not executable: {relative}")
    fstab = target_path(root, "etc/fstab").read_text()
    if not fstab_has_root_mount(fstab):
        raise ValueError("target fstab has no root filesystem entry")
    grub_config = target_path(root, "boot/grub/grub.cfg").read_text()
    if not grub_references_linux_kernel(grub_config):
        raise ValueError("target GRUB configuration does not reference the Linux kernel and initramfs")
    if "ID=meoarch" not in target_path(root, "etc/os-release").read_text().splitlines():
        raise ValueError("target system identity is not MeoArch")
    if not any(path.is_file() and path.stat().st_size for path in (root / "boot/EFI").glob("*/grubx64.efi")):
        raise ValueError("installed UEFI GRUB executable is missing")
    for service in REQUIRED_ENABLED_SERVICES:
        path = target_path(root, f"etc/systemd/system/{service}")
        if not path.is_file() or not path.stat().st_size:
            raise ValueError(f"target service is not enabled: {service}")
    for service in FORBIDDEN_ENABLED_SERVICES:
        path = root / f"etc/systemd/system/{service}"
        if path.exists() or path.is_symlink():
            raise ValueError(f"conflicting target service is enabled: {service}")

    for relative in FORBIDDEN_FILES:
        path = root / relative
        if path.exists() or path.is_symlink():
            raise ValueError(f"retired standalone Dock payload is installed: {relative}")

    for relative in FORBIDDEN_LIVE_INSTALLER_PATHS:
        path = root / relative
        if path.exists() or path.is_symlink():
            raise ValueError(f"Live installer residue is installed: {relative}")

    dock_profile = target_path(root, "etc/xdg/meo-shellrc").read_text()
    dock_layout = target_path(
        root,
        "usr/share/plasma/look-and-feel/org.meo.desktop/contents/layouts/org.kde.plasma.desktop-layout.js",
    ).read_text()
    if "DockImplementation=native" not in dock_profile:
        raise ValueError("target desktop does not select the native Plasma Dock")
    if 'bottomPanel.addWidget("org.kde.plasma.icontasks")' not in dock_layout:
        raise ValueError("target desktop is missing the native Plasma Icons-Only Task Manager")
    if "org.meo.dock" in dock_layout:
        raise ValueError("target desktop layout still references the retired standalone Dock")

    zram = target_path(root, "usr/lib/systemd/zram-generator.conf.d/50-meo-desktop.conf").read_text()
    if "zram-size = min(ram / 2, 8192)" not in zram or "swap-priority = 100" not in zram:
        raise ValueError("target zram policy is not the bounded Meo profile")

    scheduler_rules = target_path(
        root, "etc/system76-scheduler/process-scheduler/meo-cachyos.kdl"
    ).read_text()
    if "Unique process names:" not in scheduler_rules or "assignments {" not in scheduler_rules:
        raise ValueError("target System76 Scheduler classification rules are incomplete")
    if "oom_score_adj" in scheduler_rules or "ananicy-cpp" in scheduler_rules:
        raise ValueError("target scheduler rules contain unsupported Ananicy policy actions")

    preset = target_path(root, "usr/lib/systemd/system-preset/50-meo-responsiveness.preset").read_text()
    for directive in (
        "enable com.system76.Scheduler.service",
        "enable power-profiles-daemon.service",
        "disable ananicy-cpp.service",
        "disable preload-ng.service",
        "disable prelockd.service",
    ):
        if directive not in preset:
            raise ValueError(f"target responsiveness preset is missing: {directive}")


if __name__ == "__main__":
    try:
        verify(Path(sys.argv[1]))
    except (ValueError, OSError) as error:
        raise SystemExit(f"FAIL: {error}")
    print("PASS: package-managed target file and service validation; installed boot remains unverified")
