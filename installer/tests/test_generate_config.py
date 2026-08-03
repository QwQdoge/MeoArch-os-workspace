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
        self.assertEqual(config["packages"], hardware["packages"])
        self.assertIn("nvidia-open", config["packages"])

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
