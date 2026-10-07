from pathlib import Path
import unittest


ROOT = Path(__file__).resolve().parents[2]
PAGE = ROOT / "installer" / "qml" / "pages" / "LanguageRegionPage.qml"


class InputMethodUiContractTests(unittest.TestCase):
    def setUp(self):
        self.source = PAGE.read_text(encoding="utf-8")

    def test_installer_exposes_managed_and_self_managed_modes(self):
        self.assertIn('selection("inputMethod", "mode", "meo-managed")', self.source)
        self.assertIn('id: "meo-managed"', self.source)
        self.assertIn('id: "self-managed"', self.source)
        self.assertIn('setSelection("inputMethod", "framework", "fcitx5")', self.source)

    def test_self_managed_mode_clears_meo_owned_engine_intent(self):
        self.assertIn('setSelection("inputMethod", "framework", "")', self.source)
        self.assertIn('setSelection("inputMethod", "engineCapabilities", [])', self.source)
        self.assertIn('setSelection("inputMethod", "initialEngine", "")', self.source)

    def test_ui_does_not_duplicate_package_resolution_or_runtime_lifecycle(self):
        for forbidden in (
            "pacman ",
            "fcitx5-chinese-addons",
            "fcitx5-rime",
            "fcitx5-mozc",
            "fcitx5-hangul",
            "systemctl --user",
            "Exec=/usr/bin/fcitx5",
        ):
            with self.subTest(forbidden=forbidden):
                self.assertNotIn(forbidden, self.source)

    def test_copy_keeps_engine_installation_after_installation(self):
        self.assertIn("Language engines such as Pinyin or Rime can be added later", self.source)
        self.assertIn("Do not choose an input-method framework or language engine during installation", self.source)


if __name__ == "__main__":
    unittest.main()
