import json
import subprocess
import sys
import importlib.util
import tempfile
import unittest
import unittest.mock
from pathlib import Path


MODULE_PATH = Path(__file__).parents[1] / "backend" / "hardware.py"
SPEC = importlib.util.spec_from_file_location("hardware", MODULE_PATH)
MODULE = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(MODULE)


class HardwareDetectionTests(unittest.TestCase):
    def test_sysfs_detection_uses_vendor_ids(self):
        with tempfile.TemporaryDirectory() as directory:
            device = Path(directory) / "0000:01:00.0"
            device.mkdir()
            (device / "class").write_text("0x030000\n")
            (device / "vendor").write_text("0x10de\n")
            (device / "device").write_text("0x2684\n")
            self.assertEqual(MODULE.detect_devices(Path(directory))[0]["vendor"], "nvidia")

    def test_hybrid_graphics_keeps_both_driver_sets(self):
        plan = MODULE.driver_plan([
            {"vendor": "intel", "vendorId": "8086"},
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": "2684"},
        ])
        self.assertEqual(plan["vendors"], ["intel", "nvidia"])
        self.assertIn("vulkan-intel", plan["packages"])
        self.assertIn("nvidia-open", plan["packages"])

    def test_hybrid_amd_nvidia_adds_prime_helper(self):
        plan = MODULE.driver_plan([
            {"vendor": "amd", "vendorId": "1002"},
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": "2684"},
        ])
        self.assertTrue(plan["hybridGraphics"])
        self.assertIn("vulkan-radeon", plan["packages"])
        self.assertIn("nvidia-open", plan["packages"])
        self.assertIn("nvidia-prime", plan["packages"])

    def test_modern_nvidia_uses_nvidia_open(self):
        plan = MODULE.driver_plan([
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": "2684"},
        ])
        self.assertTrue(plan["nvidiaOpenSupported"])
        self.assertFalse(plan["nvidiaFallback"])
        self.assertIn("nvidia-open", plan["packages"])
        self.assertIn("nvidia-utils", plan["packages"])

    def test_legacy_nvidia_keeps_bootable_open_fallback(self):
        plan = MODULE.driver_plan([
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": "1c82"},
        ])
        self.assertFalse(plan["nvidiaOpenSupported"])
        self.assertTrue(plan["nvidiaFallback"])
        self.assertNotIn("nvidia-open", plan["packages"])
        self.assertNotIn("nvidia-utils", plan["packages"])
        self.assertIn("mesa", plan["packages"])
        self.assertIn("vulkan-swrast", plan["packages"])
        self.assertTrue(plan["warnings"])

    def test_mixed_nvidia_generations_choose_safe_fallback(self):
        plan = MODULE.driver_plan([
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": "2684"},
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": "1c82"},
        ])
        self.assertFalse(plan["nvidiaOpenSupported"])
        self.assertTrue(plan["nvidiaFallback"])
        self.assertNotIn("nvidia-open", plan["packages"])
        self.assertNotIn("nvidia-utils", plan["packages"])
        self.assertIn("mesa", plan["packages"])
        self.assertTrue(plan["warnings"])

    def test_unknown_nvidia_generation_fails_open_to_mesa(self):
        plan = MODULE.driver_plan([
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": ""},
        ])
        self.assertTrue(plan["nvidiaFallback"])
        self.assertNotIn("nvidia-utils", plan["packages"])

    def test_modern_intel_uses_intel_media_driver(self):
        plan = MODULE.driver_plan([{"vendor": "intel", "vendorId": "8086"}])
        self.assertIn("vulkan-intel", plan["packages"])
        self.assertIn("intel-media-driver", plan["packages"])
        self.assertIn("libva-intel-driver", plan["packages"])
        self.assertNotIn("libva-mesa-driver", plan["packages"])

    def test_virtual_gpu_is_supported_without_vendor_guest_tools(self):
        plan = MODULE.driver_plan([{"vendor": "virtual", "vendorId": "1af4"}])
        self.assertTrue(plan["virtualGraphics"])
        self.assertIn("vulkan-virtio", plan["packages"])
        self.assertIn("vulkan-swrast", plan["packages"])
        self.assertNotIn("nvidia-open", plan["packages"])

    def test_qemu_sysfs_vendor_is_classified_as_virtual(self):
        with tempfile.TemporaryDirectory() as directory:
            device = Path(directory) / "0000:00:02.0"
            device.mkdir()
            (device / "class").write_text("0x030000\n")
            (device / "vendor").write_text("0x1234\n")
            (device / "device").write_text("0x1111\n")
            self.assertEqual(MODULE.detect_devices(Path(directory))[0]["vendor"], "virtual")

    def test_hardware_cli_emits_vm_plan_from_synthetic_sysfs(self):
        with tempfile.TemporaryDirectory() as directory:
            device = Path(directory) / "0000:00:02.0"
            device.mkdir()
            (device / "class").write_text("0x030000\n")
            (device / "vendor").write_text("0x1af4\n")
            (device / "device").write_text("0x1050\n")
            result = subprocess.run(
                [sys.executable, MODULE_PATH, "--sysfs-root", directory],
                check=True, capture_output=True, text=True,
            )
            payload = json.loads(result.stdout)
            self.assertTrue(payload["detected"])
            self.assertTrue(payload["virtualGraphics"])
            self.assertIn("vulkan-virtio", payload["packages"])
            self.assertFalse(payload["requiresNetwork"])

    def test_unknown_hardware_uses_safe_open_stack(self):
        plan = MODULE.driver_plan([])
        self.assertFalse(plan["detected"])
        self.assertEqual(plan["packages"], MODULE.FALLBACK_PACKAGES)
        self.assertIn("vulkan-swrast", plan["packages"])
        self.assertFalse(plan["requiresNetwork"])



    @unittest.mock.patch("subprocess.run")
    def test_lspci_missing_command(self, mock_run):
        mock_run.side_effect = FileNotFoundError()
        self.assertEqual(MODULE.lspci_devices(), [])

    @unittest.mock.patch("subprocess.run")
    def test_lspci_timeout(self, mock_run):
        import subprocess
        mock_run.side_effect = subprocess.SubprocessError()
        self.assertEqual(MODULE.lspci_devices(), [])

if __name__ == "__main__":
    unittest.main()
