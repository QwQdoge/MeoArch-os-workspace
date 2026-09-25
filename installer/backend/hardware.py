"""Hardware detection and GPU driver package selection for the MeoArch installer.

This module uses PCI vendor IDs, rather than localized device descriptions, so
the result is stable across Live ISO languages.  It is intentionally a small,
auditable mapping: pacman installs the packages, but does not decide which
driver applies to a PCI device.
"""

from __future__ import annotations

import re
import subprocess
import json
from pathlib import Path
from typing import Any, Iterable


DISPLAY_CLASSES = {"0300", "0302", "0380"}
VENDORS = {
    "1002": "amd",
    "10de": "nvidia",
    "8086": "intel",
    "1af4": "virtio",
    "1234": "qemu",
    "1b36": "qxl",
    "15ad": "vmware",
    "80ee": "virtualbox",
    "1414": "hyperv",
}
DRIVER_PACKAGES = {
    "amd": ["mesa", "vulkan-radeon", "libva-mesa-driver"],
    "intel": ["mesa", "vulkan-intel", "intel-media-driver"],
    "virtio": ["mesa", "vulkan-virtio", "vulkan-swrast"],
    "qemu": ["mesa", "vulkan-swrast"],
    "qxl": ["mesa", "vulkan-swrast"],
    "vmware": ["mesa", "vulkan-swrast"],
    "virtualbox": ["mesa", "vulkan-swrast"],
    "hyperv": ["mesa", "vulkan-swrast"],
}
NVIDIA_OPEN_PACKAGES = ["nvidia-open", "nvidia-utils", "libva-nvidia-driver"]
NVIDIA_FALLBACK_PACKAGES = ["mesa", "vulkan-nouveau", "libva-mesa-driver"]
FALLBACK_PACKAGES = ["mesa", "vulkan-swrast", "vulkan-icd-loader"]


def nvidia_open_supported(device: dict[str, str]) -> bool:
    """Conservatively identify NVIDIA devices that can use open kernel modules.

    NVIDIA documents open kernel modules for Turing and newer only. PCI device
    IDs for that generation start at 0x1e00; malformed or older IDs deliberately
    use the open Mesa/Nouveau path instead of risking an unusable proprietary
    stack on first boot.
    """
    if device.get("vendor") != "nvidia":
        return False
    try:
        return int(device.get("deviceId", ""), 16) >= 0x1E00
    except (TypeError, ValueError):
        return False


def pci_devices(sysfs_root: Path = Path("/sys/bus/pci/devices")) -> Iterable[dict[str, str]]:
    """Return display PCI devices from sysfs without requiring lspci."""
    if not sysfs_root.is_dir():
        return []
    devices = []
    for device_path in sorted(sysfs_root.iterdir()):
        try:
            class_code = (device_path / "class").read_text().strip().removeprefix("0x").lower()
            vendor_id = (device_path / "vendor").read_text().strip().removeprefix("0x").lower()
            device_id = (device_path / "device").read_text().strip().removeprefix("0x").lower()
        except OSError:
            continue
        if class_code[:4] not in DISPLAY_CLASSES:
            continue
        devices.append({
            "address": device_path.name,
            "class": class_code,
            "vendorId": vendor_id,
            "deviceId": device_id,
            "vendor": VENDORS.get(vendor_id, "unknown"),
        })
    return devices


def lspci_devices(command: str = "lspci") -> Iterable[dict[str, str]]:
    """Fallback for development environments where the sysfs PCI view is absent."""
    try:
        output = subprocess.run(
            [command, "-Dn"], check=False, text=True, capture_output=True, timeout=5
        ).stdout
    except (FileNotFoundError, subprocess.SubprocessError):
        return []
    devices = []
    pattern = re.compile(r"^(?P<address>\S+)\s+(?P<class>[0-9a-fA-F]{4}):\s+"
                         r"(?P<vendor>[0-9a-fA-F]{4}):(?P<device>[0-9a-fA-F]{4})")
    for line in output.splitlines():
        match = pattern.match(line)
        if not match or match["class"].lower() not in DISPLAY_CLASSES:
            continue
        vendor_id = match["vendor"].lower()
        devices.append({
            "address": match["address"], "class": match["class"].lower(),
            "vendorId": vendor_id, "deviceId": match["device"].lower(),
            "vendor": VENDORS.get(vendor_id, "unknown"),
        })
    return devices


def detect_devices(sysfs_root: Path = Path("/sys/bus/pci/devices")) -> list[dict[str, str]]:
    """Prefer sysfs and fall back to lspci when it is unavailable."""
    return list(pci_devices(sysfs_root)) or list(lspci_devices())


def driver_plan(devices: Iterable[dict[str, str]]) -> dict[str, Any]:
    """Build a safe de-duplicated package plan for every detected adapter."""
    devices = list(devices)
    seen_vendors: set[str] = set()
    vendors: list[str] = []
    for device in devices:
        vendor = device.get("vendor", "unknown")
        if vendor not in seen_vendors:
            seen_vendors.add(vendor)
            vendors.append(vendor)

    package_groups: list[list[str]] = []
    nvidia_devices = [device for device in devices if device.get("vendor") == "nvidia"]
    if nvidia_devices:
        if all(nvidia_open_supported(device) for device in nvidia_devices):
            package_groups.append(NVIDIA_OPEN_PACKAGES)
        else:
            # One unsupported/unknown NVIDIA adapter is enough to avoid
            # nvidia-utils, because a proprietary userspace stack can disable
            # the Nouveau fallback needed by the older device.
            package_groups.append(NVIDIA_FALLBACK_PACKAGES)

    for vendor in vendors:
        if vendor == "nvidia":
            continue
        if vendor == "unknown":
            package_groups.append(FALLBACK_PACKAGES)
            continue
        package_groups.append(DRIVER_PACKAGES.get(vendor, FALLBACK_PACKAGES))

    if not package_groups:
        package_groups.append(FALLBACK_PACKAGES)

    seen_packages: set[str] = set()
    packages: list[str] = []
    for group in package_groups:
        for package in group:
            if package not in seen_packages:
                seen_packages.add(package)
                packages.append(package)

    return {
        "schemaVersion": 1,
        "detected": bool(devices),
        "devices": devices,
        "vendors": vendors,
        "packages": packages,
        "requiresNetwork": bool(nvidia_devices),
        "summary": ", ".join(vendors) if vendors else "no supported display adapter detected",
    }


if __name__ == "__main__":
    print(json.dumps(driver_plan(detect_devices()), indent=2))
