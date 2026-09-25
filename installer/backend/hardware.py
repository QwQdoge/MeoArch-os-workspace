"""Hardware detection and GPU driver package selection for the MeoArch installer.

This module uses PCI vendor IDs, rather than localized device descriptions, so
the result is stable across Live ISO languages.  It is intentionally a small,
auditable mapping: pacman installs the packages, but does not decide which
driver applies to a PCI device.
"""

from __future__ import annotations

import argparse
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
    # Common virtual display adapters. Treat these as a supported graphics
    # class instead of an unknown physical GPU so VM installs remain useful
    # even when no vendor guest utility is installed yet.
    "1234": "virtual",  # QEMU/Bochs
    "1af4": "virtual",  # virtio-gpu
    "1b36": "virtual",  # QXL / Red Hat virtual display
    "15ad": "virtual",  # VMware
    "80ee": "virtual",  # VirtualBox
    "1414": "virtual",  # Hyper-V
}
DRIVER_PACKAGES = {
    "amd": ["mesa", "vulkan-radeon", "libva-mesa-driver"],
    # Keep both Intel VA-API backends: iHD covers Broadwell+ while i965
    # keeps older Intel HD Graphics usable. libva selects the matching backend.
    "intel": ["mesa", "vulkan-intel", "intel-media-driver", "libva-intel-driver"],
    # virtio Vulkan works when Venus is available; lavapipe keeps Vulkan
    # functional in VMware/VirtualBox/QXL-style VMs without Venus.
    "virtual": ["mesa", "vulkan-virtio", "vulkan-swrast"],
}
NVIDIA_OPEN_PACKAGES = ["nvidia-open", "nvidia-utils", "libva-nvidia-driver"]
NVIDIA_SAFE_FALLBACK_PACKAGES = ["mesa", "libva-mesa-driver", "vulkan-swrast"]
FALLBACK_PACKAGES = ["mesa", "vulkan-swrast", "vulkan-icd-loader"]

GUEST_INTEGRATION = {
    "15ad": {"packages": ["open-vm-tools"], "services": ["vmtoolsd.service"]},
    "80ee": {"packages": ["virtualbox-guest-utils"], "services": ["vboxservice.service"]},
    # QXL is a strong signal for a SPICE desktop guest. spice-vdagent ships
    # its graphical-session user integration, so no system service is forced.
    "1b36": {"packages": ["spice-vdagent"], "services": ["spice-vdagentd.service"]},
}


def nvidia_open_supported(device: dict[str, str]) -> bool:
    """Conservatively identify NVIDIA generations supported by nvidia-open.

    NVIDIA PCI device IDs are generation-grouped; Turing starts at 0x1e00,
    while Volta/Pascal/Maxwell are below that boundary. Unknown/malformed IDs
    deliberately fall back to Nouveau/Mesa instead of installing nvidia-utils,
    because nvidia-utils disables Nouveau and a false positive can leave an
    older GPU without a working graphical fallback.
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
    """Build a de-duplicated package plan while preserving detected adapters."""
    devices = list(devices)
    vendors: list[str] = []
    seen_vendors = set()
    for device in devices:
        vendor = device.get("vendor", "unknown")
        if vendor not in seen_vendors:
            seen_vendors.add(vendor)
            vendors.append(vendor)

    packages: list[str] = []
    seen_packages = set()

    def add_packages(values):
        for package in values:
            if package not in seen_packages:
                seen_packages.add(package)
                packages.append(package)

    known_vendors = [vendor for vendor in vendors if vendor in DRIVER_PACKAGES or vendor == "nvidia"]
    for vendor in known_vendors:
        if vendor != "nvidia":
            add_packages(DRIVER_PACKAGES[vendor])

    nvidia_devices = [device for device in devices if device.get("vendor") == "nvidia"]
    # nvidia-utils can disable the Nouveau fallback globally. Only select the
    # proprietary/open NVIDIA userspace when every detected NVIDIA adapter is
    # confidently in the supported generation range.
    modern_nvidia = bool(nvidia_devices) and all(
        nvidia_open_supported(device) for device in nvidia_devices
    )
    legacy_or_unknown_nvidia = any(
        not nvidia_open_supported(device) for device in nvidia_devices
    )
    if modern_nvidia:
        add_packages(NVIDIA_OPEN_PACKAGES)
    elif legacy_or_unknown_nvidia:
        add_packages(NVIDIA_SAFE_FALLBACK_PACKAGES)

    # A hybrid modern NVIDIA laptop benefits from the standard PRIME helper.
    physical_vendors = {vendor for vendor in known_vendors if vendor != "virtual"}
    hybrid_nvidia = modern_nvidia and "nvidia" in physical_vendors and len(physical_vendors) > 1
    if hybrid_nvidia:
        add_packages(["nvidia-prime"])

    if not packages:
        packages = FALLBACK_PACKAGES.copy()

    guest_packages: list[str] = []
    guest_services: list[str] = []
    seen_guest_services = set()
    for device in devices:
        integration = GUEST_INTEGRATION.get(str(device.get("vendorId", "")).lower())
        if not integration:
            continue
        for package in integration["packages"]:
            if package not in seen_packages:
                seen_packages.add(package)
                packages.append(package)
            if package not in guest_packages:
                guest_packages.append(package)
        for service in integration["services"]:
            if service not in seen_guest_services:
                seen_guest_services.add(service)
                guest_services.append(service)

    unknown_vendors = [vendor for vendor in vendors if vendor not in DRIVER_PACKAGES and vendor != "nvidia"]
    warnings = []
    if legacy_or_unknown_nvidia:
        warnings.append(
            "One or more NVIDIA adapters are older than or could not be confirmed for nvidia-open; "
            "using the non-blacklisting Mesa/Nouveau fallback."
        )
    return {
        "schemaVersion": 1,
        "detected": bool(devices),
        "devices": devices,
        "vendors": vendors,
        "packages": packages,
        "hybridGraphics": hybrid_nvidia,
        "virtualGraphics": "virtual" in vendors,
        "nvidiaOpenSupported": modern_nvidia,
        "nvidiaFallback": legacy_or_unknown_nvidia,
        "unknownAdapters": unknown_vendors,
        "guestPackages": guest_packages,
        "guestServices": guest_services,
        "warnings": warnings,
        # Kept for compatibility with older consumers. The full installer is
        # network-backed regardless of GPU vendor, so graphics detection must
        # never create a separate network gate.
        "requiresNetwork": False,
        "summary": ", ".join(vendors) if vendors else "generic graphics fallback",
    }


def main() -> None:
    parser = argparse.ArgumentParser(description="Detect display hardware for the MeoArch installer.")
    parser.add_argument(
        "--sysfs-root",
        type=Path,
        default=Path("/sys/bus/pci/devices"),
        help="PCI sysfs device directory; primarily useful for deterministic Live/VM diagnostics.",
    )
    args = parser.parse_args()
    print(json.dumps(driver_plan(detect_devices(args.sysfs_root)), indent=2))


if __name__ == "__main__":
    main()
