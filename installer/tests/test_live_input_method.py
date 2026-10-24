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

    def test_live_sync_leaves_wayland_and_input_method_defaults_to_the_session(self):
        # The Meo session seeds these from the meo-desktop package into its
        # private config home (startmeo-wayland); the Live medium must not
        # shadow them with global /etc/xdg or environment.d copies.
        source = SYNC.read_text(encoding="utf-8")
        self.assertNotIn("/etc/xdg/$(basename", source)
        self.assertNotIn("90-meo-applications.conf", source)
        self.assertNotIn("classicui.conf", source)
        self.assertNotIn("MeoInputMethod-Light", source)
        profile = ROOT / "meoarch-os" / "airootfs"
        self.assertFalse((profile / "etc/xdg/fcitx5/conf/classicui.conf").exists())
        self.assertFalse((profile / "etc/environment.d/90-meo-applications.conf").exists())

    def test_live_profile_does_not_add_a_second_fcitx_launcher(self):
        source = SYNC.read_text(encoding="utf-8")
        self.assertNotIn("etc/xdg/autostart/org.fcitx", source)
        self.assertNotIn("fcitx5.service", source)
        self.assertNotIn("systemd/user/fcitx", source)


if __name__ == "__main__":
    unittest.main()
