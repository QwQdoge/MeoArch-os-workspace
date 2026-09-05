#!/usr/bin/env python3
"""Offline checks of the package-managed target; not installed-boot acceptance."""
from pathlib import Path
import sys

REQUIRED_FILES = (
    "etc/fstab", "etc/os-release", "boot/vmlinuz-linux", "boot/initramfs-linux.img", "boot/grub/grub.cfg",
    "usr/lib/libmeoui.so.0", "usr/lib/qt6/qml/MeoUI/qmldir",
    "usr/lib/qt6/qml/MeoUI/libmeoui_moduleplugin.so", "usr/lib/qt6/qml/MeoKDE/qmldir",
    "usr/lib/qt6/qml/Meo/System/libmeosystemplugin.so",
    "usr/share/plasma/look-and-feel/org.meo.desktop/metadata.json",
    "usr/share/plasma/plasmoids/org.meo.topbar/metadata.json",
    "usr/share/plasma/plasmoids/org.meo.timecenter/metadata.json",
    "etc/xdg/autostart/org.meo.dock.desktop", "etc/xdg/meo-shellrc",
    "etc/sddm.conf.d/20-meoarch.conf", "usr/share/wayland-sessions/plasma.desktop",
    "usr/share/pixmaps/meoarch-logo.svg", "usr/share/meo-release/package-catalog.json",
    "etc/environment.d/90-meo-applications.conf", "usr/lib/systemd/user/meo-dynamic-colors.path",
    "usr/lib/systemd/user/meo-dynamic-colors.service", "usr/lib/systemd/user/pipewire.service",
    "usr/share/fcitx5/themes/MeoInputMethod-Light/theme.conf",
    "usr/share/meo-desktop/input-method/ibus/gtk.css.in", "etc/plymouth/plymouthd.conf",
    "usr/share/plymouth/themes/meoarch/meoarch.plymouth", "usr/share/plymouth/themes/meoarch/meoarch.script",
)
REQUIRED_EXECUTABLES = ("usr/bin/meo-dock", "usr/bin/meo-dynamic-colors", "usr/bin/meo-input-method",
                        "usr/bin/sddm", "usr/bin/startplasma-wayland", "usr/bin/NetworkManager")


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


def verify(root: Path) -> None:
    if root.is_symlink() or root.resolve() == Path("/"):
        raise ValueError("refusing unsafe target root")
    root = root.resolve(strict=True)
    for relative in (*REQUIRED_FILES, *REQUIRED_EXECUTABLES):
        path = target_path(root, relative)
        if not path.is_file() or not path.stat().st_size:
            raise ValueError(f"target payload missing: {relative}")
        if relative in REQUIRED_EXECUTABLES and not path.stat().st_mode & 0o111:
            raise ValueError(f"target command is not executable: {relative}")
    if "ID=meoarch" not in target_path(root, "etc/os-release").read_text().splitlines():
        raise ValueError("target system identity is not MeoArch")
    if not any(path.is_file() and path.stat().st_size for path in (root / "boot/EFI").glob("*/grubx64.efi")):
        raise ValueError("installed UEFI GRUB executable is missing")
    for service in ("display-manager.service", "multi-user.target.wants/NetworkManager.service"):
        path = target_path(root, f"etc/systemd/system/{service}")
        if not path.is_file() or not path.stat().st_size:
            raise ValueError(f"target service is not enabled: {service}")


if __name__ == "__main__":
    try:
        verify(Path(sys.argv[1]))
    except (ValueError, OSError) as error:
        raise SystemExit(f"FAIL: {error}")
    print("PASS: package-managed target file and service validation; installed boot remains unverified")
