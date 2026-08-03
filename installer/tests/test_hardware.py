import importlib.util
import tempfile
import unittest
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
            {"vendor": "nvidia", "vendorId": "10de"},
        ])
        self.assertEqual(plan["vendors"], ["intel", "nvidia"])
        self.assertIn("vulkan-intel", plan["packages"])
        self.assertIn("nvidia-open", plan["packages"])

    def test_unknown_hardware_uses_safe_open_stack(self):
        plan = MODULE.driver_plan([])
        self.assertFalse(plan["detected"])
        self.assertEqual(plan["packages"], MODULE.FALLBACK_PACKAGES)


if __name__ == "__main__":
    unittest.main()
