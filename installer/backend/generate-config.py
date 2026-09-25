#!/usr/bin/env python3
"""Generate version-pinned Archinstall inputs from non-secret installer state."""

import argparse
import hashlib
import json
import os
import re
import stat
import subprocess
import tempfile
import uuid
from pathlib import Path
from typing import Any

from hardware import detect_devices, driver_plan
from install_plan import (PlanError, application_catalog_from, build_install_plan,
                          catalog_from, plan_as_dict)


MEO_DESKTOP_PACKAGES = [
    "dolphin",
    "konsole",
    "systemsettings",
    "plasma-nm",
    "plasma-pa",
    "alsa-utils",
    "pipewire-audio",
    "pipewire-pulse",
    "wireplumber",
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


HANDOFF_FILE_NAMES = (
    "user_configuration.json",
    "user_credentials.json",
    "plasma-localerc",
    "target-customizations.json",
    "install-plan.json",
)


def write_json(path: Path, payload: Any, mode=0o600):
    """Atomically write a state file without following a pre-existing symlink."""
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    if path.is_symlink():
        raise ValueError(f"refusing to replace symlinked state file: {path}")
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", suffix=".tmp", dir=path.parent,
    )
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            json.dump(payload, handle, indent=2, ensure_ascii=False)
            handle.write("\n")
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        if temporary.exists():
            temporary.unlink()


def write_text(path: Path, contents: str, mode=0o600):
    """Atomically write non-JSON state without following a stale symlink."""
    path.parent.mkdir(parents=True, exist_ok=True, mode=0o700)
    if path.is_symlink():
        raise ValueError(f"refusing to replace symlinked state file: {path}")
    descriptor, temporary_name = tempfile.mkstemp(
        prefix=f".{path.name}.", suffix=".tmp", dir=path.parent,
    )
    temporary = Path(temporary_name)
    try:
        with os.fdopen(descriptor, "w", encoding="utf-8") as handle:
            handle.write(contents)
            handle.flush()
            os.fsync(handle.fileno())
        os.chmod(temporary, mode)
        os.replace(temporary, path)
    finally:
        if temporary.exists():
            temporary.unlink()


def ensure_private_directory(path: Path) -> Path:
    """Create a root/current-user-only installer state directory.

    The state tree contains a password hash and, optionally, a NetworkManager
    connection.  It cannot safely inherit /tmp's default permissions.
    """
    if path.is_symlink():
        raise ValueError(f"refusing symlinked installer state directory: {path}")
    path.mkdir(parents=True, exist_ok=True, mode=0o700)
    info = path.stat()
    if not stat.S_ISDIR(info.st_mode):
        raise ValueError(f"installer state path is not a directory: {path}")
    if info.st_uid != os.geteuid():
        raise ValueError(f"installer state directory is not owned by this process: {path}")
    os.chmod(path, 0o700)
    return path


def private_directory_ok(path: Path) -> tuple[bool, str]:
    if path.is_symlink() or not path.is_dir():
        return False, "installer state directory is missing or unsafe"
    info = path.stat()
    if info.st_uid != os.geteuid() or info.st_mode & 0o077:
        return False, "installer state directory is not private"
    return True, ""


def sha256_file(path: Path) -> str:
    if path.is_symlink() or not path.is_file():
        raise ValueError(f"state file is missing or symlinked: {path}")
    digest = hashlib.sha256()
    with path.open("rb") as handle:
        for block in iter(lambda: handle.read(1024 * 1024), b""):
            digest.update(block)
    return digest.hexdigest()


