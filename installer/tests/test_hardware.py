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
            {"vendor": "intel", "vendorId": "8086", "deviceId": "46a6"},
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": "2684"},
        ])
        self.assertEqual(plan["vendors"], ["intel", "nvidia"])
        self.assertIn("vulkan-intel", plan["packages"])
        self.assertIn("nvidia-open", plan["packages"])

    def test_unknown_hardware_uses_safe_open_stack(self):
        plan = MODULE.driver_plan([])
        self.assertFalse(plan["detected"])
        self.assertEqual(plan["packages"], MODULE.FALLBACK_PACKAGES)

    def test_turing_or_newer_nvidia_uses_open_kernel_stack(self):
        plan = MODULE.driver_plan([
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": "1e84"},
        ])
        self.assertIn("nvidia-open", plan["packages"])
        self.assertIn("nvidia-utils", plan["packages"])
        self.assertIn("libva-nvidia-driver", plan["packages"])
        self.assertNotIn("vulkan-nouveau", plan["packages"])

    def test_legacy_or_unknown_nvidia_uses_nouveau_instead_of_wrong_open_module(self):
        for device_id in ("1b80", ""):
            with self.subTest(device_id=device_id):
                plan = MODULE.driver_plan([
                    {"vendor": "nvidia", "vendorId": "10de", "deviceId": device_id},
                ])
                self.assertNotIn("nvidia-open", plan["packages"])
                self.assertNotIn("nvidia-utils", plan["packages"])
                self.assertIn("vulkan-nouveau", plan["packages"])
                self.assertIn("mesa", plan["packages"])

    def test_mixed_new_and_legacy_nvidia_keeps_safe_common_fallback(self):
        plan = MODULE.driver_plan([
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": "2684"},
            {"vendor": "nvidia", "vendorId": "10de", "deviceId": "1b80"},
        ])
        self.assertNotIn("nvidia-open", plan["packages"])
        self.assertIn("vulkan-nouveau", plan["packages"])

    def test_virtio_gpu_gets_native_venus_plus_software_fallback(self):
        plan = MODULE.driver_plan([
            {"vendor": "virtio", "vendorId": "1af4", "deviceId": "1050"},
        ])
        self.assertIn("vulkan-virtio", plan["packages"])
        self.assertIn("vulkan-swrast", plan["packages"])

    def test_other_common_virtual_gpu_uses_mesa_software_vulkan(self):
        for vendor_id, vendor in (
            ("1234", "qemu"), ("1b36", "qxl"), ("15ad", "vmware"),
            ("80ee", "virtualbox"), ("1414", "hyperv"),
        ):
            with self.subTest(vendor=vendor):
                plan = MODULE.driver_plan([
                    {"vendor": vendor, "vendorId": vendor_id, "deviceId": "0001"},
                ])
                self.assertIn("mesa", plan["packages"])
                self.assertIn("vulkan-swrast", plan["packages"])

    def test_unknown_secondary_adapter_keeps_fallback_alongside_known_gpu(self):
        plan = MODULE.driver_plan([
            {"vendor": "amd", "vendorId": "1002", "deviceId": "744c"},
            {"vendor": "unknown", "vendorId": "abcd", "deviceId": "1234"},
        ])
        self.assertIn("vulkan-radeon", plan["packages"])
        self.assertIn("vulkan-swrast", plan["packages"])

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
