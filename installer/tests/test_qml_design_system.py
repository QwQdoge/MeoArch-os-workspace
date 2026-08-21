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


if __name__ == "__main__":
    unittest.main()