def selected_install_device(disk):
    """Return only a canonical kernel block-device path for Archinstall."""
    stable_id = str(disk.get("stableId", ""))
    device_path = str(disk.get("devicePath", ""))
    kernel_device = re.fullmatch(r"/dev/(?:vd[a-z]+|sd[a-z]+|xvd[a-z]+|nvme\d+n\d+|mmcblk\d+|pmem\d+)", device_path)
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
    if not device or "preview" in stable_id.lower():
        return None
    filesystem = disk.get("filesystem", "btrfs")
    if filesystem not in {"btrfs", "ext4"}:
        return None
    try:
        total_mib = int(disk.get("sizeBytes", 0)) // (1024 * 1024)
    except (TypeError, ValueError):
        return None
    # 16 GiB remains the recommended capacity, but it is not a correctness
    # boundary. The hard floor is derived from the actual bounded layout:
    # 8 GiB root + 512 MiB ESP + 3 MiB for start/end alignment slack.
    layout_overhead_mib = 515
    minimum_root_mib = 8 * 1024
    if total_mib < minimum_root_mib + layout_overhead_mib:
        return None
    allocatable_mib = total_mib - layout_overhead_mib
    separate_home = mode == "guided" and bool(disk.get("separateHome", True))
    if separate_home:
        try:
            root_size_mib = int(disk.get("rootSizeGiB", 32)) * 1024
        except (TypeError, ValueError):
            return None
        if root_size_mib < minimum_root_mib or allocatable_mib - root_size_mib < 4 * 1024:
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
            "size": {"sector_size": sector_size, "unit": "MiB", "value": 512},
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
            "start": {"sector_size": sector_size, "unit": "MiB", "value": 513},
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
            "start": {"sector_size": sector_size, "unit": "MiB", "value": 513 + root_size_mib},
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
    suffix = (r"p[1-9][0-9]*"
              if re.fullmatch(r"/dev/(?:nvme\d+n\d+|mmcblk\d+|pmem\d+)", device)
              else r"[1-9][0-9]*")
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
    if root["size_bytes"] < 8 * 1024 * 1024 * 1024 or efi["size_bytes"] < 512 * 1024 * 1024:
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


def _disk_identity_for_handoff(disk: dict[str, Any], configuration: dict[str, Any]) -> dict[str, Any]:
    """Capture the non-secret device facts that must still match at install time."""
    device = selected_install_device(disk)
    layout = configuration.get("disk_config")
    modifications = layout.get("device_modifications") if isinstance(layout, dict) else None
    if not device or not isinstance(modifications, list) or len(modifications) != 1:
        raise ValueError("generated disk layout has no single selected device")
    if modifications[0].get("device") != device:
        raise ValueError("generated disk layout does not match the selected device")
    try:
        size_bytes = int(disk.get("sizeBytes", 0))
    except (TypeError, ValueError) as error:
        raise ValueError("selected disk capacity is invalid") from error
    if size_bytes <= 0:
        raise ValueError("selected disk capacity is missing")

    mode = str(disk.get("mode", "erase"))
    identity: dict[str, Any] = {
        "schemaVersion": 1,
        "mode": mode,
        "stableId": str(disk.get("stableId", "")),
        "devicePath": device,
        "sizeBytes": size_bytes,
        "serial": str(disk.get("serial", "")),
        "wwn": str(disk.get("wwn", "")),
        "partitions": [],
    }
    if mode == "partition":
        for label, key in (("efi", "efiPartition"), ("root", "targetPartition")):
            partition = _safe_partition_on_device(device, disk.get(key))
            if not partition:
                raise ValueError(f"generated {label} partition is unsafe")
            identity["partitions"].append({
                "path": partition["path"],
                "startSectors": partition["start"],
                "sizeBytes": partition["size_bytes"],
                "parttype": partition["parttype"],
                "fstype": partition["fstype"],
            })
    return identity


def build_handoff_manifest(disk: dict[str, Any], configuration: dict[str, Any], generated_dir: Path) -> dict[str, Any]:
    """Bind the ready plan to the exact files and disk facts it was generated from."""
    files = {name: sha256_file(generated_dir / name) for name in HANDOFF_FILE_NAMES}
    handoff = generated_dir / "network-handoff.nmconnection"
    if handoff.exists() or handoff.is_symlink():
        if handoff.is_symlink() or not handoff.is_file():
            raise ValueError("network handoff is not a regular file")
        if handoff.stat().st_mode & 0o077:
            raise ValueError("network handoff is not private")
        files[handoff.name] = sha256_file(handoff)
    return {
        "schemaVersion": 1,
        "disk": _disk_identity_for_handoff(disk, configuration),
        "files": files,
    }


def _load_regular_json(path: Path) -> dict[str, Any]:
    if path.is_symlink() or not path.is_file():
        raise ValueError(f"state JSON is missing or symlinked: {path}")
    payload = load_json(path)
    return payload


