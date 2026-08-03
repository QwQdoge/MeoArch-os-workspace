#!/usr/bin/env python3
"""Generate version-pinned Archinstall inputs from non-secret installer state."""

import argparse
import json
import os
from pathlib import Path

from hardware import detect_devices, driver_plan


def load_json(path: Path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def write_json(path: Path, payload, mode=0o600):
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_suffix(path.suffix + ".tmp")
    temporary.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    os.chmod(temporary, mode)
    temporary.replace(path)


def build_user_configuration(selections, hardware_plan=None):
    locale = selections.get("locale", {})
    user = selections.get("user", {})
    disk = selections.get("disk", {})
    swap_mode = disk.get("swap", "zram")
    config = {
        "archinstall-language": "English",
        "audio_config": {"audio": "pipewire"},
        "bootloader_config": {"bootloader": "Grub", "uki": False, "removable": False},
        "hostname": user.get("hostname", "meoarch"),
        "kernels": ["linux"],
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
        "packages": (hardware_plan or driver_plan(detect_devices()))["packages"],
        "profile_config": {
            "gfx_driver": "All open-source (default)",
            "greeter": "sddm",
            "profile": {"details": ["KDE Plasma"], "main": "Desktop"},
        },
        "script": "guided",
        "silent": True,
        "swap": {"enabled": swap_mode == "zram", "algorithm": "zstd"} if swap_mode == "zram" else False,
        "timezone": locale.get("timezone", "UTC"),
    }
    if disk.get("layout"):
        config["disk_config"] = disk["layout"]
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
    disk_hash = secrets.get("diskEncryptionPassword")
    if disk_hash:
        payload["encryption_password"] = disk_hash
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


def build_omnistore_provisioning(selections):
    software = selections.get("software", {})
    allowed_profiles = {"productivity", "creative", "developer", "gaming"}
    profiles = []
    for profile in software.get("profiles", []):
        if profile in allowed_profiles and profile not in profiles:
            profiles.append(profile)
    return {
        "schemaVersion": 1,
        "provider": "omnistore",
        "profiles": profiles,
        "requiresUserConfirmation": True,
        "launchOnFirstLogin": bool(software.get("launchOnFirstLogin", True) and profiles),
    }


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

    secrets = load_json(Path(args.credentials)) if args.credentials else {}
    output_dir = state_dir / "generated"
    hardware = driver_plan(detect_devices())
    configuration = build_user_configuration(selections, hardware)
    credentials = build_user_credentials(selections, secrets)
    write_json(output_dir / "user_configuration.json", configuration, 0o644)
    write_json(output_dir / "user_credentials.json", credentials, 0o600)
    write_json(output_dir / "hardware.json", hardware, 0o644)
    plasma_path = output_dir / "plasma-localerc"
    plasma_path.write_text(build_plasma_localerc(selections), encoding="utf-8")
    os.chmod(plasma_path, 0o644)
    provisioning_path = output_dir / "omnistore-provisioning.json"
    write_json(provisioning_path, build_omnistore_provisioning(selections), 0o644)

    disk = selections.get("disk", {})
    ready = bool(configuration.get("disk_config")) and bool(credentials.get("users")) and all(
        user.get("enc_password") for user in credentials.get("users", [])
    )
    manifest = {
        "state": "ready" if ready else "preview",
        "realInstallReady": ready,
        "blockedReasons": (["disk layout not generated"] if not configuration.get("disk_config") else [])
        + (["user password hash missing"] if not ready and credentials.get("users") else []),
        "diskMode": disk.get("mode", "erase"),
        "files": {
            "user_configuration": str(output_dir / "user_configuration.json"),
            "user_credentials": str(output_dir / "user_credentials.json"),
            "hardware": str(output_dir / "hardware.json"),
            "plasma_localerc": str(plasma_path),
            "omnistore_provisioning": str(provisioning_path),
        },
    }
    write_json(state_dir / "config_manifest.json", manifest, 0o644)


if __name__ == "__main__":
    main()
