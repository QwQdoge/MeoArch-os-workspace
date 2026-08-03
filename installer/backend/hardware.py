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
VENDORS = {"1002": "amd", "10de": "nvidia", "8086": "intel"}
DRIVER_PACKAGES = {
    "amd": ["mesa", "vulkan-radeon", "libva-mesa-driver"],
    "intel": ["mesa", "vulkan-intel", "libva-mesa-driver"],
    # nvidia-open is the supported current NVIDIA kernel-module package in the
    # Arch repositories.  Legacy NVIDIA hardware needs a manual post-install
    # choice rather than silently selecting an unsupported third-party driver.
    "nvidia": ["nvidia-open", "nvidia-utils"],
}
FALLBACK_PACKAGES = ["mesa", "vulkan-icd-loader", "libva-mesa-driver"]


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
    """Build a de-duplicated package plan while preserving detected adapters."""
    devices = list(devices)
    vendors: list[str] = []
    for device in devices:
        vendor = device.get("vendor", "unknown")
        if vendor not in vendors:
            vendors.append(vendor)

    packages: list[str] = []
    for vendor in vendors:
        for package in DRIVER_PACKAGES.get(vendor, []):
            if package not in packages:
                packages.append(package)
    if not packages:
        packages = FALLBACK_PACKAGES.copy()

    return {
        "schemaVersion": 1,
        "detected": bool(devices),
        "devices": devices,
        "vendors": vendors,
        "packages": packages,
        "requiresNetwork": any(vendor == "nvidia" for vendor in vendors),
        "summary": ", ".join(vendors) if vendors else "no supported display adapter detected",
    }


if __name__ == "__main__":
    print(json.dumps(driver_plan(detect_devices()), indent=2))
