import re
import unittest
from pathlib import Path


QML_ROOT = Path(__file__).parents[1] / "qml"
RAW_RECTANGLE = re.compile(r"\bRectangle\s*\{")
RAW_COLOR = re.compile(
    r"#[0-9A-Fa-f]{3,8}\b|color\s*:\s*[\"'](?:white|black|transparent)[\"']"
)


class InstallerDesignSystemTests(unittest.TestCase):
    def test_visual_qml_does_not_bypass_meoui_surfaces_or_tokens(self):
        violations = []
        for qml_file in sorted(QML_ROOT.rglob("*.qml")):
            source = qml_file.read_text(encoding="utf-8")
            if RAW_RECTANGLE.search(source) or RAW_COLOR.search(source):
                violations.append(str(qml_file.relative_to(QML_ROOT)))
        self.assertEqual(
            violations,
            [],
            "Use MeoUI surfaces and named MeoTheme roles instead of raw rectangles or colour literals.",
        )

    def test_page_frame_uses_the_shared_surface_and_divider(self):
        source = (QML_ROOT / "PageFrame.qml").read_text(encoding="utf-8")
        self.assertIn("MeoMotionSurface", source)
        self.assertIn("MeoDivider", source)

    def test_custom_profile_persists_required_desktop_and_review_shows_resolved_plan(self):
        software = (QML_ROOT / "pages/SoftwarePage.qml").read_text(encoding="utf-8")
        summary = (QML_ROOT / "pages/SummaryPage.qml").read_text(encoding="utf-8")
        self.assertIn('value === "custom" ? ["meo-desktop"] : []', software)
        self.assertIn("controller.installPlan.repository", summary)
        self.assertIn("controller.installPlan.package", summary)
        self.assertIn("controller.installPlan.applications", summary)
        self.assertIn("Validated Meo package plan", summary)

    def test_software_page_exposes_system_recommended_and_opt_in_third_party_tiers(self):
        software = (QML_ROOT / "pages/SoftwarePage.qml").read_text(encoding="utf-8")
        self.assertIn('applicationsForTier("system")', software)
        self.assertIn('applicationsForTier("recommended")', software)
        self.assertIn('applicationsForTier("third-party")', software)
        self.assertIn("Always opt-in", software)

    def test_disk_page_keeps_partition_planning_inside_the_cage_client(self):
        disk = (QML_ROOT / "pages/DiskSelectionPage.qml").read_text(encoding="utf-8")
        self.assertIn("Integrated partition plan", disk)
        self.assertIn('setSelection("disk", "rootSizeGiB"', disk)
        self.assertNotIn("gparted", disk.casefold())

    def test_user_visible_static_strings_are_translation_eligible(self):
        offenders = []
        literal = re.compile(r'^\s*(?:text|title|subtitle|label|placeholder):\s*"', re.MULTILINE)
        for qml_file in sorted(QML_ROOT.rglob("*.qml")):
            if literal.search(qml_file.read_text(encoding="utf-8")):
                offenders.append(str(qml_file.relative_to(QML_ROOT)))
        self.assertEqual(offenders, [], "Wrap user-visible QML strings with qsTr().")


if __name__ == "__main__":
    unittest.main()
