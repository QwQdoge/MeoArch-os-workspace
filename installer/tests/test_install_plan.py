import json
import sys
import unittest
from pathlib import Path

ROOT = Path(__file__).parents[1]
sys.path.insert(0, str(ROOT / "backend"))
from install_plan import PlanError, build_install_plan, catalog_from, pacman_channel_fragment, plan_as_dict


class InstallPlanTests(unittest.TestCase):
    def setUp(self):
        self.catalog = catalog_from(ROOT / "data/package-catalog.json")

    def test_recommended_stable_has_complete_package_set(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "recommended", "channel": "stable"}, self.catalog)
        self.assertEqual(plan.repository.repositories, ("meo",))
        self.assertIn("meo-settings", plan.package.packages)
        self.assertIn("omnistore-bin", plan.package.packages)
        self.assertIn("meo-release", plan.package.packages)

    def test_minimal_has_no_optional_apps(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "minimal", "channel": "stable"}, self.catalog)
        self.assertIn("meo-desktop", plan.package.packages)
        self.assertNotIn("meo-settings", plan.package.packages)
        self.assertNotIn("omnistore-bin", plan.package.packages)

    def test_beta_orders_overlay_before_stable(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "recommended", "channel": "beta"}, self.catalog)
        self.assertEqual(plan.repository.repositories, ("meo-beta", "meo"))
        fragment = pacman_channel_fragment(plan)
        self.assertLess(fragment.index("[meo-beta]"), fragment.index("[meo]"))

    def test_beta_trial_defaults_to_beta_and_marks_stable_unavailable(self):
        default_plan = build_install_plan({"schemaVersion": 2, "profile": "minimal"}, self.catalog)
        self.assertEqual(default_plan.repository.channel, "beta")
        stable_plan = build_install_plan({"schemaVersion": 2, "profile": "minimal", "channel": "stable"}, self.catalog)
        self.assertFalse(stable_plan.repository.core_train_available)
        serialized = plan_as_dict(stable_plan)
        self.assertEqual(serialized["repository"]["baseUrl"], "https://packages.meoarch.org")
        self.assertIn("not published", serialized["repository"]["availabilityMessage"])

    def test_custom_forces_desktop_dependencies(self):
        plan = build_install_plan({"schemaVersion": 2, "profile": "custom", "channel": "stable", "components": ["meo-desktop", "omnistore-bin"]}, self.catalog)
        self.assertTrue({"meo-desktop", "meoui-qml", "meo-icons", "omnistore-bin"}.issubset(plan.package.packages))

    def test_custom_without_desktop_is_rejected(self):
        with self.assertRaises(PlanError):
            build_install_plan({"schemaVersion": 2, "profile": "custom", "components": ["omnistore-bin"]}, self.catalog)

    def test_unknown_architecture_and_mirror_fail_before_install(self):
        with self.assertRaises(PlanError):
            build_install_plan({"schemaVersion": 2}, self.catalog, "aarch64")
        with self.assertRaises(PlanError):
            build_install_plan({"schemaVersion": 2, "mirror": "untrusted"}, self.catalog)

    def test_catalog_generation_and_hash_contract_is_enforced(self):
        catalog = ROOT / "data/package-catalog.json"
        contract = catalog.with_name("package-catalog.contract.json")
        self.assertTrue(contract.is_file())
        self.assertEqual(catalog_from(catalog)["generation"], "2026.08-beta.1")
        original = contract.read_text(encoding="utf-8")
        try:
            contract.write_text('{"schemaVersion": 1}\n', encoding="utf-8")
            with self.assertRaises(PlanError):
                catalog_from(catalog)
        finally:
            contract.write_text(original, encoding="utf-8")
