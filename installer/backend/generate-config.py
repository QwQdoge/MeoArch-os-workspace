#!/usr/bin/env python3
"""Generate version-pinned Archinstall inputs from non-secret installer state."""

import argparse
import json
import os
import re
import uuid
from pathlib import Path

from hardware import detect_devices, driver_plan
from install_plan import (PlanError, application_catalog_from, build_install_plan,
                          catalog_from, plan_as_dict, write_json_atomic)


MEO_DESKTOP_PACKAGES = [
    "dolphin",
    "konsole",
    "systemsettings",
    "plasma-nm",
    "plasma-pa",
    "powerdevil",
    "bluedevil",
    "plymouth",
    "qtkeychain-qt6",
    "lynis",
    "polkit-kde-agent",
    "plasma-login-manager",
    "system76-scheduler",
    "zram-generator",
    "dbus-broker-units",
    "power-profiles-daemon",
    "gamemode",
]


def load_json(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def write_json(path: Path, payload, mode=0o600):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    os.chmod(temporary, mode)
    temporary.replace(path)


def selected_install_device(disk):
    """Return only a canonical kernel block-device path for Archinstall."""
    stable_id = str(disk.get("stableId", ""))
    device_path = str(disk.get("devicePath", ""))
    kernel_device = re.fullmatch(r"/dev/(?:vd[a-z]+|sd[a-z]+|nvme\d+n\d+)", device_path)
    if not kernel_device:
        return None
    if stable_id == device_path:
        return device_path
    if not re.fullmatch(r"/dev/disk/by-id/[A-Za-z0-9_.:+-]+", stable_id):
        return None
    return device_path


def verify_selected_disk_identity(disk):
    """Re-resolve the stable ID before plan generation and reject drift."""
    stable_id = str(disk.get("stableId", ""))
    device_path = selected_install_device(disk)
    if not device_path:
        return False, "selected disk has no safe canonical kernel path"
    if not os.path.exists(device_path):
        return False, "selected disk is no longer present"
    if stable_id.startswith("/dev/disk/by-id/"):
        if not os.path.islink(stable_id):
            return False, "selected stable disk identity is no longer present"
        if os.path.realpath(stable_id) != device_path:
            return False, "selected stable disk identity now resolves to another device"
    return True, ""


def build_default_disk_layout(selections):
    """Build an explicit Archinstall layout for automatic or guided full-disk installation."""
    disk = selections.get("disk", {})
    mode = disk.get("mode", "erase")
    if mode not in {"erase", "guided"}:
        return None
    device = selected_install_device(disk)
    stable_id = str(disk.get("stableId", ""))
    if not device or "usb" in stable_id.lower() or "preview" in stable_id.lower():
        return None
    filesystem = disk.get("filesystem", "btrfs")
    if filesystem not in {"btrfs", "ext4"}:
        return None
    try:
        total_mib = int(disk.get("sizeBytes", 0)) // (1024 * 1024)
    except (TypeError, ValueError):
        return None
    if total_mib < 8192:
        return None
    allocatable_mib = total_mib - 1027
    separate_home = mode == "guided" and bool(disk.get("separateHome", True))
    if separate_home:
        try:
            root_size_mib = int(disk.get("rootSizeGiB", 32)) * 1024
        except (TypeError, ValueError):
            return None
        if root_size_mib < 16 * 1024 or allocatable_mib - root_size_mib < 8 * 1024:
            return None
    else:
        root_size_mib = allocatable_mib

    def object_id(label):
        return str(uuid.uuid5(uuid.NAMESPACE_URL, f"meoarch:{device}:{label}"))

    sector_size = {"unit": "B", "value": 512}
    partitions = [
        {
            "btrfs": [],
            "dev_path": None,
            "flags": ["boot", "esp"],
            "fs_type": "fat32",
            "mount_options": [],
            "mountpoint": "/boot",
            "obj_id": object_id("efi"),
            "size": {"sector_size": sector_size, "unit": "MiB", "value": 1024},
            "start": {"sector_size": sector_size, "unit": "MiB", "value": 1},
            "status": "create",
            "type": "primary",
        },
        {
            "btrfs": [],
            "dev_path": None,
            "flags": [],
            "fs_type": filesystem,
            "mount_options": ["compress=zstd"] if filesystem == "btrfs" else [],
            "mountpoint": "/",
            "obj_id": object_id("root"),
            "size": {"sector_size": sector_size, "unit": "MiB", "value": root_size_mib},
            "start": {"sector_size": sector_size, "unit": "MiB", "value": 1025},
            "status": "create",
            "type": "primary",
        },
    ]
    if separate_home:
        partitions.append({
            "btrfs": [],
            "dev_path": None,
            "flags": [],
            "fs_type": filesystem,
            "mount_options": ["compress=zstd"] if filesystem == "btrfs" else [],
            "mountpoint": "/home",
            "obj_id": object_id("home"),
            "size": {"sector_size": sector_size, "unit": "MiB", "value": allocatable_mib - root_size_mib},
            "start": {"sector_size": sector_size, "unit": "MiB", "value": 1025 + root_size_mib},
            "status": "create",
            "type": "primary",
        })
    return {
        "config_type": "default_layout",
        "device_modifications": [{
            "device": device,
            "wipe": True,
            "partitions": partitions,
        }],
    }


def _safe_partition_on_device(device, partition):
    """Validate a partition descriptor received from the disk scanner.

    A partition plan is deliberately narrower than Archinstall's general
    manual-partitioning API: it may use exactly one existing ESP and one
    existing Linux root partition on the selected disk.  The UI is not a raw
    partition editor, and stale or hand-edited selection state must not widen
    that scope.
    """
    if not isinstance(partition, dict):
        return None
    path = str(partition.get("path", ""))
    suffix = r"p[1-9][0-9]*" if re.fullmatch(r"/dev/nvme\d+n\d+", device) else r"[1-9][0-9]*"
    expected = rf"{re.escape(device)}{suffix}"
    if not re.fullmatch(expected, path):
        return None
    try:
        start = int(partition.get("startSectors", 0))
        size = int(partition.get("sizeSectors", 0))
        sector_size = int(partition.get("logicalSectorSize", 0))
        size_bytes = int(partition.get("sizeBytes", 0))
    except (TypeError, ValueError):
        return None
    if start < 0 or size <= 0 or sector_size not in {512, 4096}:
        return None
    if size_bytes != size * sector_size:
        return None
    return {
        "path": path,
        "start": start,
        "size": size,
        "sector_size": sector_size,
        "size_bytes": size_bytes,
        "parttype": str(partition.get("parttype", "")).lower(),
        "fstype": str(partition.get("fstype", "")).lower(),
    }


def build_existing_partition_layout(selections):
    """Build a bounded Archinstall plan that only consumes one root partition.

    The ESP is represented as ``existing`` and is mounted unchanged.  The
    selected root partition is represented as ``modify``: Archinstall deletes
    and recreates *that same partition geometry* before formatting it.  This
    is why this path refuses any unknown topology instead of accepting a raw
    custom layout from the UI.
    """
    disk = selections.get("disk", {})
    if disk.get("mode") != "partition":
        return None
    device = selected_install_device(disk)
    if not device:
        return None
    root = _safe_partition_on_device(device, disk.get("targetPartition"))
    efi = _safe_partition_on_device(device, disk.get("efiPartition"))
    if not root or not efi or root["path"] == efi["path"]:
        return None
    filesystem = str(disk.get("filesystem", "btrfs"))
    if filesystem not in {"btrfs", "ext4"}:
        return None
    efi_guid = "c12a7328-f81f-11d2-ba4b-00a0c93ec93b"
    if efi["parttype"] != efi_guid or efi["fstype"] not in {"vfat", "fat", "fat16", "fat32"}:
        return None
    if root["size_bytes"] < 16 * 1024 * 1024 * 1024 or efi["size_bytes"] < 512 * 1024 * 1024:
        return None

    def size(value, unit, sector_size):
        return {"value": value, "unit": unit,
                "sector_size": {"unit": "B", "value": sector_size}}

    def object_id(label):
        return str(uuid.uuid5(uuid.NAMESPACE_URL, f"meoarch:{device}:{label}"))

    return {
        "config_type": "manual_partitioning",
        "device_modifications": [{
            "device": device,
            "wipe": False,
            "partitions": [
                {
                    "btrfs": [], "dev_path": efi["path"], "flags": [],
                    "fs_type": "fat32", "mount_options": [], "mountpoint": "/boot",
                    "obj_id": object_id("existing-efi"),
                    "size": size(efi["size"], "sectors", efi["sector_size"]),
                    "start": size(efi["start"], "sectors", efi["sector_size"]),
                    "status": "existing", "type": "primary",
                },
                {
                    "btrfs": [], "dev_path": root["path"], "flags": [],
                    "fs_type": filesystem,
                    "mount_options": ["compress=zstd"] if filesystem == "btrfs" else [],
                    "mountpoint": "/", "obj_id": object_id("selected-root"),
                    "size": size(root["size"], "sectors", root["sector_size"]),
                    "start": size(root["start"], "sectors", root["sector_size"]),
                    "status": "modify", "type": "primary",
                },
            ],
        }],
    }


def build_package_list(hardware_plan=None, firewall=False, application_packages=()):
    hardware_packages = (hardware_plan or driver_plan(detect_devices()))["packages"]
    packages = hardware_packages + MEO_DESKTOP_PACKAGES + list(application_packages)
    if firewall:
        packages.append("firewalld")
    return list(dict.fromkeys(packages))


def build_user_configuration(selections, hardware_plan=None, application_packages=()):
    locale = selections.get("locale", {})
    user = selections.get("user", {})
    disk = selections.get("disk", {})
    swap_mode = disk.get("swap", "zram")
    privacy = selections.get("privacy", {})
    desktop_packages = build_package_list(hardware_plan, bool(privacy.get("firewall", True)), application_packages)
    config = {
        "archinstall-language": "English",
        "audio_config": {"audio": "pipewire"},
        "bootloader_config": {"bootloader": "Grub", "uki": False, "removable": False},
        "hostname": user.get("hostname", "meoarch"),
        "kernels": ["linux"],
        "kernel_extra_args": ["splash", "quiet", "loglevel=3", "rd.udev.log_level=3", "vt.global_cursor_default=0", "plymouth.enable=1"],
        "locale_config": {
            "kb_layout": locale.get("keyboardLayout", "us"),
            "sys_enc": "UTF-8",
            "sys_lang": locale.get("systemLocale", "en_US.UTF-8"),
        },
        "network_config": {"type": "nm"},
        "ntp": True,
        "offline": False,
        # The selected packages are derived from PCI IDs by hardware.py.  The
        # Archinstall profile's generic graphics setting remains in place for
        # desktop dependencies; this list adds the vendor-specific driver.
        "packages": desktop_packages,
        "profile_config": {
            "gfx_driver": "All open-source",
            # The display manager is enabled by the target customisation step.
            # Do not ask Archinstall to install/configure SDDM as a side effect.
            "profile": {"details": ["KDE Plasma"], "main": "Desktop"},
        },
        "script": "guided",
        "silent": True,
        # Archinstall owns zram. A file swap is created by the target-side,
        # idempotent post-install step after the root filesystem exists.
        "swap": {"enabled": True, "algorithm": "zstd"} if swap_mode == "zram" else False,
        "timezone": locale.get("timezone", "UTC"),
    }
    disk_layout = build_existing_partition_layout(selections) or disk.get("layout") or build_default_disk_layout(selections)
    if disk_layout:
        config["disk_config"] = disk_layout
    return config


def build_user_credentials(selections, secrets):
    user = selections.get("user", {})
    username = user.get("username", "")
    payload = {"root_enc_password": secrets.get("rootPasswordHash", ""), "users": []}
    if username:
        payload["users"].append({
            "username": username,
            "enc_password": secrets.get("userPasswordHash", ""),
            "sudo": True,
        })
    return payload


def build_plasma_localerc(selections):
    locale = selections.get("locale", {})
    format_locale = locale.get("formatLocale", locale.get("systemLocale", "en_US.UTF-8"))
    return "\n".join([
        "[Formats]",
        f"LANG={format_locale}",
        f"LC_MEASUREMENT={format_locale}",
        f"LC_MONETARY={format_locale}",
        f"LC_NUMERIC={format_locale}",
        f"LC_TIME={format_locale}",
        "",
    ])


def build_target_customizations(selections):
    """Return non-secret, target-side actions consumed by the postinstall adapter."""
    user = selections.get("user", {})
    disk = selections.get("disk", {})
    privacy = selections.get("privacy", {})
    network = selections.get("network", {})
    preferences = selections.get("preferences", {})
    return {
        "schemaVersion": 1,
        "fullName": user.get("fullName", "").strip(),
        "username": user.get("username", ""),
        # Plasma Login Manager's supported unattended-login configuration is
        # intentionally not guessed. Keep sign-in authentication on until a
        # password-preserving backend transaction is implemented.
        "automaticLogin": False,
        "loginManager": "plasma-login-manager",
        "firewall": bool(privacy.get("firewall", True)),
        "networkHandoff": {
            "enabled": bool(network.get("handoffEnabled", False)),
            "file": "network-handoff.nmconnection",
        },
        "calendar": {
            "primary": "gregorian",
            "secondary": preferences.get("secondaryCalendar", "none"),
            "hebcalEnabled": bool(preferences.get("hebcalEnabled", False)),
        },
        "swap": {"mode": disk.get("swap", "zram"), "fileSizeMiB": 4096},
    }


def build_meo_install_config(selections):
    software = selections.get("software", {})
    return {
        "schemaVersion": 2,
        "channel": software.get("channel", "stable"),
        "mirror": software.get("mirror", "automatic"),
        "profile": software.get("profile", "recommended"),
        "components": software.get("components", []),
        "applications": software.get("applications", []),
    }


def validate_installation_plan(selections, configuration, credentials):
    """Return user-safe blockers; never silently downgrade a production choice."""
    blockers = []
    disk = selections.get("disk", {})
    if disk.get("mode", "erase") not in {"erase", "guided", "partition"}:
        blockers.append("unsupported disk layout mode")
    if not configuration.get("disk_config"):
        blockers.append("disk layout not generated")
    if disk.get("swap", "zram") not in {"zram", "file", "none"}:
        blockers.append("unsupported swap mode")
    if selections.get("privacy", {}).get("diskEncryption", False):
        blockers.append("disk encryption is unavailable until its tested secret flow is enabled")
    secondary_calendar = selections.get("preferences", {}).get("secondaryCalendar", "none")
    if secondary_calendar not in {"none", "buddhist", "islamic-civil", "hebcal"}:
        blockers.append("unsupported secondary calendar")
    users = credentials.get("users", [])
    if not users:
        blockers.append("user account is missing")
    elif not all(user.get("enc_password") for user in users):
        blockers.append("user password hash missing")
    try:
        package_catalog = catalog_from(Path(__file__).parents[1] / "data" / "package-catalog.json")
        app_catalog = application_catalog_from(
            Path(__file__).parents[1] / "data" / "application-catalog.json",
            package_catalog["generation"],
        )
        build_install_plan(build_meo_install_config(selections), package_catalog,
                           application_catalog=app_catalog)
    except PlanError as error:
        blockers.append(f"Meo package plan is invalid: {error}")
    return blockers


def main():
    parser = argparse.ArgumentParser(description="Generate Archinstall JSON from MeoArch selections.")
    parser.add_argument("--data-dir", default="/opt/meoarch-installer/data")
    parser.add_argument("--state-dir", default="/tmp/meoarch-installer")
    parser.add_argument("--selections")
    parser.add_argument("--credentials", help="Ephemeral 0600 JSON containing only password hashes/passphrases")
    args = parser.parse_args()

    data_dir = Path(args.data_dir)
    state_dir = Path(args.state_dir)
    selections_path = Path(args.selections) if args.selections else state_dir / "selections.json"
    selections = load_json(selections_path if selections_path.exists() else data_dir / "default_selections.json")
    if selections.get("schemaVersion") != 1:
        raise SystemExit("Unsupported selections schemaVersion; expected 1")

    identity_ok, identity_error = verify_selected_disk_identity(selections.get("disk", {}))
    if not identity_ok:
        raise SystemExit(identity_error)

    secrets = load_json(Path(args.credentials)) if args.credentials else {}
    output_dir = state_dir / "generated"
    hardware = driver_plan(detect_devices())
    package_catalog = catalog_from(data_dir / "package-catalog.json")
    app_catalog = application_catalog_from(data_dir / "application-catalog.json", package_catalog["generation"])
    try:
        install_plan = build_install_plan(build_meo_install_config(selections), package_catalog,
                                          application_catalog=app_catalog)
    except PlanError as error:
        raise SystemExit(f"Meo package plan is invalid: {error}") from error
    configuration = build_user_configuration(selections, hardware, install_plan.applications.native_packages)
    credentials = build_user_credentials(selections, secrets)
    write_json(output_dir / "user_configuration.json", configuration, 0o644)
    write_json(output_dir / "user_credentials.json", credentials, 0o600)
    write_json(output_dir / "hardware.json", hardware, 0o644)
    plasma_path = output_dir / "plasma-localerc"
    plasma_path.write_text(build_plasma_localerc(selections), encoding="utf-8")
    os.chmod(plasma_path, 0o644)
    customization_path = output_dir / "target-customizations.json"
    write_json(customization_path, build_target_customizations(selections), 0o600)
    install_plan_path = output_dir / "install-plan.json"
    write_json_atomic(install_plan_path, plan_as_dict(install_plan), 0o600)

    disk = selections.get("disk", {})
    blockers = validate_installation_plan(selections, configuration, credentials)
    ready = not blockers
    manifest = {
        "state": "ready" if ready else "preview",
        "realInstallReady": ready,
        "blockedReasons": blockers,
        "diskMode": disk.get("mode", "erase"),
        "files": {
            "user_configuration": str(output_dir / "user_configuration.json"),
            "user_credentials": str(output_dir / "user_credentials.json"),
            "hardware": str(output_dir / "hardware.json"),
            "plasma_localerc": str(plasma_path),
            "target_customizations": str(customization_path),
            "install_plan": str(install_plan_path),
        },
    }
    write_json(state_dir / "config_manifest.json", manifest, 0o644)


if __name__ == "__main__":
    main()
