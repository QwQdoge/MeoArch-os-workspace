import sys
import unittest
from pathlib import Path


ROOT = Path(__file__).parents[1]
sys.path.insert(0, str(ROOT / "backend"))

from install_plan import PlanError, build_install_plan, catalog_from, plan_as_dict


class InputMethodInstallPlanTests(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog_from(ROOT / "data" / "package-catalog.json")

    def test_default_plan_records_meo_managed_fcitx_without_forcing_an_engine(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "minimal"}, self.catalog)
        self.assertEqual(plan.input_method.mode, "meo-managed")
        self.assertEqual(plan.input_method.framework, "fcitx5")
        self.assertEqual(plan.input_method.engine_capabilities, ())
        self.assertEqual(plan.input_method.initial_engine, "")

    def test_managed_plan_keeps_engine_selection_as_capability_ids_only(self):
        plan = build_install_plan(
            {
                "schemaVersion": 2,
                "profile": "minimal",
                "inputMethod": {
                    "mode": "meo-managed",
                    "framework": "fcitx5",
                    "engineCapabilities": ["fcitx5.pinyin", "fcitx5.rime"],
                    "initialEngine": "fcitx5.pinyin",
                },
            },
            self.catalog,
        )
        output = plan_as_dict(plan)["inputMethod"]
        self.assertEqual(output["engineCapabilities"], ["fcitx5.pinyin", "fcitx5.rime"])
        self.assertEqual(output["initialEngine"], "fcitx5.pinyin")
        serialized_packages = "\n".join(plan.package.packages)
        self.assertNotIn("fcitx5-chinese-addons", serialized_packages)
        self.assertNotIn("fcitx5-rime", serialized_packages)

    def test_self_managed_plan_declines_meo_framework_and_engine_ownership(self):
        plan = build_install_plan(
            {
                "schemaVersion": 2,
                "profile": "minimal",
                "inputMethod": {"mode": "self-managed"},
            },
            self.catalog,
        )
        self.assertEqual(plan.input_method.mode, "self-managed")
        self.assertEqual(plan.input_method.framework, "")
        self.assertEqual(plan.input_method.engine_capabilities, ())
        self.assertEqual(plan.input_method.initial_engine, "")

    def test_initial_engine_must_be_selected(self):
        with self.assertRaisesRegex(PlanError, "initialEngine must be one of engineCapabilities"):
            build_install_plan(
                {
                    "schemaVersion": 2,
                    "inputMethod": {
                        "engineCapabilities": ["fcitx5.rime"],
                        "initialEngine": "fcitx5.pinyin",
                    },
                },
                self.catalog,
            )

    def test_self_managed_mode_cannot_smuggle_meo_managed_engine_requests(self):
        with self.assertRaisesRegex(PlanError, "self-managed input method cannot request"):
            build_install_plan(
                {
                    "schemaVersion": 2,
                    "inputMethod": {
                        "mode": "self-managed",
                        "framework": "fcitx5",
                        "engineCapabilities": ["fcitx5.rime"],
                    },
                },
                self.catalog,
            )

    def test_engine_ids_are_bounded_and_not_package_or_shell_input(self):
        invalid_values = (
            ["fcitx5.rime;pacman"],
            ["fcitx5/../../rime"],
            ["fcitx5.Rime"],
            ["fcitx5."],
            ["rime"],
            ["fcitx5.rime"] * 17,
        )
        for engine_ids in invalid_values:
            with self.subTest(engine_ids=engine_ids):
                with self.assertRaises(PlanError):
                    build_install_plan(
                        {"schemaVersion": 2, "inputMethod": {"engineCapabilities": engine_ids}},
                        self.catalog,
                    )

    def test_duplicate_engine_ids_and_unknown_keys_are_rejected(self):
        with self.assertRaisesRegex(PlanError, "must not contain duplicates"):
            build_install_plan(
                {
                    "schemaVersion": 2,
                    "inputMethod": {
                        "engineCapabilities": ["fcitx5.rime", "fcitx5.rime"],
                    },
                },
                self.catalog,
            )
        with self.assertRaisesRegex(PlanError, "unsupported key"):
            build_install_plan(
                {"schemaVersion": 2, "inputMethod": {"package": "fcitx5-rime"}},
                self.catalog,
            )


if __name__ == "__main__":
    unittest.main()
