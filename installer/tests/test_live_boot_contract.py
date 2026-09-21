from pathlib import Path
import struct
import unittest


ROOT = Path(__file__).resolve().parents[2]
PROFILE = ROOT / "meoarch-os/profiledef.sh"
GRUB = ROOT / "meoarch-os/grub/grub.cfg"
GRUB_LOOPBACK = ROOT / "meoarch-os/grub/loopback.cfg"
ARCHISO_HOOKS = ROOT / "meoarch-os/airootfs/etc/mkinitcpio.conf.d/archiso.conf"
PLYMOUTH_SCRIPT = ROOT / "themes/plymouth/meoarch/meoarch.script"
GENERATE_CONFIG = ROOT / "installer/backend/generate-config.py"
VERIFY_TARGET = ROOT / "installer/backend/verify-target.py"
SYNC_INSTALLER = ROOT / "scripts/sync-installer-to-airootfs.sh"
APPLY_TARGET = ROOT / "installer/backend/apply-target-customizations.sh"
GRUB_THEME = ROOT / "meoarch-os/grub/themes/meoarch/theme.txt"
GRUB_GENERATOR = ROOT / "meoarch-os/grub/themes/meoarch/generate-assets.sh"
GRUB_BRAND = ROOT / "meoarch-os/grub/themes/meoarch/brand.png"
GRUB_SPLASH = ROOT / "meoarch-os/grub/splash.png"
SYSLINUX_SPLASH = ROOT / "meoarch-os/syslinux/splash.png"
SYSLINUX_HEAD = ROOT / "meoarch-os/syslinux/archiso_head.cfg"
LIVE_MOTD = ROOT / "meoarch-os/airootfs/etc/motd"
BOOT_STATUS = ROOT / "installer/bin/meo-boot-status"
LIVE_IWD_ENABLE = ROOT / "meoarch-os/airootfs/etc/systemd/system/multi-user.target.wants/iwd.service"
LIVE_SSHD_ENABLE = ROOT / "meoarch-os/airootfs/etc/systemd/system/multi-user.target.wants/sshd.service"
BUILD_ISO = ROOT / "scripts/build-iso.sh"
CANONICAL_LOGO = ROOT / "assets/icons/Logo.svg"