def _configuration_matches_handoff(configuration: dict[str, Any], identity: dict[str, Any]) -> tuple[bool, str]:
    device = identity.get("devicePath")
    mode = identity.get("mode")
    disk_config = configuration.get("disk_config")
    modifications = disk_config.get("device_modifications") if isinstance(disk_config, dict) else None
    if not isinstance(device, str) or not isinstance(modifications, list) or len(modifications) != 1:
        return False, "generated configuration has no single disk modification"
    modification = modifications[0]
    if not isinstance(modification, dict) or modification.get("device") != device:
        return False, "generated configuration no longer targets the confirmed disk"
    if mode in {"erase", "guided"}:
        if disk_config.get("config_type") != "default_layout" or modification.get("wipe") is not True:
            return False, "generated full-disk layout is no longer safe"
        return True, ""
    if mode != "partition":
        return False, "generated disk mode is unsupported"
    if disk_config.get("config_type") != "manual_partitioning" or modification.get("wipe") is not False:
        return False, "generated existing-partition layout is no longer safe"
    expected = identity.get("partitions")
    actual = modification.get("partitions")
    if not isinstance(expected, list) or len(expected) != 2 or not isinstance(actual, list):
        return False, "generated existing-partition layout is incomplete"
    expected_paths = {entry.get("path") for entry in expected if isinstance(entry, dict)}
    actual_paths = {entry.get("dev_path") for entry in actual if isinstance(entry, dict)}
    if expected_paths != actual_paths:
        return False, "generated partition layout no longer matches the confirmed partitions"
    return True, ""


def _block_device_snapshot() -> dict[str, dict[str, Any]]:
    """Read the current block topology once, immediately before archinstall."""
    result = subprocess.run(
        ["lsblk", "-J", "-b", "-o",
         "PATH,TYPE,SIZE,RO,RM,HOTPLUG,SERIAL,WWN,MOUNTPOINTS,PKNAME,START,PARTTYPE,FSTYPE"],
        check=False, capture_output=True, text=True, timeout=10,
    )
    if result.returncode != 0:
        raise ValueError("could not refresh the block-device inventory")
    try:
        roots = json.loads(result.stdout).get("blockdevices", [])
    except json.JSONDecodeError as error:
        raise ValueError("block-device inventory was invalid") from error
    if not isinstance(roots, list):
        raise ValueError("block-device inventory was invalid")

    snapshot: dict[str, dict[str, Any]] = {}

    def visit(entry: Any, root_path: str) -> None:
        if not isinstance(entry, dict):
            return
        path = entry.get("path")
        if not isinstance(path, str) or not path:
            return
        record = dict(entry)
        record["_meo_root_path"] = root_path or path
        snapshot[path] = record
        for child in entry.get("children") or []:
            visit(child, record["_meo_root_path"])

    for root in roots:
        visit(root, "")
    return snapshot


def _mounted(record: dict[str, Any]) -> bool:
    values = record.get("mountpoints")
    if not isinstance(values, list):
        values = [values]
    return any(isinstance(value, str) and value.strip() for value in values)


def _walk_block_tree(record: dict[str, Any]):
    yield record
    for child in record.get("children") or []:
        if isinstance(child, dict):
            yield from _walk_block_tree(child)


def _has_active_mapped_descendant(record: dict[str, Any]) -> bool:
    # Under a selected partition, any block child is an active mapping layer.
    # Under a disk, normal partition children are fine, but nested non-part
    # children indicate dm-crypt/LVM/RAID/device-mapper ownership.
    for child in record.get("children") or []:
        if not isinstance(child, dict):
            continue
        if child.get("type") != "part":
            return True
        if _has_active_mapped_descendant(child):
            return True
    return False


def _integer(value: Any, description: str) -> int:
    try:
        return int(value)
    except (TypeError, ValueError) as error:
        raise ValueError(f"{description} is invalid") from error


def _verify_live_disk_state(
    identity: dict[str, Any],
    snapshot: dict[str, dict[str, Any]] | None = None,
    allow_selected_mounts: bool = False,
) -> tuple[bool, str]:
    """Reject identity drift; optionally allow target mounts only for preparation."""
    device = identity.get("devicePath")
    if not isinstance(device, str):
        return False, "confirmed disk identity is invalid"
    try:
        snapshot = snapshot if snapshot is not None else _block_device_snapshot()
        disk = snapshot.get(device)
        if not isinstance(disk, dict) or disk.get("type") != "disk":
            return False, "confirmed disk is no longer a block disk"
        if _integer(disk.get("ro", 0), "read-only flag"):
            return False, "confirmed disk is read-only"
        if _integer(disk.get("size"), "confirmed disk capacity") != _integer(identity.get("sizeBytes"), "selected disk capacity"):
            return False, "confirmed disk capacity changed"
        for field in ("serial", "wwn"):
            expected = identity.get(field)
            if expected and str(disk.get(field, "")) != expected:
                return False, f"confirmed disk {field} changed"
        descendants = [record for record in snapshot.values()
                       if record.get("_meo_root_path") == device]
        # Archinstall unmounts all existing partitions of every modified
        # device and commits the partition table even in MODIFY mode. Active
        # mapped storage anywhere on this disk can make that commit fail.
        if _has_active_mapped_descendant(disk):
            return False, "confirmed disk has active mapped storage that must be deactivated first"
        if identity.get("mode") == "partition":
            partitions = identity.get("partitions")
            if not isinstance(partitions, list) or len(partitions) != 2:
                return False, "confirmed partition identity is invalid"
            if not allow_selected_mounts and any(_mounted(record) for record in descendants):
                return False, "confirmed disk still has active filesystems or swap"
            for expected in partitions:
                if not isinstance(expected, dict):
                    return False, "confirmed partition identity is invalid"
                actual = snapshot.get(expected.get("path"))
                if not isinstance(actual, dict) or actual.get("type") != "part" \
                        or actual.get("_meo_root_path") != device:
                    return False, "confirmed partition is no longer on the selected disk"
                if _integer(actual.get("start"), "partition start") != _integer(expected.get("startSectors"), "selected partition start") \
                        or _integer(actual.get("size"), "partition size") != _integer(expected.get("sizeBytes"), "selected partition size"):
                    return False, "confirmed partition geometry changed"
                for field in ("parttype", "fstype"):
                    expected_value = str(expected.get(field, "")).lower()
                    if expected_value and str(actual.get(field, "")).lower() != expected_value:
                        return False, f"confirmed partition {field} changed"
        elif not allow_selected_mounts and any(_mounted(record) for record in descendants):
            return False, "confirmed disk still has mounted filesystems"
    except (OSError, ValueError) as error:
        return False, str(error)
    return True, ""


