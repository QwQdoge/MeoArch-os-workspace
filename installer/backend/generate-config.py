#!/usr/bin/env python3
import argparse
import json
from pathlib import Path


def load_json(path):
    with path.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def write_json(path, payload, mode=0o600):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, indent=2, ensure_ascii=False) + "\n", encoding="utf-8")
    path.chmod(mode)


def build_user_configuration(selections):
    locale = selections.get("locale", {})
    user = selections.get("user", {})
    network = selections.get("network", {})
    privacy = selections.get("privacy", {})

    return {
        "archinstall-language": locale.get("archinstallLanguage", "English"),
        "sys-language": locale.get("sys-language", "en_US"),
        "sys-encoding": locale.get("sys-encoding", "UTF-8"),
        "keyboard-layout": locale.get("keyboard-layout", "us"),
        "timezone": locale.get("timezone", "UTC"),
        "hostname": user.get("hostname", "meoarch"),
        "network_config": {
            "type": network.get("mode", "networkmanager")
        },
        "meoarch": {
            "privacy": privacy,
            "source": "meoarch-qml-installer"
        }
    }


def build_user_credentials(selections):
    credentials = selections.get("credentials", {})
    user = selections.get("user", {})
    username = user.get("username", "")

    payload = {
        "root_enc_password": credentials.get("rootPasswordHash", ""),
        "users": []
    }

    if username:
        payload["users"].append({
            "username": username,
            "enc_password": credentials.get("userPasswordHash", ""),
            "sudo": True
        })

    return payload


def main():
    parser = argparse.ArgumentParser(description="Generate archinstall JSON files from MeoArch installer selections.")
    parser.add_argument("--data-dir", default="/opt/meoarch-installer/data")
    parser.add_argument("--state-dir", default="/tmp/meoarch-installer")
    parser.add_argument("--selections")
    args = parser.parse_args()

    data_dir = Path(args.data_dir)
    state_dir = Path(args.state_dir)
    selections_path = Path(args.selections) if args.selections else state_dir / "selections.json"

    if selections_path.exists():
        selections = load_json(selections_path)
    else:
        selections = load_json(data_dir / "default_selections.json")

    output_dir = state_dir / "generated"
    write_json(output_dir / "user_configuration.json", build_user_configuration(selections), 0o644)
    write_json(output_dir / "user_credentials.json", build_user_credentials(selections), 0o600)

    disk = selections.get("disk", {})
    if disk.get("mode") != "not_configured" and disk.get("layout"):
        write_json(output_dir / "user_disk_layouts.json", disk["layout"], 0o600)

    manifest = {
        "state": "generated",
        "files": {
            "user_configuration": str(output_dir / "user_configuration.json"),
            "user_credentials": str(output_dir / "user_credentials.json"),
            "user_disk_layouts": str(output_dir / "user_disk_layouts.json") if (output_dir / "user_disk_layouts.json").exists() else None
        }
    }
    write_json(state_dir / "config_manifest.json", manifest, 0o644)


if __name__ == "__main__":
    main()
