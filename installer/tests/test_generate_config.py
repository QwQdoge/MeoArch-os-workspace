import importlib.util
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path


MODULE_PATH = Path(__file__).parents[1] / "backend" / "generate-config.py"
sys.path.insert(0, str(MODULE_PATH.parent))
SPEC = importlib.util.spec_from_file_location("generate_config", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class GenerateConfigTests(unittest.TestCase):
    def setUp(self):
        self.selections = json.loads((Path(__file__).parents[1] / "data" / "default_selections.json").read_text(encoding="utf-8"))

    def test_archinstall_locale_mapping_and_hidden_defaults(self):
        self.selections["locale"].update({
            "systemLocale": "de_DE.UTF-8", "keyboardLayout": "de", "timezone": "Europe/Berlin"
        })
        config = MODULE.build_user_configuration(self.selections)
        self.assertEqual(config["locale_config"], {"kb_layout": "de", "sys_enc": "UTF-8", "sys_lang": "de_DE.UTF-8"})
        self.assertEqual(config["timezone"], "Europe/Berlin")
        self.assertEqual(config["bootloader_config"]["bootloader"], "Grub")
        self.assertEqual(config["kernels"], ["linux"])
        self.assertEqual(config["network_config"], {"type": "nm"})

    def test_selections_never_contain_secrets(self):
        forbidden = {"password", "passphrase", "wifiSecret", "rootPasswordHash", "userPasswordHash"}
        serialized = json.dumps(self.selections).lower()
        for key in forbidden:
            self.assertNotIn(key.lower(), serialized)

    def test_credentials_are_0600_and_separate(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "credentials.json"
            MODULE.write_json(target, {"users": []}, 0o600)
            if os.name != "nt":
                self.assertEqual(target.stat().st_mode & 0o777, 0o600)

    def test_kde_format_locale_uses_country_format_choice(self):
        self.selections["locale"]["formatLocale"] = "en_SG.UTF-8"
        localerc = MODULE.build_plasma_localerc(self.selections)
        self.assertIn("LC_TIME=en_SG.UTF-8", localerc)
        self.assertIn("LC_MEASUREMENT=en_SG.UTF-8", localerc)

    def test_nvidia_plan_is_added_to_archinstall_packages(self):
        hardware = {
            "vendors": ["intel", "nvidia"],
            "packages": ["mesa", "vulkan-intel", "libva-mesa-driver", "nvidia-open", "nvidia-utils"],
        }
        config = MODULE.build_user_configuration(self.selections, hardware)
        self.assertEqual(config["packages"][:len(hardware["packages"])], hardware["packages"])
        self.assertIn("nvidia-open", config["packages"])
        for package in MODULE.MEO_DESKTOP_PACKAGES:
            self.assertIn(package, config["packages"])

    def test_erase_mode_generates_explicit_safe_disk_layout(self):
        self.selections["disk"]["stableId"] = "/dev/vda"
        self.selections["disk"]["sizeBytes"] = 64 * 1024 * 1024 * 1024
        config = MODULE.build_user_configuration(self.selections)
        layout = config["disk_config"]
        self.assertEqual(layout["config_type"], "default_layout")
        modification = layout["device_modifications"][0]
        self.assertEqual(modification["device"], "/dev/vda")
        self.assertTrue(modification["wipe"])
        self.assertEqual(modification["partitions"][0]["mountpoint"], "/boot")
        self.assertEqual(modification["partitions"][0]["flags"], ["boot", "esp"])
        self.assertEqual(modification["partitions"][1]["mountpoint"], "/")
        self.assertEqual(modification["partitions"][1]["fs_type"], "btrfs")
        self.assertEqual(modification["partitions"][1]["size"]["value"], 64509)
        self.assertIsNone(modification["partitions"][0]["dev_path"])
        self.assertEqual(
            modification["partitions"][0]["start"]["sector_size"],
            {"unit": "B", "value": 512},
        )

    def test_unsafe_or_preview_disk_never_generates_layout(self):
        for device in ("preview-disk-0", "/dev/disk/by-id/usb-removable", "/dev/sda1", "/tmp/disk"):
            with self.subTest(device=device):
                self.selections["disk"]["stableId"] = device
                self.selections["disk"]["sizeBytes"] = 64 * 1024 * 1024 * 1024
                self.assertNotIn("disk_config", MODULE.build_user_configuration(self.selections))

    def test_omnistore_provisioning_is_allowlisted_and_requires_confirmation(self):
        self.selections["software"]["profiles"] = [
            "developer", "unknown", "developer", "gaming"
        ]
        provisioning = MODULE.build_omnistore_provisioning(self.selections)
        self.assertEqual(provisioning["profiles"], ["developer", "gaming"])
        self.assertTrue(provisioning["requiresUserConfirmation"])
        self.assertTrue(provisioning["launchOnFirstLogin"])

    def test_empty_omnistore_selection_does_not_launch(self):
        provisioning = MODULE.build_omnistore_provisioning(self.selections)
        self.assertEqual(provisioning["profiles"], [])
        self.assertFalse(provisioning["launchOnFirstLogin"])


if __name__ == "__main__":
    unittest.main()
