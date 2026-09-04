import importlib.util
import json
import os
import sys
import tempfile
import unittest
from pathlib import Path
from unittest import mock


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
        self.selections["disk"]["devicePath"] = "/dev/vda"
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

    def test_guided_layout_creates_adjustable_root_and_separate_home(self):
        self.selections["disk"].update({
            "mode": "guided",
            "stableId": "/dev/vda",
            "devicePath": "/dev/vda",
            "sizeBytes": 64 * 1024 * 1024 * 1024,
            "rootSizeGiB": 32,
            "separateHome": True,
        })
        layout = MODULE.build_default_disk_layout(self.selections)
        partitions = layout["device_modifications"][0]["partitions"]
        self.assertEqual([partition["mountpoint"] for partition in partitions], ["/boot", "/", "/home"])
        self.assertEqual(partitions[1]["size"]["value"], 32 * 1024)
        self.assertGreaterEqual(partitions[2]["size"]["value"], 8 * 1024)
        self.assertEqual(partitions[2]["start"]["value"], 1025 + 32 * 1024)

    def test_guided_layout_rejects_too_small_root_or_home(self):
        self.selections["disk"].update({
            "mode": "guided", "stableId": "/dev/vda", "devicePath": "/dev/vda",
            "sizeBytes": 32 * 1024 * 1024 * 1024, "separateHome": True,
        })
        for root_size in (8, 28):
            with self.subTest(root_size=root_size):
                self.selections["disk"]["rootSizeGiB"] = root_size
                self.assertIsNone(MODULE.build_default_disk_layout(self.selections))

    def test_unsafe_or_preview_disk_never_generates_layout(self):
        for device in ("preview-disk-0", "/dev/disk/by-id/usb-removable", "/dev/sda1", "/tmp/disk"):
            with self.subTest(device=device):
                self.selections["disk"]["stableId"] = device
                self.selections["disk"]["devicePath"] = device
                self.selections["disk"]["sizeBytes"] = 64 * 1024 * 1024 * 1024
                self.assertNotIn("disk_config", MODULE.build_user_configuration(self.selections))

    def test_firewall_is_a_real_target_package_when_selected(self):
        self.selections["privacy"] = {"firewall": True}
        self.assertIn("firewalld", MODULE.build_user_configuration(self.selections)["packages"])
        self.selections["privacy"]["firewall"] = False
        self.assertNotIn("firewalld", MODULE.build_user_configuration(self.selections)["packages"])

    def test_catalog_application_packages_are_added_to_archinstall(self):
        config = MODULE.build_user_configuration(
            self.selections, application_packages=("firefox", "libreoffice-fresh")
        )
        self.assertIn("firefox", config["packages"])
        self.assertIn("libreoffice-fresh", config["packages"])

    def test_by_id_is_revalidated_but_archinstall_receives_kernel_path(self):
        disk = {
            "stableId": "/dev/disk/by-id/nvme-MeoArch_Test",
            "devicePath": "/dev/nvme0n1",
            "sizeBytes": 64 * 1024 * 1024 * 1024,
            "mode": "erase",
            "filesystem": "btrfs",
        }
        self.selections["disk"].update(disk)
        with mock.patch.object(MODULE.os.path, "exists", return_value=True), \
             mock.patch.object(MODULE.os.path, "islink", return_value=True), \
             mock.patch.object(MODULE.os.path, "realpath", return_value="/dev/nvme0n1"):
            self.assertEqual(MODULE.verify_selected_disk_identity(disk), (True, ""))
        layout = MODULE.build_default_disk_layout(self.selections)
        self.assertEqual(layout["device_modifications"][0]["device"], "/dev/nvme0n1")

    def test_by_id_resolution_drift_is_rejected(self):
        disk = {
            "stableId": "/dev/disk/by-id/nvme-MeoArch_Test",
            "devicePath": "/dev/nvme0n1",
        }
        with mock.patch.object(MODULE.os.path, "exists", return_value=True), \
             mock.patch.object(MODULE.os.path, "islink", return_value=True), \
             mock.patch.object(MODULE.os.path, "realpath", return_value="/dev/nvme1n1"):
            verified, reason = MODULE.verify_selected_disk_identity(disk)
        self.assertFalse(verified)
        self.assertIn("another device", reason)

    def test_target_customizations_carry_no_secrets(self):
        self.selections["user"].update({"fullName": "Meo User", "username": "meo", "automaticLogin": True})
        self.selections["disk"]["swap"] = "file"
        payload = MODULE.build_target_customizations(self.selections)
        self.assertEqual(payload["fullName"], "Meo User")
        self.assertEqual(payload["sddmSession"], "plasma.desktop")
        self.assertEqual(payload["swap"], {"mode": "file", "fileSizeMiB": 4096})
        serialized = json.dumps(payload).lower()
        self.assertNotIn("password", serialized)
        self.assertNotIn("passphrase", serialized)

    def test_generated_plan_uses_signed_package_channel_model(self):
        self.selections["software"] = {"profile": "minimal", "channel": "beta", "mirror": "automatic", "components": []}
        config = MODULE.build_meo_install_config(self.selections)
        plan = MODULE.build_install_plan(config, MODULE.catalog_from(Path(__file__).parents[1] / "data" / "package-catalog.json"))
        self.assertEqual(plan.repository.repositories, ("meo-beta", "meo"))
        self.assertNotIn("meo-settings", plan.package.packages)

    def test_real_runner_preflights_signed_meo_metadata_before_archinstall(self):
        runner = (Path(__file__).parents[2] / "installer/backend/run-archinstall.sh").read_text(encoding="utf-8")
        self.assertIn("preflight-meo-repository.sh", runner)
        self.assertLess(runner.index("preflight-meo-repository.sh"), runner.index("archinstall --silent"))

    def test_selection_change_invalidates_persisted_confirmation_and_preflight(self):
        controller = (Path(__file__).parents[2] / "installer/app/installercontroller.cpp").read_text(encoding="utf-8")
        self.assertIn('QFile::remove(QDir(directory).absoluteFilePath(QStringLiteral("summary_confirmed")))', controller)
        self.assertIn('QFile::remove(QDir(directory).absoluteFilePath(QStringLiteral("preflight_status.json")))', controller)

    def test_plan_validation_blocks_manual_and_unimplemented_encryption(self):
        self.selections["disk"].update({"mode": "manual", "stableId": "/dev/vda", "devicePath": "/dev/vda", "sizeBytes": 64 * 1024 * 1024 * 1024})
        self.selections["privacy"] = {"diskEncryption": True}
        config = MODULE.build_user_configuration(self.selections)
        credentials = {"users": [{"username": "meo", "enc_password": "$6$hash"}]}
        blockers = MODULE.validate_installation_plan(self.selections, config, credentials)
        self.assertIn("unsupported disk layout mode", blockers)
        self.assertIn("disk encryption is unavailable until its tested secret flow is enabled", blockers)



    def test_build_user_credentials_happy_path(self):
        selections = {"user": {"username": "testuser"}}
        secrets = {
            "rootPasswordHash": "root_hash",
            "userPasswordHash": "user_hash"
        }
        payload = MODULE.build_user_credentials(selections, secrets)
        self.assertEqual(payload["root_enc_password"], "root_hash")
        self.assertEqual(len(payload["users"]), 1)
        self.assertEqual(payload["users"][0], {"username": "testuser", "enc_password": "user_hash", "sudo": True})
        self.assertNotIn("encryption_password", payload)

    def test_build_user_credentials_missing_username(self):
        selections = {"user": {}}
        secrets = {"rootPasswordHash": "root_hash"}
        payload = MODULE.build_user_credentials(selections, secrets)
        self.assertEqual(payload["users"], [])
        self.assertNotIn("encryption_password", payload)
        self.assertEqual(payload["root_enc_password"], "root_hash")

    def test_build_user_credentials_empty_inputs(self):
        payload = MODULE.build_user_credentials({}, {})
        self.assertEqual(payload["users"], [])
        self.assertEqual(payload["root_enc_password"], "")
        self.assertNotIn("encryption_password", payload)

    def test_load_json_valid_file(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "valid.json"
            target.write_text('{"key": "value"}', encoding="utf-8")
            result = MODULE.load_json(target)
            self.assertEqual(result, {"key": "value"})

    def test_load_json_bad_json(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "bad.json"
            target.write_text('{bad json}', encoding="utf-8")
            with self.assertRaises(json.JSONDecodeError):
                MODULE.load_json(target)

    def test_load_json_missing_file(self):
        with tempfile.TemporaryDirectory() as directory:
            target = Path(directory) / "missing.json"
            with self.assertRaises(FileNotFoundError):
                MODULE.load_json(target)


if __name__ == "__main__":
    unittest.main()
