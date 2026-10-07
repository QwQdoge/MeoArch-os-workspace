from pathlib import Path
import unittest


ROOT = Path(__file__).parents[1]
CHECK = ROOT / "checks" / "input-method.sh"
ALL_CHECK = ROOT / "checks" / "all.sh"
CMAKE = ROOT / "CMakeLists.txt"


class InputMethodDiagnosticContractTests(unittest.TestCase):
    def test_check_is_read_only_and_fixed_scope(self):
        source = CHECK.read_text(encoding="utf-8")
        self.assertIn("set -u -o pipefail", source)
        self.assertIn("org.fcitx.Fcitx5", source)
        self.assertIn("GetNameOwner", source)
        self.assertIn('pacman -Q "${package}"', source)
        self.assertNotIn("pacman -S", source)
        self.assertNotIn("sudo ", source)
        self.assertNotIn("pkexec", source)
        self.assertNotIn("curl ", source)
        self.assertNotIn("wget ", source)
        self.assertNotIn("systemctl --user start", source)
        self.assertNotIn("systemctl --user restart", source)

    def test_check_has_structured_findings_for_runtime_and_bridges(self):
        source = CHECK.read_text(encoding="utf-8")
        for finding in (
            "input_method.framework_missing",
            "input_method.runtime_inactive",
            "input_method.package_framework_missing",
            "input_method.qt_bridge_missing",
            "input_method.gtk_bridge_missing",
            "input_method.qt_override_unexpected",
            "input_method.user_config_missing",
        ):
            with self.subTest(finding=finding):
                self.assertIn(finding, source)

    def test_overview_and_install_payload_include_the_check(self):
        all_check = ALL_CHECK.read_text(encoding="utf-8")
        cmake = CMAKE.read_text(encoding="utf-8")
        self.assertIn("hardware audio input-method display", all_check)
        self.assertIn("checks/input-method.sh", cmake)


if __name__ == "__main__":
    unittest.main()