def verify_generated_handoff(state_dir: Path, allow_selected_mounts: bool = False) -> tuple[bool, str]:
    """Verify that a ready handoff has not drifted before a destructive run."""
    private, reason = private_directory_ok(state_dir)
    if not private:
        return False, reason
    try:
        manifest = _load_regular_json(state_dir / "config_manifest.json")
        handoff = manifest.get("handoff")
        if manifest.get("schemaVersion") != 2 or manifest.get("realInstallReady") is not True \
                or not isinstance(handoff, dict) or handoff.get("schemaVersion") != 1:
            return False, "generated installation manifest is incomplete"
        files = handoff.get("files")
        identity = handoff.get("disk")
        if not isinstance(files, dict) or not isinstance(identity, dict):
            return False, "generated installation handoff is incomplete"
        if set(HANDOFF_FILE_NAMES) - set(files):
            return False, "generated installation handoff is missing required files"
        allowed = set(HANDOFF_FILE_NAMES) | {"network-handoff.nmconnection"}
        if set(files) - allowed:
            return False, "generated installation handoff lists an unsafe file"
        generated_dir = state_dir / "generated"
        for name, expected_digest in files.items():
            if not isinstance(expected_digest, str) or not re.fullmatch(r"[0-9a-f]{64}", expected_digest):
                return False, "generated installation handoff has an invalid file digest"
            path = generated_dir / name
            if sha256_file(path) != expected_digest:
                return False, f"generated {name} changed after confirmation"
            if name in {"user_credentials.json", "network-handoff.nmconnection"} \
                    and path.stat().st_mode & 0o077:
                return False, f"generated {name} is not private"
        configuration = _load_regular_json(generated_dir / "user_configuration.json")
        matches, reason = _configuration_matches_handoff(configuration, identity)
        if not matches:
            return False, reason
        identity_ok, identity_error = verify_selected_disk_identity(identity)
        if not identity_ok:
            return False, identity_error
        return _verify_live_disk_state(identity, allow_selected_mounts=allow_selected_mounts)
    except (OSError, ValueError, json.JSONDecodeError) as error:
        return False, str(error)


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
        # Graphics packages are derived once from PCI IDs by hardware.py.
        # Leave Archinstall's optional gfx_driver unset so it does not add a
        # second generic Nouveau/AMD/Intel driver stack on top of that plan.
        "packages": desktop_packages,
        "profile_config": {
            # The display manager is enabled by the target customisation step.
            # Do not ask Archinstall to install/configure another greeter as a side effect.
            "profile": {"details": ["KDE Plasma"], "main": "Desktop"},
        },
        "script": "guided",
        "silent": True,
        # Archinstall owns zram. A file swap is created by the target-side,
        # idempotent post-install step after the root filesystem exists.
        "swap": {"enabled": True, "algorithm": "zstd"} if swap_mode == "zram" else False,
        "timezone": locale.get("timezone", "UTC"),
    }
    # The UI exposes only three bounded layouts.  Never consume a raw
    # selections["disk"]["layout"] object: accepting it would let a stale or
    # hand-edited state widen Archinstall's destructive device scope.
    disk_layout = build_existing_partition_layout(selections) or build_default_disk_layout(selections)
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


