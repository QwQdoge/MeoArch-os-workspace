import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]
CHECKS = ROOT / "repair/checks"
CMAKE = ROOT / "repair/CMakeLists.txt"


class RepairHardwareChecksContractTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        cls.packages = (CHECKS / "packages.sh").read_text(encoding="utf-8")
        cls.graphics = (CHECKS / "graphics.sh").read_text(encoding="utf-8")
        cls.hardware = (CHECKS / "hardware.sh").read_text(encoding="utf-8")
        cls.all_checks = (CHECKS / "all.sh").read_text(encoding="utf-8")
        cls.cmake = CMAKE.read_text(encoding="utf-8")

    def test_package_update_view_is_read_only(self):
        self.assertIn("pacman -Qu", self.packages)
        self.assertIn("does not refresh repository metadata", self.packages)
        for forbidden in ("pacman -Sy", "pacman -Syu", "pacman -Su", "checkupdates -d"):
            self.assertNotIn(forbidden, self.packages)

    def test_live_package_update_view_targets_installed_system(self):
        self.assertIn("/mnt/var/lib/pacman/sync", self.packages)
        self.assertIn("/usr/bin/arch-chroot /mnt", self.packages)

    def test_graphics_check_reports_driver_and_drm_state(self):
        for marker in (
            "Kernel driver in use",
            "DRM render nodes",
            "nvidia_drm/parameters/modeset",
            "amdgpu|radeon",
            "i915|xe",
            "XDG session type",
        ):
            self.assertIn(marker, self.graphics)

    def test_hardware_inventory_is_read_only(self):
        for marker in (
            "/sys/class/dmi/id/sys_vendor",
            "/proc/cpuinfo",
            "/proc/meminfo",
            "lsblk -d",
            "ip -brief link",
            "/sys/class/power_supply",
            "systemd-detect-virt",
        ):
            self.assertIn(marker, self.hardware)
        for forbidden in (
            "mount ",
            "umount ",
            "systemctl restart",
            "systemctl enable",
            "pacman -S",
            "modprobe ",
            "> /sys/",
        ):
            self.assertNotIn(forbidden, self.hardware)

    def test_overview_runs_and_installs_hardware_check(self):
        self.assertIn("hardware audio display network graphics security", self.all_checks)
        self.assertIn("hardware audio display network boot packages storage graphics security", self.all_checks)
        self.assertIn("checks/all.sh checks/hardware.sh", self.cmake)


if __name__ == "__main__":
    unittest.main()
