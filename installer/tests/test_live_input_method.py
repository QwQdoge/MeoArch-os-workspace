from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
PACKAGES = ROOT / "meoarch-os" / "packages.x86_64"
SYNC = ROOT / "scripts" / "sync-installer-to-airootfs.sh"


class LiveInputMethodContractTests(unittest.TestCase):
    def test_live_image_contains_framework_and_toolkit_bridges(self):
        packages = {
            line.strip()
            for line in PACKAGES.read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        }
        self.assertTrue({"fcitx5", "fcitx5-qt", "fcitx5-gtk"}.issubset(packages))

    def test_live_image_does_not_force_language_engines(self):
        packages = {
            line.strip()
            for line in PACKAGES.read_text(encoding="utf-8").splitlines()
            if line.strip() and not line.lstrip().startswith("#")
        }
        for engine in (
            "fcitx5-chinese-addons",
            "fcitx5-rime",
            "fcitx5-mozc",
            "fcitx5-hangul",
            "fcitx5-m17n",
        ):
            with self.subTest(engine=engine):
                self.assertNotIn(engine, packages)

    def test_live_sync_reuses_meokde_owned_wayland_defaults(self):
        source = SYNC.read_text(encoding="utf-8")
        self.assertIn("for default_file in kde/kdeglobals kde/kglobalshortcutsrc kwin/kwinrc", source)
        self.assertIn('"${airootfs}/etc/xdg/$(basename "${default_file}")"', source)
        self.assertIn('defaults/environment/90-meo-applications.conf', source)
        self.assertIn('defaults/input-method/fcitx5/conf/classicui.conf', source)
        self.assertIn('themes/input-method/fcitx5/MeoInputMethod-Light', source)
        self.assertIn('themes/input-method/fcitx5/MeoInputMethod-Dark', source)

    def test_live_profile_does_not_add_a_second_fcitx_launcher(self):
        source = SYNC.read_text(encoding="utf-8")
        self.assertNotIn("etc/xdg/autostart/org.fcitx", source)
        self.assertNotIn("fcitx5.service", source)
        self.assertNotIn("systemd/user/fcitx", source)


if __name__ == "__main__":
    unittest.main()