def current_boot_mode(efi_directory: Path = Path("/sys/firmware/efi")) -> str:
    """Return the firmware mode actually used by the live installer."""
    return "uefi" if efi_directory.is_dir() else "bios"


def validate_installation_plan(selections, configuration, credentials, boot_mode="uefi"):
    """Return user-safe blockers; never silently downgrade a production choice."""
    blockers = []
    disk = selections.get("disk", {})
    if disk.get("mode", "erase") not in {"erase", "guided", "partition"}:
        blockers.append("unsupported disk layout mode")
    if "layout" in disk:
        blockers.append("custom disk layouts are not accepted by this installer")
    if not configuration.get("disk_config"):
        blockers.append("disk layout not generated")
    if disk.get("swap", "zram") not in {"zram", "file", "none"}:
        blockers.append("unsupported swap mode")
    if boot_mode not in {"uefi", "bios"}:
        blockers.append("installer firmware mode is unknown")
    elif boot_mode != "uefi":
        # The current bounded layouts always create/preserve an ESP and final
        # validation requires a UEFI GRUB executable.  Do not let a BIOS-live
        # boot reach disk writes and then fail after partitioning.
        blockers.append("BIOS target installation is unavailable until a tested BIOS GRUB layout exists")
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
    verification = parser.add_mutually_exclusive_group()
    verification.add_argument("--verify-handoff", action="store_true",
                              help="Strictly verify an already-generated handoff immediately before a destructive run")
    verification.add_argument("--verify-handoff-for-preparation", action="store_true",
                              help="Verify identity and generated files before safely unmounting selected targets")
    args = parser.parse_args()

    state_dir = Path(args.state_dir)
    if args.verify_handoff or args.verify_handoff_for_preparation:
        verified, error = verify_generated_handoff(
            state_dir, allow_selected_mounts=args.verify_handoff_for_preparation
        )
        if not verified:
            raise SystemExit(f"installation handoff verification failed: {error}")
        print("installation handoff verification passed")
        return

    try:
        state_dir = ensure_private_directory(state_dir)
        output_dir = ensure_private_directory(state_dir / "generated")
    except (OSError, ValueError) as error:
        raise SystemExit(f"unsafe installer state directory: {error}") from error

    data_dir = Path(args.data_dir)
    selections_path = Path(args.selections) if args.selections else state_dir / "selections.json"
    selections = load_json(selections_path if selections_path.exists() else data_dir / "default_selections.json")
    if selections.get("schemaVersion") != 1:
        raise SystemExit("Unsupported selections schemaVersion; expected 1")

    identity_ok, identity_error = verify_selected_disk_identity(selections.get("disk", {}))
    if not identity_ok:
        raise SystemExit(identity_error)

    secrets = load_json(Path(args.credentials)) if args.credentials else {}
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
    write_json(output_dir / "user_configuration.json", configuration, 0o600)
    write_json(output_dir / "user_credentials.json", credentials, 0o600)
    write_json(output_dir / "hardware.json", hardware, 0o600)
    plasma_path = output_dir / "plasma-localerc"
    write_text(plasma_path, build_plasma_localerc(selections), 0o600)
    customization_path = output_dir / "target-customizations.json"
    write_json(customization_path, build_target_customizations(selections), 0o600)
    install_plan_path = output_dir / "install-plan.json"
    write_json(install_plan_path, plan_as_dict(install_plan), 0o600)

    disk = selections.get("disk", {})
    boot_mode = current_boot_mode()
    blockers = validate_installation_plan(selections, configuration, credentials, boot_mode)
    handoff = None
    if configuration.get("disk_config"):
        try:
            handoff = build_handoff_manifest(disk, configuration, output_dir)
        except (OSError, ValueError) as error:
            blockers.append(f"installation handoff is invalid: {error}")
    ready = not blockers
    manifest = {
        "schemaVersion": 2,
        "state": "ready" if ready else "preview",
        "realInstallReady": ready,
        "blockedReasons": blockers,
        "diskMode": disk.get("mode", "erase"),
        "bootMode": boot_mode,
        "files": {
            "user_configuration": str(output_dir / "user_configuration.json"),
            "user_credentials": str(output_dir / "user_credentials.json"),
            "hardware": str(output_dir / "hardware.json"),
            "plasma_localerc": str(plasma_path),
            "target_customizations": str(customization_path),
            "install_plan": str(install_plan_path),
        },
        "handoff": handoff,
    }
    write_json(state_dir / "config_manifest.json", manifest, 0o600)


if __name__ == "__main__":
    main()
