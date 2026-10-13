from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
WORDMARK = ROOT / "assets/icons/text logo.png"
SOURCE_THEME = ROOT / "themes/plymouth/meoarch"
ISO_THEME = ROOT / "meoarch-os/airootfs/usr/share/plymouth/themes/meoarch"
PLYMOUTH_CONFIG = ROOT / "meoarch-os/airootfs/etc/plymouth/plymouthd.conf"
PLYMOUTH_BUILD_HOOK = ROOT / "meoarch-os/airootfs/etc/pacman.d/hooks/80-meoarch-plymouth.hook"


class PlymouthBrandTests(unittest.TestCase):
    def test_boot_splash_uses_canonical_text_wordmark(self):
        wordmark = WORDMARK.read_bytes()
        self.assertEqual((SOURCE_THEME / "logo.png").read_bytes(), wordmark)
        self.assertEqual((ISO_THEME / "logo.png").read_bytes(), wordmark)

    def test_wordmark_is_responsive_on_small_framebuffers(self):
        source_script = (SOURCE_THEME / "meoarch.script").read_text(encoding="utf-8")
        iso_script = (ISO_THEME / "meoarch.script").read_text(encoding="utf-8")
        self.assertEqual(source_script, iso_script)
        self.assertIn('logo_image = Image("logo.png")', source_script)
        self.assertIn("max_logo_width = Math.Min(760, screen_width * 0.62)", source_script)
        self.assertIn("logo_image = logo_image.Scale(", source_script)

    def test_meoarch_theme_is_selected_for_live_boot(self):
        config = PLYMOUTH_CONFIG.read_text(encoding="utf-8")
        self.assertIn("Theme=meoarch", config)
        self.assertNotIn("Theme=arch", config)

    def test_build_stages_branding_before_mkinitcpio_transaction_hook(self):
        hook = PLYMOUTH_BUILD_HOOK.read_text(encoding="utf-8")
        self.assertTrue(PLYMOUTH_BUILD_HOOK.name.startswith("80-"))
        self.assertIn("# remove from airootfs!", hook)
        self.assertIn("Target = linux", hook)
        self.assertIn("Target = plymouth", hook)
        self.assertIn("meoarch-airootfs-overlay.tar", hook)
        self.assertIn("./etc/plymouth/plymouthd.conf", hook)
        self.assertIn("./usr/share/plymouth/themes/meoarch/logo.png", hook)
        self.assertIn("Theme[[:space:]]*=[[:space:]]*meoarch", hook)


if __name__ == "__main__":
    unittest.main()
