from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
PROFILE = ROOT / "meoarch-os/profiledef.sh"
GRUB = ROOT / "meoarch-os/grub/grub.cfg"
ARCHISO_HOOKS = ROOT / "meoarch-os/airootfs/etc/mkinitcpio.conf.d/archiso.conf"
PLYMOUTH_SCRIPT = ROOT / "themes/plymouth/meoarch/meoarch.script"
GENERATE_CONFIG = ROOT / "installer/backend/generate-config.py"
VERIFY_TARGET = ROOT / "installer/backend/verify-target.py"


def grub_kernel_options(title_prefix: str) -> str:
    active = False
    for line in GRUB.read_text(encoding="utf-8").splitlines():
        if line.startswith("menuentry "):
            active = title_prefix in line
            continue
        if active and line.lstrip().startswith("linux "):
            _, options = line.split("vmlinuz-linux", 1)
            return options.strip()
    raise AssertionError(f"missing GRUB kernel line for {title_prefix!r}")


class LiveBootContractTests(unittest.TestCase):
    def test_uefi_live_media_uses_themed_grub(self):
        profile = PROFILE.read_text(encoding="utf-8")
        self.assertIn("'bios.syslinux'", profile)
        self.assertIn("'uefi.grub'", profile)
        self.assertNotIn("'uefi.systemd-boot'", profile)

        grub = GRUB.read_text(encoding="utf-8")
        self.assertIn('set theme="${prefix}/themes/meoarch/theme.txt"', grub)
        self.assertIn("export theme", grub)
        for relative in (
            "meoarch-os/grub/themes/meoarch/theme.txt",
            "meoarch-os/grub/themes/meoarch/brand.png",
            "meoarch-os/grub/themes/meoarch/meoarch-sans-regular-24.pf2",
            "meoarch-os/grub/themes/meoarch/meoarch-sans-bold-24.pf2",
        ):
            self.assertTrue((ROOT / relative).is_file(), relative)

    def test_normal_and_repair_entries_keep_plymouth_kernel_contract(self):
        expected = (
            "archisobasedir=%INSTALL_DIR% archisosearchuuid=%ARCHISO_UUID% "
            "meoarch.mode=install quiet splash loglevel=3 rd.udev.log_level=3 "
            "vt.global_cursor_default=0 plymouth.enable=1"
        )
        self.assertEqual(
            grub_kernel_options('Install MeoArch OS - graphical setup'),
            expected,
        )
        self.assertEqual(
            grub_kernel_options('Diagnostics and repair - no installation'),
            expected.replace("meoarch.mode=install", "meoarch.mode=repair"),
        )

    def test_live_initramfs_and_theme_keep_plymouth_enabled(self):
        hooks = ARCHISO_HOOKS.read_text(encoding="utf-8")
        self.assertIn("udev plymouth", hooks)
        script = PLYMOUTH_SCRIPT.read_text(encoding="utf-8")
        self.assertIn('logo_image = Image("logo.png")', script)
        self.assertIn("Plymouth.SetBootProgressFunction", script)
        self.assertIn("Plymouth.SetQuitFunction", script)

    @unittest.skip(
        "TODO: migrate installed-system GRUB customization and validation to "
        "Limine only after the installed-VM acceptance path covers the new EFI payload."
    )
    def test_installed_system_bootloader_migrates_to_limine(self):
        generate = GENERATE_CONFIG.read_text(encoding="utf-8")
        verify = VERIFY_TARGET.read_text(encoding="utf-8")
        self.assertIn('"bootloader": "Limine"', generate)
        self.assertIn("limine.conf", verify)
        self.assertNotIn("boot/grub/grub.cfg", verify)


if __name__ == "__main__":
    unittest.main()