def png_size(path: Path) -> tuple[int, int]:
    data = path.read_bytes()
    if data[:8] != b"\x89PNG\r\n\x1a\n" or data[12:16] != b"IHDR":
        raise AssertionError(f"not a PNG: {path}")
    return struct.unpack(">II", data[16:24])

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

    def test_grub_visual_assets_use_canonical_logo_and_dynamic_menu(self):
        theme = GRUB_THEME.read_text(encoding="utf-8")
        generator = GRUB_GENERATOR.read_text(encoding="utf-8")
        logo = CANONICAL_LOGO.read_text(encoding="utf-8")

        self.assertEqual(png_size(GRUB_BRAND), (260, 117))
        self.assertEqual(png_size(GRUB_SPLASH), (1920, 1080))
        self.assertEqual(png_size(SYSLINUX_SPLASH), (640, 480))
        self.assertIn('fill="#B69DF8"', logo)
        self.assertIn('assets/icons/Logo.svg', generator)
        self.assertNotIn('-annotate', generator)
        self.assertIn('splash.png', generator)
        self.assertIn('syslinux/splash.png', generator)
        self.assertIn('left = 50%-130', theme)
        self.assertIn('left = 50%-380', theme)
        self.assertIn('width = 760', theme)
        self.assertNotIn('menu_pixmap_style = "panel_*.png"', theme)
        self.assertIn('desktop-image-scale-method: "crop"', theme)
        self.assertIn('desktop-image-h-align: "center"', theme)
        self.assertIn('desktop-image-v-align: "center"', theme)
        self.assertIn('selected_item_pixmap_style = "select_*.png"', theme)
        self.assertIn('selected_item_color = "#FFFFFF"', theme)

    def test_bios_menu_and_live_shell_keep_meoarch_product_language(self):
        syslinux = SYSLINUX_HEAD.read_text(encoding="utf-8")
        motd = LIVE_MOTD.read_text(encoding="utf-8")
        status = BOOT_STATUS.read_text(encoding="utf-8")

        self.assertIn("#ff6750a4", syslinux)
        self.assertIn("#ff49454f", syslinux)
        self.assertIn("NetworkManager", motd)
        self.assertIn("nmcli", motd)
        self.assertNotIn("iwctl", motd)
        self.assertNotIn("wiki.archlinux.org/title/Installation_guide", motd)
        self.assertIn('display_text = f"ERROR: {title} - {message}"', status)
        self.assertNotIn('ERROR:{unit_name}:{code}', status)

    def test_networkmanager_does_not_compete_with_standalone_iwd(self):
        packages = (ROOT / "meoarch-os/packages.x86_64").read_text(encoding="utf-8")
        self.assertIn("\nnetworkmanager\n", "\n" + packages + "\n")
        self.assertIn("\nwpa_supplicant\n", "\n" + packages + "\n")
        self.assertFalse(LIVE_IWD_ENABLE.exists())
        self.assertFalse(LIVE_IWD_ENABLE.is_symlink())

    def test_production_live_ssh_is_off_but_acceptance_can_enable_it(self):
        build = BUILD_ISO.read_text(encoding="utf-8")
        sshd_config = (ROOT / "meoarch-os/airootfs/etc/ssh/sshd_config.d/10-archiso.conf").read_text(encoding="utf-8")
        self.assertFalse(LIVE_SSHD_ENABLE.exists())
        self.assertFalse(LIVE_SSHD_ENABLE.is_symlink())
        self.assertIn("/usr/lib/systemd/system/sshd.service", build)
        self.assertIn("MEOARCH_ACCEPTANCE_SSH_PUBLIC_KEY", build)
        self.assertIn("PasswordAuthentication no", sshd_config)
        self.assertIn("PermitRootLogin no", sshd_config)

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

    def test_loopback_install_and_repair_keep_quiet_plymouth_handoff(self):
        loopback = GRUB_LOOPBACK.read_text(encoding="utf-8")
        common = "quiet splash loglevel=3 rd.udev.log_level=3 vt.global_cursor_default=0 plymouth.enable=1"
        self.assertIn(f"meoarch.mode=install {common}", loopback)
        self.assertIn(f"meoarch.mode=repair {common}", loopback)
        # The speech-reader path intentionally stays unsilenced.
        speech_line = next(
            line for line in loopback.splitlines()
            if "meoarch.mode=install accessibility=on" in line
        )
        self.assertNotIn(" quiet ", speech_line)
        self.assertNotIn(" splash ", speech_line)

    def test_installed_grub_theme_keeps_its_background_asset(self):
        theme = (ROOT / "meoarch-os/grub/themes/meoarch/theme.txt").read_text(encoding="utf-8")
        sync = SYNC_INSTALLER.read_text(encoding="utf-8")
        apply = APPLY_TARGET.read_text(encoding="utf-8")
        verify = VERIFY_TARGET.read_text(encoding="utf-8")
        self.assertIn('desktop-image: "../../splash.png"', theme)
        self.assertIn('boot-splash.png', sync)
        self.assertIn('boot_splash_source', apply)
        self.assertIn('"boot/grub/splash.png"', verify)

    def test_live_initramfs_and_theme_keep_plymouth_enabled(self):
        hooks = ARCHISO_HOOKS.read_text(encoding="utf-8")
        self.assertIn("udev plymouth", hooks)
        script = PLYMOUTH_SCRIPT.read_text(encoding="utf-8")
        self.assertIn('logo_image = Image("logo.png")', script)
        self.assertIn("logo_glow_image = logo_image.Scale", script)
        self.assertIn("Math.Cos(frame_count * 0.08)", script)
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
