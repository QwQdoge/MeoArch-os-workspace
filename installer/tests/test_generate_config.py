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

    def test_state_writers_refuse_a_stale_symlink(self):
        with tempfile.TemporaryDirectory() as directory:
            root = Path(directory)
            outside = root / "must-not-change"
            outside.write_text("sentinel\n", encoding="utf-8")
            destination = root / "generated" / "plasma-localerc"
            destination.parent.mkdir()
            destination.symlink_to(outside)
            with self.assertRaisesRegex(ValueError, "symlinked state file"):
                MODULE.write_text(destination, "[Formats]\nLANG=en_US.UTF-8\n", 0o600)
            self.assertEqual(outside.read_text(encoding="utf-8"), "sentinel\n")

    def test_kde_format_locale_uses_country_format_choice(self):
        self.selections["locale"]["formatLocale"] = "en_SG.UTF-8"
        localerc = MODULE.build_plasma_localerc(self.selections)
        self.assertIn("LC_TIME=en_SG.UTF-8", localerc)
        self.assertIn("LC_MEASUREMENT=en_SG.UTF-8", localerc)

    def test_region_presets_cover_the_supported_country_first_defaults(self):
        presets = json.loads((Path(__file__).parents[1] / "data" / "region-presets.json").read_text(encoding="utf-8"))["presets"]
        self.assertEqual(presets["CN"]["systemLocale"], "zh_CN.UTF-8")
        self.assertEqual(presets["CN"]["timeZone"], "Asia/Shanghai")
        self.assertEqual(presets["HK"]["systemLocale"], "zh_HK.UTF-8")
        self.assertEqual(presets["HK"]["timeZone"], "Asia/Hong_Kong")
        self.assertEqual(presets["KR"]["systemLocale"], "ko_KR.UTF-8")
        self.assertEqual(presets["KR"]["timeZone"], "Asia/Seoul")
        self.assertEqual(presets["SG"]["systemLocaleByUiLanguage"],
                         {"en": "en_SG.UTF-8", "zh_CN": "zh_SG.UTF-8"})

    def test_target_customizations_keep_calendar_and_network_handoff_non_secret(self):
        self.selections["preferences"].update({
            "secondaryCalendar": "hebcal", "hebcalEnabled": True,
        })
        self.selections["network"]["handoffEnabled"] = True
        customizations = MODULE.build_target_customizations(self.selections)
        self.assertEqual(customizations["calendar"], {
            "primary": "gregorian", "secondary": "hebcal", "hebcalEnabled": True,
        })
        self.assertEqual(customizations["networkHandoff"], {
            "enabled": True, "file": "network-handoff.nmconnection",
        })
        self.assertNotIn("password", json.dumps(customizations).lower())

    def test_unknown_secondary_calendar_blocks_plan(self):
        self.selections["preferences"]["secondaryCalendar"] = "invented"
        configuration = MODULE.build_user_configuration(self.selections)
        credentials = MODULE.build_user_credentials(self.selections, {"userPasswordHash": "$6$hash"})
        blockers = MODULE.validate_installation_plan(self.selections, configuration, credentials)
        self.assertIn("unsupported secondary calendar", blockers)

    def test_nvidia_plan_is_added_to_archinstall_packages(self):
        hardware = {
            "vendors": ["intel", "nvidia"],
            "packages": ["mesa", "vulkan-intel", "libva-mesa-driver", "nvidia-open", "nvidia-utils"],
        }
        config = MODULE.build_user_configuration(self.selections, hardware)
        self.assertEqual(config["packages"][:len(hardware["packages"])], hardware["packages"])
        self.assertIn("nvidia-open", config["packages"])
        self.assertNotIn("gfx_driver", config["profile_config"])
        for package in MODULE.MEO_DESKTOP_PACKAGES:
            self.assertIn(package, config["packages"])

    def test_archinstall_does_not_request_meo_repository_packages_before_repo_setup(self):
        # Meo packages are installed only after the target's signed Meo
        # repository is configured by run-archinstall.sh. Asking Archinstall
        # for OmniStore earlier would fail against the Arch official catalog
        # and would ignore a Minimal/unchecked Custom choice.
        config = MODULE.build_user_configuration(self.selections)
        self.assertNotIn("omnistore-bin", MODULE.MEO_DESKTOP_PACKAGES)
        self.assertNotIn("omnistore-bin", config["packages"])

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
        self.assertEqual(modification["partitions"][1]["size"]["value"], 65021)
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
        self.assertEqual(partitions[2]["start"]["value"], 513 + 32 * 1024)

    def test_guided_simple_layout_keeps_one_linux_root_partition(self):
        self.selections["disk"].update({
            "mode": "guided",
            "stableId": "/dev/vda",
            "devicePath": "/dev/vda",
            "sizeBytes": 64 * 1024 * 1024 * 1024,
            "separateHome": False,
        })
        layout = MODULE.build_default_disk_layout(self.selections)
        partitions = layout["device_modifications"][0]["partitions"]
        self.assertEqual([partition["mountpoint"] for partition in partitions], ["/boot", "/"])
        self.assertEqual(partitions[1]["size"]["value"], 65021)

    def test_full_disk_layout_allows_below_recommended_capacity_but_keeps_absolute_floor(self):
        mib = 1024 * 1024
        self.selections["disk"].update({
            "mode": "erase",
            "stableId": "/dev/vda",
            "devicePath": "/dev/vda",
            "sizeBytes": 15 * 1024 * 1024 * 1024,
        })
        self.assertIsNotNone(MODULE.build_default_disk_layout(self.selections))
        self.selections["disk"]["sizeBytes"] = (8 * 1024 + 515) * mib
        self.assertIsNotNone(MODULE.build_default_disk_layout(self.selections))
        self.selections["disk"]["sizeBytes"] = (8 * 1024 + 514) * mib
        self.assertIsNone(MODULE.build_default_disk_layout(self.selections))

    def test_existing_partition_plan_only_rebuilds_the_selected_root(self):
        gib = 1024 * 1024 * 1024
        self.selections["disk"].update({
            "mode": "partition", "stableId": "/dev/nvme0n1", "devicePath": "/dev/nvme0n1",
            "filesystem": "btrfs",
            "efiPartition": {
                "path": "/dev/nvme0n1p1", "startSectors": 2048,
                "sizeSectors": (512 * 1024 * 1024) // 512, "logicalSectorSize": 512,
                "sizeBytes": 512 * 1024 * 1024,
                "parttype": "c12a7328-f81f-11d2-ba4b-00a0c93ec93b", "fstype": "vfat",
            },
            "targetPartition": {
                "path": "/dev/nvme0n1p4", "startSectors": 4 * 1024 * 1024,
                "sizeSectors": (32 * gib) // 512, "logicalSectorSize": 512,
                "sizeBytes": 32 * gib, "parttype": "0fc63daf-8483-4772-8e79-3d69d8477de4", "fstype": "ext4",
            },
        })
        layout = MODULE.build_existing_partition_layout(self.selections)
        self.assertEqual(layout["config_type"], "manual_partitioning")
        modification = layout["device_modifications"][0]
        self.assertFalse(modification["wipe"])
        self.assertEqual([(item["dev_path"], item["status"], item["mountpoint"])
                          for item in modification["partitions"]], [
                              ("/dev/nvme0n1p1", "existing", "/boot"),
                              ("/dev/nvme0n1p4", "modify", "/"),
                          ])
        self.assertEqual(modification["partitions"][1]["fs_type"], "btrfs")
        self.assertEqual(modification["partitions"][1]["size"]["unit"], "sectors")

    def test_existing_partition_plan_rejects_cross_disk_or_unsafe_efi(self):
        self.selections["disk"].update({
            "mode": "partition", "stableId": "/dev/vda", "devicePath": "/dev/vda",
            "efiPartition": {"path": "/dev/vda1", "startSectors": 2048, "sizeSectors": 1048576,
                             "logicalSectorSize": 512, "sizeBytes": 512 * 1024 * 1024,
                             "parttype": "not-an-esp", "fstype": "vfat"},
            "targetPartition": {"path": "/dev/vdb1", "startSectors": 1050624,
                                "sizeSectors": 32 * 1024 * 1024 * 1024 // 512,
                                "logicalSectorSize": 512, "sizeBytes": 32 * 1024 * 1024 * 1024},
        })
        self.assertIsNone(MODULE.build_existing_partition_layout(self.selections))

    def test_guided_layout_rejects_too_small_root_or_home(self):
        self.selections["disk"].update({
            "mode": "guided", "stableId": "/dev/vda", "devicePath": "/dev/vda",
            "sizeBytes": 32 * 1024 * 1024 * 1024, "separateHome": True,
        })
        for root_size in (7, 29):
            with self.subTest(root_size=root_size):
                self.selections["disk"]["rootSizeGiB"] = root_size
                self.assertIsNone(MODULE.build_default_disk_layout(self.selections))

    def test_unsafe_or_preview_disk_never_generates_layout(self):
        for device in ("preview-disk-0", "/dev/sda1", "/tmp/disk"):
            with self.subTest(device=device):
                self.selections["disk"]["stableId"] = device
                self.selections["disk"]["devicePath"] = device
                self.selections["disk"]["sizeBytes"] = 64 * 1024 * 1024 * 1024
                self.assertNotIn("disk_config", MODULE.build_user_configuration(self.selections))

    def test_removable_by_id_can_use_a_canonical_kernel_device(self):
        self.selections["disk"].update({
            "mode": "erase",
            "stableId": "/dev/disk/by-id/usb-MeoArch_Test",
            "devicePath": "/dev/sdb",
            "sizeBytes": 15 * 1024 * 1024 * 1024,
        })
        layout = MODULE.build_default_disk_layout(self.selections)
        self.assertIsNotNone(layout)
        self.assertEqual(layout["device_modifications"][0]["device"], "/dev/sdb")

    def test_emmc_partition_paths_are_supported(self):
        gib = 1024 * 1024 * 1024
        self.selections["disk"].update({
            "mode": "partition", "stableId": "/dev/mmcblk0", "devicePath": "/dev/mmcblk0",
            "filesystem": "ext4",
            "efiPartition": {
                "path": "/dev/mmcblk0p1", "startSectors": 2048,
                "sizeSectors": (512 * 1024 * 1024) // 512, "logicalSectorSize": 512,
                "sizeBytes": 512 * 1024 * 1024,
                "parttype": "c12a7328-f81f-11d2-ba4b-00a0c93ec93b", "fstype": "vfat",
            },
            "targetPartition": {
                "path": "/dev/mmcblk0p2", "startSectors": 264192,
                "sizeSectors": (12 * gib) // 512, "logicalSectorSize": 512,
                "sizeBytes": 12 * gib,
                "parttype": "0fc63daf-8483-4772-8e79-3d69d8477de4", "fstype": "ext4",
            },
        })
        layout = MODULE.build_existing_partition_layout(self.selections)
        self.assertIsNotNone(layout)
        self.assertEqual(
            [item["dev_path"] for item in layout["device_modifications"][0]["partitions"]],
            ["/dev/mmcblk0p1", "/dev/mmcblk0p2"],
        )

    def test_existing_partition_plan_rejects_esp_too_small_for_reliable_boot_files(self):
        gib = 1024 * 1024 * 1024
        self.selections["disk"].update({
            "mode": "partition", "stableId": "/dev/vda", "devicePath": "/dev/vda",
            "filesystem": "ext4",
            "efiPartition": {
                "path": "/dev/vda1", "startSectors": 2048,
                "sizeSectors": (256 * 1024 * 1024) // 512, "logicalSectorSize": 512,
                "sizeBytes": 256 * 1024 * 1024,
                "parttype": "c12a7328-f81f-11d2-ba4b-00a0c93ec93b", "fstype": "vfat",
            },
            "targetPartition": {
                "path": "/dev/vda2", "startSectors": 526336,
                "sizeSectors": (12 * gib) // 512, "logicalSectorSize": 512,
                "sizeBytes": 12 * gib,
                "parttype": "0fc63daf-8483-4772-8e79-3d69d8477de4", "fstype": "ext4",
            },
        })
        self.assertIsNone(MODULE.build_existing_partition_layout(self.selections))

    def test_hand_edited_raw_layout_is_rejected_instead_of_overriding_selected_disk(self):
        self.selections["disk"].update({
            "stableId": "/dev/vda", "devicePath": "/dev/vda",
            "sizeBytes": 64 * 1024 * 1024 * 1024,
            "layout": {"device_modifications": [{"device": "/dev/sdz", "wipe": True}]},
        })
        configuration = MODULE.build_user_configuration(self.selections)
        self.assertEqual(configuration["disk_config"]["device_modifications"][0]["device"], "/dev/vda")
        credentials = MODULE.build_user_credentials(self.selections, {"userPasswordHash": "$6$hash"})
        self.assertIn("custom disk layouts are not accepted by this installer",
                      MODULE.validate_installation_plan(self.selections, configuration, credentials))

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

    def test_live_disk_verification_allows_removable_media_when_identity_is_stable(self):
        identity = {
            "devicePath": "/dev/sdb", "sizeBytes": 15 * 1024 * 1024 * 1024,
            "mode": "erase", "serial": "USB123", "wwn": "",
        }
        snapshot = {
            "/dev/sdb": {
                "path": "/dev/sdb", "type": "disk", "size": identity["sizeBytes"],
                "ro": 0, "rm": 1, "hotplug": 1, "serial": "USB123", "wwn": "",
                "mountpoints": [None], "_meo_root_path": "/dev/sdb",
            },
        }
        self.assertEqual(MODULE._verify_live_disk_state(identity, snapshot), (True, ""))

    def test_preparation_verification_allows_selected_mounts_but_strict_verification_rejects_them(self):
        gib = 1024 * 1024 * 1024
        identity = {
            "devicePath": "/dev/vda", "sizeBytes": 16 * gib,
            "mode": "erase", "serial": "", "wwn": "",
        }
        snapshot = {
            "/dev/vda": {
                "path": "/dev/vda", "type": "disk", "size": 16 * gib, "ro": 0,
                "serial": "", "wwn": "", "mountpoints": [None], "_meo_root_path": "/dev/vda",
            },
            "/dev/vda1": {
                "path": "/dev/vda1", "type": "part", "size": 15 * gib,
                "mountpoints": ["/mnt/old-system"], "_meo_root_path": "/dev/vda",
            },
        }
        self.assertEqual(
            MODULE._verify_live_disk_state(identity, snapshot, allow_selected_mounts=True),
            (True, ""),
        )
        verified, reason = MODULE._verify_live_disk_state(identity, snapshot)
        self.assertFalse(verified)
        self.assertIn("mounted", reason)

    def test_active_mapped_storage_is_blocked_before_mount_preparation(self):
        gib = 1024 * 1024 * 1024
        crypt = {
            "path": "/dev/mapper/cryptroot", "type": "crypt", "size": 12 * gib,
            "mountpoints": ["/mnt/old-root"], "_meo_root_path": "/dev/sda",
        }
        root = {
            "path": "/dev/sda3", "type": "part", "size": 12 * gib, "start": 4194304,
            "parttype": "0fc63daf-8483-4772-8e79-3d69d8477de4", "fstype": "crypto_LUKS",
            "mountpoints": [None], "children": [crypt], "_meo_root_path": "/dev/sda",
        }
        disk = {
            "path": "/dev/sda", "type": "disk", "size": 64 * gib, "ro": 0,
            "serial": "", "wwn": "", "mountpoints": [None], "children": [root],
            "_meo_root_path": "/dev/sda",
        }
        identity = {
            "devicePath": "/dev/sda", "sizeBytes": 64 * gib, "mode": "erase",
            "serial": "", "wwn": "",
        }
        snapshot = {"/dev/sda": disk, "/dev/sda3": root, "/dev/mapper/cryptroot": crypt}
        self.assertEqual(
            MODULE._verify_live_disk_state(identity, snapshot, allow_selected_mounts=True),
            (True, ""),
        )
        verified, reason = MODULE._verify_live_disk_state(identity, snapshot)
        self.assertFalse(verified)
        self.assertIn("active mapped storage", reason)

    def test_partition_mode_blocks_unrelated_active_mapping_on_same_disk(self):
        gib = 1024 * 1024 * 1024
        mapped = {
            "path": "/dev/mapper/data-vg", "type": "lvm", "size": 16 * gib,
            "mountpoints": [None], "_meo_root_path": "/dev/sda",
        }
        data_part = {
            "path": "/dev/sda2", "type": "part", "size": 16 * gib, "start": 264192,
            "parttype": "", "fstype": "LVM2_member", "mountpoints": [None],
            "children": [mapped], "_meo_root_path": "/dev/sda",
        }
        identity = {
            "devicePath": "/dev/sda", "sizeBytes": 64 * gib, "mode": "partition",
            "serial": "", "wwn": "",
            "partitions": [
                {"path": "/dev/sda1", "startSectors": 2048, "sizeBytes": 512 * 1024 * 1024,
                 "parttype": "c12a7328-f81f-11d2-ba4b-00a0c93ec93b", "fstype": "vfat"},
                {"path": "/dev/sda3", "startSectors": 4194304, "sizeBytes": 12 * gib,
                 "parttype": "0fc63daf-8483-4772-8e79-3d69d8477de4", "fstype": "ext4"},
            ],
        }
        efi = {
            "path": "/dev/sda1", "type": "part", "size": 512 * 1024 * 1024,
            "start": 2048, "parttype": identity["partitions"][0]["parttype"],
            "fstype": "vfat", "mountpoints": [None], "_meo_root_path": "/dev/sda",
        }
        root = {
            "path": "/dev/sda3", "type": "part", "size": 12 * gib,
            "start": 4194304, "parttype": identity["partitions"][1]["parttype"],
            "fstype": "ext4", "mountpoints": [None], "_meo_root_path": "/dev/sda",
        }
        disk = {
            "path": "/dev/sda", "type": "disk", "size": 64 * gib, "ro": 0,
            "serial": "", "wwn": "", "mountpoints": [None],
            "children": [efi, data_part, root], "_meo_root_path": "/dev/sda",
        }
        snapshot = {
            "/dev/sda": disk, "/dev/sda1": efi, "/dev/sda2": data_part,
            "/dev/sda3": root, "/dev/mapper/data-vg": mapped,
        }
        self.assertEqual(
            MODULE._verify_live_disk_state(identity, snapshot, allow_selected_mounts=True),
            (True, ""),
        )
        verified, reason = MODULE._verify_live_disk_state(identity, snapshot)
        self.assertFalse(verified)
        self.assertIn("active mapped storage", reason)

    def test_active_mapped_storage_blocks_full_disk_erase_before_archinstall(self):
        gib = 1024 * 1024 * 1024
        identity = {
            "devicePath": "/dev/vda", "sizeBytes": 32 * gib,
            "mode": "erase", "serial": "", "wwn": "",
        }
        mapped = {
            "path": "/dev/mapper/cryptroot", "type": "crypt", "size": 24 * gib,
            "mountpoints": [None], "_meo_root_path": "/dev/vda",
        }
        partition = {
            "path": "/dev/vda1", "type": "part", "size": 24 * gib,
            "mountpoints": [None], "children": [mapped], "_meo_root_path": "/dev/vda",
        }
        disk = {
            "path": "/dev/vda", "type": "disk", "size": 32 * gib, "ro": 0,
            "serial": "", "wwn": "", "mountpoints": [None],
            "children": [partition], "_meo_root_path": "/dev/vda",
        }
        snapshot = {
            "/dev/vda": disk,
            "/dev/vda1": partition,
            "/dev/mapper/cryptroot": mapped,
        }
        self.assertEqual(
            MODULE._verify_live_disk_state(identity, snapshot, allow_selected_mounts=True),
            (True, ""),
        )
        verified, reason = MODULE._verify_live_disk_state(identity, snapshot)
        self.assertFalse(verified)
        self.assertIn("active mapped storage", reason)

    def test_active_mapped_storage_blocks_selected_partition_before_archinstall(self):
        gib = 1024 * 1024 * 1024
        efi_guid = "c12a7328-f81f-11d2-ba4b-00a0c93ec93b"
        linux_guid = "0fc63daf-8483-4772-8e79-3d69d8477de4"
        identity = {
            "devicePath": "/dev/sda", "sizeBytes": 64 * gib, "mode": "partition",
            "serial": "", "wwn": "",
            "partitions": [
                {"path": "/dev/sda1", "startSectors": 2048, "sizeBytes": 512 * 1024 * 1024,
                 "parttype": efi_guid, "fstype": "vfat"},
                {"path": "/dev/sda2", "startSectors": 1050624, "sizeBytes": 24 * gib,
                 "parttype": linux_guid, "fstype": "ext4"},
            ],
        }
        mapped = {
            "path": "/dev/mapper/vg-root", "type": "lvm", "size": 20 * gib,
            "mountpoints": [None], "_meo_root_path": "/dev/sda",
        }
        efi = {
            "path": "/dev/sda1", "type": "part", "size": 512 * 1024 * 1024,
            "start": 2048, "parttype": efi_guid, "fstype": "vfat",
            "mountpoints": [None], "_meo_root_path": "/dev/sda",
        }
        root = {
            "path": "/dev/sda2", "type": "part", "size": 24 * gib,
            "start": 1050624, "parttype": linux_guid, "fstype": "ext4",
            "mountpoints": [None], "children": [mapped], "_meo_root_path": "/dev/sda",
        }
        disk = {
            "path": "/dev/sda", "type": "disk", "size": 64 * gib, "ro": 0,
            "serial": "", "wwn": "", "mountpoints": [None],
            "children": [efi, root], "_meo_root_path": "/dev/sda",
        }
        snapshot = {
            "/dev/sda": disk, "/dev/sda1": efi, "/dev/sda2": root,
            "/dev/mapper/vg-root": mapped,
        }
        self.assertEqual(
            MODULE._verify_live_disk_state(identity, snapshot, allow_selected_mounts=True),
            (True, ""),
        )
        verified, reason = MODULE._verify_live_disk_state(identity, snapshot)
        self.assertFalse(verified)
        self.assertIn("active mapped storage", reason)

    def test_live_disk_verification_still_rejects_read_only_media(self):
        identity = {
            "devicePath": "/dev/sdb", "sizeBytes": 15 * 1024 * 1024 * 1024,
            "mode": "erase", "serial": "USB123", "wwn": "",
        }
        snapshot = {
            "/dev/sdb": {
                "path": "/dev/sdb", "type": "disk", "size": identity["sizeBytes"],
                "ro": 1, "rm": 1, "hotplug": 1, "serial": "USB123", "wwn": "",
                "mountpoints": [None], "_meo_root_path": "/dev/sdb",
            },
        }
        verified, reason = MODULE._verify_live_disk_state(identity, snapshot)
        self.assertFalse(verified)
        self.assertIn("read-only", reason)

    def test_partition_preparation_allows_unrelated_mount_but_strict_check_requires_release(self):
        gib = 1024 * 1024 * 1024
        identity = {
            "devicePath": "/dev/sda", "sizeBytes": 64 * gib, "mode": "partition",
            "serial": "", "wwn": "",
            "partitions": [
                {"path": "/dev/sda1", "startSectors": 2048, "sizeBytes": 128 * 1024 * 1024,
                 "parttype": "c12a7328-f81f-11d2-ba4b-00a0c93ec93b", "fstype": "vfat"},
                {"path": "/dev/sda3", "startSectors": 4194304, "sizeBytes": 12 * gib,
                 "parttype": "0fc63daf-8483-4772-8e79-3d69d8477de4", "fstype": "ext4"},
            ],
        }
        snapshot = {
            "/dev/sda": {"path": "/dev/sda", "type": "disk", "size": 64 * gib, "ro": 0,
                         "serial": "", "wwn": "", "mountpoints": [None], "_meo_root_path": "/dev/sda"},
            "/dev/sda1": {"path": "/dev/sda1", "type": "part", "size": 128 * 1024 * 1024,
                          "start": 2048, "parttype": identity["partitions"][0]["parttype"],
                          "fstype": "vfat", "mountpoints": [None], "_meo_root_path": "/dev/sda"},
            "/dev/sda2": {"path": "/dev/sda2", "type": "part", "size": 16 * gib,
                          "start": 264192, "parttype": "", "fstype": "ext4",
                          "mountpoints": ["/mnt/data"], "_meo_root_path": "/dev/sda"},
            "/dev/sda3": {"path": "/dev/sda3", "type": "part", "size": 12 * gib,
                          "start": 4194304, "parttype": identity["partitions"][1]["parttype"],
                          "fstype": "ext4", "mountpoints": [None], "_meo_root_path": "/dev/sda"},
        }
        self.assertEqual(
            MODULE._verify_live_disk_state(identity, snapshot, allow_selected_mounts=True),
            (True, ""),
        )
        verified, reason = MODULE._verify_live_disk_state(identity, snapshot)
        self.assertFalse(verified)
        self.assertIn("active filesystems or swap", reason)

    def test_handoff_rejects_config_drift_after_preflight_generation(self):
        with tempfile.TemporaryDirectory() as directory:
            state = Path(directory) / "state"
            generated = state / "generated"
            state.mkdir(mode=0o700)
            generated.mkdir(mode=0o700)
            self.selections["disk"].update({
                "stableId": "/dev/vda", "devicePath": "/dev/vda",
                "sizeBytes": 64 * 1024 * 1024 * 1024,
            })
            configuration = MODULE.build_user_configuration(self.selections)
            credentials = MODULE.build_user_credentials(self.selections, {"userPasswordHash": "$6$hash"})
            plan = {"schemaVersion": 2, "package": {"packages": ["meo-desktop"]}}
            customizations = MODULE.build_target_customizations(self.selections)
            MODULE.write_json(generated / "user_configuration.json", configuration, 0o600)
            MODULE.write_json(generated / "user_credentials.json", credentials, 0o600)
            MODULE.write_text(generated / "plasma-localerc", MODULE.build_plasma_localerc(self.selections), 0o600)
            MODULE.write_json(generated / "target-customizations.json", customizations, 0o600)
            MODULE.write_json(generated / "install-plan.json", plan, 0o600)
            handoff = MODULE.build_handoff_manifest(self.selections["disk"], configuration, generated)
            self.assertIn("plasma-localerc", handoff["files"])
            manifest = {
                "schemaVersion": 2,
                "realInstallReady": True,
                "handoff": handoff,
            }
            MODULE.write_json(state / "config_manifest.json", manifest, 0o600)
            with mock.patch.object(MODULE, "verify_selected_disk_identity", return_value=(True, "")), \
                 mock.patch.object(MODULE, "_verify_live_disk_state", return_value=(True, "")):
                self.assertEqual(MODULE.verify_generated_handoff(state), (True, ""))
                (generated / "user_configuration.json").write_text("{}\n", encoding="utf-8")
                verified, reason = MODULE.verify_generated_handoff(state)
            self.assertFalse(verified)
            self.assertIn("changed after confirmation", reason)

    def test_target_customizations_carry_no_secrets(self):
        self.selections["user"].update({"fullName": "Meo User", "username": "meo", "automaticLogin": True})
        self.selections["disk"]["swap"] = "file"
        payload = MODULE.build_target_customizations(self.selections)
        self.assertEqual(payload["fullName"], "Meo User")
        self.assertEqual(payload["loginManager"], "plasma-login-manager")
        self.assertFalse(payload["automaticLogin"])
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
        self.assertIn("prepare_selected_mounts", runner)
        self.assertIn("--verify-handoff-for-preparation", runner)
        self.assertIn("Unmounting selected target filesystem", runner)
        self.assertIn("Disabling selected target swap", runner)
        self.assertIn('swapoff -- "${first}"', runner)
        self.assertIn("Deactivating selected target mapping", runner)
        self.assertIn("cryptsetup close", runner)
        self.assertIn("lvchange -an", runner)
        self.assertIn("mdadm --stop", runner)
        self.assertIn("dmsetup remove", runner)
        self.assertIn("os.path.realpath", runner)
        self.assertIn("dmsetup info -c --noheadings -o name", runner)
        self.assertIn('cryptsetup close "${map_name}"', runner)
        self.assertIn('lvchange -an "/dev/mapper/${map_name}"', runner)
        self.assertNotIn('cryptsetup close "$(basename -- "${second}")"', runner)
        self.assertIn("udevadm settle --timeout=10", runner)
        self.assertIn("strict storage verification will decide", runner)
        self.assertLess(runner.index("Disabling selected target swap"),
                        runner.index("Unmounting selected target filesystem"))
        target_root_check = runner.index('target_root="$(resolve_target_root')
        preparation_verify = runner.index("--verify-handoff-for-preparation")
        repository_preflight = runner.index("preflight-meo-repository.sh")
        first_unmount_prepare = runner.index("if ! prepare_selected_mounts", target_root_check)
        strict_verify = runner.index("--verify-handoff", first_unmount_prepare)
        self.assertLess(target_root_check, preparation_verify)
        self.assertLess(preparation_verify, repository_preflight)
        self.assertLess(repository_preflight, first_unmount_prepare)
        self.assertLess(first_unmount_prepare, strict_verify)

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

    def test_bios_live_boot_is_blocked_before_any_real_installation_plan(self):
        self.selections["disk"].update({
            "stableId": "/dev/vda", "devicePath": "/dev/vda",
            "sizeBytes": 64 * 1024 * 1024 * 1024,
        })
        configuration = MODULE.build_user_configuration(self.selections)
        credentials = MODULE.build_user_credentials(self.selections, {"userPasswordHash": "$6$hash"})
        blockers = MODULE.validate_installation_plan(
            self.selections, configuration, credentials, boot_mode="bios",
        )
        self.assertIn("BIOS target installation is unavailable until a tested BIOS GRUB layout exists", blockers)



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
